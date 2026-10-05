import 'package:equatable/equatable.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';

/// A notification to show at [scheduledAt] for one planned intake.
class Reminder extends Equatable {
  const Reminder({required this.medication, required this.scheduledAt});

  final Medication medication;
  final DateTime scheduledAt;

  @override
  List<Object> get props => [medication, scheduledAt];
}
