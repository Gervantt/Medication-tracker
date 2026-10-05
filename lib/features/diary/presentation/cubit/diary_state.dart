part of 'diary_cubit.dart';

sealed class DiaryState extends Equatable {
  const DiaryState();

  @override
  List<Object> get props => [];
}

final class DiaryLoading extends DiaryState {
  const DiaryLoading();
}

final class DiaryLoaded extends DiaryState {
  const DiaryLoaded(this.entries);

  /// Newest first.
  final List<WellbeingEntry> entries;

  @override
  List<Object> get props => [entries];
}

final class DiaryError extends DiaryState {
  const DiaryError();
}
