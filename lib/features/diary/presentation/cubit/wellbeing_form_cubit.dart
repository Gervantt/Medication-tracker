import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/delete_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/get_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/save_wellbeing_entry.dart';

part 'wellbeing_form_state.dart';

class WellbeingFormCubit extends Cubit<WellbeingFormState> {
  WellbeingFormCubit({
    required DateTime date,
    required this._getEntry,
    required this._saveEntry,
    required this._deleteEntry,
  }) : super(WellbeingFormState(date: date.dateOnly));

  static const maxCustomSymptomLength = 40;

  final GetWellbeingEntry _getEntry;
  final SaveWellbeingEntry _saveEntry;
  final DeleteWellbeingEntry _deleteEntry;

  /// Loads the saved entry of the day, or starts an empty one.
  Future<void> load() async {
    emit(state.copyWith(status: WellbeingFormStatus.loading));
    try {
      final entry = await _getEntry(state.date);
      emit(
        entry == null
            ? state.copyWith(status: WellbeingFormStatus.editing)
            : WellbeingFormState(
                date: state.date,
                status: WellbeingFormStatus.editing,
                mood: entry.mood,
                symptoms: entry.symptoms,
                note: entry.note ?? '',
                isExisting: true,
              ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: WellbeingFormStatus.loadFailure));
    }
  }

  void moodSelected(int mood) => emit(state.copyWith(mood: mood));

  /// Adds or removes a predefined or previously added custom symptom.
  void symptomToggled(String symptom) {
    final symptoms = [...state.symptoms];
    if (!symptoms.remove(symptom)) symptoms.add(symptom);
    emit(state.copyWith(symptoms: symptoms));
  }

  /// Ignores blank input and case-insensitive duplicates.
  void customSymptomAdded(String text) {
    final symptom = text.trim();
    final isDuplicate = state.symptoms.any(
      (existing) => existing.toLowerCase() == symptom.toLowerCase(),
    );
    if (symptom.isEmpty ||
        symptom.length > maxCustomSymptomLength ||
        isDuplicate) {
      return;
    }
    emit(state.copyWith(symptoms: [...state.symptoms, symptom]));
  }

  void noteChanged(String note) => emit(state.copyWith(note: note));

  Future<void> submit() async {
    final mood = state.mood;
    if (mood == null) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    final note = state.note.trim();
    await _run(
      () => _saveEntry(
        WellbeingEntry(
          date: state.date,
          mood: mood,
          symptoms: state.symptoms,
          note: note.isEmpty ? null : note,
        ),
      ),
      doneStatus: WellbeingFormStatus.saved,
    );
  }

  Future<void> delete() => _run(
    () => _deleteEntry(state.date),
    doneStatus: WellbeingFormStatus.deleted,
  );

  Future<void> _run(
    Future<void> Function() action, {
    required WellbeingFormStatus doneStatus,
  }) async {
    emit(state.copyWith(status: WellbeingFormStatus.saving));
    try {
      await action();
      emit(state.copyWith(status: doneStatus));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: WellbeingFormStatus.saveFailure));
    }
  }
}
