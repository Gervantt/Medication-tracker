part of 'drug_details_cubit.dart';

sealed class DrugDetailsState extends Equatable {
  const DrugDetailsState();

  @override
  List<Object> get props => [];
}

final class DrugDetailsLoading extends DrugDetailsState {
  const DrugDetailsLoading();
}

final class DrugDetailsLoaded extends DrugDetailsState {
  const DrugDetailsLoaded(this.label);

  final DrugLabel label;

  @override
  List<Object> get props => [label];
}

final class DrugDetailsError extends DrugDetailsState {
  const DrugDetailsError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}
