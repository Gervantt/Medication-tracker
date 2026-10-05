import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:medtrack/core/database/converters/string_list_converter.dart';
import 'package:medtrack/core/database/daos/intakes_dao.dart';
import 'package:medtrack/core/database/daos/medications_dao.dart';
import 'package:medtrack/core/database/daos/wellbeing_dao.dart';
import 'package:medtrack/core/database/tables/intakes_table.dart';
import 'package:medtrack/core/database/tables/medications_table.dart';
import 'package:medtrack/core/database/tables/schedules_table.dart';
import 'package:medtrack/core/database/tables/wellbeing_entries_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Medications, Schedules, Intakes, WellbeingEntries],
  daos: [MedicationsDao, IntakesDao, WellbeingDao],
)
class AppDatabase extends _$AppDatabase {
  /// Pass an [executor] (e.g. an in-memory database) in tests.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'medtrack'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) async {
      // SQLite ignores foreign keys (and ON DELETE CASCADE) unless enabled
      // for every connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
