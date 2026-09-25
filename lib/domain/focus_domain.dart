import 'home_state.dart';

/// A validated quote created only by the domain. Applied after platform success.
class SettlementPlan {
  const SettlementPlan._(this.sessionId, this.status, this.amount, this.at);
  final String sessionId;
  final RestrictionStatus status;
  final Duration amount;
  final DateTime at;
}

/// Pure Dart business state: no Flutter, timers, navigation or OS calls.
class FocusDomain {
  FocusDomain({TimePool? initialPool}) : _pool = initialPool ?? TimePool();
  final List<AppRule> _rules = [];
  final List<RestrictionResult> _results = [];
  final Set<String> _executedOccurrences = {};
  RestrictionSession? _session;
  TimePool _pool;
  CoreEvent? _event;
  int _sequence = 0;
  String nextId(String prefix) => '$prefix-${++_sequence}';

  HomeState snapshot(DateTime now) => HomeState(
    now: now,
    rules: _rules,
    session: _session,
    timePool: _pool,
    event: _event,
    results: _results,
  );

  RestrictionSession planTemporary(
    List<TargetApp> apps,
    Duration duration,
    DateTime now,
  ) {
    _requireFree();
    if (duration < const Duration(minutes: 1) ||
        duration > const Duration(hours: 24)) {
      throw const DomainFailure('时长需在 1–1440 分钟之间。');
    }
    return RestrictionSession(
      id: nextId('session'),
      origin: RestrictionOrigin.temporary,
      apps: apps,
      startedAt: now,
      endsAt: now.add(duration),
    );
  }

  RestrictionSession? planScheduled(DateTime now) {
    if (_session != null) return null;
    final candidates = <(AppRule, RuleWindow)>[];
    for (final rule in _rules) {
      final window = rule.activeWindow(now);
      if (window != null &&
          !_executedOccurrences.contains(_occurrence(rule.id, window))) {
        candidates.add((rule, window));
      }
    }
    candidates.sort((a, b) {
      final order = a.$2.start.compareTo(b.$2.start);
      return order != 0 ? order : a.$1.id.compareTo(b.$1.id);
    });
    if (candidates.isEmpty) return null;
    final (rule, window) = candidates.first;
    // Late starts earn only the duration actually scheduled from now.
    return RestrictionSession(
      id: nextId('session'),
      origin: RestrictionOrigin.rule,
      apps: rule.apps,
      startedAt: now,
      endsAt: window.end,
      ruleId: rule.id,
      ruleName: rule.name,
      occurrenceKey: _occurrence(rule.id, window),
    );
  }

  bool hasScheduled(DateTime now) =>
      _session == null &&
      _rules.any((rule) {
        final window = rule.activeWindow(now);
        return window != null &&
            !_executedOccurrences.contains(_occurrence(rule.id, window));
      });

  String _occurrence(String id, RuleWindow window) =>
      '$id@${window.start.toIso8601String()}';

  void activate(RestrictionSession session) {
    _requireFree();
    if (session.status != RestrictionStatus.active) {
      throw const DomainFailure('不能启动已结束的限制。');
    }
    if (_results.any((result) => result.id == session.id) ||
        (session.occurrenceKey != null &&
            _executedOccurrences.contains(session.occurrenceKey))) {
      throw const DomainFailure('这次限制已经处理，不能重复启动。');
    }
    _session = session;
    if (session.occurrenceKey != null) {
      _executedOccurrences.add(session.occurrenceKey!);
    }
  }

  void _requireFree() {
    if (_session != null) throw const DomainFailure('请先完成当前限制，或通过时间池提前解除。');
  }

  SettlementPlan prepareSettlement(
    String sessionId,
    DateTime now, {
    bool earlyExit = false,
  }) {
    final session = _requireSession(sessionId);
    final remaining = session.remainingAt(now);
    if (remaining == Duration.zero) {
      return SettlementPlan._(
        sessionId,
        RestrictionStatus.completed,
        session.originalDuration,
        now,
      );
    }
    if (!earlyExit) throw const DomainFailure('限制尚未结束。');
    if (_pool.balance < remaining) {
      throw const DomainFailure('时间池余额不足，当前限制将继续。');
    }
    return SettlementPlan._(
      sessionId,
      RestrictionStatus.earlyExited,
      remaining,
      now,
    );
  }

  RestrictionSession _requireSession(String id) {
    final session = _session;
    if (session == null || session.id != id) {
      throw const DomainFailure('限制状态已变化，请重新查看。');
    }
    return session;
  }

  RestrictionResult commitSettlement(SettlementPlan plan) {
    final session = _requireSession(plan.sessionId);
    final earned = plan.status == RestrictionStatus.completed;
    final balance = earned
        ? _pool.balance + plan.amount
        : _pool.balance - plan.amount;
    if (balance.isNegative) throw const DomainFailure('时间池余额不足，当前限制将继续。');
    final transaction = TimePoolTransaction(
      id: nextId('transaction'),
      kind: earned ? TransactionKind.earned : TransactionKind.spent,
      amount: plan.amount,
      source: session.id,
      timestamp: plan.at,
      balanceAfter: balance,
    );
    _pool = TimePool(
      balance: balance,
      transactions: [transaction, ..._pool.transactions],
    );
    final result = RestrictionResult(
      session: session.settled(plan.status),
      transaction: transaction,
    );
    _results.insert(0, result);
    _session = null;
    _event = CoreEvent(
      id: result.id,
      kind: earned ? CoreEventKind.reward : CoreEventKind.redemption,
    );
    return result;
  }

  bool canExit(String sessionId, DateTime now) {
    if (_session?.id != sessionId) return false;
    return _pool.balance >= _session!.remainingAt(now);
  }

  void saveRule(AppRule rule) {
    final index = _rules.indexWhere((item) => item.id == rule.id);
    if (index < 0) {
      _rules.add(rule);
    } else {
      _rules[index] = rule;
    }
    // Edits/disable affect future occurrences, never the immutable active session.
  }

  void setRuleEnabled(String id, bool enabled) {
    final index = _rules.indexWhere((rule) => rule.id == id);
    if (index < 0) throw const DomainFailure('找不到这条 Rule。');
    _rules[index] = _rules[index].withEnabled(enabled);
  }

  void acknowledge(String resultId) {
    if (_event?.id == resultId) _event = null;
  }
}
