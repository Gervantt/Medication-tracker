part of 'drug_search_bloc.dart';

sealed class DrugSearchEvent {
  const DrugSearchEvent();
}

final class DrugSearchQueryChanged extends DrugSearchEvent {
  const DrugSearchQueryChanged(this.query);

  final String query;
}

final class DrugSearchRetried extends DrugSearchEvent {
  const DrugSearchRetried();
}
