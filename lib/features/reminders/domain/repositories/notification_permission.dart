abstract interface class NotificationPermission {
  /// Shows the system prompt (Android 13+, iOS) and returns whether
  /// notifications are allowed.
  Future<bool> requestNotificationPermission();
}
