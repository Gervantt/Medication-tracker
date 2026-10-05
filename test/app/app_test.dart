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
import 'package:medtrack/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:medtrack/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:medtrack/features/reminders/domain/repositories/notification_permission.dart';
import 'package:medtrack/features/today/domain/usecases/watch_day_intakes.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchMedications extends Mock implements WatchMedications;

class _MockWatchDayIntakes extends Mock implements WatchDayIntakes;

class _MockIntakeRepository extends Mock implements IntakeRepository;

class _MockNotificationPermission extends Mock
    implements NotificationPermission;

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({required this.isCompleted});

  @override
  bool isCompleted;

  @override
  Future<void> complete() async => isCompleted = true;
}

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  group('MedTrackApp', () {
    late _FakeOnboardingRepository onboarding;

    setUp(() {
      final watchMedications = _MockWatchMedications();
      when(watchMedications.call).thenAnswer((_) => Stream.value(const []));
      final watchDayIntakes = _MockWatchDayIntakes();
      when(() => watchDayIntakes(any()))
          .thenAnswer((_) => Stream.value(const []));
      onboarding = _FakeOnboardingRepository(isCompleted: true);
      getIt
        ..registerFactory(() => MedicationsListCubit(watchMedications))
        ..registerFactory(
          () => TodayCubit(
            watchDayIntakes: watchDayIntakes,
            markIntake: MarkIntake(_MockIntakeRepository()),
            clearIntakeMark: ClearIntakeMark(_MockIntakeRepository()),
          ),
        )
        ..registerFactory(
          () => OnboardingCubit(
            repository: onboarding,
            notificationPermission: _MockNotificationPermission(),
          ),
        );
    });

    tearDown(getIt.reset);

    testWidgets('opens Today tab and switches to Medications', (tester) async {
      await tester.pumpWidget(
        MedTrackApp(router: createAppRouter(onboarding: onboarding)),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Сегодня'), findsOneWidget);
      expect(find.text('На сегодня приёмов нет'), findsOneWidget);

      await tester.tap(find.text('Лекарства'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Лекарства'), findsOneWidget);
      expect(find.text('Пока нет лекарств'), findsOneWidget);
    });

    testWidgets('shows onboarding on first launch, then Today', (tester) async {
      onboarding.isCompleted = false;
      await tester.pumpWidget(
        MedTrackApp(router: createAppRouter(onboarding: onboarding)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Добро пожаловать в MedTrack'), findsOneWidget);
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();
      expect(find.textContaining('не заменяет консультацию'), findsOneWidget);
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Не сейчас'));
      await tester.pumpAndSettle();

      expect(onboarding.isCompleted, isTrue);
      expect(find.widgetWithText(AppBar, 'Сегодня'), findsOneWidget);
    });
  });
}
