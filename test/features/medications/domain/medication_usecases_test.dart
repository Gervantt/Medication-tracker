import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/medications/domain/usecases/add_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/delete_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/get_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/update_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/watch_medications.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository;

void main() {
  late _MockMedicationRepository repository;
  final medication = buildMedication();

  setUpAll(() => registerFallbackValue(medication));

  setUp(() => repository = _MockMedicationRepository());

  group('Medication use cases', () {
    test('AddMedication returns the new id', () async {
      when(() => repository.addMedication(any())).thenAnswer((_) async => 7);

      expect(await AddMedication(repository)(medication), 7);
    });

    test('Update, delete and get delegate to the repository', () async {
      when(() => repository.updateMedication(any())).thenAnswer((_) async {});
      when(() => repository.deleteMedication(1)).thenAnswer((_) async {});
      when(() => repository.getMedication(1))
          .thenAnswer((_) async => medication);

      await UpdateMedication(repository)(medication);
      await DeleteMedication(repository)(1);
      final loaded = await GetMedication(repository)(1);

      verify(() => repository.updateMedication(medication)).called(1);
      verify(() => repository.deleteMedication(1)).called(1);
      expect(loaded, medication);
    });

    test('WatchMedications streams the list', () {
      when(repository.watchMedications)
          .thenAnswer((_) => Stream.value([medication]));

      expect(WatchMedications(repository)(), emits([medication]));
    });
  });
}
