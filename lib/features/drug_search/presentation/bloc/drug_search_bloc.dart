import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/usecases/search_drugs.dart';
import 'package:rxdart/rxdart.dart';

part 'drug_search_event.dart';
part 'drug_search_state.dart';

/// A Bloc rather than a Cubit: typing produces a stream of events that
/// has to be debounced, and a new query must supersede a running search.
class DrugSearchBloc extends Bloc<DrugSearchEvent, DrugSearchState> {
  DrugSearchBloc(this._searchDrugs, {this.debounce = defaultDebounce})
    : super(const DrugSearchState()) {
    on<DrugSearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounceRestartable(debounce),
    );
    on<DrugSearchRetried>(_onRetried);
  }

  static const defaultDebounce = Duration(milliseconds: 400);

  final SearchDrugs _searchDrugs;
  final Duration debounce;

  /// Waits for a pause in typing, then handles only the latest query;
  /// switchMap drops the handler of a query that was replaced.
  static EventTransformer<E> _debounceRestartable<E>(Duration duration) =>
      (events, mapper) => events.debounceTime(duration).switchMap(mapper);

  Future<void> _onQueryChanged(
    DrugSearchQueryChanged event,
    Emitter<DrugSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.query && state.status != DrugSearchStatus.failure) {
      return;
    }
    if (query.length < SearchDrugs.minQueryLength) {
      emit(DrugSearchState(query: query));
      return;
    }
    await _search(query, emit);
  }

  Future<void> _onRetried(
    DrugSearchRetried event,
    Emitter<DrugSearchState> emit,
  ) async {
    if (state.query.length >= SearchDrugs.minQueryLength) {
      await _search(state.query, emit);
    }
  }

  Future<void> _search(String query, Emitter<DrugSearchState> emit) async {
    emit(state.copyWith(status: DrugSearchStatus.loading, query: query));
    final result = await _searchDrugs(query);
    // A newer query (or a retry of it) has started meanwhile.
    if (state.query != query) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(status: DrugSearchStatus.success, results: value));
      case Err(failure: CancelledFailure()):
        break;
      case Err(:final failure):
        emit(
          state.copyWith(
            status: DrugSearchStatus.failure,
            results: const [],
            failure: failure,
          ),
        );
    }
  }
}
