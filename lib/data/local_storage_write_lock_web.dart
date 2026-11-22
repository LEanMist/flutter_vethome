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

  late T result;
  (Object, StackTrace)? failure;

  Future<JSAny?> runAction(JSAny? lock) async {
    try {
      if (lock == null) {
        throw StateError('Não foi possível reservar o armazenamento local.');
      }
      result = await action();
    } catch (error, stackTrace) {
      failure = (error, stackTrace);
    }
    return null;
  }

  JSPromise<JSAny?> onGranted(JSAny? lock) => runAction(lock).toJS;

  await navigator.locks
      .request('vethome.state.write.v1', onGranted.toJS)
      .toDart;
  if (failure case (final error, final stackTrace)) {
    Error.throwWithStackTrace(error, stackTrace);
  }
  return result;
}
