import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';

import '../../../helpers/medication_fixtures.dart';

void main() {
  group('Medication.scheduledTimesOn', () {
    // 5 October 2026 is a Monday.
    final monday = DateTime(2026, 10, 5);
    final tuesday = DateTime(2026, 10, 6);

    test('returns all intake times on an active day', () {
      final medication = buildMedication(
        times: const [
          DoseTime(hour: 8, minute: 0),
          DoseTime(hour: 20, minute: 30),
        ],
        startDate: monday,
      );

      expect(medication.scheduledTimesOn(DateTime(2026, 10, 5, 15)), [
        DateTime(2026, 10, 5, 8),
        DateTime(2026, 10, 5, 20, 30),
      ]);
    });

    test('skips weekdays that are not scheduled', () {
      final medication = buildMedication(
        weekdays: {DateTime.monday},
        startDate: monday,
      );

      expect(medication.scheduledTimesOn(monday), isNotEmpty);
      expect(medication.scheduledTimesOn(tuesday), isEmpty);
    });

    test('respects course start and inclusive end date', () {
      final medication = buildMedication(startDate: tuesday, endDate: tuesday);

      expect(medication.scheduledTimesOn(monday), isEmpty);
      expect(medication.scheduledTimesOn(tuesday), isNotEmpty);
      expect(medication.scheduledTimesOn(DateTime(2026, 10, 7)), isEmpty);
    });
  });
}
