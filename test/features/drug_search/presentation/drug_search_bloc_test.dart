import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/usecases/search_drugs.dart';
import 'package:medtrack/features/drug_search/presentation/bloc/drug_search_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockSearchDrugs extends Mock implements SearchDrugs;

void main() {
  late _MockSearchDrugs searchDrugs;
  const debounce = Duration(milliseconds: 20);
  const wait = Duration(milliseconds: 60);
  const advil = DrugLabel(id: '1', brandName: 'Advil');

  setUp(() {
    searchDrugs = _MockSearchDrugs();
    when(() => searchDrugs(any())).thenAnswer((_) async => const Ok([advil]));
  });

  DrugSearchBloc build() => DrugSearchBloc(searchDrugs, debounce: debounce);

  group('DrugSearchBloc', () {
    blocTest<DrugSearchBloc, DrugSearchState>(
      'searches only for the last query after typing stops',
      build: build,
      act: (bloc) => bloc
        ..add(const DrugSearchQueryChanged('ad'))
        ..add(const DrugSearchQueryChanged('adv'))
        ..add(const DrugSearchQueryChanged(' advil ')),
      wait: wait,
      expect: () => const [
        DrugSearchState(status: DrugSearchStatus.loading, query: 'advil'),
        DrugSearchState(
          status: DrugSearchStatus.success,
          query: 'advil',
          results: [advil],
        ),
      ],
      verify: (_) {
        verify(() => searchDrugs('advil')).called(1);
        verifyNever(() => searchDrugs('ad'));
      },
    );

    blocTest<DrugSearchBloc, DrugSearchState>(
      'does not search for too short queries',
      build: build,
      seed: () => const DrugSearchState(
        status: DrugSearchStatus.success,
        query: 'advil',
        results: [advil],
      ),
      act: (bloc) => bloc.add(const DrugSearchQueryChanged('a')),
      wait: wait,
      expect: () => const [DrugSearchState(query: 'a')],
      verify: (_) => verifyNever(() => searchDrugs(any())),
    );

    blocTest<DrugSearchBloc, DrugSearchState>(
      'shows a failure and retries the same query',
      setUp: () {
        var calls = 0;
        when(() => searchDrugs('advil')).thenAnswer(
          (_) async =>
              calls++ == 0 ? const Err(RateLimitFailure()) : const Ok([advil]),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const DrugSearchQueryChanged('advil'));
        await Future<void>.delayed(wait);
        bloc.add(const DrugSearchRetried());
      },
      wait: wait,
      expect: () => [
        const DrugSearchState(status: DrugSearchStatus.loading, query: 'advil'),
        isA<DrugSearchState>()
            .having((s) => s.status, 'status', DrugSearchStatus.failure)
            .having((s) => s.failure, 'failure', isA<RateLimitFailure>()),
        const DrugSearchState(status: DrugSearchStatus.loading, query: 'advil'),
        const DrugSearchState(
          status: DrugSearchStatus.success,
          query: 'advil',
          results: [advil],
        ),
      ],
    );

    blocTest<DrugSearchBloc, DrugSearchState>(
      'reports an empty result as success without results',
      setUp: () =>
          when(() => searchDrugs(any())).thenAnswer((_) async => const Ok([])),
      build: build,
      act: (bloc) => bloc.add(const DrugSearchQueryChanged('zzz')),
      wait: wait,
      skip: 1,
      expect: () => const [
        DrugSearchState(status: DrugSearchStatus.success, query: 'zzz'),
      ],
    );
  });
}
