import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/form_section.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_select.dart';
import 'package:medtrack/features/medications/presentation/formatters/field_error_messages.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';

class WeekdaysSection extends StatelessWidget {
  const WeekdaysSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = MedicationFormatter(l10n);
    final cubit = context.read<MedicationFormCubit>();
    final (everyDay, weekdays, error) = context.selectForm(
      (state) => (state.everyDay, state.weekdays, state.visibleErrors.weekdays),
    );
    return FormSection(
      title: l10n.sectionDays,
      errorText: error?.message(l10n),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.everyDay),
            value: everyDay,
            onChanged: (value) => cubit.everyDayChanged(everyDay: value),
          ),
          if (!everyDay)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                  FilterChip(
                    label: Text(formatter.weekday(day)),
                    selected: weekdays.contains(day),
                    onSelected: (_) => cubit.weekdayToggled(day),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
