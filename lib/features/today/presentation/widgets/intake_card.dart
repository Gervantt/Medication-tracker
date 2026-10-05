import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/color_dot.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/presentation/formatters/medication_formatter.dart';
import 'package:medtrack/features/today/domain/entities/scheduled_intake.dart';
import 'package:medtrack/features/today/presentation/widgets/intake_actions.dart';

class IntakeCard extends StatelessWidget {
  const IntakeCard({required this.intake, super.key});

  final ScheduledIntake intake;

  @override
  Widget build(BuildContext context) {
    final formatter = MedicationFormatter(context.l10n);
    final medication = intake.medication;
    final time = formatter.time(
      DoseTime(
        hour: intake.scheduledAt.hour,
        minute: intake.scheduledAt.minute,
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 12, 8),
        child: Column(
          children: [
            ListTile(
              leading: ColorDot(color: Color(medication.colorValue)),
              title: Text(medication.name),
              subtitle: Text('$time · ${formatter.dosage(medication.dosage)}'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: IntakeActions(intake: intake),
            ),
          ],
        ),
      ),
    );
  }
}
