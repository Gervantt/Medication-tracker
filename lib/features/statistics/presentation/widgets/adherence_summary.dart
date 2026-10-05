import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/statistics/domain/entities/adherence_rate.dart';
import 'package:medtrack/features/statistics/presentation/formatters/statistics_formatter.dart';

class AdherenceSummary extends StatelessWidget {
  const AdherenceSummary({
    required this.weekRate,
    required this.monthRate,
    super.key,
  });

  final AdherenceRate weekRate;
  final AdherenceRate monthRate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _RateCard(label: l10n.statsWeek, rate: weekRate),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RateCard(label: l10n.statsMonth, rate: monthRate),
        ),
      ],
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.label, required this.rate});

  final String label;
  final AdherenceRate rate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statsAdherence(label), style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              StatisticsFormatter(l10n).rate(rate),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.statsTakenOf(rate.taken, rate.counted),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
