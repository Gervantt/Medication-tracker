import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/time/local_time_zone.dart';
import 'package:medtrack/features/onboarding/data/onboarding_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_data.dart';

/// Walks through the app with demo data and saves screenshots to
/// `docs/screenshots/`. Run on an iOS simulator:
///
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/screenshots_test.dart -d "iPhone 17"
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures screenshots', (tester) async {
    await configureLocalTimeZone();
    final preferences = await SharedPreferencesWithCache.create(
      cacheOptions: OnboardingRepositoryImpl.cacheOptions,
    );
    await preferences.clear();
    await configureDependencies();
    await seedDemoData();

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      // The live test binding paints a crosshair where the test tapped;
      // it fades out over a few frames.
      for (var frame = 0; frame < 3; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await binding.takeScreenshot(name);
    }

    // pageBack() looks for a Cupertino back button on iOS; the app uses
    // Material app bars everywhere.
    Future<void> goBack() async {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }

    Future<void> openTab(String label) async {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(MedTrackApp(router: getIt<GoRouter>()));
    await tester.pumpAndSettle();

    // Onboarding.
    await tester.tap(find.text('Далее'));
    await shot('01_onboarding_disclaimer');
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Не сейчас'));
    await tester.pumpAndSettle();

    // Light theme.
    await shot('02_today');
    await openTab('Лекарства');
    await shot('03_medications');
    await tester.tap(find.text('Ibuprofen'));
    await shot('04_medication_form');
    await goBack();
    await openTab('Дневник');
    await shot('05_diary');
    await openTab('Статистика');
    await shot('06_statistics');
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await shot('07_statistics_calendar');

    // Drug search (needs network).
    await openTab('Лекарства');
    await tester.tap(find.byTooltip('Поиск препарата'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'advil');
    await tester.pump(const Duration(seconds: 3));
    await shot('08_drug_search');
    await tester.tap(find.byType(ListTile).first);
    await shot('09_drug_details');
    await goBack();
    await goBack();

    // Dark theme.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await openTab('Сегодня');
    await shot('10_today_dark');
    await openTab('Статистика');
    await tester.drag(find.byType(ListView).first, const Offset(0, 600));
    await shot('11_statistics_dark');
    await openTab('Дневник');
    await shot('12_diary_dark');
  });
}
