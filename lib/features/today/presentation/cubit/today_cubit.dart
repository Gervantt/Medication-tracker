import 'dart:async';

import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/extensions/date_time_extensions.dart';
import 'package:medtrack/features/intakes/domain/entities/intake.dart';
import 'package:medtrack/features/intakes/domain/usecases/clear_intake_mark.dart';
import 'package:medtrack/features/intakes/domain/usecases/mark_intake.dart';
import 'package:medtrack/features/today/domain/entities/scheduled_intake.dart';
import 'package:medtrack/features/today/domain/usecases/watch_day_intakes.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayState> {
  TodayCubit({
    required this._watchDayIntakes,
    required this._markIntake,
    required this._clearIntakeMark,
  }) : super(const TodayLoading());

  final WatchDayIntakes _watchDayIntakes;
  final MarkIntake _markIntake;
  final ClearIntakeMark _clearIntakeMark;

  StreamSubscription<List<ScheduledIntake>>? _subscription;
  DateTime? _day;

  /// Starts (or restarts) watching today's intakes.
  void subscribe() {
    final day = clock.now().dateOnly;
    _day = day;
    emit(const TodayLoading());
    unawaited(_subscription?.cancel());
    _subscription = _watchDayIntakes(day).listen(
      (intakes) => emit(TodayLoaded(day: day, intakes: intakes)),
      onError: (Object error, StackTrace stackTrace) {
        addError(error, stackTrace);
        emit(const TodayError());
      },
    );
  }

  /// Switches to the new day if midnight passed while the app was open
  /// or in the background.
  void refreshIfDayChanged() {
    if (clock.now().dateOnly != _day) subscribe();
  }

  Future<void> markTaken(ScheduledIntake intake) =>
      _mark(intake, IntakeStatus.taken);

  Future<void> markSkipped(ScheduledIntake intake) =>
      _mark(intake, IntakeStatus.skipped);

  Future<void> undo(ScheduledIntake intake) => _guard(
    () => _clearIntakeMark(
      medicationId: intake.medication.id!,
      scheduledAt: intake.scheduledAt,
    ),
  );

  // The UI updates through the watched stream, so success needs no emit.
  Future<void> _mark(ScheduledIntake intake, IntakeStatus status) => _guard(
    () => _markIntake(
      medicationId: intake.medication.id!,
      scheduledAt: intake.scheduledAt,
      status: status,
    ),
  );

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
