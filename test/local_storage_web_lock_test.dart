import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/local_storage_write_lock.dart';

void main() {
  test(
    'bloqueio web mantém a segunda operação aguardando a primeira',
    () async {
      final firstEntered = Completer<void>();
      final releaseFirst = Completer<void>();
      var secondStarted = false;

      final first = withLocalStorageWriteLock(() async {
        firstEntered.complete();
        await releaseFirst.future;
        return 'primeira';
      });
      await firstEntered.future;

      final second = withLocalStorageWriteLock(() async {
        secondStarted = true;
        return 'segunda';
      });
      await Future<void>.delayed(Duration.zero);

      expect(secondStarted, isFalse);
      releaseFirst.complete();

      expect(await first, 'primeira');
      expect(await second, 'segunda');
      expect(secondStarted, isTrue);
    },
    skip: !kIsWeb,
  );

  test(
    'sem Web Locks permite leitura e bloqueia mutações entre abas',
    () async {
      var mutationStarted = false;
      await expectLater(
        withLocalStorageWriteLock(() async {
          mutationStarted = true;
          return true;
        }, lockApiAvailable: false),
        throwsA(isA<StateError>()),
      );
      expect(mutationStarted, isFalse);

      final read = await withLocalStorageWriteLock(
        () async => 'leitura permitida',
        requireCrossContextLock: false,
        lockApiAvailable: false,
      );
      expect(read, 'leitura permitida');
    },
    skip: !kIsWeb,
  );
}
