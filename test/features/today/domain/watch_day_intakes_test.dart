import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/today/domain/entities/scheduled_intake.dart';
import 'package:medtrack/features/today/domain/usecases/watch_day_intakes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository;

class _MockIntakeRepository extends Mock implements IntakeRepository;

void main() {
  final day = DateTime(2026, 10, 6);
  final vitaminD = buildMedication(
    name: 'Vitamin D',
    times: const [DoseTime(hour: 20, minute: 0)],
  );
  final aspirin = buildMedication(
    id: 2,
    name: 'aspirin',
    times: const [DoseTime(hour: 8, minute: 0), DoseTime(hour: 20, minute: 0)],
  );
  final notStarted = buildMedication(id: 3, startDate: DateTime(2026, 11));

  group('WatchDayIntakes.buildDayIntakes', () {
    test('sorts by time, then name, and skips inactive medications', () {
      final intakes = WatchDayIntakes.buildDayIntakes(day, [
        vitaminD,
        aspirin,
        notStarted,
      ], const []);

      expect(intakes.map((i) => (i.scheduledAt.hour, i.medication.name)), [
        (8, 'aspirin'),
        (20, 'aspirin'),
        (20, 'Vitamin D'),
      ]);
      expect(intakes.every((i) => i.isPending), isTrue);
    });

    test('attaches marks to matching slots only', () {
      final intakes = WatchDayIntakes.buildDayIntakes(
        day,
        [aspirin],
        [
          Intake(
            medicationId: 2,
            scheduledAt: DateTime(2026, 10, 6, 8),
            status: IntakeStatus.taken,
            recordedAt: DateTime(2026, 10, 6, 8, 5),
          ),
        ],
      );

      expect(intakes.map((i) => i.status), [IntakeStatus.taken, null]);
    });
  });

  group('WatchDayIntakes', () {
    test('queries intakes for the whole day', () async {
      final medications = _MockMedicationRepository();
      final intakeRepository = _MockIntakeRepository();
      when(medications.watchMedications)
          .thenAnswer((_) => Stream.value([aspirin]));
      when(
        () => intakeRepository.watchIntakes(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.value(const []));

      final result = await WatchDayIntakes(medications, intakeRepository)(
        DateTime(2026, 10, 6, 13, 45),
      ).first;

      expect(result, hasLength(2));
      verify(
        () =>
            intakeRepository.watchIntakes(from: day, to: DateTime(2026, 10, 7)),
      ).called(1);
      expect(result.first, isA<ScheduledIntake>());
    });
  });
}
