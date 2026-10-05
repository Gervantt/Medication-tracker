import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';
import 'package:medtrack/features/medications/presentation/formatters/field_error_messages.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';
import 'package:medtrack/features/medications/presentation/widgets/form/form_section.dart';

class CourseDatesSection extends StatelessWidget {
  const CourseDatesSection({super.key});

  static final _firstDate = DateTime(2000);
  static final _lastDate = DateTime(2100);

  Future<DateTime?> _pickDate(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: _lastDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = MedicationFormatter(l10n);
    final cubit = context.read<MedicationFormCubit>();
    final (startDate, endDate, error) = context.selectForm(
      (state) => (state.startDate, state.endDate, state.visibleErrors.endDate),
    );
    return FormSection(
      title: l10n.sectionCourse,
      errorText: error?.message(l10n),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(l10n.courseStart),
            subtitle: Text(formatter.date(startDate)),
            onTap: () async {
              final date = await _pickDate(
                context,
                initialDate: startDate,
                firstDate: _firstDate,
              );
              if (date != null) cubit.startDateChanged(date);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available),
            title: Text(l10n.courseEnd),
            subtitle: Text(
              endDate == null ? l10n.courseEndNotSet : formatter.date(endDate),
            ),
            trailing: endDate == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.clearEndDate,
                    onPressed: () => cubit.endDateChanged(null),
                  ),
            onTap: () async {
              final date = await _pickDate(
                context,
                initialDate: endDate ?? startDate,
                firstDate: startDate,
              );
              if (date != null) cubit.endDateChanged(date);
            },
          ),
        ],
      ),
    );
  }
}
