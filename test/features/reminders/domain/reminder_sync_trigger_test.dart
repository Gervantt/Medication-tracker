import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/reminders/domain/usecases/reminder_sync_trigger.dart';
import 'package:medtrack/features/reminders/domain/usecases/sync_reminders.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicationRepository extends Mock implements MedicationRepository;

class _MockIntakeRepository extends Mock implements IntakeRepository;

class _MockSyncReminders extends Mock implements SyncReminders;

void main() {
  setUpAll(() => registerFallbackValue(DateTime(2000)));

  test('syncs once per burst of database changes', () {
    fakeAsync((async) {
      final medications = StreamController<List<Medication>>();
      final intakes = StreamController<List<Intake>>();
      final medicationRepository = _MockMedicationRepository();
      final intakeRepository = _MockIntakeRepository();
      final syncReminders = _MockSyncReminders();
      when(medicationRepository.watchMedications)
          .thenAnswer((_) => medications.stream);
      when(
        () => intakeRepository.watchIntakes(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => intakes.stream);
      when(syncReminders.call).thenAnswer((_) async {});

      ReminderSyncTrigger(
        medicationRepository,
        intakeRepository,
        syncReminders,
      ).start();

      medications.add(const []);
      intakes.add(const []);
      async.elapse(ReminderSyncTrigger.debounce * 2);
      verify(syncReminders.call).called(1);

      intakes.add(const []);
      async.elapse(ReminderSyncTrigger.debounce * 2);
      verify(syncReminders.call).called(1);
    });
  });
}
