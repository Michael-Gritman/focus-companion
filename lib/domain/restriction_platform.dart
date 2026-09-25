import 'home_state.dart';

/// Implementations must make start/stop idempotent by session id.
/// A successful start acknowledges enforcement; errors must be thrown.
abstract interface class RestrictionPlatform {
  bool get isMock;
  Future<List<TargetApp>> availableApps();
  Future<void> startRestriction(RestrictionSession session);
  Future<void> stopRestriction(String sessionId);
  Future<bool> isRestrictionActive(String sessionId);
}

abstract interface class AppClock {
  DateTime get now;
}

abstract interface class AdjustableClock implements AppClock {
  void advance(Duration amount);
}
