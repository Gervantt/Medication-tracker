import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';

class DeleteMedication {
  const DeleteMedication(this._repository);

  final MedicationRepository _repository;

  Future<void> call(int id) => _repository.deleteMedication(id);
}
