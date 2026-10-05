import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/confirm_dialog.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';

class DeleteEntryButton extends StatelessWidget {
  const DeleteEntryButton({super.key});

  Future<void> _confirmAndDelete(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<WellbeingFormCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteEntryTitle,
      message: l10n.deleteEntryMessage,
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
