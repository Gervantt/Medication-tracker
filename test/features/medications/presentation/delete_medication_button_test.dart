import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/widgets/delete_medication_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockMedicationFormCubit extends MockCubit<MedicationFormState>
    implements MedicationFormCubit;

void main() {
  late _MockMedicationFormCubit cubit;

  setUp(() {
    cubit = _MockMedicationFormCubit();
    when(() => cubit.state).thenReturn(
      MedicationFormState(
        startDate: DateTime(2026, 10, 6),
        medicationId: 1,
        name: 'Ibuprofen',
      ),
    );
    when(() => cubit.delete()).thenAnswer((_) async {});
  });

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpApp(
      BlocProvider<MedicationFormCubit>.value(
        value: cubit,
        child: const Scaffold(body: DeleteMedicationButton()),
      ),
    );
    await tester.tap(find.byType(DeleteMedicationButton));
    await tester.pumpAndSettle();
  }

  group('DeleteMedicationButton', () {
    testWidgets('names the medication and deletes only after confirm', (
      tester,
    ) async {
      await openDialog(tester);

      expect(find.textContaining('«Ibuprofen»'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Удалить'));
      await tester.pumpAndSettle();

      verify(() => cubit.delete()).called(1);
    });

    testWidgets('cancel keeps the medication', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      verifyNever(() => cubit.delete());
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
