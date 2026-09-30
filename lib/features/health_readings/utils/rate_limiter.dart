class RateLimiter {
  RateLimiter._();
  static final RateLimiter _instance = RateLimiter._();
  static RateLimiter get instance => _instance;

  final Map<String, List<DateTime>> _actionTimestamps = {};

  bool canPerformAction(
      String actionKey, {
        int maxActions = 10,
        Duration window = const Duration(minutes: 5),
      }) {
    final now = DateTime.now();
    final timestamps = _actionTimestamps[actionKey] ?? [];

    timestamps.removeWhere((time) => now.difference(time) > window);

    if (timestamps.length >= maxActions) {
      _actionTimestamps[actionKey] = timestamps;
      return false;
    }

    timestamps.add(now);
    _actionTimestamps[actionKey] = timestamps;
    return true;
  }

  Duration? getWaitTime(
      String actionKey, {
        int maxActions = 10,
        Duration window = const Duration(minutes: 5),
      }) {
    final now = DateTime.now();
    final timestamps = _actionTimestamps[actionKey] ?? [];

    timestamps.removeWhere((time) => now.difference(time) > window);

    if (timestamps.length < maxActions) return null;

    final oldestTimestamp = timestamps.first;
    final waitUntil = oldestTimestamp.add(window);

    if (waitUntil.isAfter(now)) {
      return waitUntil.difference(now);
    }

    return null;
  }

  int getRemainingActions(
      String actionKey, {
        int maxActions = 10,
        Duration window = const Duration(minutes: 5),
      }) {
    final now = DateTime.now();
    final timestamps = _actionTimestamps[actionKey] ?? [];

    timestamps.removeWhere((time) => now.difference(time) > window);
    _actionTimestamps[actionKey] = timestamps;

    return (maxActions - timestamps.length).clamp(0, maxActions);
  }

  void reset(String actionKey) {
    _actionTimestamps.remove(actionKey);
  }

  void resetAll() {
    _actionTimestamps.clear();
  }

  bool isBlocked(
      String actionKey, {
        int maxActions = 10,
        Duration window = const Duration(minutes: 5),
      }) {
    return !canPerformAction(actionKey, maxActions: maxActions, window: window);
  }
}

class RateLimitConfig {
  RateLimitConfig._();

  static const int maxSaveActions = 20;
  static const Duration saveWindow = Duration(minutes: 10);

  static const int maxDeleteActions = 10;
  static const Duration deleteWindow = Duration(hours: 1);

  static const int maxUpdateActions = 30;
  static const Duration updateWindow = Duration(minutes: 15);

  static String createKey(String action, String userId) {
    return '${action}_$userId';
  }
}