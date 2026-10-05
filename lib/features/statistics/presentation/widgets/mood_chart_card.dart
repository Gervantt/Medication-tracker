import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/presentation/formatters/diary_formatter.dart';
import 'package:medtrack/features/statistics/domain/usecases/watch_statistics.dart';
import 'package:medtrack/features/statistics/presentation/formatters/statistics_formatter.dart';

/// Mood of the last 30 days; days without a diary entry break the line.
class MoodChartCard extends StatelessWidget {
  const MoodChartCard({required this.entries, required this.today, super.key});

  final List<WellbeingEntry> entries;
  final DateTime today;

  static const int _days = WatchStatistics.monthDays;

  DateTime get _firstDay =>
      DateTime(today.year, today.month, today.day - _days + 1);

  DateTime _dayAt(double x) =>
      DateTime(_firstDay.year, _firstDay.month, _firstDay.day + x.toInt());

  List<FlSpot> _spots() {
    final moodByDay = {for (final entry in entries) entry.date: entry.mood};
    return [
      for (var x = 0; x < _days; x++)
        switch (moodByDay[_dayAt(x.toDouble())]) {
          final mood? => FlSpot(x.toDouble(), mood.toDouble()),
          null => FlSpot.nullSpot,
        },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statsMoodTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l10n.statsMoodEmpty),
              )
            else
              SizedBox(height: 200, child: LineChart(_chartData(context))),
          ],
        ),
      ),
    );
  }

  LineChartData _chartData(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final diary = DiaryFormatter(context.l10n);
    final statistics = StatisticsFormatter(context.l10n);
    return LineChartData(
      minX: 0,
      maxX: _days - 1,
      minY: WellbeingEntry.minMood.toDouble(),
      maxY: WellbeingEntry.maxMood.toDouble(),
      gridData: const FlGridData(drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 32,
            getTitlesWidget: (value, meta) =>
                Text(diary.moodEmoji(value.toInt())),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 7,
            reservedSize: 28,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              meta: meta,
              child: Text(
                statistics.shortDate(_dayAt(value)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => [
            for (final spot in spots)
              LineTooltipItem(
                '${statistics.fullDate(_dayAt(spot.x))}\n'
                '${diary.moodLabel(spot.y.toInt())}',
                TextStyle(color: colors.onInverseSurface),
              ),
          ],
          getTooltipColor: (_) => colors.inverseSurface,
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: _spots(),
          color: colors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            color: colors.primary.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}
