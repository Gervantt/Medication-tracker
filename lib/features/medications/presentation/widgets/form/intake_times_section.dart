import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/form_section.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';
import 'package:medtrack/features/medications/presentation/formatters/field_error_messages.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';

class IntakeTimesSection extends StatelessWidget {
  const IntakeTimesSection({super.key});

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null || !context.mounted) return;
    context.read<MedicationFormCubit>().timeAdded(
      DoseTime(hour: picked.hour, minute: picked.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = MedicationFormatter(l10n);
    final (times, error) = context.selectForm(
      (state) => (state.times, state.visibleErrors.times),
    );
    return FormSection(
      title: l10n.sectionSchedule,
      errorText: error?.message(l10n),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final time in times)
            InputChip(
              label: Text(formatter.time(time)),
              onDeleted: () =>
                  context.read<MedicationFormCubit>().timeRemoved(time),
            ),
          ActionChip(
            avatar: const Icon(Icons.add),
            label: Text(l10n.addTime),
            onPressed: () => _pickTime(context),
          ),
        ],
      ),
    );
  }
}
