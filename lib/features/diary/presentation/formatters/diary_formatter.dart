import 'package:intl/intl.dart';
import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/diary/domain/entities/predefined_symptom.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

/// Turns diary values into localized, user-facing text.
class DiaryFormatter {
  DiaryFormatter(this._l10n);

  final AppLocalizations _l10n;

  static const _moodEmojis = ['😣', '🙁', '😐', '🙂', '😄'];

  /// Emoji for a mood from 1 (very bad) to 5 (great).
  String moodEmoji(int mood) => _moodEmojis[mood - 1];

  String moodLabel(int mood) => switch (mood) {
    1 => _l10n.moodVeryBad,
    2 => _l10n.moodBad,
    3 => _l10n.moodOkay,
    4 => _l10n.moodGood,
    _ => _l10n.moodGreat,
  };

  String predefinedSymptom(PredefinedSymptom symptom) => switch (symptom) {
    PredefinedSymptom.headache => _l10n.symptomHeadache,
    PredefinedSymptom.nausea => _l10n.symptomNausea,
    PredefinedSymptom.weakness => _l10n.symptomWeakness,
  };

  /// Translates predefined symptom keys; custom symptoms are shown as typed.
  String symptom(String value) {
    final predefined = PredefinedSymptom.tryParse(value);
    return predefined == null ? value : predefinedSymptom(predefined);
  }

  /// "Сегодня", "Вчера" or a date like "Пн, 5 октября".
  String day(DateTime date, {required DateTime today}) {
    final day = date.dateOnly;
    final todayDate = today.dateOnly;
    if (day == todayDate) return _l10n.today;
    if (day == DateTime(todayDate.year, todayDate.month, todayDate.day - 1)) {
      return _l10n.yesterday;
    }
    return toBeginningOfSentenceCase(
      DateFormat.MMMEd(_l10n.localeName).format(day),
    );
  }
}
