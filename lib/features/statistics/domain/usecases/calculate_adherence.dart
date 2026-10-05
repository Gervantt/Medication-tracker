import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/statistics/domain/entities/day_adherence.dart';

/// Pure adherence rules:
/// * an unmarked intake of a past day counts as missed;
/// * today's unmarked intakes are pending and do not count yet;
/// * a skipped intake counts as not taken.
///
/// History is derived from the *current* schedules, so editing a schedule
/// also changes how past days are evaluated.
abstract final class CalculateAdherence {
  /// One entry per day in `[from, to)`.
  static List<DayAdherence> byDay({
    required List<Medication> medications,
    required List<Intake> marks,
    required DateTime from,
    required DateTime to,
    required DateTime now,
  }) {
    final statusBySlot = {
      for (final mark in marks)
        (mark.medicationId, mark.scheduledAt): mark.status,
    };
    final today = now.dateOnly;
    return [
      for (
        var day = from.dateOnly;
        day.isBefore(to);
        day = DateTime(day.year, day.month, day.day + 1)
      )
        _dayAdherence(day, today, medications, statusBySlot),
    ];
  }

  static DayAdherence _dayAdherence(
    DateTime day,
    DateTime today,
    List<Medication> medications,
    Map<(int?, DateTime), IntakeStatus> statusBySlot,
  ) {
    var taken = 0;
    var skipped = 0;
    var missed = 0;
    var pending = 0;
    for (final medication in medications) {
      for (final slot in medication.scheduledTimesOn(day)) {
        switch (statusBySlot[(medication.id, slot)]) {
          case IntakeStatus.taken:
            taken++;
          case IntakeStatus.skipped:
            skipped++;
          case null when day.isBefore(today):
            missed++;
          case null:
            pending++;
        }
      }
    }
    return DayAdherence(
      date: day,
      isFuture: day.isAfter(today),
      taken: taken,
      skipped: skipped,
      missed: missed,
      pending: pending,
    );
  }
}
