import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/watch_diary_entries.dart';
import 'package:medtrack/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchDiaryEntries extends Mock implements WatchDiaryEntries;

void main() {
  late _MockWatchDiaryEntries watchDiaryEntries;
  final entry = WellbeingEntry(date: DateTime(2026, 10, 6), mood: 4);

  setUp(() => watchDiaryEntries = _MockWatchDiaryEntries());

  group('DiaryCubit', () {
    blocTest<DiaryCubit, DiaryState>(
      'emits entries from the stream',
      setUp: () =>
          when(watchDiaryEntries.call).thenAnswer((_) => Stream.value([entry])),
      build: () => DiaryCubit(watchDiaryEntries),
      act: (cubit) => cubit.subscribe(),
      expect: () => [
        const DiaryLoading(),
        DiaryLoaded([entry]),
      ],
    );

    blocTest<DiaryCubit, DiaryState>(
      'emits error when the stream fails',
      setUp: () =>
          when(watchDiaryEntries.call)
              .thenAnswer((_) => Stream.error(Exception('db'))),
      build: () => DiaryCubit(watchDiaryEntries),
      act: (cubit) => cubit.subscribe(),
      expect: () => [const DiaryLoading(), const DiaryError()],
      errors: () => [isA<Exception>()],
    );
  });
}
