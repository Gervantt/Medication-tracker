import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';
import 'package:medtrack/features/diary/domain/usecases/delete_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/get_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/save_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/watch_diary_entries.dart';
import 'package:mocktail/mocktail.dart';

class _MockWellbeingRepository extends Mock implements WellbeingRepository;

void main() {
  late _MockWellbeingRepository repository;
  final day = DateTime(2026, 10, 6);
  final entry = WellbeingEntry(date: day, mood: 4);

  setUpAll(() => registerFallbackValue(entry));

  setUp(() => repository = _MockWellbeingRepository());

  group('Diary use cases', () {
    test('GetWellbeingEntry looks the day up by its midnight', () async {
      when(() => repository.getEntry(day)).thenAnswer((_) async => entry);

      final result = await GetWellbeingEntry(repository)(
        DateTime(2026, 10, 6, 21, 15),
      );

      expect(result, entry);
    });

    test('DeleteWellbeingEntry deletes by the day midnight', () async {
      when(() => repository.deleteEntry(day)).thenAnswer((_) async {});

      await DeleteWellbeingEntry(repository)(DateTime(2026, 10, 6, 7));

      verify(() => repository.deleteEntry(day)).called(1);
    });

    test('SaveWellbeingEntry saves the entry', () async {
      when(() => repository.saveEntry(any())).thenAnswer((_) async {});

      await SaveWellbeingEntry(repository)(entry);

      verify(() => repository.saveEntry(entry)).called(1);
    });

    test('WatchDiaryEntries streams all entries', () {
      when(repository.watchAllEntries).thenAnswer((_) => Stream.value([entry]));

      expect(WatchDiaryEntries(repository)(), emits([entry]));
    });
  });
}
