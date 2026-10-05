part of 'drug_search_bloc.dart';

enum DrugSearchStatus { initial, loading, success, failure }

class DrugSearchState extends Equatable {
  const DrugSearchState({
    this.status = DrugSearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.failure,
  });

  final DrugSearchStatus status;

  /// Trimmed query of the latest search.
  final String query;
  final List<DrugLabel> results;
  final Failure? failure;

  DrugSearchState copyWith({
    DrugSearchStatus? status,
    String? query,
    List<DrugLabel>? results,
    Failure? failure,
  }) {
    return DrugSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, query, results, failure];
}
