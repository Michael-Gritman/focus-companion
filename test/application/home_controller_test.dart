import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:focus_companion/application/home_controller.dart';
import 'package:focus_companion/domain/focus_domain.dart';
import 'package:focus_companion/domain/home_state.dart';
import 'package:focus_companion/platform/mock_restriction_platform.dart';

class ControlledPlatform extends MockRestrictionPlatform {
  ControlledPlatform({required super.clock});
  bool failStart = false, failStop = false;
  int starts = 0, stops = 0;
  Completer<void>? gate;
  @override
  Future<void> startRestriction(RestrictionSession session) async {
    starts++;
    if (gate != null) await gate!.future;
    if (failStart) throw StateError('start failed');
    await super.startRestriction(session);
  }

  @override
  Future<void> stopRestriction(String id) async {
    stops++;
    if (failStop) throw StateError('stop failed');
    await super.stopRestriction(id);
  }
}

void main() {
  late MockClock clock;
  late ControlledPlatform platform;
  late HomeController controller;
  setUp(() {
    clock = MockClock(wallClock: () => DateTime(2026, 9, 8, 12));
    platform = ControlledPlatform(clock: clock);
    controller = HomeController(
      platform: platform,
      clock: clock,
      autoTick: false,
    );
  });
  tearDown(() => controller.dispose());

  test(
    'start failure leaves domain and ledger unchanged, retry works',
    () async {
      await controller.ready;
      platform.failStart = true;
      expect(
        await controller.startTemporary([
          mockApps.first,
        ], const Duration(minutes: 30)),
        isNotNull,
      );
      expect(controller.state.activeSession, isNull);
      expect(controller.state.timePool.transactions, isEmpty);
      platform.failStart = false;
      expect(
        await controller.startTemporary([
          mockApps.first,
        ], const Duration(minutes: 30)),
        isNull,
      );
      expect(
        await platform.isRestrictionActive(controller.state.activeSession!.id),
        isTrue,
      );
    },
  );

  test('stop failure does not award; repeated refresh settles only once after recovery', () async {
    await controller.ready;
    await controller.startTemporary([
      mockApps.first,
    ], const Duration(minutes: 30));
    platform.failStop = true;
    clock.advance(const Duration(hours: 1));
    await controller.refresh();
    expect(controller.state.activeSession, isNotNull);
    expect(controller.state.timePool.balance, Duration.zero);
    platform.failStop = false;
    await controller.refresh();
    await controller.refresh();
    expect(controller.state.activeSession, isNull);
    expect(controller.state.timePool.balance, const Duration(minutes: 30));
    expect(controller.state.timePool.transactions, hasLength(1));
  });

  test('insufficient early exit never calls platform stop', () async {
    await controller.ready;
    await controller.startTemporary([
      mockApps.first,
    ], const Duration(minutes: 30));
    expect(
      await controller.earlyExit(controller.state.activeSession!.id),
      isNotNull,
    );
    expect(platform.stops, 0);
    expect(controller.state.activeSession, isNotNull);
  });

  test('failed early stop cannot debit pool', () async {
    controller.dispose();
    controller = HomeController(
      platform: platform,
      clock: clock,
      autoTick: false,
      domain: FocusDomain(
        initialPool: TimePool(balance: const Duration(minutes: 40)),
      ),
    );
    await controller.ready;
    await controller.startTemporary([
      mockApps.first,
    ], const Duration(minutes: 20));
    final id = controller.state.activeSession!.id;
    platform.failStop = true;
    expect(await controller.earlyExit(id), isNotNull);
    expect(controller.state.timePool.balance, const Duration(minutes: 40));
    expect(controller.state.activeSession!.id, id);
    platform.failStop = false;
    expect(await controller.earlyExit(id), isNull);
    expect(controller.state.timePool.balance, const Duration(minutes: 20));
  });

  test('rapid duplicate starts are serialized across platform await', () async {
    await controller.ready;
    platform.gate = Completer<void>();
    final pending = controller.startTemporary([
      mockApps.first,
    ], const Duration(minutes: 30));
    await Future<void>.delayed(Duration.zero);
    expect(
      await controller.startTemporary([
        mockApps.first,
      ], const Duration(minutes: 30)),
      isNotNull,
    );
    platform.gate!.complete();
    expect(await pending, isNull);
    expect(platform.starts, 1);
  });

  test('Rule save, automatic start, disable and next-day scheduling', () async {
    await controller.ready;
    expect(
      await controller.saveRule(
        name: '每日限制',
        apps: [mockApps.first],
        startMinute: 12 * 60 + 1,
        endMinute: 13 * 60,
        enabled: true,
      ),
      isNull,
    );
    expect(controller.state.scenario, HomeScenario.ruleIdle);
    await controller.advanceMockTime(const Duration(minutes: 1));
    expect(controller.state.scenario, HomeScenario.ruleActive);
    final rule = controller.state.rules.single;
    final active = controller.state.activeSession!;
    await controller.setRuleEnabled(rule.id, false);
    expect(controller.state.activeSession!.id, active.id);
    await controller.advanceMockTime(const Duration(hours: 24));
    expect(controller.state.activeSession, isNull);
    expect(controller.state.timePool.balance, const Duration(minutes: 59));
    await controller.setRuleEnabled(rule.id, true);
    expect(controller.state.activeSession!.origin, RestrictionOrigin.rule);
  });

  test(
    'failed scheduled start retries without consuming the Rule occurrence',
    () async {
      await controller.ready;
      platform.failStart = true;
      await controller.saveRule(
        name: '当前时段',
        apps: [mockApps.first],
        startMinute: 660,
        endMinute: 780,
        enabled: true,
      );
      expect(controller.state.rules, hasLength(1));
      expect(controller.state.activeSession, isNull);
      platform.failStart = false;
      await controller.refresh();
      expect(controller.state.scenario, HomeScenario.ruleActive);
    },
  );

  test('advance and early exit at deadline cannot settle twice', () async {
    await controller.ready;
    await controller.startTemporary([
      mockApps.first,
    ], const Duration(minutes: 1));
    final id = controller.state.activeSession!.id;
    clock.advance(const Duration(minutes: 1));
    expect(await controller.earlyExit(id), isNull);
    await controller.refresh();
    expect(await controller.earlyExit(id), isNotNull);
    expect(controller.state.timePool.balance, const Duration(minutes: 1));
    expect(controller.state.timePool.transactions, hasLength(1));
  });
}
