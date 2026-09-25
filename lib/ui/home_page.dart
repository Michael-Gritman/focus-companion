import 'package:flutter/material.dart';

import '../domain/home_state.dart';
import '../theme/focus_theme.dart';
import 'components.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.state,
    required this.onSetup,
    required this.onRules,
    required this.onRestriction,
    required this.onEvent,
    this.isMock = true,
  });
  final HomeState state;
  final VoidCallback onSetup;
  final VoidCallback onRules;
  final VoidCallback onRestriction;
  final ValueChanged<CoreEvent> onEvent;
  final bool isMock;

  @override
  Widget build(BuildContext context) {
    final active = state.activeSession;
    final text = Theme.of(context).textTheme;
    return ListView(
      key: const PageStorageKey('home-scroll'),
      padding: const EdgeInsets.fromLTRB(
        FocusTokens.pagePadding,
        22,
        FocusTokens.pagePadding,
        28,
      ),
      children: [
        Row(
          children: [
            Container(width: 18, height: 2, color: FocusTokens.muted),
            const SizedBox(width: 8),
            const Text(
              '我的空间',
              style: TextStyle(
                fontSize: 12,
                color: FocusTokens.muted,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          active == null
              ? '今天，给自己\n一段不被打扰的时间。'
              : active.remainingAt(state.now) == Duration.zero
              ? '本次限制已到期，\n正在确认结果。'
              : '限制正在运行，\n把这段时间留给自己。',
          style: text.headlineLarge?.copyWith(
            fontSize: MediaQuery.sizeOf(context).width < 360 ? 26 : 30,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          active == null
              ? '从暂时放下几个 App 开始。'
              : isMock
              ? '模拟模式：其他 App 仍可使用。'
              : '承诺继续，其他事慢慢来。',
          style: text.bodyLarge?.copyWith(color: FocusTokens.muted),
        ),
        const SizedBox(height: 28),
        _TodayStats(state: state),
        const SizedBox(height: 22),
        if (active == null)
          _StartCard(onSetup: onSetup)
        else
          _ActiveCard(
            session: active,
            now: state.now,
            onOpen: onRestriction,
            isMock: isMock,
          ),
        // A single conditional slot supports future outcomes without fake rewards.
        if (state.event case final event?) ...[
          const SizedBox(height: 20),
          CoreEventCard(event: event, onOpen: () => onEvent(event)),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: Text('自动限制', style: text.titleMedium)),
            Text(
              'RULES',
              style: text.bodyMedium?.copyWith(
                color: FocusTokens.muted,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.rules.isEmpty)
          _EmptyRule(onOpen: onRules)
        else
          _RuleSummary(
            rule: _featuredRule,
            now: state.now,
            running:
                active?.origin == RestrictionOrigin.rule &&
                active?.ruleId == _featuredRule.id,
            count: state.rules.length,
            onOpen: onRules,
          ),
        if (active != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRules,
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text('管理自动 Rule'),
          ),
        ],
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 14, color: FocusTokens.muted),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                '少刷一会儿，生活多一点。',
                style: TextStyle(fontSize: 11, color: FocusTokens.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }

  AppRule get _featuredRule {
    return state.featuredRule!;
  }
}

class _TodayStats extends StatelessWidget {
  const _TodayStats({required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final today = state.now;
    final completedToday = state.results.where((result) {
      final t = result.transaction.timestamp;
      return t.year == today.year && t.month == today.month && t.day == today.day;
    }).where((result) => result.completed).toList();
    final minutes = completedToday.fold<int>(
      0,
      (sum, result) => sum + result.transaction.amount.inMinutes,
    );
    return Row(
      children: [
        _StatTile(value: '$minutes', label: '今日专注', color: FocusTokens.actionPrimary),
        const SizedBox(width: 10),
        _StatTile(value: '${completedToday.length}', label: '完成次数', color: FocusTokens.accent),
        const SizedBox(width: 10),
        _StatTile(value: '${state.timePool.balance.inMinutes}', label: '时间池', color: FocusTokens.gold),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
      decoration: BoxDecoration(
        color: FocusTokens.surface,
        border: Border.all(color: FocusTokens.line, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: FocusTokens.muted)),
        ],
      ),
    ),
  );
}

class _StartCard extends StatelessWidget {
  const _StartCard({required this.onSetup});
  final VoidCallback onSetup;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    key: const Key('primary-action-card'),
    color: FocusTokens.accent,
    border: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: FocusTokens.ink),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.phonelink_lock_rounded, size: 25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '暂时离线\n为自己留白',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FocusPrimaryButton(
            key: const Key('home-primary-action'),
            label: '开始一次禁用',
            onPressed: onSetup,
            trailing: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            '选择 App · 设置时长 · 开始限制',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: FocusTokens.ink),
          ),
        ),
      ],
    ),
  );
}

class _ActiveCard extends StatelessWidget {
  const _ActiveCard({
    required this.session,
    required this.now,
    required this.onOpen,
    required this.isMock,
  });
  final RestrictionSession session;
  final DateTime now;
  final VoidCallback onOpen;
  final bool isMock;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    key: const Key('active-restriction-card'),
    color: FocusTokens.darkSurface,
    border: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              color: FocusTokens.onDark,
              size: 22,
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                '当前限制',
                style: TextStyle(
                  color: FocusTokens.onDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            StatusPill(
              session.origin == RestrictionOrigin.rule ? 'Rule 运行中' : '临时禁用',
              dark: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          '距离解除还有',
          style: TextStyle(fontSize: 12, color: FocusTokens.onDarkMuted),
        ),
        const SizedBox(height: 2),
        Semantics(
          label: '剩余 ${remainingLabel(session.remainingAt(now))}',
          child: ExcludeSemantics(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                remainingLabel(session.remainingAt(now)),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 54,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -2,
                  color: FocusTokens.onDark,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppLabels(session.apps, dark: true),
        const SizedBox(height: 10),
        Text(
          '${session.apps.length} 个 App · ${isMock ? '模拟限制' : '限制生效'} · ${timeLabel(session.endsAt)} 结束',
          style: const TextStyle(fontSize: 12, color: FocusTokens.onDarkMuted),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FocusTokens.accent,
              foregroundColor: FocusTokens.ink,
            ),
            onPressed: onOpen,
            child: const Text('查看当前限制'),
          ),
        ),
      ],
    ),
  );
}

class _EmptyRule extends StatelessWidget {
  const _EmptyRule({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: FocusTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: FocusTokens.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.update_rounded, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '设置 Rule',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '让固定时段，自动少些干扰。',
                      style: TextStyle(fontSize: 12, color: FocusTokens.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.add_rounded, size: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RuleSummary extends StatelessWidget {
  const _RuleSummary({
    required this.rule,
    required this.now,
    required this.running,
    required this.count,
    required this.onOpen,
  });
  final AppRule rule;
  final DateTime now;
  final bool running;
  final int count;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final next = rule.nextStart(now);
    final nextLabel = next == null
        ? '开启后将按时自动限制'
        : '${next.day == now.day ? '今天' : '明天'} ${timeLabel(next)} 开始';
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rule.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                running
                    ? '运行中'
                    : rule.enabled
                    ? '已启用'
                    : '已停用',
                dark: running,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${clockLabel(rule.startMinute)}–${clockLabel(rule.endMinute)}${rule.endMinute <= rule.startMinute ? ' 次日' : ''}',
            style: const TextStyle(
              fontSize: 22,
              fontFamily: FocusTokens.fontFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '每天 · ${rule.apps.map((app) => app.name).join(' / ')}',
            style: const TextStyle(fontSize: 12, color: FocusTokens.muted),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  running ? '已按计划开始限制' : nextLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: FocusTokens.muted,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpen,
                child: Text(count > 1 ? '查看 $count 条' : '查看 Rule'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CoreEventCard extends StatelessWidget {
  const CoreEventCard({super.key, required this.event, required this.onOpen});
  final CoreEvent event;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    color: FocusTokens.sage,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.kind == CoreEventKind.reward ? '这次坚持，已存入时间池' : '查看这次限制的结果',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TextButton(
          onPressed: onOpen,
          child: Text(
            event.kind == CoreEventKind.reward ? '查看完成结果' : '查看提前解除结果',
          ),
        ),
      ],
    ),
  );
}
