import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/today/domain/entities/scheduled_intake.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';
import 'package:medtrack/features/today/presentation/pages/today_page.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockTodayCubit extends MockCubit<TodayState> implements TodayCubit;

void main() {
  late _MockTodayCubit cubit;

  final pending = ScheduledIntake(
    medication: buildMedication(name: 'Aspirin'),
    scheduledAt: DateTime(2026, 10, 6, 8),
  );
  final taken = ScheduledIntake(
    medication: buildMedication(id: 2, name: 'Vitamin D'),
    scheduledAt: DateTime(2026, 10, 6, 9),
    status: IntakeStatus.taken,
  );

  setUp(() {
    cubit = _MockTodayCubit();
    when(() => cubit.state).thenReturn(
      TodayLoaded(day: DateTime(2026, 10, 6), intakes: [pending, taken]),
    );
    when(() => cubit.markTaken(pending)).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<TodayCubit>.value(
          value: cubit,
          child: const TodayView(),
        ),
      ),
    );
  }

  group('TodayView', () {
    testWidgets('shows day progress and intake states', (tester) async {
      await pumpView(tester);

      expect(find.text('Вторник, 6 октября'), findsOneWidget);
      expect(find.text('Принято 1 из 2'), findsOneWidget);
      expect(find.text('Принял'), findsOneWidget);
      expect(find.text('Принято'), findsOneWidget);
    });

    testWidgets('marks a pending intake as taken', (tester) async {
      await pumpView(tester);

      await tester.tap(find.text('Принял'));

      verify(() => cubit.markTaken(pending)).called(1);
    });
  });
}
