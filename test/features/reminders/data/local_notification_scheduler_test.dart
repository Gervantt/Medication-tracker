import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medtrack/features/reminders/data/local_notification_scheduler.dart';
import 'package:medtrack/features/reminders/data/reminder_payload.dart';
import 'package:medtrack/features/reminders/domain/entities/reminder.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../helpers/medication_fixtures.dart';

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin;

void main() {
  late _MockPlugin plugin;
  late LocalNotificationScheduler scheduler;
  final scheduledAt = DateTime(2026, 10, 6, 20, 30);
  final reminder = Reminder(
    medication: buildMedication(),
    scheduledAt: scheduledAt,
  );

  setUpAll(() async {
    await initializeDateFormatting('ru');
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Almaty'));
    registerFallbackValue(tz.TZDateTime(tz.local, 2001));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exact);
  });

  setUp(() {
    plugin = _MockPlugin();
    scheduler = LocalNotificationScheduler(
      plugin,
      lookupAppLocalizations(const Locale('ru')),
    );
    when(plugin.cancelAllPendingNotifications).thenAnswer((_) async {});
    when(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
  });

  group('LocalNotificationScheduler.replaceAll', () {
    test('cancels pending reminders and schedules new ones', () async {
      await scheduler.replaceAll([reminder]);

      final payload = ReminderPayload(
        medicationId: 1,
        scheduledAt: scheduledAt,
      );
      verifyInOrder([
        plugin.cancelAllPendingNotifications,
        () => plugin.zonedSchedule(
          id: payload.notificationId,
          scheduledDate: tz.TZDateTime(tz.local, 2026, 10, 6, 20, 30),
          notificationDetails: any(named: 'notificationDetails'),
          // No Android implementation in tests -> no exact alarm permission.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: 'Ibuprofen',
          body: 'Пора принять 200 мг · 20:30',
          payload: payload.encode(),
        ),
      ]);
      verifyNever(plugin.cancelAll);
    });

    test('does not throw when the plugin fails', () async {
      when(plugin.cancelAllPendingNotifications).thenThrow(Exception('plugin'));

      await expectLater(scheduler.replaceAll([reminder]), completes);
    });
  });
}
