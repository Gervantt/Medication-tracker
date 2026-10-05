import 'package:medtrack/features/medications/domain/entities/dosage.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/entities/medication_form.dart';
import 'package:medtrack/features/medications/domain/entities/medication_schedule.dart';

const Set<int> everyDay = {
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
  DateTime.saturday,
  DateTime.sunday,
};

Medication buildMedication({
  int? id = 1,
  String name = 'Ibuprofen',
  List<DoseTime> times = const [DoseTime(hour: 8, minute: 0)],
  Set<int> weekdays = everyDay,
  DateTime? startDate,
  DateTime? endDate,
}) {
  return Medication(
    id: id,
    name: name,
    dosage: const Dosage(amount: 200, unit: DosageUnit.mg),
    form: MedicationForm.tablet,
    schedule: MedicationSchedule(times: times, weekdays: weekdays),
    startDate: startDate ?? DateTime(2026, 10),
    endDate: endDate,
    colorValue: 0xFF00897B,
  );
}
