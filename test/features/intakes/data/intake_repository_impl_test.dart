import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/core/database/app_database.dart';
import 'package:medtrack/features/intakes/data/repositories/intake_repository_impl.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';

void main() {
  late AppDatabase database;
  late IntakeRepositoryImpl repository;
  late int medicationId;

  final scheduledAt = DateTime(2026, 10, 5, 8);

  Intake intake(IntakeStatus status) => Intake(
    medicationId: medicationId,
    scheduledAt: scheduledAt,
    status: status,
    recordedAt: scheduledAt,
  );

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = IntakeRepositoryImpl(database.intakesDao);
    medicationId = await database.medicationsDao.insertWithSchedules(
      MedicationsCompanion.insert(
        name: 'Ibuprofen',
        dosageAmount: 200,
        dosageUnit: 'mg',
        form: 'tablet',
        weekdays: 127,
        startDate: DateTime(2026, 10),
        colorValue: 0,
      ),
      [480],
    );
  });

  tearDown(() => database.close());

  group('IntakeRepositoryImpl', () {
    test('saving the same slot twice overwrites the status', () async {
      await repository.saveIntake(intake(IntakeStatus.skipped));
      await repository.saveIntake(intake(IntakeStatus.taken));

      final intakes = await repository.getIntakes(
        from: DateTime(2026, 10, 5),
        to: DateTime(2026, 10, 6),
      );

      expect(intakes, [intake(IntakeStatus.taken)]);
    });

    test('range excludes the upper bound', () async {
      await repository.saveIntake(intake(IntakeStatus.taken));

      final intakes = await repository.getIntakes(
        from: DateTime(2026, 10, 4),
        to: scheduledAt,
      );

      expect(intakes, isEmpty);
    });

    test('clearIntake removes the mark', () async {
      await repository.saveIntake(intake(IntakeStatus.taken));

      await repository.clearIntake(
        medicationId: medicationId,
        scheduledAt: scheduledAt,
      );

      expect(
        await repository.getIntakes(
          from: DateTime(2026, 10, 5),
          to: DateTime(2026, 10, 6),
        ),
        isEmpty,
      );
    });
  });
}
