import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';
import 'package:medtrack/features/reminders/data/reminder_payload.dart';
import 'package:medtrack/features/reminders/domain/entities/reminder.dart';
import 'package:medtrack/features/reminders/domain/repositories/reminder_scheduler.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationScheduler implements ReminderScheduler {
  LocalNotificationScheduler(this._plugin, this._l10n);

  static const takenActionId = 'mark_taken';
  static const _androidChannelId = 'intake_reminders';
  static const _iosCategoryId = 'intake_reminder';

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLocalizations _l10n;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<void> initialize({
    required DidReceiveNotificationResponseCallback onResponse,
    required DidReceiveBackgroundNotificationResponseCallback
    onBackgroundResponse,
  }) {
    return _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permissions are requested explicitly, not on initialization.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          // iOS actions must be registered up front as a category.
          notificationCategories: [
            DarwinNotificationCategory(
              _iosCategoryId,
              actions: [
                DarwinNotificationAction.plain(takenActionId, _l10n.markTaken),
              ],
            ),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
  }

  /// Android 13+ runtime permission and the iOS authorization prompt.
  Future<bool> requestPermissions() async {
    final granted =
        await _android?.requestNotificationsPermission() ??
        await _ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? false;
  }

  @override
  Future<void> replaceAll(List<Reminder> reminders) async {
    try {
      // Only pending ones: delivered reminders stay in the notification shade.
      await _plugin.cancelAllPendingNotifications();
      final scheduleMode = await _androidScheduleMode();
      for (final reminder in reminders) {
        await _schedule(reminder, scheduleMode);
      }
    } on Object catch (error, stackTrace) {
      // A failed reschedule must not break saving data in the app.
      log(
        'Failed to schedule reminders',
        name: 'reminders',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _schedule(Reminder reminder, AndroidScheduleMode mode) {
    final medication = reminder.medication;
    final at = reminder.scheduledAt;
    final payload = ReminderPayload(
      medicationId: medication.id!,
      scheduledAt: at,
    );
    final formatter = MedicationFormatter(_l10n);
    return _plugin.zonedSchedule(
      id: payload.notificationId,
      scheduledDate: tz.TZDateTime(
        tz.local,
        at.year,
        at.month,
        at.day,
        at.hour,
        at.minute,
      ),
      notificationDetails: _details,
      androidScheduleMode: mode,
      title: medication.name,
      body: _l10n.reminderBody(
        formatter.dosage(medication.dosage),
        formatter.time(DoseTime(hour: at.hour, minute: at.minute)),
      ),
      payload: payload.encode(),
    );
  }

  /// Exact alarms need user consent on Android 14+; without it reminders
  /// may arrive a few minutes late instead of not at all.
  Future<AndroidScheduleMode> _androidScheduleMode() async {
    final canScheduleExact =
        await _android?.canScheduleExactNotifications() ?? false;
    return canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      _androidChannelId,
      _l10n.reminderChannelName,
      channelDescription: _l10n.reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      actions: [AndroidNotificationAction(takenActionId, _l10n.markTaken)],
    ),
    iOS: const DarwinNotificationDetails(categoryIdentifier: _iosCategoryId),
  );
}
