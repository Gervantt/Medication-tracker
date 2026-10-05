part of 'medication_form_cubit.dart';

enum MedicationFormStatus {
  loading,
  loadFailure,
  editing,
  saving,
  saveFailure,
  saved,
  deleted,
}

class MedicationFormState extends Equatable {
  MedicationFormState({
    required this.startDate,
    this.status = MedicationFormStatus.editing,
    this.medicationId,
    this.name = '',
    this.dosageAmount = '',
    this.dosageUnit = DosageUnit.mg,
    this.form = MedicationForm.tablet,
    this.times = const [DoseTime(hour: 9, minute: 0)],
    this.everyDay = true,
    this.weekdays = const {},
    this.endDate,
    this.note = '',
    int? colorValue,
    this.showErrors = false,
  }) : colorValue = colorValue ?? LabelColors.defaultValue;

  final MedicationFormStatus status;

  /// `null` when creating a new medication.
  final int? medicationId;
  final String name;

  /// Raw text from the input; parsed only on validation and save.
  final String dosageAmount;
  final DosageUnit dosageUnit;
  final MedicationForm form;

  /// Sorted ascending, without duplicates.
  final List<DoseTime> times;
  final bool everyDay;

  /// Selected weekdays; used only when [everyDay] is `false`.
  final Set<int> weekdays;
  final DateTime startDate;
  final DateTime? endDate;
  final String note;
  final int colorValue;

  /// Errors are hidden until the user tries to save for the first time.
  final bool showErrors;

  bool get isEditing => medicationId != null;

  bool get isSaving => status == MedicationFormStatus.saving;

  MedicationFormErrors get errors => MedicationFormValidator.validate(this);

  MedicationFormErrors get visibleErrors =>
      showErrors ? errors : const MedicationFormErrors();

  MedicationFormState copyWith({
    MedicationFormStatus? status,
    int? medicationId,
    String? name,
    String? dosageAmount,
    DosageUnit? dosageUnit,
    MedicationForm? form,
    List<DoseTime>? times,
    bool? everyDay,
    Set<int>? weekdays,
    DateTime? startDate,
    // A getter lets callers distinguish "keep" (omitted) from "clear" (null).
    DateTime? Function()? endDate,
    String? note,
    int? colorValue,
    bool? showErrors,
  }) {
    return MedicationFormState(
      status: status ?? this.status,
      medicationId: medicationId ?? this.medicationId,
      name: name ?? this.name,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      form: form ?? this.form,
      times: times ?? this.times,
      everyDay: everyDay ?? this.everyDay,
      weekdays: weekdays ?? this.weekdays,
      startDate: startDate ?? this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      note: note ?? this.note,
      colorValue: colorValue ?? this.colorValue,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [
    status,
    medicationId,
    name,
    dosageAmount,
    dosageUnit,
    form,
    times,
    everyDay,
    weekdays,
    startDate,
    endDate,
    note,
    colorValue,
    showErrors,
  ];
}
