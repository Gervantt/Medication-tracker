import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/medications/domain/usecases/add_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/delete_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/get_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/update_medication.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/pages/medication_form_page.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockAddMedication extends Mock implements AddMedication;

void main() {
  late _MockAddMedication addMedication;

  setUpAll(() => registerFallbackValue(buildMedication()));

  setUp(() {
    addMedication = _MockAddMedication();
    when(() => addMedication(any())).thenAnswer((_) async => 1);
    getIt.registerFactory(
      () => MedicationFormCubit(
        getMedication: GetMedication(_UnusedRepository()),
        addMedication: addMedication,
        updateMedication: UpdateMedication(_UnusedRepository()),
        deleteMedication: DeleteMedication(_UnusedRepository()),
      ),
    );
  });

  tearDown(getIt.reset);

  Future<void> pumpForm(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('list')),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const MedicationFormPage()),
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
    unawaited(router.push('/new'));
    await tester.pumpAndSettle();
  }

  group('MedicationFormPage', () {
    testWidgets('shows validation errors when saving an empty form', (
      tester,
    ) async {
      await pumpForm(tester);

      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      expect(find.text('Обязательное поле'), findsNWidgets(2));
      verifyNever(() => addMedication(any()));
    });

    testWidgets('saves a filled form and closes', (tester) async {
      await pumpForm(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Название'),
        'Ibuprofen',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Дозировка'),
        '2,5',
      );
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      final saved =
          verify(() => addMedication(captureAny())).captured.single
              as Medication;
      expect(saved.name, 'Ibuprofen');
      expect(saved.dosage.amount, 2.5);
      expect(find.text('list'), findsOneWidget);
    });
  });
}

class _UnusedRepository extends Mock implements MedicationRepository;
