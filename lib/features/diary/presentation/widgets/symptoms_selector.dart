import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/form_section.dart';
import 'package:medtrack/features/diary/domain/entities/predefined_symptom.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_select.dart';
import 'package:medtrack/features/diary/presentation/formatters/diary_formatter.dart';

class SymptomsSelector extends StatelessWidget {
  const SymptomsSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = DiaryFormatter(l10n);
    final cubit = context.read<WellbeingFormCubit>();
    final selected = context.selectEntry((state) => state.symptoms);
    final predefinedKeys = {
      for (final symptom in PredefinedSymptom.values) symptom.name,
    };
    final customSymptoms = selected.where((s) => !predefinedKeys.contains(s));
    return FormSection(
      title: l10n.sectionSymptoms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final symptom in PredefinedSymptom.values)
                FilterChip(
                  label: Text(formatter.predefinedSymptom(symptom)),
                  selected: selected.contains(symptom.name),
                  onSelected: (_) => cubit.symptomToggled(symptom.name),
                ),
              for (final symptom in customSymptoms)
                InputChip(
                  label: Text(symptom),
                  selected: true,
                  onDeleted: () => cubit.symptomToggled(symptom),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const _CustomSymptomField(),
        ],
      ),
    );
  }
}

class _CustomSymptomField extends StatefulWidget {
  const _CustomSymptomField();

  @override
  State<_CustomSymptomField> createState() => _CustomSymptomFieldState();
}

class _CustomSymptomFieldState extends State<_CustomSymptomField> {
  final _controller = TextEditingController();

  void _add() {
    context.read<WellbeingFormCubit>().customSymptomAdded(_controller.text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextField(
      controller: _controller,
      maxLength: WellbeingFormCubit.maxCustomSymptomLength,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l10n.customSymptom,
        counterText: '',
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          tooltip: l10n.addSymptom,
          onPressed: _add,
        ),
      ),
      onSubmitted: (_) => _add(),
    );
  }
}
