import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/usecases/get_drug_label.dart';
import 'package:medtrack/features/drug_search/presentation/cubit/drug_details_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetDrugLabel extends Mock implements GetDrugLabel;

void main() {
  late _MockGetDrugLabel getDrugLabel;
  const label = DrugLabel(id: '1', brandName: 'Advil');

  setUp(() => getDrugLabel = _MockGetDrugLabel());

  group('DrugDetailsCubit', () {
    blocTest<DrugDetailsCubit, DrugDetailsState>(
      'shows a label from the search without a request',
      build: () => DrugDetailsCubit(getDrugLabel),
      act: (cubit) => cubit.show(label),
      expect: () => const [DrugDetailsLoaded(label)],
      verify: (_) => verifyNever(() => getDrugLabel(any())),
    );

    blocTest<DrugDetailsCubit, DrugDetailsState>(
      'loads a label by id',
      setUp: () =>
          when(() => getDrugLabel('1'))
              .thenAnswer((_) async => const Ok(label)),
      build: () => DrugDetailsCubit(getDrugLabel),
      act: (cubit) => cubit.load('1'),
      expect: () => const [DrugDetailsLoading(), DrugDetailsLoaded(label)],
    );

    blocTest<DrugDetailsCubit, DrugDetailsState>(
      'emits the failure when loading fails',
      setUp: () =>
          when(() => getDrugLabel('1'))
              .thenAnswer((_) async => const Err(NetworkFailure())),
      build: () => DrugDetailsCubit(getDrugLabel),
      act: (cubit) => cubit.load('1'),
      expect: () => [
        const DrugDetailsLoading(),
        isA<DrugDetailsError>().having(
          (s) => s.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      ],
    );
  });
}
