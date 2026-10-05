import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/usecases/mark_intake.dart';
import 'package:medtrack/features/reminders/data/local_notification_scheduler.dart';
import 'package:medtrack/features/reminders/data/notification_response_handler.dart';
import 'package:medtrack/features/reminders/data/reminder_payload.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarkIntake extends Mock implements MarkIntake;

class _MockGoRouter extends Mock implements GoRouter;

void main() {
  late _MockMarkIntake markIntake;
  late _MockGoRouter router;
  late NotificationResponseHandler handler;
  final payload = ReminderPayload(
    medicationId: 3,
    scheduledAt: DateTime(2026, 10, 6, 8),
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(IntakeStatus.taken);
  });

  setUp(() {
    markIntake = _MockMarkIntake();
    router = _MockGoRouter();
    handler = NotificationResponseHandler(markIntake, router);
    when(
      () => markIntake(
        medicationId: any(named: 'medicationId'),
        scheduledAt: any(named: 'scheduledAt'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async {});
  });

  group('NotificationResponseHandler', () {
    test('the "Taken" action marks the intake without navigating', () async {
      await handler.handle(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: LocalNotificationScheduler.takenActionId,
          payload: payload.encode(),
        ),
      );

      verify(
        () => markIntake(
          medicationId: 3,
          scheduledAt: DateTime(2026, 10, 6, 8),
          status: IntakeStatus.taken,
        ),
      ).called(1);
      verifyNever(() => router.go(any()));
    });

    test('a tap on the notification opens Today', () async {
      await handler.handle(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: payload.encode(),
        ),
      );

      verify(() => router.go(AppRoutes.today)).called(1);
      verifyNever(
        () => markIntake(
          medicationId: any(named: 'medicationId'),
          scheduledAt: any(named: 'scheduledAt'),
          status: any(named: 'status'),
        ),
      );
    });
  });
}
