import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/statistics/domain/entities/adherence_rate.dart';
import 'package:medtrack/features/statistics/domain/entities/statistics.dart';
import 'package:medtrack/features/statistics/domain/usecases/watch_statistics.dart';
import 'package:medtrack/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchStatistics extends Mock implements WatchStatistics;

void main() {
  late _MockWatchStatistics watchStatistics;
  final now = DateTime(2026, 10, 6, 12);

  Statistics statisticsFor(DateTime month) => Statistics(
    today: DateTime(2026, 10, 6),
    month: DateTime(month.year, month.month),
    weekRate: const AdherenceRate(taken: 0, counted: 0),
    monthRate: const AdherenceRate(taken: 0, counted: 0),
    calendar: const [],
    moodEntries: const [],
  );

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  setUp(() {
    watchStatistics = _MockWatchStatistics();
    when(
      () => watchStatistics(
        now: any(named: 'now'),
        month: any(named: 'month'),
      ),
    ).thenAnswer(
      (invocation) => Stream.value(
        statisticsFor(invocation.namedArguments[#month] as DateTime),
      ),
    );
  });

  group('StatisticsCubit', () {
    blocTest<StatisticsCubit, StatisticsState>(
      'starts with the current month and cannot go past it',
      build: () => StatisticsCubit(watchStatistics),
      act: (cubit) async {
        withClock(Clock.fixed(now), cubit.subscribe);
        await Future<void>.delayed(Duration.zero);
        cubit.nextMonth();
      },
      expect: () => [
        const StatisticsLoading(),
        StatisticsLoaded(statisticsFor(DateTime(2026, 10))),
      ],
      verify: (cubit) =>
          expect((cubit.state as StatisticsLoaded).canShowNextMonth, isFalse),
    );

    blocTest<StatisticsCubit, StatisticsState>(
      'navigates to the previous month and back',
      build: () => StatisticsCubit(watchStatistics),
      act: (cubit) => withClock(Clock.fixed(now), () async {
        cubit.subscribe();
        await Future<void>.delayed(Duration.zero);
        cubit.previousMonth();
        await Future<void>.delayed(Duration.zero);
        cubit.nextMonth();
      }),
      skip: 1,
      expect: () => [
        StatisticsLoaded(statisticsFor(DateTime(2026, 10))),
        StatisticsLoaded(statisticsFor(DateTime(2026, 9))),
        StatisticsLoaded(statisticsFor(DateTime(2026, 10))),
      ],
    );
  });
}
