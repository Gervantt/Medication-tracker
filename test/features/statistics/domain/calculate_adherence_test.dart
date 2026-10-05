import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/statistics/domain/entities/adherence_rate.dart';
import 'package:medtrack/features/statistics/domain/entities/day_adherence.dart';
import 'package:medtrack/features/statistics/domain/usecases/calculate_adherence.dart';

import '../../../helpers/medication_fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 6, 12);
  final twiceADay = buildMedication(
    times: const [DoseTime(hour: 8, minute: 0), DoseTime(hour: 20, minute: 0)],
  );

  Intake mark(DateTime at, IntakeStatus status) =>
      Intake(medicationId: 1, scheduledAt: at, status: status, recordedAt: at);

  List<DayAdherence> calculate(List<Intake> marks, {int days = 1}) {
    return CalculateAdherence.byDay(
      medications: [twiceADay],
      marks: marks,
      from: DateTime(2026, 10, 5),
      to: DateTime(2026, 10, 5 + days),
      now: now,
    );
  }

  group('CalculateAdherence', () {
    test('counts unmarked intakes of past days as missed', () {
      final yesterday = calculate([
        mark(DateTime(2026, 10, 5, 8), IntakeStatus.taken),
      ]).single;

      expect(yesterday.taken, 1);
      expect(yesterday.missed, 1);
      expect(yesterday.status, DayStatus.partial);
    });

    test('keeps unmarked intakes of today pending', () {
      final days = calculate([
        mark(DateTime(2026, 10, 6, 8), IntakeStatus.taken),
      ], days: 2);

      final today = days.last;
      expect(today.taken, 1);
      expect(today.pending, 1);
      expect(today.counted, 1);
      expect(today.status, DayStatus.inProgress);
    });

    test('derives day statuses', () {
      final allTaken = calculate([
        mark(DateTime(2026, 10, 5, 8), IntakeStatus.taken),
        mark(DateTime(2026, 10, 5, 20), IntakeStatus.taken),
      ]).single;
      final skipped = calculate([
        mark(DateTime(2026, 10, 5, 8), IntakeStatus.skipped),
      ]).single;
      final future = CalculateAdherence.byDay(
        medications: [twiceADay],
        marks: const [],
        from: DateTime(2026, 10, 7),
        to: DateTime(2026, 10, 8),
        now: now,
      ).single;

      expect(allTaken.status, DayStatus.allTaken);
      expect(skipped.status, DayStatus.missed);
      expect(future.status, DayStatus.upcoming);
    });

    test('reports no intakes before the course started', () {
      final days = CalculateAdherence.byDay(
        medications: [buildMedication(startDate: DateTime(2026, 10, 6))],
        marks: const [],
        from: DateTime(2026, 10, 5),
        to: DateTime(2026, 10, 6),
        now: now,
      );

      expect(days.single.status, DayStatus.noIntakes);
    });
  });

  group('AdherenceRate', () {
    test('is taken over counted, or null without data', () {
      final days = calculate([
        mark(DateTime(2026, 10, 5, 8), IntakeStatus.taken),
        mark(DateTime(2026, 10, 6, 8), IntakeStatus.taken),
      ], days: 2);

      expect(AdherenceRate.of(days).value, closeTo(2 / 3, 1e-9));
      expect(AdherenceRate.of(const []).value, isNull);
    });
  });
}
