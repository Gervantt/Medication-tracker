import 'package:medtrack/features/reminders/domain/entities/reminder.dart';

/// Platform notification scheduling, hidden behind an interface so the
/// domain does not depend on a notifications plugin.
abstract interface class ReminderScheduler {
  /// Cancels all pending reminders and schedules [reminders] instead.
  Future<void> replaceAll(List<Reminder> reminders);
}
