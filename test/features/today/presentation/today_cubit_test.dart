import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/usecases/clear_intake_mark.dart';
import 'package:medtrack/features/intakes/domain/usecases/mark_intake.dart';
import 'package:medtrack/features/today/domain/entities/scheduled_intake.dart';
import 'package:medtrack/features/today/domain/usecases/watch_day_intakes.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockWatchDayIntakes extends Mock implements WatchDayIntakes;

class _MockMarkIntake extends Mock implements MarkIntake;

class _MockClearIntakeMark extends Mock implements ClearIntakeMark;

void main() {
  late _MockWatchDayIntakes watchDayIntakes;
  late _MockMarkIntake markIntake;
  late _MockClearIntakeMark clearIntakeMark;

  final today = DateTime(2026, 10, 6);
  final intake = ScheduledIntake(
    medication: buildMedication(),
    scheduledAt: DateTime(2026, 10, 6, 8),
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(IntakeStatus.taken);
  });

  setUp(() {
    watchDayIntakes = _MockWatchDayIntakes();
    markIntake = _MockMarkIntake();
    clearIntakeMark = _MockClearIntakeMark();
    when(() => watchDayIntakes(any()))
        .thenAnswer((_) => Stream.value([intake]));
  });

  TodayCubit buildCubit() => TodayCubit(
    watchDayIntakes: watchDayIntakes,
    markIntake: markIntake,
    clearIntakeMark: clearIntakeMark,
  );

  group('TodayCubit', () {
    blocTest<TodayCubit, TodayState>(
      'loads intakes of the current day',
      build: buildCubit,
      act: (cubit) =>
          withClock(Clock.fixed(DateTime(2026, 10, 6, 14)), cubit.subscribe),
      expect: () => [
        const TodayLoading(),
        TodayLoaded(day: today, intakes: [intake]),
      ],
      verify: (_) => verify(() => watchDayIntakes(today)).called(1),
    );

    blocTest<TodayCubit, TodayState>(
      'emits error when the stream fails',
      setUp: () =>
          when(() => watchDayIntakes(any()))
              .thenAnswer((_) => Stream.error(Exception('db'))),
      build: buildCubit,
      act: (cubit) => cubit.subscribe(),
      expect: () => [const TodayLoading(), const TodayError()],
      errors: () => [isA<Exception>()],
    );

    blocTest<TodayCubit, TodayState>(
      'refresh on the same day reloads silently',
      build: buildCubit,
      act: (cubit) async {
        withClock(Clock.fixed(DateTime(2026, 10, 6, 9)), cubit.subscribe);
        await Future<void>.delayed(Duration.zero);
        withClock(Clock.fixed(DateTime(2026, 10, 6, 21)), cubit.refresh);
      },
      expect: () => [
        const TodayLoading(),
        TodayLoaded(day: today, intakes: [intake]),
      ],
      verify: (_) => verify(() => watchDayIntakes(today)).called(2),
    );

    blocTest<TodayCubit, TodayState>(
      'refresh after midnight shows loading and switches the day',
      build: buildCubit,
      act: (cubit) async {
        withClock(Clock.fixed(DateTime(2026, 10, 6, 23)), cubit.subscribe);
        await Future<void>.delayed(Duration.zero);
        withClock(Clock.fixed(DateTime(2026, 10, 7, 7)), cubit.refresh);
      },
      expect: () => [
        const TodayLoading(),
        TodayLoaded(day: today, intakes: [intake]),
        const TodayLoading(),
        TodayLoaded(day: DateTime(2026, 10, 7), intakes: [intake]),
      ],
    );

    blocTest<TodayCubit, TodayState>(
      'marks an intake as taken and skipped, and undoes a mark',
      setUp: () {
        when(
          () => markIntake(
            medicationId: any(named: 'medicationId'),
            scheduledAt: any(named: 'scheduledAt'),
            status: any(named: 'status'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => clearIntakeMark(
            medicationId: any(named: 'medicationId'),
            scheduledAt: any(named: 'scheduledAt'),
          ),
        ).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.markTaken(intake);
        await cubit.markSkipped(intake);
        await cubit.undo(intake);
      },
      verify: (_) {
        for (final status in IntakeStatus.values) {
          verify(
            () => markIntake(
              medicationId: 1,
              scheduledAt: intake.scheduledAt,
              status: status,
            ),
          ).called(1);
        }
        verify(
          () =>
              clearIntakeMark(medicationId: 1, scheduledAt: intake.scheduledAt),
        ).called(1);
      },
    );
  });
}
