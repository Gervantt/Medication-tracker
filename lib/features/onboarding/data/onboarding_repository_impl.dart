import 'package:medtrack/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backed by [SharedPreferencesWithCache]: values are loaded once on
/// startup, then read synchronously from memory.
class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._preferences);

  static const completedKey = 'onboarding_completed';
  static const cacheOptions = SharedPreferencesWithCacheOptions(
    allowList: {completedKey},
  );

  final SharedPreferencesWithCache _preferences;

  @override
  bool get isCompleted => _preferences.getBool(completedKey) ?? false;

  @override
  Future<void> complete() => _preferences.setBool(completedKey, true);
}
