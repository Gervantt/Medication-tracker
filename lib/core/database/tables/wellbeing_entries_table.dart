import 'package:drift/drift.dart';
import 'package:medtrack/core/database/converters/string_list_converter.dart';

@DataClassName('WellbeingEntryRow')
class WellbeingEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Local midnight of the day; one entry per day.
  DateTimeColumn get date => dateTime().unique()();

  // Drift only reads table getters during code generation, so the
  // self-reference inside `check` is not real recursion.
  // ignore: recursive_getters
  IntColumn get mood => integer().check(mood.isBetweenValues(1, 5))();

  TextColumn get symptoms => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  TextColumn get note => text().nullable()();
}
