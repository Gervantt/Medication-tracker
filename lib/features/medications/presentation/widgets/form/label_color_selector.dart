import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/medications/presentation/constants/label_colors.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/form_section.dart';

class LabelColorSelector extends StatelessWidget {
  const LabelColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = context.selectForm((state) => state.colorValue);
    return FormSection(
      title: l10n.sectionColor,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final (index, value) in LabelColors.values.indexed)
            _ColorOption(
              color: Color(value),
              semanticLabel: l10n.labelColorOption(index + 1),
              isSelected: value == selected,
              onTap: () =>
                  context.read<MedicationFormCubit>().colorChanged(value),
            ),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.semanticLabel,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final String semanticLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      selected: isSelected,
      button: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
