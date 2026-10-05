import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/today/domain/entities/scheduled_intake.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';

/// "Taken" / "Skipped" buttons for a pending intake, or its mark with undo.
class IntakeActions extends StatelessWidget {
  const IntakeActions({required this.intake, super.key});

  final ScheduledIntake intake;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TodayCubit>();
    final status = intake.status;
    if (status == null) {
      return OverflowBar(
        spacing: 8,
        alignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => cubit.markSkipped(intake),
            child: Text(l10n.markSkipped),
          ),
          FilledButton.tonal(
            onPressed: () => cubit.markTaken(intake),
            child: Text(l10n.markTaken),
          ),
        ],
      );
    }
    return Row(
      children: [
        _StatusLabel(status: status),
        const Spacer(),
        TextButton(onPressed: () => cubit.undo(intake), child: Text(l10n.undo)),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final IntakeStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final (icon, label, color) = switch (status) {
      IntakeStatus.taken => (
        Icons.check_circle,
        l10n.intakeTaken,
        colors.primary,
      ),
      IntakeStatus.skipped => (Icons.cancel, l10n.intakeSkipped, colors.error),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
