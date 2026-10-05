abstract interface class OnboardingRepository {
  /// Synchronous, because the router reads it on every redirect.
  bool get isCompleted;

  Future<void> complete();
}
