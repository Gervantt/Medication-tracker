import 'package:equatable/equatable.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';

enum MedicationFieldError {
  required,
  tooLong,
  invalidNumber,
  noTimes,
  noWeekdays,
  endBeforeStart,
}

class MedicationFormErrors extends Equatable {
  const MedicationFormErrors({
    this.name,
    this.dosageAmount,
    this.times,
    this.weekdays,
    this.endDate,
  });

  final MedicationFieldError? name;
  final MedicationFieldError? dosageAmount;
  final MedicationFieldError? times;
  final MedicationFieldError? weekdays;
  final MedicationFieldError? endDate;

  bool get isValid => props.every((error) => error == null);

  @override
  List<Object?> get props => [name, dosageAmount, times, weekdays, endDate];
}

abstract final class MedicationFormValidator {
  /// Matches the length constraint of the `medications.name` column.
  static const maxNameLength = 100;

  static MedicationFormErrors validate(MedicationFormState state) {
    return MedicationFormErrors(
      name: _validateName(state.name),
      dosageAmount: _validateDosageAmount(state.dosageAmount),
      times: state.times.isEmpty ? MedicationFieldError.noTimes : null,
      weekdays: !state.everyDay && state.weekdays.isEmpty
          ? MedicationFieldError.noWeekdays
          : null,
      endDate: _validateEndDate(state.startDate, state.endDate),
    );
  }

  /// Accepts both "2.5" and the Russian-style "2,5".
  static double? parseDosageAmount(String input) {
    final value = double.tryParse(input.trim().replaceAll(',', '.'));
    return value != null && value.isFinite && value > 0 ? value : null;
  }

  static MedicationFieldError? _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return MedicationFieldError.required;
    if (trimmed.length > maxNameLength) return MedicationFieldError.tooLong;
    return null;
  }

  static MedicationFieldError? _validateDosageAmount(String amount) {
    if (amount.trim().isEmpty) return MedicationFieldError.required;
    if (parseDosageAmount(amount) == null) {
      return MedicationFieldError.invalidNumber;
    }
    return null;
  }

  static MedicationFieldError? _validateEndDate(
    DateTime startDate,
    DateTime? endDate,
  ) {
    if (endDate != null && endDate.isBefore(startDate)) {
      return MedicationFieldError.endBeforeStart;
    }
    return null;
  }
}
