import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/features/diary/data/repositories/wellbeing_repository_impl.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';

void main() {
  late AppDatabase database;
  late WellbeingRepositoryImpl repository;

  final day = DateTime(2026, 10, 5);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = WellbeingRepositoryImpl(database.wellbeingDao);
  });

  tearDown(() => database.close());

  group('WellbeingRepositoryImpl', () {
    test('stores symptoms list and overwrites entry for same day', () async {
      await repository.saveEntry(
        WellbeingEntry(date: day, mood: 2, symptoms: const ['headache']),
      );
      final updated = WellbeingEntry(
        date: day,
        mood: 4,
        symptoms: const ['nausea', 'Dizziness'],
        note: 'Better after lunch',
      );

      await repository.saveEntry(updated);

      expect(await repository.getEntry(day), updated);
    });

    test('watchEntries returns entries in range sorted by date', () async {
      final yesterday = DateTime(2026, 10, 4);
      await repository.saveEntry(WellbeingEntry(date: day, mood: 3));
      await repository.saveEntry(WellbeingEntry(date: yesterday, mood: 5));

      final entries = await repository
          .watchEntries(from: yesterday, to: DateTime(2026, 10, 6))
          .first;

      expect(entries.map((e) => e.date), [yesterday, day]);
    });
  });
}
