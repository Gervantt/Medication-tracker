import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/features/intakes/data/repositories/intake_repository_impl.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/medications/data/repositories/medication_repository_impl.dart';
import 'package:medtrack/features/medications/domain/entities/dosage.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/entities/medication_form.dart';
import 'package:medtrack/features/medications/domain/entities/medication_schedule.dart';

void main() {
  late AppDatabase database;
  late MedicationRepositoryImpl repository;

  final medication = Medication(
    name: 'Ibuprofen',
    dosage: const Dosage(amount: 200, unit: DosageUnit.mg),
    form: MedicationForm.tablet,
    schedule: const MedicationSchedule(
      times: [DoseTime(hour: 8, minute: 0), DoseTime(hour: 20, minute: 30)],
      weekdays: {DateTime.monday, DateTime.wednesday, DateTime.friday},
    ),
    startDate: DateTime(2026, 10),
    colorValue: 0xFF00897B,
  );

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = MedicationRepositoryImpl(database.medicationsDao);
  });

  tearDown(() => database.close());

  group('MedicationRepositoryImpl', () {
    test('adds a medication and reads it back with its schedule', () async {
      final id = await repository.addMedication(medication);

      final saved = await repository.getMedication(id);

      expect(saved, isNotNull);
      expect(saved!.id, id);
      expect(saved.schedule, medication.schedule);
      expect(saved.dosage, medication.dosage);
    });

    test('update replaces schedule times', () async {
      final id = await repository.addMedication(medication);
      const newSchedule = MedicationSchedule(
        times: [DoseTime(hour: 12, minute: 0)],
        weekdays: {
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        },
      );

      await repository.updateMedication(
        Medication(
          id: id,
          name: medication.name,
          dosage: medication.dosage,
          form: medication.form,
          schedule: newSchedule,
          startDate: medication.startDate,
          colorValue: medication.colorValue,
        ),
      );

      final updated = await repository.getMedication(id);
      expect(updated!.schedule, newSchedule);
    });

    test('watchMedications emits medications sorted by name', () async {
      await repository.addMedication(medication);
      await repository.addMedication(
        Medication(
          name: 'aspirin',
          dosage: medication.dosage,
          form: medication.form,
          schedule: medication.schedule,
          startDate: medication.startDate,
          colorValue: medication.colorValue,
        ),
      );

      final medications = await repository.watchMedications().first;

      expect(medications.map((m) => m.name), ['aspirin', 'Ibuprofen']);
    });

    test('delete cascades to intakes', () async {
      final id = await repository.addMedication(medication);
      final intakes = IntakeRepositoryImpl(database.intakesDao);
      final scheduledAt = DateTime(2026, 10, 5, 8);
      await intakes.saveIntake(
        Intake(
          medicationId: id,
          scheduledAt: scheduledAt,
          status: IntakeStatus.taken,
          recordedAt: scheduledAt,
        ),
      );

      await repository.deleteMedication(id);

      expect(await repository.getMedications(), isEmpty);
      expect(
        await intakes.getIntakes(
          from: DateTime(2026, 10, 5),
          to: DateTime(2026, 10, 6),
        ),
        isEmpty,
      );
    });
  });
}
