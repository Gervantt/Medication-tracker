import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/today/domain/entities/scheduled_intake.dart';
import 'package:medtrack/features/today/presentation/cubit/today_cubit.dart';

/// "Taken" / "Skipped" buttons for a pending intake, or its mark with undo.
/// Switching between the two fades and resizes instead of jumping.
class IntakeActions extends StatelessWidget {
  const IntakeActions({required this.intake, super.key});

  final ScheduledIntake intake;

  @override
  Widget build(BuildContext context) {
    final status = intake.status;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      // Different keys make AnimatedSwitcher treat them as new children.
      child: status == null
          ? _PendingActions(key: const ValueKey('pending'), intake: intake)
          : _MarkedStatus(
              key: ValueKey(status),
              intake: intake,
              status: status,
            ),
    );
  }
}

class _PendingActions extends StatelessWidget {
  const _PendingActions({required this.intake, super.key});

  final ScheduledIntake intake;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TodayCubit>();
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
}

class _MarkedStatus extends StatelessWidget {
  const _MarkedStatus({required this.intake, required this.status, super.key});

  final ScheduledIntake intake;
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
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
        const Spacer(),
        TextButton(
          onPressed: () => context.read<TodayCubit>().undo(intake),
          child: Text(l10n.undo),
        ),
      ],
    );
  }
}
