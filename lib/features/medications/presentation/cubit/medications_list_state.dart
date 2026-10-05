part of 'medications_list_cubit.dart';

sealed class MedicationsListState extends Equatable {
  const MedicationsListState();

  @override
  List<Object> get props => [];
}

final class MedicationsListLoading extends MedicationsListState {
  const MedicationsListLoading();
}

final class MedicationsListLoaded extends MedicationsListState {
  const MedicationsListLoaded(this.medications);

  final List<Medication> medications;

  @override
  List<Object> get props => [medications];
}

final class MedicationsListError extends MedicationsListState {
  const MedicationsListError();
}
