import 'package:drift/drift.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/database/tables/medications_table.dart';
import 'package:medtrack/core/database/tables/schedules_table.dart';

part 'medications_dao.g.dart';

class MedicationWithSchedules {
  const MedicationWithSchedules({
    required this.medication,
    required this.schedules,
  });

  final MedicationRow medication;
  final List<ScheduleRow> schedules;
}

@DriftAccessor(tables: [Medications, Schedules])
class MedicationsDao extends DatabaseAccessor<AppDatabase>
    with _$MedicationsDaoMixin {
  MedicationsDao(super.attachedDatabase);

  Stream<List<MedicationWithSchedules>> watchAll() =>
      _selectWithSchedules().watch().map(_groupBySchedule);

  Future<List<MedicationWithSchedules>> getAll() =>
      _selectWithSchedules().get().then(_groupBySchedule);

  Future<MedicationWithSchedules?> getById(int id) async {
    final query = _selectWithSchedules()..where(medications.id.equals(id));
    final grouped = _groupBySchedule(await query.get());
    return grouped.isEmpty ? null : grouped.single;
  }

  /// Inserts a medication together with its intake times atomically.
  Future<int> insertWithSchedules(
    MedicationsCompanion medication,
    List<int> minutesOfDay,
  ) {
    return transaction(() async {
      final id = await into(medications).insert(medication);
      await _insertSchedules(id, minutesOfDay);
      return id;
    });
  }

  /// Replaces the medication row and all its intake times atomically.
  Future<void> updateWithSchedules(
    MedicationsCompanion medication,
    List<int> minutesOfDay,
  ) {
    return transaction(() async {
      final id = medication.id.value;
      await update(medications).replace(medication);
      await (delete(schedules)..where((s) => s.medicationId.equals(id))).go();
      await _insertSchedules(id, minutesOfDay);
    });
  }

  /// Schedules and intakes are removed by `ON DELETE CASCADE`.
  Future<int> deleteById(int id) =>
      (delete(medications)..where((m) => m.id.equals(id))).go();

  Future<void> _insertSchedules(int medicationId, List<int> minutesOfDay) {
    return batch((batch) {
      batch.insertAll(
        schedules,
        minutesOfDay.map(
          (minute) => SchedulesCompanion.insert(
            medicationId: medicationId,
            minuteOfDay: minute,
          ),
        ),
      );
    });
  }

  JoinedSelectStatement<HasResultSet, dynamic> _selectWithSchedules() {
    return select(medications).join([
      leftOuterJoin(
        schedules,
        schedules.medicationId.equalsExp(medications.id),
      ),
    ])..orderBy([
      OrderingTerm.asc(medications.name.lower()),
      OrderingTerm.asc(medications.id),
      OrderingTerm.asc(schedules.minuteOfDay),
    ]);
  }

  List<MedicationWithSchedules> _groupBySchedule(List<TypedResult> rows) {
    // Map literals keep insertion order, so the SQL ordering is preserved.
    final grouped = <int, MedicationWithSchedules>{};
    for (final row in rows) {
      final medication = row.readTable(medications);
      final entry = grouped.putIfAbsent(
        medication.id,
        () => MedicationWithSchedules(medication: medication, schedules: []),
      );
      final schedule = row.readTableOrNull(schedules);
      if (schedule != null) entry.schedules.add(schedule);
    }
    return grouped.values.toList();
  }
}
