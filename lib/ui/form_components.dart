import 'package:flutter/material.dart';

import '../domain/home_state.dart';
import '../theme/focus_theme.dart';
import 'components.dart';

class AppSelection extends StatelessWidget {
  const AppSelection({
    super.key,
    required this.apps,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });
  final List<TargetApp> apps;
  final Set<AppIdentifier> selected;
  final ValueChanged<Set<AppIdentifier>> onChanged;
  final bool enabled;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      children: [
        for (final app in apps)
          CheckboxListTile(
            key: ValueKey('app-${app.id.value}'),
            title: Text(app.name),
            value: selected.contains(app.id),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: !enabled
                ? null
                : (value) {
                    final next = {...selected};
                    value == true ? next.add(app.id) : next.remove(app.id);
                    onChanged(next);
                  },
          ),
      ],
    ),
  );
}

class InlineError extends StatelessWidget {
  const InlineError(this.message, {super.key});
  final String? message;
  @override
  Widget build(BuildContext context) => message == null
      ? const SizedBox.shrink()
      : Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SurfaceCard(
              color: FocusTokens.accentLight,
              border: false,
              padding: const EdgeInsets.all(14),
              child: Text(message!),
            ),
          ),
        );
}

class MockNotice extends StatelessWidget {
  const MockNotice({super.key});
  @override
  Widget build(BuildContext context) => const Text(
    '模拟模式 · 不会真正禁用设备上的 App',
    style: TextStyle(fontSize: 12, color: FocusTokens.muted),
  );
}

class FieldHeading extends StatelessWidget {
  const FieldHeading(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
