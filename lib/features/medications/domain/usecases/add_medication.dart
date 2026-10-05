import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';

class AddMedication {
  const AddMedication(this._repository);

  final MedicationRepository _repository;

  /// Returns the id of the created medication.
  Future<int> call(Medication medication) =>
      _repository.addMedication(medication);
}
