import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:medtrack/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:medtrack/features/reminders/domain/repositories/notification_permission.dart';
import 'package:mocktail/mocktail.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository;

class _MockNotificationPermission extends Mock
    implements NotificationPermission;

void main() {
  late _MockOnboardingRepository repository;
  late _MockNotificationPermission permission;

  setUp(() {
    repository = _MockOnboardingRepository();
    permission = _MockNotificationPermission();
    when(repository.complete).thenAnswer((_) async {});
  });

  OnboardingCubit build() => OnboardingCubit(
    repository: repository,
    notificationPermission: permission,
  );

  group('OnboardingCubit', () {
    blocTest<OnboardingCubit, OnboardingStatus>(
      'requests notifications, then completes',
      setUp: () =>
          when(permission.requestNotificationPermission)
              .thenAnswer((_) async => true),
      build: build,
      act: (cubit) => cubit.enableReminders(),
      expect: () => const [
        OnboardingStatus.requestingPermission,
        OnboardingStatus.completed,
      ],
      verify: (_) => verify(repository.complete).called(1),
    );

    blocTest<OnboardingCubit, OnboardingStatus>(
      'completes even if the permission prompt fails',
      setUp: () =>
          when(permission.requestNotificationPermission)
              .thenThrow(Exception('plugin')),
      build: build,
      act: (cubit) => cubit.enableReminders(),
      expect: () => const [
        OnboardingStatus.requestingPermission,
        OnboardingStatus.completed,
      ],
      errors: () => [isA<Exception>()],
    );

    blocTest<OnboardingCubit, OnboardingStatus>(
      'skipping does not ask for notifications',
      build: build,
      act: (cubit) => cubit.skipReminders(),
      expect: () => const [OnboardingStatus.completed],
      verify: (_) => verifyNever(permission.requestNotificationPermission),
    );
  });
}
