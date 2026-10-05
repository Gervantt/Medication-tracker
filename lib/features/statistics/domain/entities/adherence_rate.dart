import 'package:equatable/equatable.dart';
import 'package:medtrack/features/statistics/domain/entities/day_adherence.dart';

/// Share of counted intakes that were taken.
class AdherenceRate extends Equatable {
  const AdherenceRate({required this.taken, required this.counted});

  factory AdherenceRate.of(Iterable<DayAdherence> days) => AdherenceRate(
    taken: days.fold(0, (sum, day) => sum + day.taken),
    counted: days.fold(0, (sum, day) => sum + day.counted),
  );

  final int taken;
  final int counted;

  /// 0..1, or `null` when there is nothing to measure yet.
  double? get value => counted == 0 ? null : taken / counted;

  @override
  List<Object> get props => [taken, counted];
}
