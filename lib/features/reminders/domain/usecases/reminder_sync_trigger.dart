import 'dart:async';
import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:medtrack/features/intakes/domain/repositories/intake_repository.dart';
import 'package:medtrack/features/medications/domain/repositories/medication_repository.dart';
import 'package:medtrack/features/reminders/domain/usecases/sync_reminders.dart';
import 'package:rxdart/rxdart.dart';

/// Keeps reminders in sync with the database: any change to medications
/// or to intake marks in the reminder window triggers [SyncReminders].
///
/// Reminders become a projection of the data, so no screen or use case
/// has to remember to reschedule them after a change.
class ReminderSyncTrigger {
  ReminderSyncTrigger(this._medications, this._intakes, this._syncReminders);

  static const debounce = Duration(milliseconds: 500);

  final MedicationRepository _medications;
  final IntakeRepository _intakes;
  final SyncReminders _syncReminders;

  StreamSubscription<void>? _subscription;

  /// (Re)starts watching. Call on app start and on resume, because the
  /// reminder window moves with the current day.
  void start() {
    unawaited(_subscription?.cancel());
    final (from, to) = SyncReminders.window(clock.now());
    _subscription =
        Rx.merge<Object>([
              _medications.watchMedications(),
              _intakes.watchIntakes(from: from, to: to),
            ])
            .debounceTime(debounce)
            // asyncMap waits for each sync, so two never run concurrently.
            .asyncMap((_) => _syncReminders())
            .listen(
              null,
              onError: (Object error, StackTrace stackTrace) => log(
                'Reminder sync failed',
                name: 'reminders',
                error: error,
                stackTrace: stackTrace,
              ),
            );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
