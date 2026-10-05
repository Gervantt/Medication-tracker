import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';

class NoteField extends StatelessWidget {
  const NoteField({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MedicationFormCubit>();
    return TextFormField(
      initialValue: cubit.state.note,
      decoration: InputDecoration(labelText: context.l10n.fieldNote),
      textCapitalization: TextCapitalization.sentences,
      minLines: 2,
      maxLines: 5,
      onChanged: cubit.noteChanged,
    );
  }
}
