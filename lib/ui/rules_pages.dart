import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../application/home_controller.dart';
import '../domain/home_state.dart';
import '../theme/focus_theme.dart';
import 'components.dart';
import 'form_components.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key, required this.controller});
  final HomeController controller;
  void edit(BuildContext context, [AppRule? rule]) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => RuleEditorPage(controller: controller, rule: rule),
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Rules')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '固定时段，\n自动留白。',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              '每天重复。停用或编辑只影响后续执行，已经开始的限制会继续。',
              style: TextStyle(color: FocusTokens.muted),
            ),
            const SizedBox(height: 20),
            if (controller.isMock) const MockNotice(),
            InlineError(controller.error),
            for (final rule in controller.state.rules) ...[
              const SizedBox(height: 18),
              SurfaceCard(
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
                        Switch(
                          key: ValueKey('rule-toggle-${rule.id}'),
                          value: rule.enabled,
                          onChanged: controller.busy
                              ? null
                              : (value) =>
                                    controller.setRuleEnabled(rule.id, value),
                        ),
                      ],
                    ),
                    Text(
                      '${clockLabel(rule.startMinute)}–${clockLabel(rule.endMinute)}${rule.endMinute < rule.startMinute ? ' 次日' : ''}',
                    ),
                    const SizedBox(height: 14),
                    AppLabels(rule.apps),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.state.activeSession?.ruleId == rule.id
                                ? '本次执行中'
                                : rule.enabled
                                ? '已启用'
                                : '已停用',
                            style: const TextStyle(
                              fontSize: 12,
                              color: FocusTokens.muted,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => edit(context, rule),
                          child: const Text('编辑 Rule'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (controller.state.rules.isEmpty) ...[
              const SizedBox(height: 32),
              const Text('还没有 Rule，先安排一个固定时段。'),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('create-rule'),
              onPressed: controller.initialized ? () => edit(context) : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('创建 Rule'),
            ),
            const SizedBox(height: 18),
            const Text(
              '本版一次运行一个限制。重叠 Rule 会等待，仍处于时段内时执行剩余部分。',
              style: TextStyle(fontSize: 12, color: FocusTokens.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class RuleEditorPage extends StatefulWidget {
  const RuleEditorPage({super.key, required this.controller, this.rule});
  final HomeController controller;
  final AppRule? rule;
  @override
  State<RuleEditorPage> createState() => _RuleEditorPageState();
}

class _RuleEditorPageState extends State<RuleEditorPage> {
  late final TextEditingController name;
  late final TextEditingController start;
  late final TextEditingController end;
  late Set<AppIdentifier> selected;
  late bool enabled;
  String? error;
  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    name = TextEditingController(text: rule?.name ?? '');
    start = TextEditingController(text: clockLabel(rule?.startMinute ?? 1350));
    end = TextEditingController(text: clockLabel(rule?.endMinute ?? 420));
    selected = rule?.apps.map((app) => app.id).toSet() ?? {};
    enabled = rule?.enabled ?? true;
  }

  @override
  void dispose() {
    name.dispose();
    start.dispose();
    end.dispose();
    super.dispose();
  }

  int? parseTime(String value) {
    if (!RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').hasMatch(value.trim())) {
      return null;
    }
    final parts = value.trim().split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> save() async {
    final from = parseTime(start.text), to = parseTime(end.text);
    if (from == null || to == null) {
      setState(() => error = '请输入 24 小时制时间，例如 22:30。');
      return;
    }
    final message = await widget.controller.saveRule(
      id: widget.rule?.id,
      name: name.text,
      apps: widget.controller.availableApps
          .where((app) => selected.contains(app.id))
          .toList(),
      startMinute: from,
      endMinute: to,
      enabled: enabled,
    );
    if (!mounted) return;
    if (message == null) {
      Navigator.pop(context);
    } else {
      setState(() => error = message);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(widget.rule == null ? '创建 Rule' : '编辑 Rule')),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('rule-name'),
              controller: name,
              maxLength: 40,
              enabled: !widget.controller.busy,
              decoration: const InputDecoration(
                labelText: 'Rule 名称',
                hintText: '例如：晚间社交媒体',
                border: OutlineInputBorder(),
              ),
            ),
            const FieldHeading('选择目标 App'),
            AppSelection(
              apps: widget.controller.availableApps,
              selected: selected,
              enabled: !widget.controller.busy,
              onChanged: (value) => setState(() => selected = value),
            ),
            const FieldHeading('每天运行的时段'),
            TextField(
              key: const Key('rule-start'),
              controller: start,
              enabled: !widget.controller.busy,
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9:]')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: const InputDecoration(
                labelText: '开始时间',
                helperText: '24 小时制 HH:mm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('rule-end'),
              controller: end,
              enabled: !widget.controller.busy,
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9:]')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: const InputDecoration(
                labelText: '结束时间',
                helperText: '结束早于开始时，表示次日结束',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                title: const Text('启用 Rule'),
                value: enabled,
                onChanged: widget.controller.busy
                    ? null
                    : (value) => setState(() => enabled = value),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '保存时若已在运行时段内，会从当前时间开始执行剩余部分。当前限制不受编辑影响。',
              style: TextStyle(fontSize: 12, color: FocusTokens.muted),
            ),
            InlineError(error),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('save-rule'),
              onPressed: widget.controller.busy ? null : save,
              child: const Text('保存 Rule'),
            ),
          ],
        ),
      ),
    ),
  );
}
