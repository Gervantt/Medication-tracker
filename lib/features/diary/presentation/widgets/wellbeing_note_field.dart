import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';

class WellbeingNoteField extends StatelessWidget {
  const WellbeingNoteField({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingFormCubit>();
    return TextFormField(
      initialValue: cubit.state.note,
      decoration: InputDecoration(labelText: context.l10n.fieldNote),
      textCapitalization: TextCapitalization.sentences,
      minLines: 3,
      maxLines: 6,
      onChanged: cubit.noteChanged,
    );
  }
}
