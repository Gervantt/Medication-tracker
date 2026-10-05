import 'dart:async';

import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/features/statistics/domain/entities/statistics.dart';
import 'package:medtrack/features/statistics/domain/usecases/watch_statistics.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(this._watchStatistics) : super(const StatisticsLoading());

  final WatchStatistics _watchStatistics;
  StreamSubscription<Statistics>? _subscription;
  DateTime? _month;

  /// Starts (or restarts after an error) with the current month.
  void subscribe() {
    emit(const StatisticsLoading());
    _watch(clock.now());
  }

  /// Recalculates relative to the current time (e.g. after midnight)
  /// while the previous numbers stay on screen.
  void refresh() => _watch(_month ?? clock.now());

  void previousMonth() => _shiftMonth(-1);

  void nextMonth() {
    final state = this.state;
    if (state is StatisticsLoaded && state.canShowNextMonth) _shiftMonth(1);
  }

  void _shiftMonth(int months) {
    final month = _month;
    if (month == null) return;
    _watch(DateTime(month.year, month.month + months));
  }

  void _watch(DateTime month) {
    _month = DateTime(month.year, month.month);
    unawaited(_subscription?.cancel());
    _subscription = _watchStatistics(now: clock.now(), month: month).listen(
      (statistics) => emit(StatisticsLoaded(statistics)),
      onError: (Object error, StackTrace stackTrace) {
        addError(error, stackTrace);
        emit(const StatisticsError());
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
