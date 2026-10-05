import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/router/app_router.dart';
import 'package:medtrack/core/router/app_routes.dart';
import 'package:medtrack/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medications_list_cubit.dart';
import 'package:medtrack/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _CompletedOnboarding implements OnboardingRepository {
  @override
  bool get isCompleted => true;

  @override
  Future<void> complete() async {}
}

class _MockMedicationsListCubit extends MockCubit<MedicationsListState>
    implements MedicationsListCubit;

class _MockDiaryCubit extends MockCubit<DiaryState> implements DiaryCubit;

class _MockTodayCubit extends MockCubit<TodayState> implements TodayCubit;

void main() {
  group('AppRoutes', () {
    test('builds paths with encoded parameters', () {
      expect(AppRoutes.medicationEdit(5), '/medications/5/edit');
      expect(
        AppRoutes.diaryEntry(DateTime(2026, 3, 7)),
        '/diary/entry/2026-03-07',
      );
      expect(
        AppRoutes.medicationNewWithName('Advil PM'),
        '/medications/new?name=Advil+PM',
      );
      expect(AppRoutes.drugDetails('a/b'), '/medications/search/a%2Fb');
    });
  });

  group('createAppRouter redirects', () {
    setUp(() {
      // Tab pages built after a redirect get their cubits from get_it.
      getIt
        ..registerFactory<MedicationsListCubit>(() {
          final cubit = _MockMedicationsListCubit();
          when(() => cubit.state).thenReturn(const MedicationsListLoaded([]));
          return cubit;
        })
        ..registerFactory<DiaryCubit>(() {
          final cubit = _MockDiaryCubit();
          when(() => cubit.state).thenReturn(const DiaryLoaded([]));
          return cubit;
        })
        ..registerFactory<TodayCubit>(() {
          final cubit = _MockTodayCubit();
          when(() => cubit.state).thenReturn(const TodayLoading());
          return cubit;
        });
    });

    tearDown(getIt.reset);

    Future<String> resolve(WidgetTester tester, String location) async {
      final router = createAppRouter(onboarding: _CompletedOnboarding());
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      router.go(location);
      await tester.pump();
      return router.routerDelegate.currentConfiguration.uri.toString();
    }

    testWidgets('an invalid medication id goes back to the list', (
      tester,
    ) async {
      expect(
        await resolve(tester, '/medications/abc/edit'),
        AppRoutes.medications,
      );
    });

    testWidgets('a future or malformed diary date goes back to the diary', (
      tester,
    ) async {
      expect(await resolve(tester, '/diary/entry/2999-01-01'), AppRoutes.diary);
      expect(await resolve(tester, '/diary/entry/not-a-date'), AppRoutes.diary);
    });

    testWidgets('completed onboarding cannot be opened again', (tester) async {
      expect(await resolve(tester, AppRoutes.onboarding), AppRoutes.today);
    });
  });
}
