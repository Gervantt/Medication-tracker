import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/medications/domain/entities/dose_time.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/usecases/add_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/delete_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/get_medication.dart';
import 'package:medtrack/features/medications/domain/usecases/update_medication.dart';
import 'package:medtrack/features/medications/presentation/cubit/medication_form_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/medication_fixtures.dart';

class _MockGetMedication extends Mock implements GetMedication;

class _MockAddMedication extends Mock implements AddMedication;

class _MockUpdateMedication extends Mock implements UpdateMedication;

class _MockDeleteMedication extends Mock implements DeleteMedication;

void main() {
  late _MockGetMedication getMedication;
  late _MockAddMedication addMedication;
  late _MockUpdateMedication updateMedication;
  late _MockDeleteMedication deleteMedication;

  final today = DateTime(2026, 10, 6);

  setUpAll(() => registerFallbackValue(buildMedication()));

  setUp(() {
    getMedication = _MockGetMedication();
    addMedication = _MockAddMedication();
    updateMedication = _MockUpdateMedication();
    deleteMedication = _MockDeleteMedication();
  });

  MedicationFormCubit buildCubit() => withClock(
    Clock.fixed(DateTime(2026, 10, 6, 14, 30)),
    () => MedicationFormCubit(
      getMedication: getMedication,
      addMedication: addMedication,
      updateMedication: updateMedication,
      deleteMedication: deleteMedication,
    ),
  );

  group('MedicationFormCubit', () {
    test('starts a new course today at midnight', () {
      expect(buildCubit().state.startDate, today);
    });

    blocTest<MedicationFormCubit, MedicationFormState>(
      'keeps times sorted and ignores duplicates',
      build: buildCubit,
      act: (cubit) => cubit
        ..timeAdded(const DoseTime(hour: 7, minute: 30))
        ..timeAdded(const DoseTime(hour: 7, minute: 30)),
      verify: (cubit) => expect(cubit.state.times, const [
        DoseTime(hour: 7, minute: 30),
        DoseTime(hour: 9, minute: 0),
      ]),
    );

    blocTest<MedicationFormCubit, MedicationFormState>(
      'shows errors and does not save an invalid form',
      build: buildCubit,
      act: (cubit) => cubit.submit(),
      expect: () => [
        isA<MedicationFormState>().having(
          (s) => s.showErrors,
          'showErrors',
          isTrue,
        ),
      ],
      verify: (_) => verifyNever(() => addMedication(any())),
    );

    blocTest<MedicationFormCubit, MedicationFormState>(
      'adds a new medication with every-day schedule',
      setUp: () => when(() => addMedication(any())).thenAnswer((_) async => 1),
      build: buildCubit,
      act: (cubit) async {
        cubit
          ..nameChanged('  Ibuprofen ')
          ..dosageAmountChanged('200');
        await cubit.submit();
      },
      skip: 2,
      expect: () => [
        isA<MedicationFormState>().having(
          (s) => s.status,
          'status',
          MedicationFormStatus.saving,
        ),
        isA<MedicationFormState>().having(
          (s) => s.status,
          'status',
          MedicationFormStatus.saved,
        ),
      ],
      verify: (_) {
        final saved =
            verify(() => addMedication(captureAny())).captured.single
                as Medication;
        expect(saved.name, 'Ibuprofen');
        expect(saved.schedule.weekdays, everyDay);
        expect(saved.startDate, today);
      },
    );

    blocTest<MedicationFormCubit, MedicationFormState>(
      'emits saveFailure when saving throws',
      setUp: () =>
          when(() => addMedication(any())).thenThrow(Exception('disk full')),
      build: buildCubit,
      act: (cubit) async {
        cubit
          ..nameChanged('Ibuprofen')
          ..dosageAmountChanged('200');
        await cubit.submit();
      },
      verify: (cubit) =>
          expect(cubit.state.status, MedicationFormStatus.saveFailure),
      errors: () => [isA<Exception>()],
    );

    blocTest<MedicationFormCubit, MedicationFormState>(
      'loads an existing medication with specific weekdays for editing',
      setUp: () => when(() => getMedication(1)).thenAnswer(
        (_) async =>
            buildMedication(weekdays: {DateTime.monday, DateTime.friday}),
      ),
      build: buildCubit,
      act: (cubit) => cubit.load(1),
      verify: (cubit) {
        final state = cubit.state;
        expect(state.status, MedicationFormStatus.editing);
        expect(state.isEditing, isTrue);
        expect(state.dosageAmount, '200');
        expect(state.everyDay, isFalse);
        expect(state.weekdays, {DateTime.monday, DateTime.friday});
      },
    );

    blocTest<MedicationFormCubit, MedicationFormState>(
      'emits loadFailure when the medication does not exist',
      setUp: () => when(() => getMedication(1)).thenAnswer((_) async => null),
      build: buildCubit,
      act: (cubit) => cubit.load(1),
      verify: (cubit) =>
          expect(cubit.state.status, MedicationFormStatus.loadFailure),
    );

    blocTest<MedicationFormCubit, MedicationFormState>(
      'updates and deletes an existing medication',
      setUp: () {
        when(() => getMedication(1)).thenAnswer((_) async => buildMedication());
        when(() => updateMedication(any())).thenAnswer((_) async {});
        when(() => deleteMedication(1)).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (cubit) async {
        await cubit.load(1);
        await cubit.submit();
        await cubit.delete();
      },
      verify: (cubit) {
        verify(() => updateMedication(buildMedication())).called(1);
        verify(() => deleteMedication(1)).called(1);
        expect(cubit.state.status, MedicationFormStatus.deleted);
      },
    );
  });
}
