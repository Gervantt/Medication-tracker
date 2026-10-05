import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/today/domain/entities/scheduled_intake.dart';
import 'package:rxdart/rxdart.dart';

/// Emits planned intakes of [call]'s day with their marks, re-emitting
/// whenever medications or intake marks change.
class WatchDayIntakes {
  const WatchDayIntakes(this._medications, this._intakes);

  final MedicationRepository _medications;
  final IntakeRepository _intakes;

  Stream<List<ScheduledIntake>> call(DateTime day) {
    final from = day.dateOnly;
    final to = DateTime(from.year, from.month, from.day + 1);
    return Rx.combineLatest2(
      _medications.watchMedications(),
      _intakes.watchIntakes(from: from, to: to),
      (medications, intakes) => buildDayIntakes(from, medications, intakes),
    );
  }

  /// Sorted by time, then by medication name.
  static List<ScheduledIntake> buildDayIntakes(
    DateTime day,
    List<Medication> medications,
    List<Intake> intakes,
  ) {
    final statusBySlot = {
      for (final intake in intakes)
        (intake.medicationId, intake.scheduledAt): intake.status,
    };
    return [
      for (final medication in medications)
        for (final scheduledAt in medication.scheduledTimesOn(day))
          ScheduledIntake(
            medication: medication,
            scheduledAt: scheduledAt,
            status: statusBySlot[(medication.id, scheduledAt)],
          ),
    ]..sort(_byTimeThenName);
  }

  static int _byTimeThenName(ScheduledIntake a, ScheduledIntake b) {
    final byTime = a.scheduledAt.compareTo(b.scheduledAt);
    if (byTime != 0) return byTime;
    return a.medication.name.toLowerCase().compareTo(
      b.medication.name.toLowerCase(),
    );
  }
}
