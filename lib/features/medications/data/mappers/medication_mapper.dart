import 'package:drift/drift.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/core/database/daos/medications_dao.dart';
import 'package:medtrack/features/medications/data/mappers/weekdays_mask.dart';
import 'package:medtrack/features/medications/domain/entities/dosage.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/entities/medication_form.dart';
import 'package:medtrack/features/medications/domain/entities/medication_schedule.dart';

extension MedicationWithSchedulesMapper on MedicationWithSchedules {
  Medication toEntity() {
    return Medication(
      id: medication.id,
      name: medication.name,
      dosage: Dosage(
        amount: medication.dosageAmount,
        unit: DosageUnit.values.byName(medication.dosageUnit),
      ),
      form: MedicationForm.values.byName(medication.form),
      schedule: MedicationSchedule(
        times: [
          for (final schedule in schedules)
            DoseTime.fromMinutesOfDay(schedule.minuteOfDay),
        ],
        weekdays: WeekdaysMask.decode(medication.weekdays),
      ),
      startDate: medication.startDate,
      endDate: medication.endDate,
      note: medication.note,
      colorValue: medication.colorValue,
    );
  }
}

extension MedicationToCompanion on Medication {
  MedicationsCompanion toCompanion() {
    return MedicationsCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      name: Value(name),
      dosageAmount: Value(dosage.amount),
      dosageUnit: Value(dosage.unit.name),
      form: Value(form.name),
      weekdays: Value(WeekdaysMask.encode(schedule.weekdays)),
      startDate: Value(startDate),
      endDate: Value(endDate),
      note: Value(note),
      colorValue: Value(colorValue),
    );
  }

  List<int> get scheduleMinutes => [
    for (final time in schedule.times) time.minutesOfDay,
  ];
}
