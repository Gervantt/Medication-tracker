import 'package:medtrack/core/database/daos/medications_dao.dart';
import 'package:medtrack/features/medications/data/mappers/medication_mapper.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  const MedicationRepositoryImpl(this._dao);

  final MedicationsDao _dao;

  @override
  Stream<List<Medication>> watchMedications() =>
      _dao.watchAll().map(_toEntities);

  @override
  Future<List<Medication>> getMedications() => _dao.getAll().then(_toEntities);

  @override
  Future<Medication?> getMedication(int id) async =>
      (await _dao.getById(id))?.toEntity();

  @override
  Future<int> addMedication(Medication medication) => _dao.insertWithSchedules(
    medication.toCompanion(),
    medication.scheduleMinutes,
  );

  @override
  Future<void> updateMedication(Medication medication) {
    assert(medication.id != null, 'Only saved medications can be updated');
    return _dao.updateWithSchedules(
      medication.toCompanion(),
      medication.scheduleMinutes,
    );
  }

  @override
  Future<void> deleteMedication(int id) => _dao.deleteById(id);

  List<Medication> _toEntities(List<MedicationWithSchedules> rows) => [
    for (final row in rows) row.toEntity(),
  ];
}
