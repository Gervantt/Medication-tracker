import 'package:intl/intl.dart';
import 'package:medtrack/features/medications/domain/entities/dosage.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/entities/medication_form.dart';
import 'package:medtrack/features/medications/domain/entities/medication_schedule.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

/// Turns medication domain values into localized, user-facing text.
class MedicationFormatter {
  MedicationFormatter(this._l10n);

  final AppLocalizations _l10n;

  String get _locale => _l10n.localeName;

  String dosage(Dosage dosage) {
    final amount = NumberFormat.decimalPattern(_locale).format(dosage.amount);
    return '$amount ${dosageUnit(dosage.unit)}';
  }

  String dosageUnit(DosageUnit unit) => switch (unit) {
    DosageUnit.mg => _l10n.dosageUnitMg,
    DosageUnit.ml => _l10n.dosageUnitMl,
    DosageUnit.tablet => _l10n.dosageUnitTablet,
  };

  String form(MedicationForm form) => switch (form) {
    MedicationForm.tablet => _l10n.medicationFormTablet,
    MedicationForm.capsule => _l10n.medicationFormCapsule,
    MedicationForm.syrup => _l10n.medicationFormSyrup,
    MedicationForm.injection => _l10n.medicationFormInjection,
  };

  String time(DoseTime time) =>
      DateFormat.Hm(_locale)
          .format(DateTime(2000, 1, 1, time.hour, time.minute));

  /// Short weekday name, e.g. "пн" for [DateTime.monday].
  String weekday(int weekday) =>
      // 1 January 2024 was a Monday, so day N of that week is weekday N.
      DateFormat.E(_locale).format(DateTime(2024, 1, weekday));

  String weekdays(Set<int> weekdays) {
    if (weekdays.length == DateTime.daysPerWeek) return _l10n.everyDay;
    final sorted = weekdays.toList()..sort();
    return sorted.map(weekday).join(', ');
  }

  String schedule(MedicationSchedule schedule) => _l10n.scheduleSummary(
    schedule.times.map(time).join(', '),
    weekdays(schedule.weekdays),
  );
}
