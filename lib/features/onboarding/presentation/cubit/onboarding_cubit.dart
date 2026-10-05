import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtrack/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:medtrack/features/reminders/domain/repositories/notification_permission.dart';

enum OnboardingStatus { idle, requestingPermission, completed }

class OnboardingCubit extends Cubit<OnboardingStatus> {
  OnboardingCubit({
    required this._repository,
    required this._notificationPermission,
  }) : super(OnboardingStatus.idle);

  final OnboardingRepository _repository;
  final NotificationPermission _notificationPermission;

  /// Asks for notifications at the moment the user understands why,
  /// instead of on the first launch.
  Future<void> enableReminders() async {
    emit(OnboardingStatus.requestingPermission);
    try {
      await _notificationPermission.requestNotificationPermission();
    } on Object catch (error, stackTrace) {
      // A denied or failed prompt must not block the user in onboarding.
      addError(error, stackTrace);
    }
    await _complete();
  }

  Future<void> skipReminders() => _complete();

  Future<void> _complete() async {
    await _repository.complete();
    emit(OnboardingStatus.completed);
  }
}
