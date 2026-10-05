import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/presentation/bloc/drug_search_bloc.dart';
import 'package:medtrack/features/drug_search/presentation/pages/drug_search_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockDrugSearchBloc extends MockBloc<DrugSearchEvent, DrugSearchState>
    implements DrugSearchBloc;

void main() {
  late _MockDrugSearchBloc bloc;

  // DrugSearchEvent is sealed, so a real event serves as the fallback.
  setUpAll(() => registerFallbackValue(const DrugSearchRetried()));

  setUp(() => bloc = _MockDrugSearchBloc());

  Future<void> pumpView(WidgetTester tester, DrugSearchState state) {
    when(() => bloc.state).thenReturn(state);
    return tester.pumpApp(
      BlocProvider<DrugSearchBloc>.value(
        value: bloc,
        child: const DrugSearchView(),
      ),
    );
  }

  group('DrugSearchView', () {
    testWidgets('explains that the database is English-only', (tester) async {
      await pumpView(tester, const DrugSearchState());

      expect(find.textContaining('на английском'), findsOneWidget);
    });

    testWidgets('sends typed queries to the bloc', (tester) async {
      await pumpView(tester, const DrugSearchState());

      await tester.enterText(find.byType(TextField), 'advil');

      verify(() => bloc.add(any(that: isA<DrugSearchQueryChanged>())))
          .called(1);
    });

    testWidgets('shows results with generic name and manufacturer', (
      tester,
    ) async {
      await pumpView(
        tester,
        const DrugSearchState(
          status: DrugSearchStatus.success,
          query: 'advil',
          results: [
            DrugLabel(
              id: '1',
              brandName: 'Advil',
              genericName: 'IBUPROFEN',
              manufacturer: 'Haleon',
            ),
          ],
        ),
      );

      expect(find.text('Advil'), findsOneWidget);
      expect(find.text('IBUPROFEN\nHaleon'), findsOneWidget);
    });

    testWidgets('shows a no-results state', (tester) async {
      await pumpView(
        tester,
        const DrugSearchState(status: DrugSearchStatus.success, query: 'zzz'),
      );

      expect(find.text('Ничего не найдено'), findsOneWidget);
    });

    testWidgets('explains the rate limit and retries', (tester) async {
      await pumpView(
        tester,
        const DrugSearchState(
          status: DrugSearchStatus.failure,
          query: 'advil',
          failure: RateLimitFailure(),
        ),
      );

      expect(find.textContaining('Слишком много запросов'), findsOneWidget);
      await tester.tap(find.text('Повторить'));
      verify(() => bloc.add(any(that: isA<DrugSearchRetried>()))).called(1);
    });
  });
}
