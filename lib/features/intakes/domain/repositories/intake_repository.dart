import 'package:medtrack/features/intakes/domain/entities/intake.dart';

abstract interface class IntakeRepository {
  /// Intakes scheduled in `[from, to)`.
  Stream<List<Intake>> watchIntakes({
    required DateTime from,
    required DateTime to,
  });

  Future<List<Intake>> getIntakes({
    required DateTime from,
    required DateTime to,
  });

  /// Creates the mark or replaces the existing one for the same slot.
  Future<void> saveIntake(Intake intake);

  /// Removes the mark, returning the slot to "not marked".
  Future<void> clearIntake({
    required int medicationId,
    required DateTime scheduledAt,
  });
}
