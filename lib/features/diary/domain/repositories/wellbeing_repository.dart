import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';

abstract interface class WellbeingRepository {
  /// Entries whose date is in `[from, to)`, oldest first.
  Stream<List<WellbeingEntry>> watchEntries({
    required DateTime from,
    required DateTime to,
  });

  /// All entries, newest first.
  Stream<List<WellbeingEntry>> watchAllEntries();

  Future<WellbeingEntry?> getEntry(DateTime date);

  /// Creates the entry or replaces the existing one for the same day.
  Future<void> saveEntry(WellbeingEntry entry);

  Future<void> deleteEntry(DateTime date);
}
