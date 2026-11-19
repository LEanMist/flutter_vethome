import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage.dart';
import 'package:flutter_vethome/data/vet_repository.dart';

class _QueuedStorage extends LocalStorage {
  final completions = <Completer<void>>[];
  final savedNames = <String>[];

  @override
  Future<LocalLoadResult> load() async => const LocalLoadResult.empty();

  @override
  Future<void> save(LocalState state) {
    final completion = Completer<void>();
    completions.add(completion);
    return completion.future.then((_) {
      savedNames.add(state.client.name);
    });
  }
}

void main() {
  test(
    'alterações pendentes permanecem sinalizadas até a última gravação',
    () async {
      await VetRepository.flush();
      final storage = _QueuedStorage();
      await VetRepository.initialize(storage: storage);
      expect(VetRepository.unsavedChanges.value, isFalse);
      expect(VetRepository.savingChanges.value, isFalse);

      VetRepository.updateClient(name: 'Primeira alteração');
      VetRepository.updateClient(name: 'Última alteração');
      expect(VetRepository.unsavedChanges.value, isTrue);
      expect(VetRepository.savingChanges.value, isTrue);
      final flush = VetRepository.flush();

      await Future<void>.delayed(Duration.zero);
      expect(storage.completions, hasLength(1));
      storage.completions.first.complete();
      await Future<void>.delayed(Duration.zero);

      expect(storage.completions, hasLength(2));
      expect(VetRepository.unsavedChanges.value, isTrue);
      expect(VetRepository.savingChanges.value, isTrue);
      storage.completions.last.complete();

      expect(await flush, isTrue);
      expect(VetRepository.unsavedChanges.value, isFalse);
      expect(VetRepository.savingChanges.value, isFalse);
      expect(storage.savedNames, ['Primeira alteração', 'Última alteração']);
    },
  );

  test(
    'falha de gravação encerra o estado de salvamento e mantém o aviso',
    () async {
      await VetRepository.flush();
      final storage = _QueuedStorage();
      await VetRepository.initialize(storage: storage);

      VetRepository.updateClient(name: 'Falha simulada');
      final flush = VetRepository.flush();
      await Future<void>.delayed(Duration.zero);
      expect(storage.completions, hasLength(1));

      storage.completions.single.completeError(StateError('falha simulada'));

      expect(await flush, isFalse);
      expect(VetRepository.savingChanges.value, isFalse);
      expect(VetRepository.unsavedChanges.value, isTrue);
    },
  );
}
