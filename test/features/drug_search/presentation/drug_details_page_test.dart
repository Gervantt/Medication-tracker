import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/usecases/get_drug_label.dart';
import 'package:medtrack/features/drug_search/presentation/cubit/drug_details_cubit.dart';
import 'package:medtrack/features/drug_search/presentation/pages/drug_details_page.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetDrugLabel extends Mock implements GetDrugLabel;

void main() {
  setUp(() {
    getIt.registerFactory(() => DrugDetailsCubit(_MockGetDrugLabel()));
  });

  tearDown(getIt.reset);

  testWidgets('shows disclaimer, sections and collapses long text', (
    tester,
  ) async {
    // Tall enough to show the whole page without scrolling.
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);
    final label = DrugLabel(
      id: '1',
      brandName: 'Lipitor',
      genericName: 'ATORVASTATIN',
      purpose: 'Lowers cholesterol.',
      sideEffects: 'Muscle pain. ' * 200,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DrugDetailsPage(id: '1', initialLabel: label),
      ),
    );

    expect(find.textContaining('не заменяет консультацию врача'), findsOne);
    expect(find.text('Назначение'), findsOneWidget);
    expect(find.text('Предупреждения'), findsNothing);
    expect(find.text('Добавить в мои лекарства'), findsOneWidget);

    await tester.tap(find.text('Показать полностью'));
    await tester.pump();
    expect(find.text('Свернуть'), findsOneWidget);
  });
}
