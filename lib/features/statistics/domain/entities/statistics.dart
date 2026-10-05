import 'package:equatable/equatable.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/statistics/domain/entities/adherence_rate.dart';
import 'package:medtrack/features/statistics/domain/entities/day_adherence.dart';

class Statistics extends Equatable {
  const Statistics({
    required this.today,
    required this.month,
    required this.weekRate,
    required this.monthRate,
    required this.calendar,
    required this.moodEntries,
  });

  final DateTime today;

  /// First day of the month shown in the calendar.
  final DateTime month;

  /// Last 7 and 30 days, including today.
  final AdherenceRate weekRate;
  final AdherenceRate monthRate;

  /// Every day of [month], in order.
  final List<DayAdherence> calendar;

  /// Diary entries of the last 30 days, oldest first.
  final List<WellbeingEntry> moodEntries;

  bool get hasData =>
      monthRate.counted > 0 ||
      calendar.any((day) => day.planned > 0) ||
      moodEntries.isNotEmpty;

  @override
  List<Object> get props => [
    today,
    month,
    weekRate,
    monthRate,
    calendar,
    moodEntries,
  ];
}
