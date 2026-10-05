import 'package:clock/clock.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';

/// Marks a planned intake as taken or skipped (overwriting a previous mark).
class MarkIntake {
  const MarkIntake(this._repository);

  final IntakeRepository _repository;

  Future<void> call({
    required int medicationId,
    required DateTime scheduledAt,
    required IntakeStatus status,
  }) {
    return _repository.saveIntake(
      Intake(
        medicationId: medicationId,
        scheduledAt: scheduledAt,
        status: status,
        recordedAt: clock.now(),
      ),
    );
  }
}
