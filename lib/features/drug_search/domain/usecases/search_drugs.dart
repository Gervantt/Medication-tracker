import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/repositories/drug_repository.dart';

class SearchDrugs {
  const SearchDrugs(this._repository);

  /// Shorter queries match too much and waste the API rate limit.
  static const minQueryLength = 2;

  final DrugRepository _repository;

  Future<Result<List<DrugLabel>>> call(String query) =>
      _repository.searchByName(query.trim());
}
