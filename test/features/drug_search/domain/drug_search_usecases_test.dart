import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/repositories/drug_repository.dart';
import 'package:medtrack/features/drug_search/domain/usecases/get_drug_label.dart';
import 'package:medtrack/features/drug_search/domain/usecases/search_drugs.dart';
import 'package:mocktail/mocktail.dart';

class _MockDrugRepository extends Mock implements DrugRepository;

void main() {
  late _MockDrugRepository repository;

  setUp(() => repository = _MockDrugRepository());

  group('Drug search use cases', () {
    test('SearchDrugs trims the query', () async {
      when(() => repository.searchByName('advil'))
          .thenAnswer((_) async => const Ok([]));

      await SearchDrugs(repository)('  advil ');

      verify(() => repository.searchByName('advil')).called(1);
    });

    test('GetDrugLabel passes failures through', () async {
      when(() => repository.getById('42'))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await GetDrugLabel(repository)('42');

      expect(
        result,
        isA<Err<DrugLabel>>().having(
          (e) => e.failure,
          'failure',
          isA<NotFoundFailure>(),
        ),
      );
    });
  });
}
