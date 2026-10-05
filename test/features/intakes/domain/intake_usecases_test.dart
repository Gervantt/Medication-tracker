import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/intakes/domain/usecases/clear_intake_mark.dart';
import 'package:medtrack/features/intakes/domain/usecases/mark_intake.dart';
import 'package:mocktail/mocktail.dart';

class _MockIntakeRepository extends Mock implements IntakeRepository;

void main() {
  late _MockIntakeRepository repository;
  final scheduledAt = DateTime(2026, 10, 6, 8);

  setUpAll(() {
    registerFallbackValue(
      Intake(
        medicationId: 0,
        scheduledAt: DateTime(2000),
        status: IntakeStatus.taken,
        recordedAt: DateTime(2000),
      ),
    );
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    repository = _MockIntakeRepository();
    when(() => repository.saveIntake(any())).thenAnswer((_) async {});
    when(
      () => repository.clearIntake(
        medicationId: any(named: 'medicationId'),
        scheduledAt: any(named: 'scheduledAt'),
      ),
    ).thenAnswer((_) async {});
  });

  group('Intake use cases', () {
    test('MarkIntake records when the user marked the intake', () async {
      final now = DateTime(2026, 10, 6, 8, 12);

      await withClock(
        Clock.fixed(now),
        () => MarkIntake(repository)(
          medicationId: 1,
          scheduledAt: scheduledAt,
          status: IntakeStatus.skipped,
        ),
      );

      verify(
        () => repository.saveIntake(
          Intake(
            medicationId: 1,
            scheduledAt: scheduledAt,
            status: IntakeStatus.skipped,
            recordedAt: now,
          ),
        ),
      ).called(1);
    });

    test('ClearIntakeMark clears the slot', () async {
      await ClearIntakeMark(repository)(
        medicationId: 1,
        scheduledAt: scheduledAt,
      );

      verify(
        () => repository.clearIntake(medicationId: 1, scheduledAt: scheduledAt),
      ).called(1);
    });
  });
}
