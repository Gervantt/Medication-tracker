import 'package:drift/drift.dart';

@DataClassName('MedicationRow')
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  RealColumn get dosageAmount => real()();

  /// Stored by enum name so reordering enum values cannot corrupt data.
  TextColumn get dosageUnit => text()();

  TextColumn get form => text()();

  /// Bitmask of weekdays: bit 0 = Monday ... bit 6 = Sunday.
  // Drift only reads table getters during code generation, so the
  // self-reference inside `check` is not real recursion.
  // ignore: recursive_getters
  IntColumn get weekdays => integer().check(weekdays.isBetweenValues(1, 127))();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime().nullable()();

  TextColumn get note => text().nullable()();

  /// ARGB color value of the label.
  IntColumn get colorValue => integer()();
}
