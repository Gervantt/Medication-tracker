import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';

class WatchDiaryEntries {
  const WatchDiaryEntries(this._repository);

  final WellbeingRepository _repository;

  Stream<List<WellbeingEntry>> call() => _repository.watchAllEntries();
}
