import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/theme/status_colors.dart';
import 'package:medtrack/core/widgets/color_dot.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';
import 'package:medtrack/features/statistics/domain/entities/day_adherence.dart';
import 'package:medtrack/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:medtrack/features/statistics/presentation/formatters/statistics_formatter.dart';

/// Month calendar where each day is colored by how intakes were followed.
class AdherenceCalendarCard extends StatelessWidget {
  const AdherenceCalendarCard({
    required this.month,
    required this.days,
    required this.today,
    required this.canShowNextMonth,
    super.key,
  });

  final DateTime month;

  /// Every day of [month], in order.
  final List<DayAdherence> days;
  final DateTime today;
  final bool canShowNextMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<StatisticsCubit>();
    final formatter = MedicationFormatter(l10n);
    // Monday-first grid: blank cells before the 1st of the month.
    final leadingBlanks = month.weekday - DateTime.monday;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: l10n.previousMonth,
                  onPressed: cubit.previousMonth,
                ),
                Expanded(
                  child: Text(
                    StatisticsFormatter(l10n).month(month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: l10n.nextMonth,
                  onPressed: canShowNextMonth ? cubit.nextMonth : null,
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: DateTime.daysPerWeek,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                  Center(
                    child: Text(
                      formatter.weekday(day),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                for (var i = 0; i < leadingBlanks; i++) const SizedBox(),
                for (final day in days)
                  _CalendarDay(day: day, isToday: day.date == today),
              ],
            ),
            const SizedBox(height: 8),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.day, required this.isToday});

  final DayAdherence day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = StatisticsFormatter(context.l10n);
    final fill = StatisticsFormatter.dayColor(
      day.status,
      StatusColors.of(context),
    );
    return Semantics(
      label:
          '${formatter.fullDate(day.date)}: ${formatter.dayStatus(day.status)}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill?.withValues(alpha: 0.85),
            border: isToday
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '${day.date.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: fill == null ? null : _onColor(fill),
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Black or white, whichever is readable on [background]
/// (white on yellow would be unreadable in the light theme).
Color _onColor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
    ? Colors.white
    : Colors.black;

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final formatter = StatisticsFormatter(context.l10n);
    final colors = StatusColors.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        for (final status in [
          DayStatus.allTaken,
          DayStatus.partial,
          DayStatus.missed,
        ])
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorDot(
                color: StatisticsFormatter.dayColor(status, colors)!,
                size: 10,
              ),
              const SizedBox(width: 6),
              Text(
                formatter.dayStatus(status),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
