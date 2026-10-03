import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailOnceStorage extends LocalStorage {
  bool fail = true;

  @override
  Future<void> save(LocalState state) async {
    if (fail) {
      fail = false;
      throw StateError('Falha simulada');
    }
    await super.save(state);
  }
}

class _OrderedStorage extends LocalStorage {
  final firstStarted = Completer<void>();
  final releaseFirst = Completer<void>();
  final started = <String>[];
  final completed = <String>[];
  int active = 0;
  int maxActive = 0;

  @override
  Future<void> save(LocalState state) async {
    active++;
    if (active > maxActive) maxActive = active;
    started.add(state.client.name);
    try {
      if (started.length == 1) {
        firstStarted.complete();
        await releaseFirst.future;
      }
      await super.save(state);
      completed.add(state.client.name);
    } finally {
      active--;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  tearDown(() async {
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  PetModel addPet(String name) => VetRepository.addPet(
    name: name,
    species: 'Gato',
    sex: 'Fêmea',
    weightKg: 4.5,
    birthDate: DateTime(2020, 4, 2),
    breed: 'SRD',
  );

  Agendamento event(String description) => Agendamento(
    data: DateTime(2030, 5, 6, 14, 30),
    tipo: 'Consulta Geral',
    veterinario: 'Dra. Ana Silva',
    local: 'VetHome · Particular',
    status: StatusAgendamento.pendente,
    descricao: description,
  );

  Future<Map<String, dynamic>> savedJson() async {
    expect(await VetRepository.flush(), isTrue);
    final prefs = await SharedPreferences.getInstance();
    return jsonDecode(prefs.getString(LocalStorage.stateKey)!)
        as Map<String, dynamic>;
  }

  test('PetModel preserva todos os campos e ID no roundtrip JSON', () {
    final pet = PetModel(
      id: 'pet-roundtrip',
      name: 'Ágata',
      imagePath: 'assets/imagens/figma/cachorroegatopng-3.png',
      description: 'Gato · Fêmea',
      species: 'Gato',
      sex: 'Fêmea',
      weightKg: 4.5,
      birthDate: DateTime(2020, 4, 2),
      breed: 'SRD',
      neutered: true,
      ageYears: 6,
    );
    final restored = PetModel.fromJson(
      jsonDecode(jsonEncode(pet.toJson())) as Map<String, dynamic>,
    );
    expect(restored.toJson(), pet.toJson());
    expect(restored.copyWith(name: 'Rex').id, pet.id);
    final minimal = PetModel(name: 'Pet', imagePath: '', description: '');
    expect(PetModel.fromJson(minimal.toJson()).toJson(), minimal.toJson());
  });

  test('PetModel rejeita ID vazio, tipos incorretos e data inválida', () {
    final json = PetModel(name: 'Pet', imagePath: '', description: '').toJson();
    for (final change in [
      {'id': ''},
      {'id': null},
      {'weightKg': '4'},
      {'birthDate': '2026-02-31T00:00:00.000'},
      {'neutered': 'true'},
      {'ageYears': 1.5},
    ]) {
      expect(
        () => PetModel.fromJson({...json, ...change}),
        throwsFormatException,
      );
    }
  });

  test('Primeira execução mantém quatro mocks sem criar snapshot', () async {
    expect(VetRepository.pets.map((pet) => pet.id), [
      'pet-demo-1',
      'pet-demo-2',
      'pet-demo-3',
      'pet-demo-4',
    ]);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(LocalStorage.stateKey), isFalse);
  });

  test('Cadastro e edição do cliente sobrevivem à reinicialização', () async {
    VetRepository.registerClient({
      'client.Nome Completo': 'Cliente teste',
      'client.Data de Nascimento': '05/02/1995',
      'client.E-mail': 'cliente@example.com',
      'client.Telefone/Celular': '11912345678',
      'client.Gênero/Sexo': 'F',
      'client.Endereço': 'Rua A',
      'client.Número': '10',
      'pet.Nome Completo': 'Outro nome',
      'client.Senha': 'nunca persistir',
    });
    await VetRepository.initialize();
    expect(VetRepository.clientName, 'Cliente teste');
    expect(VetRepository.clientBirthDate, DateTime(1995, 2, 5));
    expect(VetRepository.clientEmail, 'cliente@example.com');
    expect(VetRepository.clientPhone, '11912345678');
    expect(VetRepository.clientAddress, 'Rua A, 10');
    expect(VetRepository.clientGender, 'F');
    VetRepository.updateClient(
      name: 'Nome editado',
      birthDate: DateTime(1990, 1, 2),
      address: 'Rua B',
      phone: '21912345678',
      email: 'novo@example.com',
    );
    await VetRepository.initialize();
    expect(VetRepository.clientName, 'Nome editado');
    expect(VetRepository.clientBirthDate, DateTime(1990, 1, 2));
    expect(VetRepository.clientAddress, 'Rua B');
    expect(VetRepository.clientPhone, '21912345678');
    expect(VetRepository.clientEmail, 'novo@example.com');
    expect(jsonEncode(await savedJson()), isNot(contains('nunca persistir')));
  });

  test('Pets cadastrados substituem a lista inicial no reload', () async {
    final added = addPet('Ágata');
    final expected = VetRepository.pets.map((pet) => pet.toJson()).toList();
    VetRepository.clientPhotoPath = 'blob:temporario';
    VetRepository.clientPhotoBytes = Uint8List.fromList([1, 2, 3]);
    final json = await savedJson();
    expect(jsonEncode(json), isNot(contains('blob:temporario')));
    await VetRepository.initialize();
    expect(VetRepository.pets.map((pet) => pet.toJson()).toList(), expected);
    expect(VetRepository.petById(added.id)?.name, 'Ágata');
    expect(VetRepository.clientPhotoPath, isNull);
    expect(VetRepository.clientPhotoBytes, isNull);
  });

  test('Lista vazia salva não recria os quatro mocks', () async {
    for (final pet in [...VetRepository.pets]) {
      VetRepository.removePet(pet);
    }
    expect((await savedJson())['pets'], isEmpty);
    await VetRepository.initialize();
    expect(VetRepository.pets, isEmpty);
    expect(VetRepository.selectedPet, isNull);
    await VetRepository.initialize();
    expect(VetRepository.pets, isEmpty);
  });

  test('Renomear e editar pet preserva ID e campos depois do reload', () async {
    final pet = addPet('Fernando novo');
    final updated = pet.copyWith(name: 'Rex', weightKg: 6, neutered: true);
    VetRepository.updatePet(pet, updated);
    await VetRepository.initialize();
    expect(VetRepository.petById(pet.id)?.toJson(), updated.toJson());
  });

  test('Exclusão persiste e novo cadastro não reutiliza ID anterior', () async {
    final pet = addPet('Nome reutilizável');
    VetRepository.removePet(pet);
    await VetRepository.initialize();
    expect(VetRepository.petById(pet.id), isNull);
    final replacement = addPet('Nome reutilizável');
    expect(replacement.id, isNot(pet.id));
    await VetRepository.initialize();
    expect(VetRepository.petById(replacement.id), isNotNull);
    expect(VetRepository.petById(pet.id), isNull);
  });

  test('Agendamento mantém proprietário por ID após rename e reload', () async {
    final pet = addPet('Fernando novo');
    final other = addPet('Outro pet');
    final appointment = event('Evento criado');
    VetRepository.addAgendamento(pet.id, appointment);
    await VetRepository.initialize();
    final restoredPet = VetRepository.petById(pet.id)!;
    expect(restoredPet.name, 'Fernando novo');
    expect(
      VetRepository.agendamentos(pet.id).last.toJson(petId: pet.id),
      appointment.toJson(petId: pet.id),
    );
    VetRepository.updatePet(restoredPet, restoredPet.copyWith(name: 'Rex'));
    final json = await savedJson();
    expect(json['appointments'], [appointment.toJson(petId: pet.id)]);
    await VetRepository.initialize();
    final events = VetRepository.agendamentos(
      pet.id,
    ).where((item) => item.descricao == 'Evento criado').toList();
    expect(
      events.single.toJson(petId: pet.id),
      appointment.toJson(petId: pet.id),
    );
    expect(VetRepository.petById(pet.id)?.name, 'Rex');
    expect(
      VetRepository.agendamentos(
        other.id,
      ).where((item) => item.descricao == 'Evento criado'),
      isEmpty,
    );
    VetRepository.removePet(VetRepository.petById(pet.id)!);
    await VetRepository.initialize();
    expect(VetRepository.petById(pet.id), isNull);
    expect(VetRepository.agendamentos(pet.id), isEmpty);
    expect(VetRepository.petById(other.id), isNotNull);
    expect((await savedJson())['appointments'], isEmpty);
  });

  test('Excluir pet remove somente seus eventos também no storage', () async {
    final pet = addPet('Excluir');
    final other = addPet('Manter');
    VetRepository.addAgendamento(pet.id, event('Excluir evento'));
    VetRepository.addAgendamento(other.id, event('Manter evento'));
    VetRepository.removePet(pet);
    await VetRepository.initialize();
    expect(VetRepository.agendamentos(pet.id), isEmpty);
    expect((await savedJson())['appointments'], [
      event('Manter evento').toJson(petId: other.id),
    ]);
  });

  test(
    'Mocks de agendamento e dados de sessão não entram no snapshot',
    () async {
      VetRepository.sendChatMessage('Chat apenas da sessão');
      VetRepository.updateClient(name: 'Cliente');
      final json = await savedJson();
      expect(json.keys.toSet(), {
        'schemaVersion',
        'client',
        'pets',
        'appointments',
      });
      expect(json['appointments'], isEmpty);
      expect(
        VetRepository.agendamentos(VetRepository.pets.first.id),
        hasLength(2),
      );
      expect(jsonEncode(json), isNot(contains('Chat apenas da sessão')));
      for (var i = 0; i < 2; i++) {
        await VetRepository.initialize();
        expect(VetRepository.pets, hasLength(4));
        expect(
          VetRepository.agendamentos(VetRepository.pets.first.id),
          hasLength(2),
        );
        expect((await savedJson())['appointments'], isEmpty);
      }
    },
  );

  for (final invalid in ['{quebrado', '[]', '{}', 'null']) {
    test('Storage inválido ($invalid) não derruba nem apaga o app', () async {
      SharedPreferences.setMockInitialValues({LocalStorage.stateKey: invalid});
      await VetRepository.initialize();
      expect(VetRepository.pets, hasLength(4));
      expect(VetRepository.clientName, 'Liminha');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalStorage.stateKey), invalid);
      VetRepository.updateClient(name: 'Recuperado');
      final repaired = await savedJson();
      expect(repaired['schemaVersion'], 1);
      expect(prefs.getString(LocalStorage.stateKey), isNot(invalid));
      await VetRepository.initialize();
      expect(VetRepository.clientName, 'Recuperado');
    });
  }

  test('Snapshot estruturalmente corrompido tem fallback integral', () async {
    VetRepository.updateClient(name: 'Nome salvo');
    final good = await savedJson();
    for (final bad in [
      {...good}..remove('schemaVersion'),
      {...good, 'schemaVersion': '1'},
      {...good, 'schemaVersion': 99},
      {
        ...good,
        'pets': [1],
      },
      {
        ...good,
        'pets': [good['pets'][0], good['pets'][0]],
      },
      {
        ...good,
        'appointments': [event('órfão').toJson(petId: 'inexistente')],
      },
      {
        ...good,
        'client': {...good['client'], 'phone': 123},
      },
    ]) {
      SharedPreferences.setMockInitialValues({
        LocalStorage.stateKey: jsonEncode(bad),
      });
      await VetRepository.initialize();
      expect(VetRepository.clientName, 'Liminha');
      expect(VetRepository.pets, hasLength(4));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalStorage.stateKey), jsonEncode(bad));
    }
  });

  test('Tipo errado na preferência não derruba a inicialização', () async {
    SharedPreferences.setMockInitialValues({LocalStorage.stateKey: 42});
    await VetRepository.initialize();
    expect(VetRepository.pets, hasLength(4));
  });

  test('Gravações consecutivas preservam a última alteração', () async {
    final storage = _OrderedStorage();
    await VetRepository.initialize(storage: storage);
    for (var i = 0; i < 20; i++) {
      VetRepository.updateClient(name: 'Cliente $i');
    }
    try {
      await storage.firstStarted.future.timeout(const Duration(seconds: 5));
      // Mesmo com 20 alterações enfileiradas, nenhuma ultrapassa a primeira.
      expect(storage.started, ['Cliente 0']);
      expect(storage.completed, isEmpty);
    } finally {
      storage.releaseFirst.complete();
    }
    await VetRepository.initialize();
    final expectedOrder = List.generate(20, (i) => 'Cliente $i');
    expect(storage.started, expectedOrder);
    expect(storage.completed, expectedOrder);
    expect(storage.maxActive, 1);
    expect(VetRepository.clientName, 'Cliente 19');
  });

  test(
    'Falha de gravação é observável e não bloqueia próxima gravação',
    () async {
      await VetRepository.initialize(storage: _FailOnceStorage());
      VetRepository.updateClient(name: 'Falha');
      expect(await VetRepository.flush(), isFalse);
      expect(VetRepository.lastPersistenceError, isA<StateError>());
      VetRepository.updateClient(name: 'Recuperado');
      expect(await VetRepository.flush(), isTrue);
      expect(VetRepository.lastPersistenceError, isNull);
      await VetRepository.initialize();
      expect(VetRepository.clientName, 'Recuperado');
    },
  );

  test('Limpeza remove apenas a chave de estado do VetHome', () async {
    VetRepository.updateClient(name: 'Salvo');
    await VetRepository.flush();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('outro.estado', 'preservar');
    await LocalStorage().clear();
    expect(prefs.containsKey(LocalStorage.stateKey), isFalse);
    expect(prefs.getString('outro.estado'), 'preservar');
    await VetRepository.initialize();
    expect(VetRepository.pets, hasLength(4));
    expect(VetRepository.clientName, 'Liminha');
  });
}
