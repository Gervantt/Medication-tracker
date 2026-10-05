import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';

abstract interface class DrugRepository {
  /// Labels whose brand or generic name matches [query]; an empty list
  /// when nothing is found.
  Future<Result<List<DrugLabel>>> searchByName(String query);

  Future<Result<DrugLabel>> getById(String id);
}
