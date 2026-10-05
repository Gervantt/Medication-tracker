import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/delete_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/get_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/save_wellbeing_entry.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';
import 'package:medtrack/features/diary/presentation/pages/wellbeing_entry_page.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetEntry extends Mock implements GetWellbeingEntry;

class _MockSaveEntry extends Mock implements SaveWellbeingEntry;

class _MockDeleteEntry extends Mock implements DeleteWellbeingEntry;

void main() {
  late _MockSaveEntry saveEntry;
  final day = DateTime(2026, 10, 2);

  setUpAll(() {
    registerFallbackValue(day);
    registerFallbackValue(WellbeingEntry(date: day, mood: 3));
  });

  setUp(() {
    final getEntry = _MockGetEntry();
    saveEntry = _MockSaveEntry();
    when(() => getEntry(any())).thenAnswer((_) async => null);
    when(() => saveEntry(any())).thenAnswer((_) async {});
    getIt.registerFactoryParam<WellbeingFormCubit, DateTime, void>(
      (date, _) => WellbeingFormCubit(
        date: date,
        getEntry: getEntry,
        saveEntry: saveEntry,
        deleteEntry: _MockDeleteEntry(),
      ),
    );
  });

  tearDown(getIt.reset);

  testWidgets('saves mood, symptoms and a custom symptom', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('diary')),
          routes: [
            GoRoute(
              path: 'entry',
              builder: (_, _) => WellbeingEntryPage(date: day),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    unawaited(router.push('/entry'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Сохранить'));
    await tester.pump();
    expect(find.text('Выберите самочувствие'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Хорошо'));
    await tester.tap(find.text('Тошнота'));
    await tester.enterText(find.byType(TextField).first, 'Dizziness');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.widgetWithText(InputChip, 'Dizziness'), findsOneWidget);

    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    verify(
      () => saveEntry(
        WellbeingEntry(
          date: day,
          mood: 4,
          symptoms: const ['nausea', 'Dizziness'],
        ),
      ),
    ).called(1);
    expect(find.text('diary'), findsOneWidget);
  });
}
