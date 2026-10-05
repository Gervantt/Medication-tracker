import 'package:bloc_test/bloc_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/theme/app_theme.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/statistics/domain/entities/adherence_rate.dart';
import 'package:medtrack/features/statistics/domain/entities/day_adherence.dart';
import 'package:medtrack/features/statistics/domain/entities/statistics.dart';
import 'package:medtrack/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:medtrack/features/statistics/presentation/pages/statistics_page.dart';
import 'package:medtrack/l10n/gen/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatisticsCubit extends MockCubit<StatisticsState>
    implements StatisticsCubit;

void main() {
  testWidgets('shows rates, mood chart and colored calendar', (tester) async {
    final cubit = _MockStatisticsCubit();
    when(() => cubit.state).thenReturn(
      StatisticsLoaded(
        Statistics(
          today: DateTime(2026, 10, 6),
          month: DateTime(2026, 10),
          weekRate: const AdherenceRate(taken: 6, counted: 8),
          monthRate: const AdherenceRate(taken: 20, counted: 25),
          calendar: [
            for (var day = 1; day <= 31; day++)
              DayAdherence(
                date: DateTime(2026, 10, day),
                isFuture: day > 6,
                taken: day.isEven ? 2 : 1,
                missed: day < 6 && day.isOdd ? 1 : 0,
                pending: day >= 6 && day.isOdd ? 1 : 0,
              ),
          ],
          moodEntries: [
            WellbeingEntry(date: DateTime(2026, 10, 2), mood: 2),
            WellbeingEntry(date: DateTime(2026, 10, 3), mood: 4),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<StatisticsCubit>.value(
          value: cubit,
          child: const StatisticsView(),
        ),
      ),
    );

    expect(find.text('75 %'), findsOneWidget);
    expect(find.text('80 %'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);

    // The calendar is below the fold of the lazily built list.
    await tester.scrollUntilVisible(
      find.text('Всё принято'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // intl puts a narrow no-break space before "г.".
    expect(find.text('Октябрь 2026\u202fг.'), findsOneWidget);
    expect(find.text('Всё принято'), findsOneWidget);
  });
}
