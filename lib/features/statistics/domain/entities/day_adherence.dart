import 'package:equatable/equatable.dart';

enum DayStatus {
  /// Nothing was planned on this day.
  noIntakes,

  /// The day is in the future.
  upcoming,

  /// Today, with intakes that are not marked yet.
  inProgress,
  allTaken,
  partial,

  /// Intakes were planned, none was taken.
  missed,
}

/// How planned intakes of one day were followed.
class DayAdherence extends Equatable {
  const DayAdherence({
    required this.date,
    required this.isFuture,
    this.taken = 0,
    this.skipped = 0,
    this.missed = 0,
    this.pending = 0,
  });

  final DateTime date;
  final bool isFuture;
  final int taken;
  final int skipped;

  /// Not marked on a past day.
  final int missed;

  /// Not marked yet today (or on a future day).
  final int pending;

  int get planned => taken + skipped + missed + pending;

  /// Intakes that count towards the adherence rate.
  int get counted => taken + skipped + missed;

  DayStatus get status {
    if (planned == 0) return DayStatus.noIntakes;
    if (isFuture) return DayStatus.upcoming;
    if (pending > 0) return DayStatus.inProgress;
    if (taken == planned) return DayStatus.allTaken;
    if (taken == 0) return DayStatus.missed;
    return DayStatus.partial;
  }

  @override
  List<Object> get props => [date, isFuture, taken, skipped, missed, pending];
}
