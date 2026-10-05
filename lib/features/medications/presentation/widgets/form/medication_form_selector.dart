import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/form_section.dart';
import 'package:medtrack/features/medications/domain/entities/medication_form.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';

class MedicationFormSelector extends StatelessWidget {
  const MedicationFormSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = MedicationFormatter(l10n);
    final selected = context.selectForm((state) => state.form);
    return FormSection(
      title: l10n.sectionForm,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final form in MedicationForm.values)
            ChoiceChip(
              label: Text(formatter.form(form)),
              selected: form == selected,
              onSelected: (_) =>
                  context.read<MedicationFormCubit>().formChanged(form),
            ),
        ],
      ),
    );
  }
}
