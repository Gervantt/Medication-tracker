import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/presentation/cubit/medications_list_cubit.dart';
import 'package:medtrack/features/medications/presentation/pages/medications_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';
import '../../../helpers/pump_app.dart';

class _MockMedicationsListCubit extends MockCubit<MedicationsListState>
    implements MedicationsListCubit;

void main() {
  late _MockMedicationsListCubit cubit;

  setUp(() => cubit = _MockMedicationsListCubit());

  Future<void> pumpView(WidgetTester tester, MedicationsListState state) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpApp(
      BlocProvider<MedicationsListCubit>.value(
        value: cubit,
        child: const MedicationsView(),
      ),
    );
  }

  group('MedicationsView', () {
    testWidgets('lists medications with dosage and schedule', (tester) async {
      await pumpView(
        tester,
        MedicationsListLoaded([
          buildMedication(
            times: const [
              DoseTime(hour: 8, minute: 0),
              DoseTime(hour: 20, minute: 30),
            ],
            weekdays: {DateTime.monday, DateTime.friday},
          ),
        ]),
      );

      expect(find.text('Ibuprofen'), findsOneWidget);
      expect(find.textContaining('200 мг · Таблетка'), findsOneWidget);
      expect(find.textContaining('08:00, 20:30 · пн, пт'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('empty list offers adding or searching, without a FAB', (
      tester,
    ) async {
      await pumpView(tester, const MedicationsListLoaded([]));

      expect(find.text('Пока нет лекарств'), findsOneWidget);
      expect(find.text('Добавить лекарство'), findsOneWidget);
      expect(find.text('Найти в базе FDA'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('error state retries the subscription', (tester) async {
      when(() => cubit.subscribe()).thenReturn(null);
      await pumpView(tester, const MedicationsListError());

      await tester.tap(find.text('Повторить'));

      verify(() => cubit.subscribe()).called(1);
    });
  });
}
