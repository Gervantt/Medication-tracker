part of 'statistics_cubit.dart';

sealed class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object> get props => [];
}

final class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

final class StatisticsLoaded extends StatisticsState {
  const StatisticsLoaded(this.statistics);

  final Statistics statistics;

  /// The calendar does not go past the current month.
  bool get canShowNextMonth {
    final today = statistics.today;
    return statistics.month.isBefore(DateTime(today.year, today.month));
  }

  @override
  List<Object> get props => [statistics];
}

final class StatisticsError extends StatisticsState {
  const StatisticsError();
}
