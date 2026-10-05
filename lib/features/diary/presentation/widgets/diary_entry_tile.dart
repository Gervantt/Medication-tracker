import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/presentation/formatters/diary_formatter.dart';

class DiaryEntryTile extends StatelessWidget {
  const DiaryEntryTile({required this.entry, this.onTap, super.key});

  final WellbeingEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DiaryFormatter(context.l10n);
    final details = [
      formatter.moodLabel(entry.mood),
      ...entry.symptoms.map(formatter.symptom),
    ].join(' · ');
    final note = entry.note;
    return ListTile(
      leading: Text(
        formatter.moodEmoji(entry.mood),
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(formatter.day(entry.date, today: clock.now())),
      subtitle: Text(
        note == null ? details : '$details\n$note',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
