import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/color_dot.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';

class MedicationListTile extends StatelessWidget {
  const MedicationListTile({required this.medication, this.onTap, super.key});

  final Medication medication;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = MedicationFormatter(l10n);
    final summary = l10n.medicationSummary(
      formatter.dosage(medication.dosage),
      formatter.form(medication.form),
    );
    return ListTile(
      leading: ColorDot(color: Color(medication.colorValue)),
      title: Text(medication.name),
      subtitle: Text('$summary\n${formatter.schedule(medication.schedule)}'),
      isThreeLine: true,
      onTap: onTap,
    );
  }
}
