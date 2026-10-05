import 'package:equatable/equatable.dart';
import 'package:medtrack/features/medications/domain/entities/dosage.dart';
import 'package:medtrack/features/medications/domain/entities/medication_form.dart';
import 'package:medtrack/features/medications/domain/entities/medication_schedule.dart';

class Medication extends Equatable {
  const Medication({
    required this.name,
    required this.dosage,
    required this.form,
    required this.schedule,
    required this.startDate,
    required this.colorValue,
    this.id,
    this.endDate,
    this.note,
  });

  /// `null` until the medication is saved.
  final int? id;
  final String name;
  final Dosage dosage;
  final MedicationForm form;
  final MedicationSchedule schedule;

  /// Course start, local midnight.
  final DateTime startDate;

  /// Course end (inclusive), local midnight; `null` for an open-ended course.
  final DateTime? endDate;
  final String? note;

  /// ARGB label color; kept as `int` so the domain does not depend on Flutter.
  final int colorValue;

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    form,
    schedule,
    startDate,
    endDate,
    note,
    colorValue,
  ];
}
