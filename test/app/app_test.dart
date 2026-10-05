import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/router/app_router.dart';
import 'package:medtrack/features/medications/domain/usecases/watch_medications.dart';
import 'package:medtrack/features/medications/presentation/cubit/medications_list_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchMedications extends Mock implements WatchMedications;

void main() {
  group('MedTrackApp', () {
    setUp(() {
      final watchMedications = _MockWatchMedications();
      when(watchMedications.call).thenAnswer((_) => Stream.value(const []));
      getIt.registerFactory(() => MedicationsListCubit(watchMedications));
    });

    tearDown(getIt.reset);

    testWidgets('opens Today tab and switches to Medications', (tester) async {
      await tester.pumpWidget(MedTrackApp(router: createAppRouter()));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Сегодня'), findsOneWidget);

      await tester.tap(find.text('Лекарства'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Лекарства'), findsOneWidget);
      expect(find.text('Пока нет лекарств'), findsOneWidget);
    });
  });
}
