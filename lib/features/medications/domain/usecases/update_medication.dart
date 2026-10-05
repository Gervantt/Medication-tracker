import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';

class UpdateMedication {
  const UpdateMedication(this._repository);

  final MedicationRepository _repository;

  Future<void> call(Medication medication) =>
      _repository.updateMedication(medication);
}
