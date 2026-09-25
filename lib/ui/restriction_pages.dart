import 'package:flutter/material.dart';

import '../application/home_controller.dart';
import '../domain/home_state.dart';
import '../theme/focus_theme.dart';
import 'components.dart';
import 'form_components.dart';

class RestrictionDetailsPage extends StatelessWidget {
  const RestrictionDetailsPage({
    super.key,
    required this.controller,
    required this.sessionId,
    required this.onHome,
    required this.onPool,
  });
  final HomeController controller;
  final String sessionId;
  final VoidCallback onHome;
  final VoidCallback onPool;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final state = controller.state;
      final result = state.resultFor(sessionId);
      if (result != null) {
        return ResultPage(
          controller: controller,
          result: result,
          onHome: onHome,
          onPool: onPool,
        );
      }
      final session = state.activeSession;
      if (session == null || session.id != sessionId) {
        return Scaffold(
          appBar: AppBar(title: const Text('当前限制')),
          body: Center(
            child: TextButton(onPressed: onHome, child: const Text('返回 Home')),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('当前限制')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                Icons.shield_outlined,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                session.remainingAt(state.now) == Duration.zero
                    ? '限制已到期，等待结算'
                    : controller.isMock
                    ? '模拟限制正在运行'
                    : '限制正在运行',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (controller.isMock) const Center(child: MockNotice()),
              const SizedBox(height: 32),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '距离本次限制结束',
                      style: TextStyle(color: FocusTokens.muted),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        remainingLabel(session.remainingAt(state.now)),
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    AppLabels(session.apps),
                    const SizedBox(height: 22),
                    const Divider(),
                    Text('总时长 · ${durationLabel(session.originalDuration)}'),
                    const SizedBox(height: 10),
                    Text(
                      session.origin == RestrictionOrigin.rule
                          ? '来源 · Rule / ${session.ruleName}'
                          : '来源 · 临时限制',
                    ),
                    const SizedBox(height: 10),
                    Text('预计结束 · ${dateTimeLabel(session.endsAt)}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '先去做自己的事。离开这个页面，不会暂停本次限制。',
                style: TextStyle(color: FocusTokens.muted),
              ),
              InlineError(controller.error),
              if (session.remainingAt(state.now) == Duration.zero)
                TextButton(
                  onPressed: controller.busy ? null : controller.refresh,
                  child: const Text('正在确认完成 · 重试结算'),
                )
              else
                TextButton(
                  key: const Key('early-exit-entry'),
                  onPressed: controller.busy
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => EarlyExitPage(
                              controller: controller,
                              sessionId: sessionId,
                              onHome: onHome,
                              onPool: onPool,
                            ),
                          ),
                        ),
                  child: const Text('通过时间池提前解除'),
                ),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onHome, child: const Text('返回 Home')),
            ],
          ),
        ),
      );
    },
  );
}

class EarlyExitPage extends StatefulWidget {
  const EarlyExitPage({
    super.key,
    required this.controller,
    required this.sessionId,
    required this.onHome,
    required this.onPool,
  });
  final HomeController controller;
  final String sessionId;
  final VoidCallback onHome;
  final VoidCallback onPool;
  @override
  State<EarlyExitPage> createState() => _EarlyExitPageState();
}

class _EarlyExitPageState extends State<EarlyExitPage> {
  String? error;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final state = widget.controller.state;
      final result = state.resultFor(widget.sessionId);
      if (result != null) {
        return ResultPage(
          controller: widget.controller,
          result: result,
          onHome: widget.onHome,
          onPool: widget.onPool,
        );
      }
      final session = state.activeSession;
      if (session == null || session.id != widget.sessionId) {
        return const SizedBox.shrink();
      }
      final remaining = session.remainingAt(state.now);
      final sufficient = widget.controller.canExit(widget.sessionId);
      return Scaffold(
        appBar: AppBar(title: const Text('提前解除')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '用积累的时间，\n换回这次自由。',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              const Text(
                '确认时按当下剩余时长扣除，余额不足时本次限制继续。',
                style: TextStyle(color: FocusTokens.muted),
              ),
              const SizedBox(height: 28),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本次需要 · ${durationLabel(remaining, roundUp: true)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text('时间池余额 · ${durationLabel(state.timePool.balance)}'),
                    const SizedBox(height: 16),
                    const Divider(),
                    Text(
                      sufficient ? '余额足够，可以提前解除。' : '时间池余额不足，当前限制将继续。',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '提前解除不会获得本次限制的时间奖励。',
                style: TextStyle(color: FocusTokens.muted),
              ),
              InlineError(error ?? widget.controller.error),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('confirm-early-exit'),
                onPressed: !sufficient || widget.controller.busy
                    ? null
                    : () async {
                        final message = await widget.controller.earlyExit(
                          widget.sessionId,
                        );
                        if (mounted) setState(() => error = message);
                      },
                child: const Text('确认消耗并解除'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.controller.busy
                    ? null
                    : () => Navigator.pop(context),
                child: const Text('继续这次限制'),
              ),
              const SizedBox(height: 16),
              if (widget.controller.isMock) const MockNotice(),
            ],
          ),
        ),
      );
    },
  );
}

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.controller,
    required this.result,
    required this.onHome,
    required this.onPool,
  });
  final HomeController controller;
  final RestrictionResult result;
  final VoidCallback onHome;
  final VoidCallback onPool;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('本次结果')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: result.completed
                    ? FocusTokens.sage
                    : FocusTokens.accentLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                result.completed
                    ? Icons.check_rounded
                    : Icons.lock_open_rounded,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            result.completed ? '这次承诺，完成了。' : '本次限制已提前结束。',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 14),
          Text(
            result.completed ? '坚持的时间，已经存进时间池。' : '你使用了过去积累的时间。',
            style: const TextStyle(color: FocusTokens.muted),
          ),
          const SizedBox(height: 28),
          SurfaceCard(
            color: FocusTokens.sage,
            border: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.completed ? '本次获得' : '本次消耗'),
                const SizedBox(height: 12),
                Text(
                  '${result.completed ? '+' : '−'} ${durationLabel(result.transaction.amount)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                const Divider(),
                Text(
                  '当前时间池 · ${durationLabel(controller.state.timePool.balance)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppLabels(result.session.apps),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              controller.acknowledge(result.id);
              onHome();
            },
            child: const Text('返回 Home'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              controller.acknowledge(result.id);
              onPool();
            },
            child: const Text('查看 Time Pool'),
          ),
          const SizedBox(height: 16),
          if (controller.isMock) const MockNotice(),
        ],
      ),
    ),
  );
}
