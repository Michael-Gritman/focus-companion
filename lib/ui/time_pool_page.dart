import 'package:flutter/material.dart';

import '../domain/home_state.dart';
import '../theme/focus_theme.dart';
import 'components.dart';

class TimePoolPage extends StatelessWidget {
  const TimePoolPage({super.key, required this.state, required this.exchange});
  final HomeState state;
  final TimeCoinExchange exchange;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Time Pool', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 8),
      const Text('过去的坚持，成为未来的自由。', style: TextStyle(color: FocusTokens.muted)),
      const SizedBox(height: 24),
      SurfaceCard(
        color: FocusTokens.sage,
        border: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('可用时间池'),
            const SizedBox(height: 14),
            Text(
              durationLabel(state.timePool.balance),
              key: const Key('pool-balance'),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              '完成限制时存入，提前解除时消耗。',
              style: TextStyle(fontSize: 12, color: FocusTokens.muted),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('时间兑换金币'),
                  content: Text(
                    exchange.available
                        ? '兑换规则待接入。当前不会扣除时间。'
                        : '兑换比例尚未确定。本版只保留入口，不扣除时间，也不发放金币。',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('知道了'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.monetization_on_outlined, size: 20),
              label: const Text('时间兑换金币 · 待开放'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 28),
      Text('最近记录', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      if (state.timePool.transactions.isEmpty)
        const SurfaceCard(child: Text('还没有记录。完成第一次限制后，这里会留下你的积累。'))
      else
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              for (final transaction in state.timePool.transactions.take(10))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Text(
                            switch (transaction.kind) {
                              TransactionKind.earned => '完成限制',
                              TransactionKind.spent => '提前解除',
                              TransactionKind.converted => '兑换金币',
                            },
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${transaction.kind == TransactionKind.earned ? '+' : '−'} ${durationLabel(transaction.amount)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateTimeLabel(transaction.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: FocusTokens.muted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      const SizedBox(height: 28),
      const _TaskPreview(title: '每日任务', description: '完成一次限制，为今天留一点空间。'),
      const SizedBox(height: 16),
      const _TaskPreview(title: '每周任务', description: '在一周里，建立自己的使用节奏。'),
      const SizedBox(height: 20),
      const Text(
        '连续记录与成长成就 · 后续开放',
        style: TextStyle(fontSize: 12, color: FocusTokens.muted),
      ),
      const SizedBox(height: 12),
      const Text(
        '本版数据仅保存在当前运行内存中，重启后重置。',
        style: TextStyle(fontSize: 12, color: FocusTokens.muted),
      ),
    ],
  );
}

class _TaskPreview extends StatelessWidget {
  const _TaskPreview({required this.title, required this.description});
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const StatusPill('任务预览'),
          ],
        ),
        const SizedBox(height: 10),
        Text(description),
        const SizedBox(height: 6),
        const Text(
          '尚未参与奖励结算',
          style: TextStyle(fontSize: 11, color: FocusTokens.muted),
        ),
      ],
    ),
  );
}
