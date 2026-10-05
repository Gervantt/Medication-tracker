import 'package:equatable/equatable.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';

class MedicationSchedule extends Equatable {
  const MedicationSchedule({required this.times, required this.weekdays});

  /// Daily intake times, sorted ascending.
  final List<DoseTime> times;

  /// Active weekdays as [DateTime.monday]..[DateTime.sunday].
  /// All seven days means "every day".
  final Set<int> weekdays;

  @override
  List<Object> get props => [times, weekdays];
}
