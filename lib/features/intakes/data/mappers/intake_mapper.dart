import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';

extension IntakeRowMapper on IntakeRow {
  Intake toEntity() => Intake(
    medicationId: medicationId,
    scheduledAt: scheduledAt,
    status: IntakeStatus.values.byName(status),
    recordedAt: recordedAt,
  );
}

extension IntakeToCompanion on Intake {
  IntakesCompanion toCompanion() => IntakesCompanion.insert(
    medicationId: medicationId,
    scheduledAt: scheduledAt,
    status: status.name,
    recordedAt: recordedAt,
  );
}
