import 'package:drift/drift.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';

extension WellbeingEntryRowMapper on WellbeingEntryRow {
  WellbeingEntry toEntity() =>
      WellbeingEntry(date: date, mood: mood, symptoms: symptoms, note: note);
}

extension WellbeingEntryToCompanion on WellbeingEntry {
  WellbeingEntriesCompanion toCompanion() => WellbeingEntriesCompanion.insert(
    date: date,
    mood: mood,
    symptoms: Value(symptoms),
    note: Value(note),
  );
}
