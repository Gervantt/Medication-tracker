import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.failureNetwork,
    TimeoutFailure() => l10n.failureTimeout,
    NotFoundFailure() => l10n.failureNotFound,
    RateLimitFailure() => l10n.failureRateLimit,
    ServerFailure() => l10n.failureServer,
    CancelledFailure() || UnexpectedFailure() => l10n.errorGenericMessage,
  };
}
