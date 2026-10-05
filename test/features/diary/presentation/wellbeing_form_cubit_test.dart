import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/delete_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/get_wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/save_wellbeing_entry.dart';
import 'package:medtrack/features/diary/presentation/cubit/wellbeing_form_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetEntry extends Mock implements GetWellbeingEntry;

class _MockSaveEntry extends Mock implements SaveWellbeingEntry;

class _MockDeleteEntry extends Mock implements DeleteWellbeingEntry;

void main() {
  late _MockGetEntry getEntry;
  late _MockSaveEntry saveEntry;
  late _MockDeleteEntry deleteEntry;

  final day = DateTime(2026, 10, 6);
  final savedEntry = WellbeingEntry(
    date: day,
    mood: 2,
    symptoms: const ['headache', 'Dizziness'],
    note: 'Slept badly',
  );

  setUpAll(() {
    registerFallbackValue(day);
    registerFallbackValue(savedEntry);
  });

  setUp(() {
    getEntry = _MockGetEntry();
    saveEntry = _MockSaveEntry();
    deleteEntry = _MockDeleteEntry();
    when(() => getEntry(any())).thenAnswer((_) async => null);
    when(() => saveEntry(any())).thenAnswer((_) async {});
    when(() => deleteEntry(any())).thenAnswer((_) async {});
  });

  WellbeingFormCubit buildCubit() => WellbeingFormCubit(
    date: DateTime(2026, 10, 6, 15, 30),
    getEntry: getEntry,
    saveEntry: saveEntry,
    deleteEntry: deleteEntry,
  );

  group('WellbeingFormCubit', () {
    blocTest<WellbeingFormCubit, WellbeingFormState>(
      'starts an empty entry when the day has none',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        WellbeingFormState(date: day),
        WellbeingFormState(date: day, status: WellbeingFormStatus.editing),
      ],
    );

    blocTest<WellbeingFormCubit, WellbeingFormState>(
      'fills the form from a saved entry',
      setUp: () =>
          when(() => getEntry(day)).thenAnswer((_) async => savedEntry),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.mood, 2);
        expect(cubit.state.symptoms, savedEntry.symptoms);
        expect(cubit.state.note, 'Slept badly');
        expect(cubit.state.isExisting, isTrue);
      },
    );

    blocTest<WellbeingFormCubit, WellbeingFormState>(
      'requires a mood before saving',
      build: buildCubit,
      act: (cubit) => cubit.submit(),
      verify: (cubit) {
        expect(cubit.state.showMoodError, isTrue);
        verifyNever(() => saveEntry(any()));
      },
    );

    blocTest<WellbeingFormCubit, WellbeingFormState>(
      'toggles symptoms and ignores blank or duplicate custom ones',
      build: buildCubit,
      act: (cubit) => cubit
        ..symptomToggled('nausea')
        ..customSymptomAdded('  Dizziness ')
        ..customSymptomAdded('dizziness')
        ..customSymptomAdded('   ')
        ..customSymptomAdded('x' * 41)
        ..symptomToggled('nausea'),
      verify: (cubit) => expect(cubit.state.symptoms, ['Dizziness']),
    );

    blocTest<WellbeingFormCubit, WellbeingFormState>(
      'saves the entry with a trimmed note',
      build: buildCubit,
      act: (cubit) async {
        cubit
          ..moodSelected(4)
          ..symptomToggled('weakness')
          ..noteChanged('  ok  ');
        await cubit.submit();
      },
      verify: (cubit) {
        verify(
          () => saveEntry(
            WellbeingEntry(
              date: day,
              mood: 4,
              symptoms: const ['weakness'],
              note: 'ok',
            ),
          ),
        ).called(1);
        expect(cubit.state.status, WellbeingFormStatus.saved);
      },
    );

    blocTest<WellbeingFormCubit, WellbeingFormState>(
      'deletes the entry of the day',
      build: buildCubit,
      act: (cubit) => cubit.delete(),
      verify: (cubit) {
        verify(() => deleteEntry(day)).called(1);
        expect(cubit.state.status, WellbeingFormStatus.deleted);
      },
    );

    blocTest<WellbeingFormCubit, WellbeingFormState>(
      'reports a failed save',
      setUp: () => when(() => saveEntry(any())).thenThrow(Exception('db')),
      build: buildCubit,
      act: (cubit) async {
        cubit.moodSelected(3);
        await cubit.submit();
      },
      verify: (cubit) =>
          expect(cubit.state.status, WellbeingFormStatus.saveFailure),
      errors: () => [isA<Exception>()],
    );
  });
}
