/// A discriminated union for operations that can succeed or fail.
///
/// Pattern-match with `switch` for exhaustive handling:
/// ```dart
/// final text = switch (result) {
///   Ok(value: final v) => v,
///   Err(message: final m) => 'Error: $m',
/// };
/// ```
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final String message;
  final Object? cause;
  const Err(this.message, {this.cause});

  @override
  String toString() => 'Err: $message${cause != null ? ' (cause: $cause)' : ''}';
}
