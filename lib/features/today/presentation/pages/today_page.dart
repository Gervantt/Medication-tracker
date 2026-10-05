import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/empty_view.dart';
import 'package:medtrack/core/widgets/error_view.dart';
import 'package:medtrack/core/widgets/loading_view.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';
import 'package:medtrack/features/today/presentation/widgets/day_progress_card.dart';
import 'package:medtrack/features/today/presentation/widgets/intake_card.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodayCubit>()..subscribe(),
      child: const TodayView(),
    );
  }
}

class TodayView extends StatefulWidget {
  const TodayView({super.key});

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: context.read<TodayCubit>().refreshIfDayChanged,
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
      appBar: AppBar(title: Text(l10n.navToday)),
      body: BlocBuilder<TodayCubit, TodayState>(
        builder: (context, state) => switch (state) {
          TodayLoading() => const LoadingView(),
          TodayError() => ErrorView(
            onRetry: context.read<TodayCubit>().subscribe,
          ),
          TodayLoaded(:final intakes) when intakes.isEmpty => EmptyView(
            icon: Icons.event_available,
            title: l10n.todayEmptyTitle,
            message: l10n.todayEmptyMessage,
          ),
          TodayLoaded() => _TodayList(state: state),
        },
      ),
    );
  }
}

class _TodayList extends StatelessWidget {
  const _TodayList({required this.state});

  final TodayLoaded state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.intakes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return DayProgressCard(
            day: state.day,
            taken: state.takenCount,
            total: state.intakes.length,
          );
        }
        final intake = state.intakes[index - 1];
        return IntakeCard(
          key: ValueKey((intake.medication.id, intake.scheduledAt)),
          intake: intake,
        );
      },
    );
  }
}
