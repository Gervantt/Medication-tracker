import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/presentation/cubit/diary_cubit.dart';
import 'package:medtrack/features/diary/presentation/pages/diary_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockDiaryCubit extends MockCubit<DiaryState> implements DiaryCubit;

void main() {
  testWidgets('shows entries with relative days, mood and symptoms', (
    tester,
  ) async {
    final cubit = _MockDiaryCubit();
    final today = clock.now();
    when(() => cubit.state).thenReturn(
      DiaryLoaded([
        WellbeingEntry(
          date: DateTime(today.year, today.month, today.day),
          mood: 5,
          symptoms: const ['nausea', 'Dizziness'],
          note: 'Felt fine',
        ),
        WellbeingEntry(
          date: DateTime(today.year, today.month, today.day - 1),
          mood: 1,
        ),
      ]),
    );

    await tester.pumpApp(
      BlocProvider<DiaryCubit>.value(value: cubit, child: const DiaryView()),
    );

    expect(find.text('Сегодня'), findsOneWidget);
    expect(find.text('Вчера'), findsOneWidget);
    expect(find.text('😄'), findsOneWidget);
    expect(find.text('Отлично · Тошнота · Dizziness\nFelt fine'), findsOne);
    expect(find.text('Очень плохо'), findsOneWidget);
  });
}
