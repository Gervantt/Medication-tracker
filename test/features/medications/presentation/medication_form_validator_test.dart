import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_validator.dart';

void main() {
  final validState = MedicationFormState(
    startDate: DateTime(2026, 10, 6),
    name: 'Ibuprofen',
    dosageAmount: '200',
  );

  group('MedicationFormValidator', () {
    test('accepts a valid form', () {
      expect(MedicationFormValidator.validate(validState).isValid, isTrue);
    });

    test('requires a non-blank name', () {
      final errors = MedicationFormValidator.validate(
        validState.copyWith(name: '   '),
      );
      expect(errors.name, MedicationFieldError.required);
    });

    test('rejects names longer than the database limit', () {
      final errors = MedicationFormValidator.validate(
        validState.copyWith(name: 'a' * 101),
      );
      expect(errors.name, MedicationFieldError.tooLong);
    });

    test('rejects zero, negative and non-numeric dosage', () {
      for (final amount in ['0', '-1', 'abc', '1e400']) {
        final errors = MedicationFormValidator.validate(
          validState.copyWith(dosageAmount: amount),
        );
        expect(errors.dosageAmount, MedicationFieldError.invalidNumber);
      }
    });

    test('parses decimal comma and dot', () {
      expect(MedicationFormValidator.parseDosageAmount('2,5'), 2.5);
      expect(MedicationFormValidator.parseDosageAmount(' 2.5 '), 2.5);
    });

    test('requires at least one intake time', () {
      final errors = MedicationFormValidator.validate(
        validState.copyWith(times: []),
      );
      expect(errors.times, MedicationFieldError.noTimes);
    });

    test('requires weekdays only when not every day', () {
      final specificDays = validState.copyWith(everyDay: false);
      expect(
        MedicationFormValidator.validate(specificDays).weekdays,
        MedicationFieldError.noWeekdays,
      );
      expect(
        MedicationFormValidator.validate(
          specificDays.copyWith(weekdays: {DateTime.monday}),
        ).isValid,
        isTrue,
      );
    });

    test('rejects end date before start date, allows same day', () {
      expect(
        MedicationFormValidator.validate(
          validState.copyWith(endDate: () => DateTime(2026, 10, 5)),
        ).endDate,
        MedicationFieldError.endBeforeStart,
      );
      expect(
        MedicationFormValidator.validate(
          validState.copyWith(endDate: () => DateTime(2026, 10, 6)),
        ).isValid,
        isTrue,
      );
    });
  });
}
