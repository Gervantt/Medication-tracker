part of 'today_cubit.dart';

sealed class TodayState extends Equatable {
  const TodayState();

  @override
  List<Object> get props => [];
}

final class TodayLoading extends TodayState {
  const TodayLoading();
}

final class TodayLoaded extends TodayState {
  const TodayLoaded({required this.day, required this.intakes});

  final DateTime day;
  final List<ScheduledIntake> intakes;

  int get takenCount =>
      intakes.where((i) => i.status == IntakeStatus.taken).length;

  @override
  List<Object> get props => [day, intakes];
}

final class TodayError extends TodayState {
  const TodayError();
}
