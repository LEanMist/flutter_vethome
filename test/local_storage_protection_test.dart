import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/main.dart';
import 'package:flutter_vethome/models/pet_model.dart';
import 'package:flutter_vethome/models/saved_address.dart';
import 'package:flutter_vethome/models/vet_models.dart';
import 'package:flutter_vethome/pages/critical_storage_error_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ResultStorage extends LocalStorage {
  _ResultStorage(this.result);

  final LocalLoadResult result;
  int saveCalls = 0;

  @override
  Future<LocalLoadResult> load() async => result;

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
  }
}

class _CountingLocalStorage extends LocalStorage {
  int saveCalls = 0;

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
    await super.save(state);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LocalState validState({String name = 'Cliente salvo'}) => LocalState(
    client: ClientData(
      name: name,
      birthDate: DateTime(1990, 1, 2),
      address: '',
      phone: '',
      email: 'cliente@example.com',
      gender: '',
    ),
    pets: const [],
    appointments: const {},
  );

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

  test('load distingue armazenamento vazio de snapshot válido', () async {
    final storage = LocalStorage();

    final empty = await storage.load();
    expect(empty.status, LocalLoadStatus.empty);
    expect(empty.state, isNull);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      LocalStorage.stateKey,
      jsonEncode(validState().toJson()),
    );

    final valid = await storage.load();
    expect(valid.status, LocalLoadStatus.valid);
    expect(valid.state?.client.name, 'Cliente salvo');
  });

  test('load classifica JSON, estrutura e versão inválidos', () async {
    final storage = LocalStorage();
    final snapshots = <String>[
      '{quebrado',
      jsonEncode({'schemaVersion': 1}),
      jsonEncode({...validState().toJson(), 'schemaVersion': 2}),
    ];

    for (final snapshot in snapshots) {
      SharedPreferences.setMockInitialValues({LocalStorage.stateKey: snapshot});
      final result = await storage.load();
      expect(result.status, LocalLoadStatus.invalid);
      expect(result.state, isNull);
    }
  });

  test('load não transforma falha de acesso em armazenamento vazio', () async {
    final storage = LocalStorage(
      preferencesLoader: () async => throw StateError('indisponível'),
    );

    final result = await storage.load();

    expect(result.status, LocalLoadStatus.unavailable);
    expect(result.state, isNull);
    expect(result.error, isA<StateError>());
  });

  test('load classifica tipo incorreto como snapshot inválido', () async {
    SharedPreferences.setMockInitialValues({LocalStorage.stateKey: 42});

    final result = await LocalStorage().load();

    expect(result.status, LocalLoadStatus.invalid);
    expect(result.state, isNull);
  });

  test(
    'load classifica falha de reload como armazenamento indisponível',
    () async {
      final storage = LocalStorage(
        reloadPreferences: (_) async => throw StateError('reload falhou'),
      );

      final result = await storage.load();

      expect(result.status, LocalLoadStatus.unavailable);
      expect(result.error, isA<StateError>());
    },
  );

  test(
    'snapshot inválido bloqueia mutação e preserva conteúdo original',
    () async {
      const original = '{snapshot-corrompido';
      SharedPreferences.setMockInitialValues({LocalStorage.stateKey: original});
      await VetRepository.initialize();

      expect(VetRepository.persistenceStatus, LocalLoadStatus.invalid);
      expect(
        () => VetRepository.updateClient(name: 'Não pode salvar'),
        throwsA(isA<PersistenceBlockedException>()),
      );
      expect(VetRepository.clientName, 'Liminha');
      expect(await VetRepository.flush(), isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LocalStorage.stateKey), original);
    },
  );

  test(
    'armazenamento indisponível bloqueia mutações sem tratar como usuário novo',
    () async {
      final storage = LocalStorage(
        preferencesLoader: () async => throw StateError('sem acesso'),
      );
      await VetRepository.initialize(storage: storage);

      expect(VetRepository.persistenceStatus, LocalLoadStatus.unavailable);
      expect(VetRepository.persistenceBlocked, isTrue);
      expect(
        () => VetRepository.saveAddress(
          const SavedAddress(id: 'novo', street: 'Rua bloqueada'),
        ),
        throwsA(isA<PersistenceBlockedException>()),
      );
      expect(VetRepository.addresses, isEmpty);
      expect(await VetRepository.flush(), isFalse);
    },
  );

  test('snapshot v1 válido continua carregando e salvando', () async {
    SharedPreferences.setMockInitialValues({
      LocalStorage.stateKey: jsonEncode(validState().toJson()),
    });
    await VetRepository.initialize();

    expect(VetRepository.persistenceStatus, LocalLoadStatus.valid);
    expect(VetRepository.clientName, 'Cliente salvo');
    VetRepository.updateClient(name: 'Cliente atualizado');
    expect(await VetRepository.flush(), isTrue);

    await VetRepository.initialize();
    expect(VetRepository.clientName, 'Cliente atualizado');
  });

  for (final blockedStatus in [
    LocalLoadStatus.invalid,
    LocalLoadStatus.unavailable,
  ]) {
    test('os 11 caminhos de mutação são atômicos em $blockedStatus', () async {
      const raw = '{conteúdo-original';
      late final LocalStorage storage;
      if (blockedStatus == LocalLoadStatus.invalid) {
        SharedPreferences.setMockInitialValues({LocalStorage.stateKey: raw});
        storage = _CountingLocalStorage();
      } else {
        storage = _ResultStorage(
          LocalLoadResult.unavailable(StateError('sem armazenamento')),
        );
      }
      await VetRepository.initialize(storage: storage);
      final pet = VetRepository.pets.first;
      final before = _repositorySnapshot(pet);
      final mutations = <String, Future<void> Function()>{
        'registerClient': () async => VetRepository.registerClient({}),
        'updateClient': () async => VetRepository.updateClient(name: 'Outro'),
        'saveAddress': () async => VetRepository.saveAddress(
          const SavedAddress(id: 'address-new', street: 'Rua nova'),
        ),
        'removeAddress': () async => VetRepository.removeAddress('inexistente'),
        'updatePetPhoto': () async {
          await VetRepository.updatePetPhoto(pet.id, 'foto');
        },
        'addPet': () async => VetRepository.addPet(
          name: 'Novo pet',
          species: 'Gato',
          sex: 'Fêmea',
          weightKg: 4,
          birthDate: DateTime(2020, 1, 1),
          breed: 'SRD',
        ),
        'updatePet': () async =>
            VetRepository.updatePet(pet, pet.copyWith(name: 'Nome alterado')),
        'removePet': () async => VetRepository.removePet(pet),
        'addAgendamento': () async => VetRepository.addAgendamento(
          pet.id,
          Agendamento(
            data: DateTime(2030, 1, 1, 14),
            tipo: 'Consulta',
            veterinario: 'Veterinária',
            local: 'VetHome',
            status: StatusAgendamento.pendente,
          ),
        ),
        'saveVaccine': () async => VetRepository.saveVaccine(
          pet.id,
          Vacina(nome: 'V10', aplicada: DateTime(2025, 1, 1)),
        ),
        'removeVaccine': () async =>
            VetRepository.removeVaccine(pet.id, 'vaccine-inexistente'),
      };

      expect(mutations, hasLength(11));
      for (final entry in mutations.entries) {
        await expectLater(
          entry.value,
          throwsA(isA<PersistenceBlockedException>()),
          reason: entry.key,
        );
        expect(_repositorySnapshot(pet), before, reason: entry.key);
      }

      expect(switch (storage) {
        _CountingLocalStorage value => value.saveCalls,
        _ResultStorage value => value.saveCalls,
        _ => -1,
      }, 0);
      expect(await VetRepository.flush(), isFalse);
      if (blockedStatus == LocalLoadStatus.invalid) {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(LocalStorage.stateKey), raw);
      }
    });
  }

  testWidgets('erro crítico de leitura isola as telas normais', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CriticalStorageErrorPage(status: LocalLoadStatus.invalid),
      ),
    );

    expect(find.text('Seus dados locais estão protegidos'), findsOneWidget);
    expect(find.textContaining('não foram alterados'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  for (final status in [LocalLoadStatus.invalid, LocalLoadStatus.unavailable]) {
    testWidgets('tela crítica representa $status sem expor rotas normais', (
      tester,
    ) async {
      final storage = _ResultStorage(
        status == LocalLoadStatus.invalid
            ? const LocalLoadResult.invalid(FormatException('inválido'))
            : LocalLoadResult.unavailable(StateError('indisponível')),
      );
      await tester.runAsync(
        () async => VetRepository.initialize(storage: storage),
      );

      await tester.pumpWidget(const VetHomeApp());

      expect(find.text('Seus dados locais estão protegidos'), findsOneWidget);
      final context = tester.element(find.byType(CriticalStorageErrorPage));
      expect(
        () => Navigator.of(context).pushNamed('/login'),
        throwsFlutterError,
      );
      expect(find.byType(TextField), findsNothing);
      expect(storage.saveCalls, 0);
    });
  }

  testWidgets('aplicativo bloqueado abre somente o tratamento crítico', (
    tester,
  ) async {
    await tester.runAsync(
      () async => VetRepository.initialize(
        storage: _ResultStorage(
          const LocalLoadResult.invalid(FormatException('inválido')),
        ),
      ),
    );

    await tester.pumpWidget(const VetHomeApp());

    expect(find.text('Seus dados locais estão protegidos'), findsOneWidget);
  });
}

Map<String, Object?> _repositorySnapshot(PetModel pet) => {
  'clientName': VetRepository.clientName,
  'clientBirthDate': VetRepository.clientBirthDate.toIso8601String(),
  'clientAddress': VetRepository.clientAddress,
  'clientPhone': VetRepository.clientPhone,
  'clientEmail': VetRepository.clientEmail,
  'addresses': VetRepository.addresses.map((value) => value.toJson()).toList(),
  'pets': VetRepository.pets.map((value) => value.toJson()).toList(),
  'appointments': VetRepository.realAppointments(
    pet.id,
  ).map((value) => value.toJson(petId: pet.id)).toList(),
  'vaccines': VetRepository.realVaccines(
    pet.id,
  ).map((value) => value.toJson(petId: pet.id)).toList(),
};
