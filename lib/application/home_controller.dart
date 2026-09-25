import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/focus_domain.dart';
import '../domain/home_state.dart';
import '../domain/restriction_platform.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required this.platform,
    required this.clock,
    FocusDomain? domain,
    bool autoTick = true,
  }) : _domain = domain ?? FocusDomain() {
    _sync();
    ready = _initialize();
    if (autoTick) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => unawaited(refresh()),
      );
    }
  }
  final RestrictionPlatform platform;
  final AppClock clock;
  final FocusDomain _domain;
  late final Future<void> ready;
  Timer? _timer;
  late HomeState _state;
  List<TargetApp> _apps = const [];
  bool _busy = false;
  bool _disposed = false;
  bool _initialized = false;
  String? _error;
  HomeState get state => _state;
  List<TargetApp> get availableApps => _apps;
  bool get busy => _busy;
  bool get initialized => _initialized;
  bool get isMock => platform.isMock;
  bool get canAdvanceTime => isMock && clock is AdjustableClock;
  String? get error => _error;

  Future<void> _initialize() async {
    await _run(() async {
      _apps = List.unmodifiable(await platform.availableApps());
      _initialized = true;
      await _reconcile();
    });
  }

  void _sync() {
    _state = _domain.snapshot(clock.now);
    if (!_disposed) notifyListeners();
  }

  Future<String?> _run(Future<void> Function() action) async {
    if (_busy) return '正在处理上一项操作，请稍候。';
    _busy = true;
    _error = null;
    _sync();
    try {
      await action();
      return null;
    } on DomainFailure catch (error) {
      // Form/business validation belongs to the invoking page, not global UI.
      return error.message;
    } catch (_) {
      _error = '平台操作未成功，限制与时间池尚未结算。请重试。';
      return _error;
    } finally {
      _busy = false;
      _sync();
    }
  }

  Future<void> refresh() async {
    if (_busy || !_initialized || _disposed) return;
    _sync();
    final session = _state.activeSession;
    final due = session != null && !clock.now.isBefore(session.endsAt);
    final ruleDue = session == null && _domain.hasScheduled(clock.now);
    if (due || ruleDue) await _run(_reconcile);
  }

  Future<void> _reconcile() async {
    final session = _domain.snapshot(clock.now).activeSession;
    if (session != null && !clock.now.isBefore(session.endsAt)) {
      await _settle(session.id);
    }
    final scheduled = _domain.planScheduled(clock.now);
    if (scheduled != null) await _start(scheduled);
  }

  Future<void> _start(RestrictionSession session) async {
    await platform.startRestriction(session);
    _domain.activate(session);
  }

  Future<void> _settle(String id, {bool earlyExit = false}) async {
    // Quote at the action time. Never round the debit or deduct before OS success.
    final plan = _domain.prepareSettlement(id, clock.now, earlyExit: earlyExit);
    await platform.stopRestriction(id);
    _domain.commitSettlement(plan);
  }

  Future<String?> startTemporary(List<TargetApp> apps, Duration duration) =>
      _run(() async {
        if (!_initialized) throw const DomainFailure('App 列表尚未就绪，请稍后重试。');
        await _reconcile();
        if (apps.any((app) => !_apps.any((known) => known.id == app.id))) {
          throw const DomainFailure('选择的 App 已不可用，请重新选择。');
        }
        await _start(_domain.planTemporary(apps, duration, clock.now));
      });

  Future<String?> earlyExit(String sessionId) =>
      _run(() => _settle(sessionId, earlyExit: true));
  bool canExit(String sessionId) => _domain.canExit(sessionId, clock.now);

  Future<String?> saveRule({
    String? id,
    required String name,
    required List<TargetApp> apps,
    required int startMinute,
    required int endMinute,
    required bool enabled,
  }) async {
    final error = await _run(() async {
      if (apps.any((app) => !_apps.any((known) => known.id == app.id))) {
        throw const DomainFailure('选择的 App 已不可用，请重新选择。');
      }
      _domain.saveRule(
        AppRule(
          id: id ?? _domain.nextId('rule'),
          name: name,
          apps: apps,
          startMinute: startMinute,
          endMinute: endMinute,
          enabled: enabled,
        ),
      );
    });
    if (error == null) await refresh();
    return error;
  }

  Future<String?> setRuleEnabled(String id, bool enabled) async {
    final error = await _run(() async => _domain.setRuleEnabled(id, enabled));
    if (error == null) await refresh();
    return error;
  }

  void acknowledge(String id) {
    _domain.acknowledge(id);
    _sync();
  }

  void clearError() {
    _error = null;
    _sync();
  }

  Future<void> retry() => _initialized ? refresh() : _initialize();

  Future<String?> advanceMockTime(Duration duration) => _run(() async {
    if (!canAdvanceTime) throw const DomainFailure('当前平台不支持模拟时间。');
    (clock as AdjustableClock).advance(duration);
    await _reconcile();
  });

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
