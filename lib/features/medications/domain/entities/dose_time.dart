import 'package:equatable/equatable.dart';

/// Time of day of a planned intake. Pure Dart, unlike Flutter's `TimeOfDay`,
/// so the domain layer stays independent of the UI framework.
class DoseTime extends Equatable implements Comparable<DoseTime> {
  const DoseTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24, 'hour must be in 0..23'),
      assert(minute >= 0 && minute < 60, 'minute must be in 0..59');

  factory DoseTime.fromMinutesOfDay(int minutes) =>
      DoseTime(hour: minutes ~/ 60, minute: minutes % 60);

  final int hour;
  final int minute;

  int get minutesOfDay => hour * 60 + minute;

  @override
  int compareTo(DoseTime other) => minutesOfDay.compareTo(other.minutesOfDay);

  @override
  List<Object> get props => [hour, minute];
}
