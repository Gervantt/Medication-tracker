import 'package:medtrack/features/medications/domain/entities/medication.dart';

abstract interface class MedicationRepository {
  Stream<List<Medication>> watchMedications();

  Future<List<Medication>> getMedications();

  Future<Medication?> getMedication(int id);

  /// Returns the id of the created medication.
  Future<int> addMedication(Medication medication);

  Future<void> updateMedication(Medication medication);

  /// Also removes the medication's schedule and intake history.
  Future<void> deleteMedication(int id);
}
