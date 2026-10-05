import 'package:medtrack/features/medications/presentation/cubit/medication_form_validator.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

extension MedicationFieldErrorMessage on MedicationFieldError {
  String message(AppLocalizations l10n) => switch (this) {
    MedicationFieldError.required => l10n.errorRequired,
    MedicationFieldError.tooLong => l10n.errorTooLong(
      MedicationFormValidator.maxNameLength,
    ),
    MedicationFieldError.invalidNumber => l10n.errorInvalidNumber,
    MedicationFieldError.noTimes => l10n.errorNoTimes,
    MedicationFieldError.noWeekdays => l10n.errorNoWeekdays,
    MedicationFieldError.endBeforeStart => l10n.errorEndBeforeStart,
  };
}
