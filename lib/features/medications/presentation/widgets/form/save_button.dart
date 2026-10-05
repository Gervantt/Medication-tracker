import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isSaving = context.selectForm((state) => state.isSaving);
    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: FilledButton(
        onPressed: isSaving
            ? null
            : () => context.read<MedicationFormCubit>().submit(),
        child: isSaving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.l10n.save),
      ),
    );
  }
}
