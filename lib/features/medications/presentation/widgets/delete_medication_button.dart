import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/confirm_dialog.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';

class DeleteMedicationButton extends StatelessWidget {
  const DeleteMedicationButton({super.key});

  Future<void> _confirmAndDelete(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<MedicationFormCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteMedicationTitle,
      message: l10n.deleteMedicationMessage(cubit.state.name),
      confirmLabel: l10n.delete,
    );
    if (confirmed) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      tooltip: context.l10n.delete,
      onPressed: () => _confirmAndDelete(context),
    );
  }
}
