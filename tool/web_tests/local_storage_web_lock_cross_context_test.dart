import 'dart:async';
import 'dart:js_interop';

import 'package:test/test.dart';
import 'package:web/web.dart' as web;

import 'package:flutter_vethome/data/local_storage_write_lock.dart';

void main() {
  test('Web Lock serializa gravações entre documentos da mesma origem', () async {
    const browserTimeout = Duration(seconds: 10);
    final frameLoaded = Completer<void>();
    final frame = web.HTMLIFrameElement()
      ..src = 'about:blank'
      ..style.display = 'none';
    final loadListener = ((web.Event _) {
      if (!frameLoaded.isCompleted) frameLoaded.complete();
    }).toJS;
    frame.addEventListener('load', loadListener);
    web.document.body!.append(frame);

    final firstEntered = Completer<void>();
    final releaseFirst = Completer<void>();
    final secondEntered = Completer<void>();
    const lockName = 'vethome.state.write.v1';
    final firstRequest = withLocalStorageWriteLock(() async {
      firstEntered.complete();
      await releaseFirst.future;
      return 'primeiro documento';
    });
    Future<JSAny?>? secondRequest;

    try {
      await frameLoaded.future.timeout(browserTimeout);
      final frameWindow = frame.contentWindow!;
      // about:blank inherits the parent origin, while location.origin can
      // serialize as "null" for its URL. Direct document access proves
      // same-origin without relying on that serialization.
      expect(frameWindow.document.body, isNotNull);
      await firstEntered.future.timeout(browserTimeout);

      JSAny? requestFromFrame(JSAny? lock) {
        if (lock == null) {
          throw StateError('O segundo documento não recebeu o Web Lock.');
        }
        secondEntered.complete();
        return null;
      }

      secondRequest = frameWindow.navigator.locks
          .request(lockName, requestFromFrame.toJS)
          .toDart;

      web.LockManagerSnapshot? queuedSnapshot;
      final queueWait = Stopwatch()..start();
      while (queueWait.elapsed < browserTimeout) {
        final snapshot = await web.window.navigator.locks
            .query()
            .toDart
            .timeout(browserTimeout);
        final held = snapshot.held.toDart
            .where((lock) => lock.name == lockName)
            .toList();
        final pending = snapshot.pending.toDart
            .where((lock) => lock.name == lockName)
            .toList();
        if (held.any(
          (heldLock) => pending.any(
            (pendingLock) => pendingLock.clientId != heldLock.clientId,
          ),
        )) {
          queuedSnapshot = snapshot;
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }

      expect(
        queuedSnapshot,
        isNotNull,
        reason: 'O navegador deve mostrar o segundo pedido na fila do lock.',
      );
      final heldClients = queuedSnapshot!.held.toDart
          .where((lock) => lock.name == lockName)
          .toList();
      final pendingClients = queuedSnapshot.pending.toDart
          .where((lock) => lock.name == lockName)
          .toList();
      expect(
        pendingClients.any(
          (pendingLock) => heldClients.any(
            (heldLock) => pendingLock.clientId != heldLock.clientId,
          ),
        ),
        isTrue,
      );
      expect(
        secondEntered.isCompleted,
        isFalse,
        reason:
            'O documento filho não pode entrar enquanto o lock estiver ocupado.',
      );

      releaseFirst.complete();
      expect(await firstRequest, 'primeiro documento');
      await secondRequest.timeout(browserTimeout);
      expect(secondEntered.isCompleted, isTrue);
    } finally {
      if (!releaseFirst.isCompleted) releaseFirst.complete();
      try {
        await firstRequest.timeout(browserTimeout);
      } on Object {
        // Mantém a falha original do teste; o lock já foi liberado acima.
      }
      final pendingSecondRequest = secondRequest;
      if (pendingSecondRequest != null) {
        try {
          await pendingSecondRequest.timeout(browserTimeout);
        } on Object {
          // Não deixa um erro de limpeza ocultar a falha original.
        }
      }
      frame.removeEventListener('load', loadListener);
      frame.remove();
    }
  });
}
