import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/usecases/get_drug_label.dart';

part 'drug_details_state.dart';

class DrugDetailsCubit extends Cubit<DrugDetailsState> {
  DrugDetailsCubit(this._getDrugLabel) : super(const DrugDetailsLoading());

  final GetDrugLabel _getDrugLabel;

  /// Shows a label already loaded by the search, without a request.
  void show(DrugLabel label) => emit(DrugDetailsLoaded(label));

  /// Fetches the label, e.g. when the page is opened by a deep link.
  Future<void> load(String id) async {
    emit(const DrugDetailsLoading());
    final result = await _getDrugLabel(id);
    emit(switch (result) {
      Ok(:final value) => DrugDetailsLoaded(value),
      Err(:final failure) => DrugDetailsError(failure),
    });
  }
}
