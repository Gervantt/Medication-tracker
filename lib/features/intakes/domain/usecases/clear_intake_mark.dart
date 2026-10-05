import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';

/// Undoes a mark so the intake becomes pending again.
class ClearIntakeMark {
  const ClearIntakeMark(this._repository);

  final IntakeRepository _repository;

  Future<void> call({
    required int medicationId,
    required DateTime scheduledAt,
  }) => _repository.clearIntake(
    medicationId: medicationId,
    scheduledAt: scheduledAt,
  );
}
