import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/medications/domain/entities/dosage.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';
import 'package:medtrack/features/medications/presentation/formatters/field_error_messages.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';

class DosageFields extends StatelessWidget {
  const DosageFields({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = MedicationFormatter(l10n);
    final cubit = context.read<MedicationFormCubit>();
    final error = context.selectForm(
      (state) => state.visibleErrors.dosageAmount,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: cubit.state.dosageAmount,
            decoration: InputDecoration(
              labelText: l10n.fieldDosage,
              errorText: error?.message(l10n),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: cubit.dosageAmountChanged,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: DropdownButtonFormField<DosageUnit>(
            initialValue: cubit.state.dosageUnit,
            decoration: InputDecoration(labelText: l10n.fieldUnit),
            items: [
              for (final unit in DosageUnit.values)
                DropdownMenuItem(
                  value: unit,
                  child: Text(formatter.dosageUnit(unit)),
                ),
            ],
            onChanged: (unit) {
              if (unit != null) cubit.dosageUnitChanged(unit);
            },
          ),
        ),
      ],
    );
  }
}
