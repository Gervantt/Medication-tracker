import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';

class DayProgressCard extends StatelessWidget {
  const DayProgressCard({
    required this.day,
    required this.taken,
    required this.total,
    super.key,
  });

  final DateTime day;
  final int taken;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final date = toBeginningOfSentenceCase(
      DateFormat.MMMMEEEEd(l10n.localeName).format(day),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.todayProgress(taken, total)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              // Animates from the previous value when an intake is marked.
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: total == 0 ? 0 : taken / total),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, _) =>
                    LinearProgressIndicator(value: value, minHeight: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
