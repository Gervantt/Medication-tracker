import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';

/// Creates the day's entry or replaces it: there is one entry per day.
class SaveWellbeingEntry {
  const SaveWellbeingEntry(this._repository);

  final WellbeingRepository _repository;

  Future<void> call(WellbeingEntry entry) => _repository.saveEntry(entry);
}
