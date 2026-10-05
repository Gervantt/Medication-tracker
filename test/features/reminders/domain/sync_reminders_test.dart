import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/reminders/domain/entities/reminder.dart';
import 'package:medtrack/features/reminders/domain/repositories/reminder_scheduler.dart';
import 'package:medtrack/features/reminders/domain/usecases/sync_reminders.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository;

class _MockIntakeRepository extends Mock implements IntakeRepository;

class _MockReminderScheduler extends Mock implements ReminderScheduler;

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  final now = DateTime(2026, 10, 6, 12);
  final twiceADay = buildMedication(
    times: const [DoseTime(hour: 8, minute: 0), DoseTime(hour: 20, minute: 0)],
  );

  group('SyncReminders.plan', () {
    test('skips past intakes and covers the whole window', () {
      final reminders = SyncReminders.plan(
        medications: [twiceADay],
        marks: const [],
        now: now,
      );

      expect(reminders.first.scheduledAt, DateTime(2026, 10, 6, 20));
      expect(reminders.last.scheduledAt, DateTime(2026, 10, 12, 20));
      // 1 left today + 2 per day for the next 6 days.
      expect(reminders, hasLength(13));
    });

    test('does not remind about intakes that are already marked', () {
      final reminders = SyncReminders.plan(
        medications: [twiceADay],
        marks: [
          Intake(
            medicationId: 1,
            scheduledAt: DateTime(2026, 10, 6, 20),
            status: IntakeStatus.taken,
            recordedAt: now,
          ),
        ],
        now: now,
      );

      expect(reminders.first.scheduledAt, DateTime(2026, 10, 7, 8));
    });

    test('stops at the course end date', () {
      final reminders = SyncReminders.plan(
        medications: [buildMedication(endDate: DateTime(2026, 10, 7))],
        marks: const [],
        now: now,
      );

      expect(reminders.map((r) => r.scheduledAt), [DateTime(2026, 10, 7, 8)]);
    });

    test('caps the number of reminders for the iOS limit', () {
      final manyTimes = buildMedication(
        times: [for (var h = 0; h < 24; h++) DoseTime(hour: h, minute: 30)],
      );

      final reminders = SyncReminders.plan(
        medications: [manyTimes],
        marks: const [],
        now: now,
      );

      expect(reminders, hasLength(SyncReminders.maxReminders));
      expect(reminders.first.scheduledAt, DateTime(2026, 10, 6, 12, 30));
    });
  });

  group('SyncReminders', () {
    test('replaces scheduled reminders with a fresh plan', () async {
      final medications = _MockMedicationRepository();
      final intakes = _MockIntakeRepository();
      final scheduler = _MockReminderScheduler();
      when(medications.getMedications).thenAnswer((_) async => [twiceADay]);
      when(
        () => intakes.getIntakes(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => const []);
      when(() => scheduler.replaceAll(any())).thenAnswer((_) async {});

      await withClock(
        Clock.fixed(now),
        () => SyncReminders(medications, intakes, scheduler)(),
      );

      final scheduled =
          verify(() => scheduler.replaceAll(captureAny())).captured.single
              as List<Reminder>;
      expect(scheduled, hasLength(13));
      verify(
        () => intakes.getIntakes(
          from: DateTime(2026, 10, 6),
          to: DateTime(2026, 10, 13),
        ),
      ).called(1);
    });
  });
}
