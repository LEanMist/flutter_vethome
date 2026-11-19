import 'dart:async';
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

class _SlowClearStorage extends LocalStorage {
  final clearStarted = Completer<void>();
  final allowClear = Completer<void>();
  int saveCalls = 0;

  @override
  Future<void> save(LocalState state) async {
    saveCalls++;
    throw StateError('falha de gravação simulada');
  }

  @override
  Future<void> clear() async {
    clearStarted.complete();
    await allowClear.future;
    await super.clear();
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

  Map<String, dynamic> storedSnapshot(SharedPreferences preferences) =>
      jsonDecode(preferences.getString(LocalStorage.stateKey)!)
          as Map<String, dynamic>;

  Map<String, dynamic> storedMetadata(SharedPreferences preferences) =>
      storedSnapshot(preferences)[LocalStorage.storageMetadataKey]
          as Map<String, dynamic>;

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
    'revisão local inválida bloqueia leitura e preserva o snapshot',
    () async {
      final snapshot = jsonEncode(validState().toJson());
      SharedPreferences.setMockInitialValues({
        LocalStorage.stateKey: snapshot,
        LocalStorage.generationKey: 'inválida',
      });

      final result = await LocalStorage().load();

      expect(result.status, LocalLoadStatus.invalid);
      expect(result.state, isNull);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(LocalStorage.stateKey), snapshot);
      expect(preferences.getString(LocalStorage.generationKey), 'inválida');
    },
  );

  test('revisão de gravação inválida bloqueia e preserva o snapshot', () async {
    final snapshot = jsonEncode(validState().toJson());
    SharedPreferences.setMockInitialValues({
      LocalStorage.stateKey: snapshot,
      LocalStorage.revisionKey: 'inválida',
    });

    final result = await LocalStorage().load();

    expect(result.status, LocalLoadStatus.invalid);
    expect(result.state, isNull);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(LocalStorage.stateKey), snapshot);
    expect(preferences.getString(LocalStorage.revisionKey), 'inválida');
  });

  test(
    'limpeza explícita recupera revisão corrompida sem recriar snapshot',
    () async {
      SharedPreferences.setMockInitialValues({
        LocalStorage.stateKey: jsonEncode(validState().toJson()),
        LocalStorage.generationKey: 'inválida',
      });
      final storage = LocalStorage();

      expect((await storage.load()).status, LocalLoadStatus.invalid);
      await storage.clear();

      final preferences = await SharedPreferences.getInstance();
      expect((await LocalStorage().load()).status, LocalLoadStatus.empty);
      final tombstone = storedSnapshot(preferences);
      expect(tombstone.containsKey('client'), isFalse);
      expect(storedMetadata(preferences)['cleared'], isTrue);
      expect(storedMetadata(preferences)['generation'], greaterThan(0));
    },
  );

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
    final preferences = await SharedPreferences.getInstance();
    expect(storedMetadata(preferences)['revision'], 1);

    await VetRepository.initialize();
    expect(VetRepository.clientName, 'Cliente atualizado');
  });

  test('snapshot e revisões são gravados na mesma entrada', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorage();
    await storage.load();

    await storage.save(validState(name: 'Registro único'));

    final preferences = await SharedPreferences.getInstance();
    final snapshot = storedSnapshot(preferences);
    final metadata = storedMetadata(preferences);
    expect(snapshot['schemaVersion'], 1);
    expect(
      (snapshot['client'] as Map<String, dynamic>)['name'],
      'Registro único',
    );
    expect(metadata['formatVersion'], 1);
    expect(metadata['generation'], 0);
    expect(metadata['revision'], 1);
    expect(metadata['cleared'], isFalse);
    expect(preferences.getInt(LocalStorage.revisionKey), isNull);
    expect(preferences.getInt(LocalStorage.generationKey), isNull);
  });

  test(
    'falha ao gravar o registro único preserva snapshot e revisões antigos',
    () async {
      final original = jsonEncode(validState().toJson());
      SharedPreferences.setMockInitialValues({
        LocalStorage.stateKey: original,
        LocalStorage.revisionKey: 4,
        LocalStorage.generationKey: 2,
      });
      final storage = LocalStorage(
        snapshotWriter: (preferences, key, value) async {
          expect(preferences, isNotNull);
          expect(key, LocalStorage.stateKey);
          expect(value, isNotEmpty);
          return false;
        },
      );
      expect((await storage.load()).status, LocalLoadStatus.valid);

      await expectLater(
        storage.save(validState(name: 'Falha simulada')),
        throwsA(isA<StateError>()),
      );

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(LocalStorage.stateKey), original);
      expect(preferences.getInt(LocalStorage.revisionKey), 4);
      expect(preferences.getInt(LocalStorage.generationKey), 2);
    },
  );

  test('falha ao gravar o tombstone preserva o snapshot salvo', () async {
    final originalStorage = LocalStorage();
    await originalStorage.load();
    await originalStorage.save(validState(name: 'Dados preservados'));
    final preferences = await SharedPreferences.getInstance();
    final original = preferences.getString(LocalStorage.stateKey);
    final failingStorage = LocalStorage(
      snapshotWriter: (preferences, key, value) async {
        expect(preferences, isNotNull);
        expect(key, LocalStorage.stateKey);
        expect(value, isNotEmpty);
        return false;
      },
    );
    expect((await failingStorage.load()).status, LocalLoadStatus.valid);

    await expectLater(failingStorage.clear(), throwsA(isA<StateError>()));

    expect(preferences.getString(LocalStorage.stateKey), original);
    final stillSaved = await LocalStorage().load();
    expect(stillSaved.status, LocalLoadStatus.valid);
    expect(stillSaved.state?.client.name, 'Dados preservados');
  });

  test(
    'instância nova exige leitura antes de poder salvar sobre um tombstone',
    () async {
      final tombstone = jsonEncode({
        LocalStorage.storageMetadataKey: {
          'formatVersion': 1,
          'generation': 7,
          'revision': 9,
          'cleared': true,
        },
      });
      SharedPreferences.setMockInitialValues({
        LocalStorage.stateKey: tombstone,
      });
      final freshStorage = LocalStorage();

      await expectLater(
        freshStorage.save(validState(name: 'Snapshot desatualizado')),
        throwsA(isA<StateError>()),
      );
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(LocalStorage.stateKey), tombstone);
    },
  );

  test(
    'aba desatualizada não sobrescreve alterações locais mais recentes',
    () async {
      SharedPreferences.setMockInitialValues({});
      final firstTab = LocalStorage();
      final staleTab = LocalStorage();
      expect((await firstTab.load()).status, LocalLoadStatus.empty);
      expect((await staleTab.load()).status, LocalLoadStatus.empty);

      await firstTab.save(validState(name: 'Primeira aba'));
      await expectLater(
        staleTab.save(validState(name: 'Aba desatualizada')),
        throwsA(
          isA<LocalStorageConflictException>().having(
            (error) => error.kind,
            'kind',
            LocalStorageConflictKind.modified,
          ),
        ),
      );

      final saved = await LocalStorage().load();
      expect(saved.status, LocalLoadStatus.valid);
      expect(saved.state?.client.name, 'Primeira aba');

      final refreshedTab = staleTab.createReloadInstance();
      expect((await refreshedTab.load()).status, LocalLoadStatus.valid);
      await refreshedTab.save(validState(name: 'Atualizado após recarregar'));
      final latest = await LocalStorage().load();
      expect(latest.state?.client.name, 'Atualizado após recarregar');
    },
  );

  test('aba desatualizada não apaga uma revisão mais recente', () async {
    SharedPreferences.setMockInitialValues({});
    final staleTab = LocalStorage();
    final latestTab = LocalStorage();
    await Future.wait([staleTab.load(), latestTab.load()]);

    await latestTab.save(validState(name: 'Alteração mais recente'));
    await expectLater(
      staleTab.clear(),
      throwsA(
        isA<LocalStorageConflictException>().having(
          (error) => error.kind,
          'kind',
          LocalStorageConflictKind.modified,
        ),
      ),
    );

    final latest = await LocalStorage().load();
    expect(latest.status, LocalLoadStatus.valid);
    expect(latest.state?.client.name, 'Alteração mais recente');
    final preferences = await SharedPreferences.getInstance();
    expect(storedMetadata(preferences)['revision'], 1);
    expect(storedMetadata(preferences)['cleared'], isFalse);
  });

  test(
    'gravações simultâneas preservam uma revisão e detectam conflito',
    () async {
      final firstTab = LocalStorage();
      final secondTab = LocalStorage();
      await Future.wait([firstTab.load(), secondTab.load()]);

      Future<Object?> attempt(Future<void> save) async {
        try {
          await save;
          return null;
        } catch (error) {
          return error;
        }
      }

      final outcomes = await Future.wait([
        attempt(firstTab.save(validState(name: 'Primeira aba'))),
        attempt(secondTab.save(validState(name: 'Segunda aba'))),
      ]);

      expect(outcomes.whereType<LocalStorageConflictException>(), hasLength(1));
      expect(outcomes.where((outcome) => outcome == null), hasLength(1));
      final stored = await LocalStorage().load();
      expect(stored.status, LocalLoadStatus.valid);
      expect([
        'Primeira aba',
        'Segunda aba',
      ], contains(stored.state?.client.name));
      final preferences = await SharedPreferences.getInstance();
      expect(storedMetadata(preferences)['revision'], 1);
    },
  );

  test(
    'limpeza concorrente com gravação não recria snapshot apagado',
    () async {
      final staleTab = LocalStorage();
      final clearingTab = LocalStorage();
      await Future.wait([staleTab.load(), clearingTab.load()]);

      final clear = clearingTab.clear();
      final save = staleTab.save(validState(name: 'Não pode reaparecer'));
      final outcomes = await Future.wait([
        clear.then<Object?>((_) => null, onError: (Object error) => error),
        save.then<Object?>((_) => null, onError: (Object error) => error),
      ]);

      expect(outcomes.first, isNull);
      expect(
        outcomes.last,
        anyOf(isNull, isA<LocalStorageConflictException>()),
      );
      expect((await LocalStorage().load()).status, LocalLoadStatus.empty);
    },
  );

  test('gravação enfileirada antes da limpeza não recria o snapshot', () async {
    final storage = LocalStorage();
    expect((await storage.load()).status, LocalLoadStatus.empty);

    final clear = storage.clear();
    final staleSave = storage.save(validState(name: 'Não pode reaparecer'));
    await clear;

    await expectLater(
      staleSave,
      throwsA(
        isA<LocalStorageConflictException>().having(
          (error) => error.kind,
          'kind',
          LocalStorageConflictKind.cleared,
        ),
      ),
    );
    expect((await LocalStorage().load()).status, LocalLoadStatus.empty);
  });

  test('mutação local fica bloqueada durante a exclusão do perfil', () async {
    SharedPreferences.setMockInitialValues({
      LocalStorage.stateKey: jsonEncode(
        validState(name: 'Perfil salvo').toJson(),
      ),
    });
    final storage = _SlowClearStorage();
    await VetRepository.initialize(storage: storage);
    final clear = VetRepository.clearLocalData();
    await storage.clearStarted.future;

    expect(
      () => VetRepository.updateClient(name: 'Alteração concorrente'),
      throwsA(isA<PersistenceClearingException>()),
    );
    expect(VetRepository.clientName, 'Perfil salvo');
    expect(VetRepository.unsavedChanges.value, isFalse);

    storage.allowClear.complete();
    expect(await clear, isTrue);
    expect((await LocalStorage().load()).status, LocalLoadStatus.empty);
  });

  test(
    'retrySave não enfileira gravação durante a exclusão do perfil',
    () async {
      SharedPreferences.setMockInitialValues({
        LocalStorage.stateKey: jsonEncode(
          validState(name: 'Perfil salvo').toJson(),
        ),
      });
      final storage = _SlowClearStorage();
      await VetRepository.initialize(storage: storage);
      VetRepository.updateClient(name: 'Alteração não salva');
      expect(await VetRepository.flush(), isFalse);
      expect(VetRepository.unsavedChanges.value, isTrue);
      expect(storage.saveCalls, 1);

      final clear = VetRepository.clearLocalData();
      await storage.clearStarted.future;
      expect(await VetRepository.retrySave(), isFalse);
      expect(storage.saveCalls, 1);

      storage.allowClear.complete();
      expect(await clear, isTrue);
      expect((await LocalStorage().load()).status, LocalLoadStatus.empty);
    },
  );

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

      expect(VetRepository.unsavedChanges.value, isFalse);
      expect(await VetRepository.retrySave(), isFalse);
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

  testWidgets('tela crítica mantém recuperação acessível com texto a 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: CriticalStorageErrorPage(
          status: LocalLoadStatus.invalid,
          onClear: () async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final action = find.byKey(const ValueKey('critical-storage-clear'));
    expect(action, findsOneWidget);
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();

    final safeArea = tester.getRect(find.byType(SafeArea));
    expect(
      tester.getRect(action).bottom,
      lessThanOrEqualTo(safeArea.bottom),
      reason: 'A ação de recuperação deve continuar alcançável na tela baixa.',
    );
    expect(tester.takeException(), isNull);
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
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('tela crítica pede confirmação antes de apagar os dados', (
    tester,
  ) async {
    var clearCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CriticalStorageErrorPage(
          status: LocalLoadStatus.invalid,
          onClear: () async {
            clearCalls++;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('critical-storage-clear')));
    await tester.pumpAndSettle();
    expect(find.text('Apagar os dados salvos?'), findsOneWidget);
    expect(clearCalls, 0);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(clearCalls, 0);

    await tester.tap(find.byKey(const ValueKey('critical-storage-clear')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar dados'));
    await tester.pumpAndSettle();
    expect(clearCalls, 1);
    expect(find.text('Apagar os dados salvos?'), findsNothing);
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
