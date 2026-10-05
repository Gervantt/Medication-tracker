import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';

class DeleteMedicationButton extends StatelessWidget {
  const DeleteMedicationButton({super.key});

  Future<void> _confirmAndDelete(BuildContext context) async {
    final cubit = context.read<MedicationFormCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteMedicationDialog(name: cubit.state.name),
    );
    if (confirmed ?? false) await cubit.delete();
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

class _DeleteMedicationDialog extends StatelessWidget {
  const _DeleteMedicationDialog({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.deleteMedicationTitle),
      content: Text(l10n.deleteMedicationMessage(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}
