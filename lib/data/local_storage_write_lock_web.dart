import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Serializes shared-preference mutations between tabs in the same origin.
Future<T> withLocalStorageWriteLock<T>(
  Future<T> Function() action, {
  bool requireCrossContextLock = true,
  bool? lockApiAvailable,
}) async {
  final navigator = web.window.navigator;
  final hasLocks = lockApiAvailable ?? navigator.has('locks');
  if (!hasLocks) {
    if (requireCrossContextLock) {
      throw StateError(
        'Seu navegador não oferece bloqueio entre abas; os dados não foram alterados.',
      );
    }
    return action();
  }

  final result = Completer<T>();
  Future<JSAny?> runAction(JSAny? lock) async {
    if (lock == null) {
      result.completeError(
        StateError('Não foi possível reservar o armazenamento local.'),
      );
      return null;
    }
    try {
      result.complete(await action());
    } catch (error, stackTrace) {
      result.completeError(error, stackTrace);
    }
    return null;
  }

  JSPromise<JSAny?> onGranted(JSAny? lock) => runAction(lock).toJS;

  await navigator.locks
      .request('vethome.state.write.v1', onGranted.toJS)
      .toDart;
  return result.future;
}
