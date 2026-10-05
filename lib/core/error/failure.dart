/// App-level error types. Data sources throw library-specific exceptions;
/// repositories translate them into a [Failure] so the domain and UI never
/// depend on dio or HTTP details.
sealed class Failure {
  const Failure();
}

/// No internet connection or the host is unreachable.
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

/// Too many requests (HTTP 429).
final class RateLimitFailure extends Failure {
  const RateLimitFailure();
}

final class ServerFailure extends Failure {
  const ServerFailure(this.statusCode);

  final int? statusCode;
}

/// The request was cancelled, e.g. replaced by a newer search.
final class CancelledFailure extends Failure {
  const CancelledFailure();
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.error);

  final Object error;
}
