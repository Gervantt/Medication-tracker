import 'package:clock/clock.dart';
import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/reminders/domain/entities/reminder.dart';
import 'package:medtrack/features/reminders/domain/repositories/reminder_scheduler.dart';

/// Rebuilds pending reminders from the current schedules and marks.
///
/// Reminders are one-shot notifications for a rolling window of
/// [horizonDays] days. One-shot (instead of weekly repeating) reminders
/// carry the exact intake slot for the "Taken" action, respect course
/// dates and are not scheduled for intakes that are already marked.
class SyncReminders {
  const SyncReminders(this._medications, this._intakes, this._scheduler);

  static const horizonDays = 7;

  /// iOS keeps at most 64 pending notifications; leave some headroom.
  static const maxReminders = 60;

  final MedicationRepository _medications;
  final IntakeRepository _intakes;
  final ReminderScheduler _scheduler;

  Future<void> call() async {
    final now = clock.now();
    final (from, to) = window(now);
    final medications = await _medications.getMedications();
    final marks = await _intakes.getIntakes(from: from, to: to);
    await _scheduler.replaceAll(
      plan(medications: medications, marks: marks, now: now),
    );
  }

  /// Days covered by reminders, as `[from, to)`.
  static (DateTime, DateTime) window(DateTime now) {
    final from = now.dateOnly;
    return (from, DateTime(from.year, from.month, from.day + horizonDays));
  }

  /// Upcoming unmarked intakes in the window, soonest first.
  static List<Reminder> plan({
    required List<Medication> medications,
    required List<Intake> marks,
    required DateTime now,
  }) {
    final marked = {
      for (final mark in marks) (mark.medicationId, mark.scheduledAt),
    };
    final today = now.dateOnly;
    final reminders = [
      for (var offset = 0; offset < horizonDays; offset++)
        for (final medication in medications)
          for (final scheduledAt in medication.scheduledTimesOn(
            DateTime(today.year, today.month, today.day + offset),
          ))
            if (scheduledAt.isAfter(now) &&
                !marked.contains((medication.id, scheduledAt)))
              Reminder(medication: medication, scheduledAt: scheduledAt),
    ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return reminders.take(maxReminders).toList();
  }
}
