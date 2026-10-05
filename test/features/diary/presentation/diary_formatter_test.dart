import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medtrack/features/diary/presentation/formatters/diary_formatter.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';

void main() {
  final formatter = DiaryFormatter(lookupAppLocalizations(const Locale('ru')));
  final today = DateTime(2026, 10, 6, 18);

  setUpAll(() => initializeDateFormatting('ru'));

  group('DiaryFormatter', () {
    test('names today and yesterday, formats older days', () {
      expect(formatter.day(DateTime(2026, 10, 6), today: today), 'Сегодня');
      expect(formatter.day(DateTime(2026, 10, 5), today: today), 'Вчера');
      expect(
        formatter.day(DateTime(2026, 10, 2), today: today),
        startsWith('Пт'),
      );
    });

    test('translates predefined symptoms and keeps custom ones', () {
      expect(formatter.symptom('headache'), 'Головная боль');
      expect(formatter.symptom('Dizziness'), 'Dizziness');
    });

    test('maps every mood to an emoji and a label', () {
      for (var mood = 1; mood <= 5; mood++) {
        expect(formatter.moodEmoji(mood), isNotEmpty);
        expect(formatter.moodLabel(mood), isNotEmpty);
      }
    });
  });
}
