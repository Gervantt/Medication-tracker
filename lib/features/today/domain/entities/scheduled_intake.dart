import 'package:equatable/equatable.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';

/// One planned intake of a medication and its mark, if any.
class ScheduledIntake extends Equatable {
  const ScheduledIntake({
    required this.medication,
    required this.scheduledAt,
    this.status,
  });

  final Medication medication;
  final DateTime scheduledAt;

  /// `null` while the intake is not marked yet.
  final IntakeStatus? status;

  bool get isPending => status == null;

  @override
  List<Object?> get props => [medication, scheduledAt, status];
}
