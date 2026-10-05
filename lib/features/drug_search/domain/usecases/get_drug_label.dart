import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/repositories/drug_repository.dart';

class GetDrugLabel {
  const GetDrugLabel(this._repository);

  final DrugRepository _repository;

  Future<Result<DrugLabel>> call(String id) => _repository.getById(id);
}
