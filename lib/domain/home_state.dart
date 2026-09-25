enum HomeScenario { noRule, ruleIdle, ruleActive, restrictionActive }

enum RestrictionOrigin { temporary, rule }

enum RestrictionStatus { active, completed, earlyExited }

enum CoreEventKind { reward, redemption }

enum TransactionKind { earned, spent, converted }

/// Opaque platform identifiers; display names never identify a blocked app.
class AppIdentifier {
  const AppIdentifier({required this.platform, required this.value});
  final String platform;
  final String value;
  @override
  bool operator ==(Object other) =>
      other is AppIdentifier &&
      platform == other.platform &&
      value == other.value;
  @override
  int get hashCode => Object.hash(platform, value);
}

class TargetApp {
  const TargetApp({required this.id, required this.name});
  final AppIdentifier id;
  final String name;
}

class DomainFailure implements Exception {
  const DomainFailure(this.message);
  final String message;
}

List<TargetApp> validatedApps(List<TargetApp> apps) {
  if (apps.isEmpty) throw const DomainFailure('请至少选择一个 App。');
  if (apps.any((app) => app.id.value.isEmpty || app.id.platform.isEmpty) ||
      apps.map((app) => app.id).toSet().length != apps.length) {
    throw const DomainFailure('App 标识无效或重复，请重新选择。');
  }
  return List.unmodifiable(apps);
}

class RuleWindow {
  const RuleWindow(this.start, this.end);
  final DateTime start;
  final DateTime end;
}

/// A daily plan and any individual execution remain independent.
class AppRule {
  AppRule({
    required this.id,
    required String name,
    required List<TargetApp> apps,
    required this.startMinute,
    required this.endMinute,
    this.enabled = true,
  }) : name = name.trim(),
       apps = validatedApps(apps) {
    if (this.name.isEmpty || this.name.length > 40) {
      throw const DomainFailure('Rule 名称需为 1–40 个字符。');
    }
    if (startMinute < 0 ||
        startMinute >= 1440 ||
        endMinute < 0 ||
        endMinute >= 1440 ||
        startMinute == endMinute) {
      throw const DomainFailure('请选择不同的开始与结束时间。');
    }
  }
  final String id;
  final String name;
  final List<TargetApp> apps;
  final int startMinute;
  final int endMinute;
  final bool enabled;

  DateTime _date(DateTime now, int dayOffset, int minute) => DateTime(
    now.year,
    now.month,
    now.day + dayOffset,
    minute ~/ 60,
    minute % 60,
  );

  RuleWindow? activeWindow(DateTime now) {
    if (!enabled) return null;
    for (final day in [0, -1]) {
      final start = _date(now, day, startMinute);
      final end = _date(
        now,
        day + (endMinute < startMinute ? 1 : 0),
        endMinute,
      );
      if (!now.isBefore(start) && now.isBefore(end)) {
        return RuleWindow(start, end);
      }
    }
    return null;
  }

  DateTime? nextStart(DateTime now) {
    if (!enabled) return null;
    final today = _date(now, 0, startMinute);
    return today.isAfter(now) ? today : _date(now, 1, startMinute);
  }

  AppRule withEnabled(bool value) => AppRule(
    id: id,
    name: name,
    apps: apps,
    startMinute: startMinute,
    endMinute: endMinute,
    enabled: value,
  );
}

class RestrictionSession {
  RestrictionSession({
    required this.id,
    required this.origin,
    required List<TargetApp> apps,
    required this.startedAt,
    required this.endsAt,
    this.ruleId,
    this.ruleName,
    this.occurrenceKey,
    this.status = RestrictionStatus.active,
  }) : apps = validatedApps(apps) {
    if (!endsAt.isAfter(startedAt)) throw const DomainFailure('限制时长必须大于零。');
    if (origin == RestrictionOrigin.rule ? ruleId == null : ruleId != null) {
      throw const DomainFailure('限制来源无效。');
    }
  }
  final String id;
  final RestrictionOrigin origin;
  final String? ruleId;
  final String? ruleName;
  final String? occurrenceKey;
  final List<TargetApp> apps;
  final DateTime startedAt;
  final DateTime endsAt;
  final RestrictionStatus status;
  Duration get originalDuration => endsAt.difference(startedAt);
  bool isActiveAt(DateTime now) =>
      status == RestrictionStatus.active &&
      !now.isBefore(startedAt) &&
      now.isBefore(endsAt);
  Duration remainingAt(DateTime now) {
    if (status != RestrictionStatus.active || !now.isBefore(endsAt)) {
      return Duration.zero;
    }
    if (now.isBefore(startedAt)) return originalDuration;
    return endsAt.difference(now);
  }

  RestrictionSession settled(RestrictionStatus value) => RestrictionSession(
    id: id,
    origin: origin,
    apps: apps,
    startedAt: startedAt,
    endsAt: endsAt,
    ruleId: ruleId,
    ruleName: ruleName,
    occurrenceKey: occurrenceKey,
    status: value,
  );
}

class TimePoolTransaction {
  const TimePoolTransaction({
    required this.id,
    required this.kind,
    required this.amount,
    required this.source,
    required this.timestamp,
    required this.balanceAfter,
  });
  final String id;
  final TransactionKind kind;

  /// Positive magnitude; kind determines credit/debit.
  final Duration amount;
  final String source;
  final DateTime timestamp;
  final Duration balanceAfter;
}

class TimePool {
  TimePool({
    this.balance = Duration.zero,
    List<TimePoolTransaction> transactions = const [],
  }) : transactions = List.unmodifiable(transactions) {
    if (balance.isNegative) throw const DomainFailure('时间池余额不能为负数。');
  }
  final Duration balance;
  final List<TimePoolTransaction> transactions;
}

class CoinBalance {
  const CoinBalance({this.balance = 0});
  final int balance;
}

/// Conversion is deliberately unavailable until a product rate is approved.
abstract interface class TimeCoinExchange {
  bool get available;
  CoinExchangeQuote? quote(Duration time);
}

class CoinExchangeQuote {
  const CoinExchangeQuote({required this.time, required this.coins});
  final Duration time;
  final int coins;
}

class RestrictionResult {
  const RestrictionResult({required this.session, required this.transaction});
  final RestrictionSession session;
  final TimePoolTransaction transaction;
  String get id => session.id;
  bool get completed => session.status == RestrictionStatus.completed;
}

class CoreEvent {
  const CoreEvent({required this.id, required this.kind});
  final String id;
  final CoreEventKind kind;
}

class HomeState {
  HomeState({
    required this.now,
    List<AppRule> rules = const [],
    this.session,
    this.event,
    TimePool? timePool,
    this.coinBalance = const CoinBalance(),
    List<RestrictionResult> results = const [],
  }) : rules = List.unmodifiable(rules),
       timePool = timePool ?? TimePool(),
       results = List.unmodifiable(results);
  final DateTime now;
  final List<AppRule> rules;
  final RestrictionSession? session;
  final CoreEvent? event;
  final TimePool timePool;
  final CoinBalance coinBalance;
  final List<RestrictionResult> results;
  int get coins => coinBalance.balance;
  // At zero remaining it stays active until platform stop and settlement succeed.
  RestrictionSession? get activeSession =>
      session?.status == RestrictionStatus.active ? session : null;
  HomeScenario get scenario => activeSession != null
      ? activeSession!.origin == RestrictionOrigin.rule
            ? HomeScenario.ruleActive
            : HomeScenario.restrictionActive
      : rules.isEmpty
      ? HomeScenario.noRule
      : HomeScenario.ruleIdle;
  RestrictionResult? resultFor(String id) {
    for (final result in results) {
      if (result.id == id) return result;
    }
    return null;
  }

  AppRule? get featuredRule {
    if (rules.isEmpty) return null;
    for (final rule in rules) {
      if (rule.id == session?.ruleId) return rule;
    }
    final enabled = rules.where((rule) => rule.enabled).toList()
      ..sort((a, b) => a.nextStart(now)!.compareTo(b.nextStart(now)!));
    return enabled.isEmpty ? rules.first : enabled.first;
  }
}
