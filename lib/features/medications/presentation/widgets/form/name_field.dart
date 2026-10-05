import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';
import 'package:medtrack/features/medications/presentation/formatters/field_error_messages.dart';

class NameField extends StatelessWidget {
  const NameField({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MedicationFormCubit>();
    final error = context.selectForm((state) => state.visibleErrors.name);
    return TextFormField(
      initialValue: cubit.state.name,
      decoration: InputDecoration(
        labelText: l10n.fieldName,
        errorText: error?.message(l10n),
      ),
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      onChanged: cubit.nameChanged,
    );
  }
}
