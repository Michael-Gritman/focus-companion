import 'package:flutter/material.dart';

import '../application/home_controller.dart';
import '../theme/focus_theme.dart';
import 'components.dart';
import 'form_components.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.controller,
    required this.onRules,
  });
  final HomeController controller;
  final VoidCallback onRules;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('让限制按你的安排运行', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.update_rounded),
                title: const Text('管理 Rules'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onRules,
              ),
            ),
            const FieldHeading('系统限制能力'),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(controller.isMock ? 'Mock Platform' : '系统平台'),
                  const SizedBox(height: 12),
                  Text(
                    controller.isMock
                        ? '当前只模拟限制状态，不会真正禁用其他 App。'
                        : '使用已连接的系统限制平台。',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Rule 调度在 App 运行与恢复前台时检查。未运行期间不会补发未执行的限制奖励。',
                    style: TextStyle(fontSize: 12, color: FocusTokens.muted),
                  ),
                ],
              ),
            ),
            const FieldHeading('基础设置'),
            const SurfaceCard(
              child: Text('数据范围：本次运行\n外观：跟随当前 Focus 主题\n金币兑换：待确定产品比例'),
            ),
            if (controller.canAdvanceTime) ...[
              const FieldHeading('开发验证 · 模拟时间'),
              Text(
                '当前模拟时间：${dateTimeLabel(controller.state.now)}',
                style: const TextStyle(fontSize: 12, color: FocusTokens.muted),
              ),
              const SizedBox(height: 10),
              const Text(
                '仅用于验证等待、Rule 和结算。推进后仍通过同一套业务规则处理。',
                style: TextStyle(fontSize: 12, color: FocusTokens.muted),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.busy
                    ? null
                    : () => controller.advanceMockTime(
                        const Duration(minutes: 1),
                      ),
                child: const Text('模拟推进 1 分钟'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: controller.busy
                    ? null
                    : () => controller.advanceMockTime(
                        const Duration(minutes: 30),
                      ),
                child: const Text('模拟推进 30 分钟'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('advance-to-end'),
                onPressed:
                    controller.busy || controller.state.activeSession == null
                    ? null
                    : () => controller.advanceMockTime(
                        controller.state.activeSession!.remainingAt(
                          controller.state.now,
                        ),
                      ),
                child: const Text('模拟推进到本次结束'),
              ),
            ],
            InlineError(controller.error),
            if (controller.error != null)
              TextButton(
                onPressed: controller.busy ? null : controller.retry,
                child: const Text('重试平台操作'),
              ),
            const SizedBox(height: 16),
            const Text(
              '关闭或刷新 App 后，规则、余额与记录会重置。',
              style: TextStyle(fontSize: 12, color: FocusTokens.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.onSettings, required this.onRules});
  final VoidCallback onSettings;
  final VoidCallback onRules;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('More', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 24),
      SurfaceCard(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.update_rounded),
              title: const Text('Rules'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onRules,
              minVerticalPadding: 18,
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onSettings,
              minVerticalPadding: 18,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Focus · 少一点干扰，多一点生活。',
        style: TextStyle(fontSize: 12, color: FocusTokens.muted),
      ),
    ],
  );
}
