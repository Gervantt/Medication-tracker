import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/empty_view.dart';
import 'package:medtrack/core/widgets/error_view.dart';
import 'package:medtrack/core/widgets/loading_view.dart';
import 'package:medtrack/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:medtrack/features/statistics/presentation/widgets/adherence_calendar_card.dart';
import 'package:medtrack/features/statistics/presentation/widgets/adherence_summary.dart';
import 'package:medtrack/features/statistics/presentation/widgets/mood_chart_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StatisticsCubit>()..subscribe(),
      child: const StatisticsView(),
    );
  }
}

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // "Today" and "missed" depend on the current time.
    _lifecycleListener = AppLifecycleListener(
      onResume: context.read<StatisticsCubit>().refresh,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navStatistics)),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) => switch (state) {
          StatisticsLoading() => const LoadingView(),
          StatisticsError() => ErrorView(
            onRetry: context.read<StatisticsCubit>().subscribe,
          ),
          StatisticsLoaded(:final statistics) when !statistics.hasData =>
            EmptyView(
              icon: Icons.insights_outlined,
              title: l10n.statsEmptyTitle,
              message: l10n.statsEmptyMessage,
            ),
          StatisticsLoaded() => _StatisticsContent(state: state),
        },
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.state});

  final StatisticsLoaded state;

  @override
  Widget build(BuildContext context) {
    final statistics = state.statistics;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AdherenceSummary(
          weekRate: statistics.weekRate,
          monthRate: statistics.monthRate,
        ),
        const SizedBox(height: 12),
        MoodChartCard(entries: statistics.moodEntries, today: statistics.today),
        const SizedBox(height: 12),
        AdherenceCalendarCard(
          month: statistics.month,
          days: statistics.calendar,
          today: statistics.today,
          canShowNextMonth: state.canShowNextMonth,
        ),
      ],
    );
  }
}
