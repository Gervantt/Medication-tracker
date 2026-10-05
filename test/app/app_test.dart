import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/router/app_router.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/intakes/domain/usecases/clear_intake_mark.dart';
import 'package:medtrack/features/intakes/domain/usecases/mark_intake.dart';
import 'package:medtrack/features/medications/domain/usecases/watch_medications.dart';
import 'package:medtrack/features/medications/presentation/cubit/medications_list_cubit.dart';
import 'package:medtrack/features/today/domain/usecases/watch_day_intakes.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchMedications extends Mock implements WatchMedications;

class _MockWatchDayIntakes extends Mock implements WatchDayIntakes;

class _MockIntakeRepository extends Mock implements IntakeRepository;

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  group('MedTrackApp', () {
    setUp(() {
      final watchMedications = _MockWatchMedications();
      when(watchMedications.call).thenAnswer((_) => Stream.value(const []));
      final watchDayIntakes = _MockWatchDayIntakes();
      when(() => watchDayIntakes(any()))
          .thenAnswer((_) => Stream.value(const []));
      getIt
        ..registerFactory(() => MedicationsListCubit(watchMedications))
        ..registerFactory(
          () => TodayCubit(
            watchDayIntakes: watchDayIntakes,
            markIntake: MarkIntake(_MockIntakeRepository()),
            clearIntakeMark: ClearIntakeMark(_MockIntakeRepository()),
          ),
        );
    });

    tearDown(getIt.reset);

    testWidgets('opens Today tab and switches to Medications', (tester) async {
      await tester.pumpWidget(MedTrackApp(router: createAppRouter()));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Сегодня'), findsOneWidget);
      expect(find.text('На сегодня приёмов нет'), findsOneWidget);

      await tester.tap(find.text('Лекарства'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Лекарства'), findsOneWidget);
      expect(find.text('Пока нет лекарств'), findsOneWidget);
    });
  });
}
