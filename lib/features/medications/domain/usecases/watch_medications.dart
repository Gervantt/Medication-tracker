import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';

class WatchMedications {
  const WatchMedications(this._repository);

  final MedicationRepository _repository;

  Stream<List<Medication>> call() => _repository.watchMedications();
}
