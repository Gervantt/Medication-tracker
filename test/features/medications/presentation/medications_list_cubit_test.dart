import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/medications/domain/usecases/watch_medications.dart';
import 'package:medtrack/features/medications/presentation/cubit/medications_list_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockWatchMedications extends Mock implements WatchMedications;

void main() {
  late _MockWatchMedications watchMedications;

  setUp(() => watchMedications = _MockWatchMedications());

  group('MedicationsListCubit', () {
    final medication = buildMedication();

    blocTest<MedicationsListCubit, MedicationsListState>(
      'emits loading then loaded with medications from the stream',
      setUp: () =>
          when(watchMedications.call)
              .thenAnswer((_) => Stream.value([medication])),
      build: () => MedicationsListCubit(watchMedications),
      act: (cubit) => cubit.subscribe(),
      expect: () => [
        const MedicationsListLoading(),
        MedicationsListLoaded([medication]),
      ],
    );

    blocTest<MedicationsListCubit, MedicationsListState>(
      'emits error when the stream fails',
      setUp: () =>
          when(watchMedications.call)
              .thenAnswer((_) => Stream.error(Exception('db'))),
      build: () => MedicationsListCubit(watchMedications),
      act: (cubit) => cubit.subscribe(),
      expect: () => [
        const MedicationsListLoading(),
        const MedicationsListError(),
      ],
      errors: () => [isA<Exception>()],
    );
  });
}
