import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/statistics/domain/entities/adherence_rate.dart';
import 'package:medtrack/features/statistics/domain/entities/statistics.dart';
import 'package:medtrack/features/statistics/domain/usecases/calculate_adherence.dart';
import 'package:rxdart/rxdart.dart';

/// Emits statistics for the last 30 days and the calendar [call]'s month,
/// recalculated whenever medications, marks or diary entries change.
class WatchStatistics {
  const WatchStatistics(this._medications, this._intakes, this._wellbeing);

  static const weekDays = 7;
  static const monthDays = 30;

  final MedicationRepository _medications;
  final IntakeRepository _intakes;
  final WellbeingRepository _wellbeing;

  Stream<Statistics> call({required DateTime now, required DateTime month}) {
    final today = now.dateOnly;
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final last30From = DateTime(
      today.year,
      today.month,
      today.day - monthDays + 1,
    );
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1);
    // One query range that covers both the last 30 days and the month.
    final from = monthStart.isBefore(last30From) ? monthStart : last30From;
    final to = monthEnd.isAfter(tomorrow) ? monthEnd : tomorrow;

    return Rx.combineLatest3(
      _medications.watchMedications(),
      _intakes.watchIntakes(from: from, to: to),
      _wellbeing.watchEntries(from: last30From, to: tomorrow),
      (medications, marks, entries) {
        final days = CalculateAdherence.byDay(
          medications: medications,
          marks: marks,
          from: from,
          to: to,
          now: now,
        );
        bool inRange(DateTime day, DateTime start, DateTime end) =>
            !day.isBefore(start) && day.isBefore(end);
        final last30 = days.where((d) => inRange(d.date, last30From, tomorrow));
        final last7From = DateTime(
          today.year,
          today.month,
          today.day - weekDays + 1,
        );
        return Statistics(
          today: today,
          month: monthStart,
          weekRate: AdherenceRate.of(
            last30.where((d) => !d.date.isBefore(last7From)),
          ),
          monthRate: AdherenceRate.of(last30),
          calendar: [
            for (final day in days)
              if (inRange(day.date, monthStart, monthEnd)) day,
          ],
          moodEntries: entries,
        );
      },
    );
  }
}
