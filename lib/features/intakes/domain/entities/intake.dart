import 'package:equatable/equatable.dart';

enum IntakeStatus { taken, skipped }

/// An explicit "taken" / "skipped" mark for one planned intake.
/// A slot is identified by [medicationId] + [scheduledAt].
class Intake extends Equatable {
  const Intake({
    required this.medicationId,
    required this.scheduledAt,
    required this.status,
    required this.recordedAt,
  });

  final int medicationId;
  final DateTime scheduledAt;
  final IntakeStatus status;
  final DateTime recordedAt;

  @override
  List<Object> get props => [medicationId, scheduledAt, status, recordedAt];
}
