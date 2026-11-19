/// Native mutations are serialized by [LocalStorage]'s in-process queue.
Future<T> withLocalStorageWriteLock<T>(
  Future<T> Function() action, {
  bool requireCrossContextLock = true,
  bool? lockApiAvailable,
}) => action();
