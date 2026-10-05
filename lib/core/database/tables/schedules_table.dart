import 'package:drift/drift.dart';
import 'package:medtrack/core/database/tables/medications_table.dart';

/// One row per daily intake time of a medication.
@DataClassName('ScheduleRow')
class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get medicationId =>
      integer().references(Medications, #id, onDelete: KeyAction.cascade)();

  /// Time of day as minutes since midnight (0..1439).
  IntColumn get minuteOfDay =>
      // Drift only reads table getters during code generation, so the
      // self-reference inside `check` is not real recursion.
      // ignore: recursive_getters
      integer().check(minuteOfDay.isBetweenValues(0, 1439))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {medicationId, minuteOfDay},
  ];
}
