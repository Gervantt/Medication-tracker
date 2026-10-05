import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/features/diary/domain/entities/wellbeing_entry.dart';
import 'package:medtrack/features/diary/domain/usecases/watch_diary_entries.dart';

part 'diary_state.dart';

class DiaryCubit extends Cubit<DiaryState> {
  DiaryCubit(this._watchDiaryEntries) : super(const DiaryLoading());

  final WatchDiaryEntries _watchDiaryEntries;
  StreamSubscription<List<WellbeingEntry>>? _subscription;

  /// Starts (or restarts after an error) listening to diary entries.
  void subscribe() {
    emit(const DiaryLoading());
    unawaited(_subscription?.cancel());
    _subscription = _watchDiaryEntries().listen(
      (entries) => emit(DiaryLoaded(entries)),
      onError: (Object error, StackTrace stackTrace) {
        addError(error, stackTrace);
        emit(const DiaryError());
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
