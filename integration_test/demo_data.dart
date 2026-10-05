import 'package:clock/clock.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/di/injection.dart';
import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/save_wellbeing_entry.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/usecases/mark_intake.dart';
import 'package:medtrack/features/medications/domain/entities/dosage.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/entities/medication_form.dart';
import 'package:medtrack/features/medications/domain/entities/medication_schedule.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/medications/domain/usecases/add_medication.dart';

const _everyDay = {1, 2, 3, 4, 5, 6, 7};

/// Replaces all data with a realistic two-week history for screenshots.
Future<void> seedDemoData() async {
  final database = getIt<AppDatabase>();
  // Schedules and intakes go away through ON DELETE CASCADE.
  await database.delete(database.medications).go();
  await database.delete(database.wellbeingEntries).go();

  final now = clock.now();
  final today = now.dateOnly;
  DateTime daysAgo(int days) =>
      DateTime(today.year, today.month, today.day - days);

  final addMedication = getIt<AddMedication>();
  await addMedication(
    Medication(
      name: 'Ibuprofen',
      dosage: const Dosage(amount: 200, unit: DosageUnit.mg),
      form: MedicationForm.tablet,
      schedule: const MedicationSchedule(
        times: [DoseTime(hour: 8, minute: 0), DoseTime(hour: 20, minute: 0)],
        weekdays: _everyDay,
      ),
      startDate: daysAgo(20),
      note: 'После еды',
      colorValue: 0xFF00897B,
    ),
  );
  await addMedication(
    Medication(
      name: 'Vitamin D3',
      dosage: const Dosage(amount: 1, unit: DosageUnit.tablet),
      form: MedicationForm.capsule,
      schedule: const MedicationSchedule(
        times: [DoseTime(hour: 9, minute: 0)],
        weekdays: _everyDay,
      ),
      startDate: daysAgo(45),
      colorValue: 0xFF1E88E5,
    ),
  );
  await addMedication(
    Medication(
      name: 'Amoxicillin',
      dosage: const Dosage(amount: 5, unit: DosageUnit.ml),
      form: MedicationForm.syrup,
      schedule: const MedicationSchedule(
        times: [
          DoseTime(hour: 8, minute: 0),
          DoseTime(hour: 14, minute: 0),
          DoseTime(hour: 20, minute: 0),
        ],
        weekdays: _everyDay,
      ),
      startDate: daysAgo(6),
      endDate: daysAgo(-4),
      colorValue: 0xFF8E24AA,
    ),
  );

  final markIntake = getIt<MarkIntake>();
  final medications = await getIt<MedicationRepository>().getMedications();
  var slotIndex = 0;
  for (var day = 30; day >= 0; day--) {
    for (final medication in medications) {
      for (final slot in medication.scheduledTimesOn(daysAgo(day))) {
        slotIndex++;
        // Today's morning intakes are marked even if it is still early,
        // so the Today screen shows both marked and pending intakes.
        final isTodayMorning = day == 0 && slot.hour < 12;
        if (!slot.isBefore(now) && !isTodayMorning) continue;
        // Mostly taken, sometimes skipped or forgotten.
        final status = isTodayMorning
            ? IntakeStatus.taken
            : switch (slotIndex % 17) {
                3 => IntakeStatus.skipped,
                11 => null,
                _ => IntakeStatus.taken,
              };
        if (status == null) continue;
        await markIntake(
          medicationId: medication.id!,
          scheduledAt: slot,
          status: status,
        );
      }
    }
  }

  final saveEntry = getIt<SaveWellbeingEntry>();
  const moods = [3, 2, 3, 4, 4, 3, 5, 4, 4, 5, 3, 4, 5, 4, 4, 5, 5, 4];
  for (var day = 0; day < moods.length; day++) {
    if (day == 5 || day == 11) continue;
    await saveEntry(
      WellbeingEntry(
        date: daysAgo(day),
        mood: moods[moods.length - 1 - day],
        symptoms: switch (day % 4) {
          0 => const ['headache'],
          1 => const ['weakness', 'Заложенность носа'],
          _ => const [],
        },
        note: day == 0 ? 'Хорошо выспался, к вечеру разболелась голова' : null,
      ),
    );
  }
}
