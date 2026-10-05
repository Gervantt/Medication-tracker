import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';

class GetWellbeingEntry {
  const GetWellbeingEntry(this._repository);

  final WellbeingRepository _repository;

  Future<WellbeingEntry?> call(DateTime date) =>
      _repository.getEntry(date.dateOnly);
}
