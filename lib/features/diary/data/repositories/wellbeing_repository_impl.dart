import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/database/daos/wellbeing_dao.dart';
import 'package:medtrack/features/diary/data/mappers/wellbeing_entry_mapper.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';

class WellbeingRepositoryImpl implements WellbeingRepository {
  const WellbeingRepositoryImpl(this._dao);

  final WellbeingDao _dao;

  @override
  Stream<List<WellbeingEntry>> watchEntries({
    required DateTime from,
    required DateTime to,
  }) => _dao.watchInRange(from, to).map(_toEntities);

  @override
  Stream<List<WellbeingEntry>> watchAllEntries() =>
      _dao.watchAll().map(_toEntities);

  @override
  Future<WellbeingEntry?> getEntry(DateTime date) async =>
      (await _dao.getByDate(date))?.toEntity();

  @override
  Future<void> saveEntry(WellbeingEntry entry) =>
      _dao.upsert(entry.toCompanion());

  @override
  Future<void> deleteEntry(DateTime date) => _dao.deleteByDate(date);

  List<WellbeingEntry> _toEntities(List<WellbeingEntryRow> rows) => [
    for (final row in rows) row.toEntity(),
  ];
}
