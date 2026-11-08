import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DelayedReloadStorage extends LocalStorage {
  _DelayedReloadStorage(this.initialState);

  final LocalState initialState;
  final Completer<LocalLoadResult> reloadResult = Completer<LocalLoadResult>();
  int loadCalls = 0;
  int clearCalls = 0;

  @override
  LocalStorage createReloadInstance() => this;

  @override
  Future<LocalLoadResult> load() {
    loadCalls++;
    if (loadCalls == 1) {
      return Future.value(LocalLoadResult.valid(initialState));
    }
    return reloadResult.future;
  }

  @override
  Future<void> save(LocalState state) async {
    throw LocalStorageConflictException.modified();
  }

  @override
  Future<void> clear() async {
    clearCalls++;
  }
}

class _DelayedInitializationStorage extends LocalStorage {
  final Completer<void> loadStarted = Completer<void>();
  final Completer<LocalLoadResult> loadResult = Completer<LocalLoadResult>();

  @override
  Future<LocalLoadResult> load() {
    if (!loadStarted.isCompleted) loadStarted.complete();
    return loadResult.future;
  }
}

class _ImmediateInitializationStorage extends LocalStorage {
  _ImmediateInitializationStorage(this.result);

  final LocalLoadResult result;

  @override
  Future<LocalLoadResult> load() async => result;
}

LocalState _stateWithName(String name) => LocalState(
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await VetRepository.flush();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  tearDown(() async {
    await VetRepository.flush();
    await VetRepository.clearLocalData();
    SharedPreferences.setMockInitialValues({});
    await VetRepository.initialize();
  });

  Future<_DelayedReloadStorage> createConflictStorage() async {
    final storage = _DelayedReloadStorage(_stateWithName('Estado inicial'));
    await VetRepository.initialize(storage: storage);
    VetRepository.updateClient(name: 'Alteração que encontrou conflito');
    expect(await VetRepository.flush(), isFalse);
    return storage;
  }

  test(
    'recarga atrasada não descarta uma alteração feita nesta janela',
    () async {
      final storage = await createConflictStorage();
      final reload = VetRepository.reloadLatestAfterConflict();
      expect(storage.loadCalls, 2);

      VetRepository.updateClient(name: 'Alteração local mais recente');
      expect(await VetRepository.flush(), isFalse);

      storage.reloadResult.complete(
        LocalLoadResult.valid(_stateWithName('Snapshot remoto antigo')),
      );

      expect(await reload, isFalse);
      expect(VetRepository.clientName, 'Alteração local mais recente');
      expect(VetRepository.unsavedChanges.value, isTrue);
      expect(VetRepository.savingChanges.value, isFalse);
    },
  );

  test('recarga atrasada não restaura dados após exclusão concluída', () async {
    final storage = await createConflictStorage();
    final reload = VetRepository.reloadLatestAfterConflict();
    expect(storage.loadCalls, 2);

    expect(await VetRepository.clearLocalData(), isTrue);
    expect(storage.clearCalls, 1);
    expect(VetRepository.clientName, 'Liminha');

    storage.reloadResult.complete(
      LocalLoadResult.valid(_stateWithName('Snapshot que já foi apagado')),
    );

    expect(await reload, isFalse);
    expect(VetRepository.clientName, 'Liminha');
    expect(VetRepository.lastPersistenceError, isNull);
  });

  test(
    'inicialização atrasada não descarta mutação feita durante a leitura',
    () async {
      final storage = _DelayedInitializationStorage();
      final initialization = VetRepository.initialize(storage: storage);
      await storage.loadStarted.future;

      VetRepository.updateClient(name: 'Alteração feita durante a leitura');
      expect(await VetRepository.flush(), isTrue);

      storage.loadResult.complete(
        LocalLoadResult.valid(_stateWithName('Snapshot antigo')),
      );
      await initialization;

      expect(VetRepository.clientName, 'Alteração feita durante a leitura');
    },
  );

  test('inicialização atrasada não desfaz uma exclusão concluída', () async {
    VetRepository.updateClient(name: 'Dados anteriores à exclusão');
    expect(await VetRepository.flush(), isTrue);

    final storage = _DelayedInitializationStorage();
    final initialization = VetRepository.initialize(storage: storage);
    await storage.loadStarted.future;

    expect(await VetRepository.clearLocalData(), isTrue);
    storage.loadResult.complete(
      LocalLoadResult.valid(_stateWithName('Snapshot já excluído')),
    );
    await initialization;

    expect(VetRepository.clientName, 'Liminha');
    expect(VetRepository.lastPersistenceError, isNull);
  });

  test(
    'a última inicialização iniciada prevalece sobre uma leitura antiga',
    () async {
      final delayedStorage = _DelayedInitializationStorage();
      final delayedInitialization = VetRepository.initialize(
        storage: delayedStorage,
      );
      await delayedStorage.loadStarted.future;

      await VetRepository.initialize(
        storage: _ImmediateInitializationStorage(
          LocalLoadResult.valid(_stateWithName('Inicialização mais recente')),
        ),
      );
      delayedStorage.loadResult.complete(
        LocalLoadResult.valid(_stateWithName('Inicialização antiga')),
      );
      await delayedInitialization;

      expect(VetRepository.clientName, 'Inicialização mais recente');
    },
  );

  test(
    'inicialização preserva alterações locais após falha ao salvar',
    () async {
      await createConflictStorage();
      final expectedName = VetRepository.clientName;

      await VetRepository.initialize(
        storage: _ImmediateInitializationStorage(
          LocalLoadResult.valid(_stateWithName('Snapshot antigo')),
        ),
      );

      expect(VetRepository.clientName, expectedName);
      expect(VetRepository.unsavedChanges.value, isTrue);
    },
  );
}
