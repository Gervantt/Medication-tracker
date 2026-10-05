import 'package:drift/drift.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/database/tables/intakes_table.dart';

part 'intakes_dao.g.dart';

@DriftAccessor(tables: [Intakes])
class IntakesDao extends DatabaseAccessor<AppDatabase> with _$IntakesDaoMixin {
  IntakesDao(super.attachedDatabase);

  /// Intakes scheduled in `[from, to)`.
  Stream<List<IntakeRow>> watchInRange(DateTime from, DateTime to) =>
      _selectInRange(from, to).watch();

  Future<List<IntakeRow>> getInRange(DateTime from, DateTime to) =>
      _selectInRange(from, to).get();

  /// Inserts the intake or overwrites the existing mark for the same slot,
  /// so the user can change "skipped" to "taken".
  Future<void> upsert(IntakesCompanion intake) {
    return into(intakes).insert(
      intake,
      onConflict: DoUpdate(
        (_) => intake,
        target: [intakes.medicationId, intakes.scheduledAt],
      ),
    );
  }

  Future<int> deleteSlot(int medicationId, DateTime scheduledAt) {
    return (delete(intakes)..where(
          (i) =>
              i.medicationId.equals(medicationId) &
              i.scheduledAt.equals(scheduledAt),
        ))
        .go();
  }

  SimpleSelectStatement<$IntakesTable, IntakeRow> _selectInRange(
    DateTime from,
    DateTime to,
  ) {
    return select(intakes)
      ..where(
        (i) =>
            i.scheduledAt.isBiggerOrEqualValue(from) &
            i.scheduledAt.isSmallerThanValue(to),
      )
      ..orderBy([(i) => OrderingTerm.asc(i.scheduledAt)]);
  }
}
