sealed class AsyncState<T> {
  const AsyncState();
}

class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncState<T> {
  final T data;
  const AsyncData(this.data);
}

class AsyncError<T> extends AsyncState<T> {
  final Object error;
  final StackTrace? stackTrace;
  const AsyncError(this.error, [this.stackTrace]);
}
