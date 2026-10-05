import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';

class DeleteWellbeingEntry {
  const DeleteWellbeingEntry(this._repository);

  final WellbeingRepository _repository;

  Future<void> call(DateTime date) => _repository.deleteEntry(date.dateOnly);
}
