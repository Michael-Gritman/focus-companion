import '../domain/home_state.dart';
import '../domain/restriction_platform.dart';

const mockApps = [
  TargetApp(
    id: AppIdentifier(platform: 'mock', value: 'tiktok'),
    name: 'TikTok',
  ),
  TargetApp(
    id: AppIdentifier(platform: 'mock', value: 'instagram'),
    name: 'Instagram',
  ),
  TargetApp(
    id: AppIdentifier(platform: 'mock', value: 'youtube'),
    name: 'YouTube',
  ),
  TargetApp(
    id: AppIdentifier(platform: 'mock', value: 'x'),
    name: 'X',
  ),
  TargetApp(
    id: AppIdentifier(platform: 'mock', value: 'reddit'),
    name: 'Reddit',
  ),
];

class MockClock implements AdjustableClock {
  MockClock({DateTime Function()? wallClock})
    : _wallClock = wallClock ?? DateTime.now;
  final DateTime Function() _wallClock;
  Duration _offset = Duration.zero;
  @override
  DateTime get now => _wallClock().add(_offset);
  @override
  void advance(Duration amount) {
    if (amount.isNegative) throw const DomainFailure('模拟时间只能向前推进。');
    _offset += amount;
  }
}

class MockRestrictionPlatform implements RestrictionPlatform {
  MockRestrictionPlatform({required this.clock});
  final AppClock clock;
  RestrictionSession? _active;
  @override
  bool get isMock => true;
  @override
  Future<List<TargetApp>> availableApps() async => mockApps;
  @override
  Future<void> startRestriction(RestrictionSession session) async {
    if (_active != null && _active!.id != session.id) {
      throw StateError('Another session is active');
    }
    if (session.apps.any(
      (app) => !mockApps.any((known) => known.id == app.id),
    )) {
      throw StateError('Unknown mock app');
    }
    _active = session;
  }

  @override
  Future<void> stopRestriction(String sessionId) async {
    if (_active?.id == sessionId) _active = null;
  }

  @override
  Future<bool> isRestrictionActive(String sessionId) async =>
      _active?.id == sessionId && _active!.isActiveAt(clock.now);
}

class UnavailableTimeCoinExchange implements TimeCoinExchange {
  const UnavailableTimeCoinExchange();
  @override
  bool get available => false;
  @override
  CoinExchangeQuote? quote(Duration time) => null;
}
