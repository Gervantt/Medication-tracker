part of 'wellbeing_form_cubit.dart';

enum WellbeingFormStatus {
  loading,
  loadFailure,
  editing,
  saving,
  saveFailure,
  saved,
  deleted,
}

class WellbeingFormState extends Equatable {
  const WellbeingFormState({
    required this.date,
    this.status = WellbeingFormStatus.loading,
    this.mood,
    this.symptoms = const [],
    this.note = '',
    this.isExisting = false,
    this.showErrors = false,
  });

  /// Local midnight of the day being edited.
  final DateTime date;
  final WellbeingFormStatus status;

  /// `null` until the user picks a mood.
  final int? mood;

  /// Predefined symptom keys and custom symptoms, in the order added.
  final List<String> symptoms;
  final String note;

  /// Whether an entry for [date] is already saved (and can be deleted).
  final bool isExisting;

  /// The mood error is hidden until the first save attempt.
  final bool showErrors;

  bool get isValid => mood != null;

  bool get showMoodError => showErrors && mood == null;

  bool get isSaving => status == WellbeingFormStatus.saving;

  WellbeingFormState copyWith({
    WellbeingFormStatus? status,
    int? mood,
    List<String>? symptoms,
    String? note,
    bool? isExisting,
    bool? showErrors,
  }) {
    return WellbeingFormState(
      date: date,
      status: status ?? this.status,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      note: note ?? this.note,
      isExisting: isExisting ?? this.isExisting,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [
    date,
    status,
    mood,
    symptoms,
    note,
    isExisting,
    showErrors,
  ];
}
