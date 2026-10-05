import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/features/medications/domain/entities/medication.dart';
import 'package:medtrack/features/medications/domain/usecases/watch_medications.dart';

part 'medications_list_state.dart';

class MedicationsListCubit extends Cubit<MedicationsListState> {
  MedicationsListCubit(this._watchMedications)
    : super(const MedicationsListLoading());

  final WatchMedications _watchMedications;
  StreamSubscription<List<Medication>>? _subscription;

  /// Starts (or restarts after an error) listening to the database.
  void subscribe() {
    emit(const MedicationsListLoading());
    unawaited(_subscription?.cancel());
    _subscription = _watchMedications().listen(
      (medications) => emit(MedicationsListLoaded(medications)),
      onError: (Object error, StackTrace stackTrace) {
        addError(error, stackTrace);
        emit(const MedicationsListError());
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
