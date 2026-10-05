import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';

class GetMedication {
  const GetMedication(this._repository);

  final MedicationRepository _repository;

  Future<Medication?> call(int id) => _repository.getMedication(id);
}
