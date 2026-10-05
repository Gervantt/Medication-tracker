import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/features/intakes/data/repositories/intake_repository_impl.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/usecases/mark_intake.dart';
import 'package:medtrack/features/reminders/data/local_notification_scheduler.dart';
import 'package:medtrack/features/reminders/data/reminder_payload.dart';

/// Handles taps on reminders while the app's main isolate is running.
class NotificationResponseHandler {
  const NotificationResponseHandler(this._markIntake, this._router);

  final MarkIntake _markIntake;
  final GoRouter _router;

  Future<void> handle(NotificationResponse response) async {
    if (await _markTakenIfRequested(response, _markIntake)) return;
    // A tap on the notification itself opens today's intakes.
    _router.go(AppRoutes.today);
  }
}

/// Entry point for the "Taken" action pressed while the app is in the
/// background or terminated. Runs in a separate isolate with its own
/// Flutter engine, so dependencies are created here instead of `getIt`.
@pragma('vm:entry-point')
Future<void> handleBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  final database = AppDatabase();
  try {
    await _markTakenIfRequested(
      response,
      MarkIntake(IntakeRepositoryImpl(database.intakesDao)),
    );
  } finally {
    await database.close();
  }
}

/// Returns `true` if the response was the "Taken" action and was handled.
Future<bool> _markTakenIfRequested(
  NotificationResponse response,
  MarkIntake markIntake,
) async {
  final payload = ReminderPayload.tryDecode(response.payload);
  if (response.actionId != LocalNotificationScheduler.takenActionId ||
      payload == null) {
    return false;
  }
  await markIntake(
    medicationId: payload.medicationId,
    scheduledAt: payload.scheduledAt,
    status: IntakeStatus.taken,
  );
  return true;
}
