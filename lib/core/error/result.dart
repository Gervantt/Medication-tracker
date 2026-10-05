import 'package:medtrack/core/error/failure.dart';

/// Either a value or a [Failure]. Unlike a thrown exception, the type
/// makes callers handle the failure case — `switch` must be exhaustive.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

/// Named `Err` so it does not shadow `dart:core`'s `Error`.
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
