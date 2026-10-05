import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/medications/domain/entities/dosage.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/entities/medication_form.dart';
import 'package:medtrack/features/medications/domain/entities/medication_schedule.dart';
import 'package:medtrack/features/medications/domain/usecases/add_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/delete_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/get_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/update_medication.dart';
import 'package:medtrack/features/medications/presentation/constants/label_colors.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_validator.dart';

part 'medication_form_state.dart';

const Set<int> _allWeekdays = {
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
  DateTime.saturday,
  DateTime.sunday,
};

class MedicationFormCubit extends Cubit<MedicationFormState> {
  MedicationFormCubit({
    required this._getMedication,
    required this._addMedication,
    required this._updateMedication,
    required this._deleteMedication,
  }) : super(MedicationFormState(startDate: clock.now().dateOnly));

  final GetMedication _getMedication;
  final AddMedication _addMedication;
  final UpdateMedication _updateMedication;
  final DeleteMedication _deleteMedication;

  /// Fills the form with an existing medication for editing.
  Future<void> load(int id) async {
    emit(state.copyWith(status: MedicationFormStatus.loading));
    try {
      final medication = await _getMedication(id);
      emit(
        medication == null
            ? state.copyWith(status: MedicationFormStatus.loadFailure)
            : _stateFrom(medication),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: MedicationFormStatus.loadFailure));
    }
  }

  void nameChanged(String name) => emit(state.copyWith(name: name));

  void dosageAmountChanged(String amount) =>
      emit(state.copyWith(dosageAmount: amount));

  void dosageUnitChanged(DosageUnit unit) =>
      emit(state.copyWith(dosageUnit: unit));

  void formChanged(MedicationForm form) => emit(state.copyWith(form: form));

  void timeAdded(DoseTime time) {
    if (state.times.contains(time)) return;
    emit(state.copyWith(times: [...state.times, time]..sort()));
  }

  void timeRemoved(DoseTime time) =>
      emit(state.copyWith(times: [...state.times]..remove(time)));

  void everyDayChanged({required bool everyDay}) =>
      emit(state.copyWith(everyDay: everyDay));

  void weekdayToggled(int weekday) {
    final weekdays = {...state.weekdays};
    if (!weekdays.remove(weekday)) weekdays.add(weekday);
    emit(state.copyWith(weekdays: weekdays));
  }

  void startDateChanged(DateTime date) =>
      emit(state.copyWith(startDate: date.dateOnly));

  void endDateChanged(DateTime? date) =>
      emit(state.copyWith(endDate: () => date?.dateOnly));

  void noteChanged(String note) => emit(state.copyWith(note: note));

  void colorChanged(int colorValue) =>
      emit(state.copyWith(colorValue: colorValue));

  Future<void> submit() async {
    if (!state.errors.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    emit(state.copyWith(status: MedicationFormStatus.saving));
    try {
      final medication = _toMedication();
      if (state.isEditing) {
        await _updateMedication(medication);
      } else {
        await _addMedication(medication);
      }
      emit(state.copyWith(status: MedicationFormStatus.saved));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: MedicationFormStatus.saveFailure));
    }
  }

  Future<void> delete() async {
    final id = state.medicationId;
    if (id == null) return;
    emit(state.copyWith(status: MedicationFormStatus.saving));
    try {
      await _deleteMedication(id);
      emit(state.copyWith(status: MedicationFormStatus.deleted));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: MedicationFormStatus.saveFailure));
    }
  }

  MedicationFormState _stateFrom(Medication medication) {
    final everyDay =
        medication.schedule.weekdays.length == DateTime.daysPerWeek;
    return MedicationFormState(
      medicationId: medication.id,
      name: medication.name,
      dosageAmount: _formatAmount(medication.dosage.amount),
      dosageUnit: medication.dosage.unit,
      form: medication.form,
      times: medication.schedule.times,
      everyDay: everyDay,
      weekdays: everyDay ? const {} : medication.schedule.weekdays,
      startDate: medication.startDate,
      endDate: medication.endDate,
      note: medication.note ?? '',
      colorValue: medication.colorValue,
    );
  }

  /// "200.0" -> "200", "2.5" stays "2.5".
  String _formatAmount(double amount) => amount == amount.truncateToDouble()
      ? amount.toInt().toString()
      : amount.toString();

  /// Call only after validation passed.
  Medication _toMedication() {
    final note = state.note.trim();
    return Medication(
      id: state.medicationId,
      name: state.name.trim(),
      dosage: Dosage(
        amount: MedicationFormValidator.parseDosageAmount(state.dosageAmount)!,
        unit: state.dosageUnit,
      ),
      form: state.form,
      schedule: MedicationSchedule(
        times: state.times,
        weekdays: state.everyDay ? _allWeekdays : state.weekdays,
      ),
      startDate: state.startDate,
      endDate: state.endDate,
      note: note.isEmpty ? null : note,
      colorValue: state.colorValue,
    );
  }
}
