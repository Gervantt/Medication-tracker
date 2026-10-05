import 'package:drift/drift.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/database/tables/wellbeing_entries_table.dart';

part 'wellbeing_dao.g.dart';

@DriftAccessor(tables: [WellbeingEntries])
class WellbeingDao extends DatabaseAccessor<AppDatabase>
    with _$WellbeingDaoMixin {
  WellbeingDao(super.attachedDatabase);

  /// Entries whose date is in `[from, to)`, oldest first.
  Stream<List<WellbeingEntryRow>> watchInRange(DateTime from, DateTime to) {
    return (select(wellbeingEntries)
          ..where(
            (e) =>
                e.date.isBiggerOrEqualValue(from) &
                e.date.isSmallerThanValue(to),
          )
          ..orderBy([(e) => OrderingTerm.asc(e.date)]))
        .watch();
  }

  Future<WellbeingEntryRow?> getByDate(DateTime date) {
    return (select(
      wellbeingEntries,
    )..where((e) => e.date.equals(date))).getSingleOrNull();
  }

  /// One entry per day: saving again for the same date overwrites it.
  Future<void> upsert(WellbeingEntriesCompanion entry) {
    return into(wellbeingEntries).insert(
      entry,
      onConflict: DoUpdate((_) => entry, target: [wellbeingEntries.date]),
    );
  }

  Future<int> deleteByDate(DateTime date) =>
      (delete(wellbeingEntries)..where((e) => e.date.equals(date))).go();
}
