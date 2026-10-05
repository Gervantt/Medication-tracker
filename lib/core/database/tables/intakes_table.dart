import 'package:drift/drift.dart';
import 'package:medtrack/core/database/tables/medications_table.dart';

/// Log of explicitly marked intakes. A planned intake without a row here
/// is "not marked yet" (or missed, once its day is in the past).
@DataClassName('IntakeRow')
@TableIndex(name: 'intakes_scheduled_at', columns: {#scheduledAt})
class Intakes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get medicationId =>
      integer().references(Medications, #id, onDelete: KeyAction.cascade)();

  /// Planned local date and time of the intake.
  DateTimeColumn get scheduledAt => dateTime()();

  /// `taken` or `skipped`, stored by enum name.
  TextColumn get status => text()();

  /// When the user actually marked the intake.
  DateTimeColumn get recordedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {medicationId, scheduledAt},
  ];
}
