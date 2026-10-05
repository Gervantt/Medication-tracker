import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/database/daos/intakes_dao.dart';
import 'package:medtrack/features/intakes/data/mappers/intake_mapper.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';

class IntakeRepositoryImpl implements IntakeRepository {
  const IntakeRepositoryImpl(this._dao);

  final IntakesDao _dao;

  @override
  Stream<List<Intake>> watchIntakes({
    required DateTime from,
    required DateTime to,
  }) => _dao.watchInRange(from, to).map(_toEntities);

  @override
  Future<List<Intake>> getIntakes({
    required DateTime from,
    required DateTime to,
  }) => _dao.getInRange(from, to).then(_toEntities);

  @override
  Future<void> saveIntake(Intake intake) => _dao.upsert(intake.toCompanion());

  @override
  Future<void> clearIntake({
    required int medicationId,
    required DateTime scheduledAt,
  }) => _dao.deleteSlot(medicationId, scheduledAt);

  List<Intake> _toEntities(List<IntakeRow> rows) => [
    for (final row in rows) row.toEntity(),
  ];
}
