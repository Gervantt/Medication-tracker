import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/form_section.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_select.dart';
import 'package:medtrack/features/diary/presentation/formatters/diary_formatter.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = DiaryFormatter(l10n);
    final (selected, showError) = context.selectEntry(
      (state) => (state.mood, state.showMoodError),
    );
    return FormSection(
      title: l10n.moodQuestion,
      errorText: showError ? l10n.errorMoodRequired : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (
                var mood = WellbeingEntry.minMood;
                mood <= WellbeingEntry.maxMood;
                mood++
              )
                _MoodOption(
                  emoji: formatter.moodEmoji(mood),
                  label: formatter.moodLabel(mood),
                  isSelected: mood == selected,
                  onTap: () =>
                      context.read<WellbeingFormCubit>().moodSelected(mood),
                ),
            ],
          ),
          if (selected != null) ...[
            const SizedBox(height: 8),
            Text(formatter.moodLabel(selected)),
          ],
        ],
      ),
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? colors.primaryContainer : null,
            border: Border.all(
              color: isSelected ? colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }
}
