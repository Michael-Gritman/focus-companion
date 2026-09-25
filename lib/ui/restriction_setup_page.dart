import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../application/home_controller.dart';
import '../domain/home_state.dart';
import '../theme/focus_theme.dart';
import 'components.dart';
import 'form_components.dart';

class RestrictionSetupPage extends StatefulWidget {
  const RestrictionSetupPage({super.key, required this.controller});
  final HomeController controller;
  @override
  State<RestrictionSetupPage> createState() => _RestrictionSetupPageState();
}

class _RestrictionSetupPageState extends State<RestrictionSetupPage> {
  final duration = TextEditingController(text: '30');
  Set<AppIdentifier> selected = {};
  String? error;
  @override
  void dispose() {
    duration.dispose();
    super.dispose();
  }

  Future<void> start() async {
    final minutes = int.tryParse(duration.text);
    if (minutes == null) {
      setState(() => error = '请输入有效的分钟数。');
      return;
    }
    final message = await widget.controller.startTemporary(
      widget.controller.availableApps
          .where((app) => selected.contains(app.id))
          .toList(),
      Duration(minutes: minutes),
    );
    if (!mounted) return;
    if (message != null) {
      setState(() => error = message);
      return;
    }
    Navigator.pop(context, widget.controller.state.activeSession!.id);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('开始一次禁用')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '给几个 App，\n按下暂停。',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            if (widget.controller.isMock) const MockNotice(),
            const FieldHeading('01  选择要限制的 App'),
            if (!widget.controller.initialized) ...[
              const Text('正在读取 App 列表…'),
              TextButton(
                onPressed: widget.controller.busy
                    ? null
                    : widget.controller.retry,
                child: const Text('重试'),
              ),
            ] else
              AppSelection(
                apps: widget.controller.availableApps,
                selected: selected,
                enabled: !widget.controller.busy,
                onChanged: (value) => setState(() => selected = value),
              ),
            const FieldHeading('02  设置限制时长'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in [15, 30, 45, 60])
                  ChoiceChip(
                    label: Text('$value 分钟'),
                    selected: duration.text == '$value',
                    onSelected: widget.controller.busy
                        ? null
                        : (_) => setState(() => duration.text = '$value'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('duration-input'),
              controller: duration,
              enabled: !widget.controller.busy,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                labelText: '自定义时长（分钟）',
                helperText: '1–1440 分钟',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const FieldHeading('03  确认这次承诺'),
            SurfaceCard(
              color: FocusTokens.sage,
              border: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '已选择 ${selected.length} 个 App · ${duration.text.isEmpty ? '—' : duration.text} 分钟',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '完成后积累等长时间；提前解除需消耗剩余时长对应的时间池余额。',
                    style: TextStyle(fontSize: 12, color: FocusTokens.muted),
                  ),
                ],
              ),
            ),
            InlineError(error ?? widget.controller.error),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('start-restriction'),
              onPressed:
                  widget.controller.busy || !widget.controller.initialized
                  ? null
                  : start,
              child: Text(
                widget.controller.busy
                    ? '正在开始…'
                    : widget.controller.isMock
                    ? '开始模拟限制'
                    : '开始限制',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
