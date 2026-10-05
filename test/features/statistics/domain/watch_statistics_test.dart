import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/repositories/wellbeing_repository.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/statistics/domain/usecases/watch_statistics.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository;

class _MockIntakeRepository extends Mock implements IntakeRepository;

class _MockWellbeingRepository extends Mock implements WellbeingRepository;

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  test('builds 7/30 day rates, month calendar and mood range', () async {
    final medications = _MockMedicationRepository();
    final intakes = _MockIntakeRepository();
    final wellbeing = _MockWellbeingRepository();
    final mood = WellbeingEntry(date: DateTime(2026, 10, 2), mood: 4);
    when(medications.watchMedications).thenAnswer(
      (_) => Stream.value([buildMedication(startDate: DateTime(2026, 9))]),
    );
    when(
      () => intakes.watchIntakes(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) => Stream.value(const []));
    when(
      () => wellbeing.watchEntries(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) => Stream.value([mood]));

    final statistics = await WatchStatistics(medications, intakes, wellbeing)(
      now: DateTime(2026, 10, 6, 12),
      month: DateTime(2026, 10, 15),
    ).first;

    // One 08:00 intake per day, nothing marked: past days are missed and
    // today's 08:00 intake (already past, but today) is still pending.
    expect(statistics.weekRate.counted, 6);
    expect(statistics.monthRate.counted, 29);
    expect(statistics.weekRate.value, 0);
    expect(statistics.month, DateTime(2026, 10));
    expect(statistics.calendar, hasLength(31));
    expect(statistics.moodEntries, [mood]);
    verify(
      () => intakes.watchIntakes(
        from: DateTime(2026, 9, 7),
        to: DateTime(2026, 11),
      ),
    ).called(1);
    verify(
      () => wellbeing.watchEntries(
        from: DateTime(2026, 9, 7),
        to: DateTime(2026, 10, 7),
      ),
    ).called(1);
  });
}
