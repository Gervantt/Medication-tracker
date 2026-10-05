import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/features/onboarding/data/onboarding_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  Future<OnboardingRepositoryImpl> createRepository() async =>
      OnboardingRepositoryImpl(
        await SharedPreferencesWithCache.create(
          cacheOptions: OnboardingRepositoryImpl.cacheOptions,
        ),
      );

  group('OnboardingRepositoryImpl', () {
    test('is not completed on the first launch', () async {
      expect((await createRepository()).isCompleted, isFalse);
    });

    test('remembers completion across app launches', () async {
      await (await createRepository()).complete();

      // A new instance reloads the cache from storage, like a cold start.
      expect((await createRepository()).isCompleted, isTrue);
    });
  });
}
