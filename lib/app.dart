import 'package:flutter/material.dart';

import 'application/home_controller.dart';
import 'platform/mock_restriction_platform.dart';
import 'theme/focus_theme.dart';
import 'ui/home_page.dart';
import 'ui/secondary_pages.dart';
import 'ui/restriction_setup_page.dart';
import 'ui/restriction_pages.dart';
import 'ui/rules_pages.dart';
import 'ui/time_pool_page.dart';
import 'ui/form_components.dart';

class FocusApp extends StatefulWidget {
  const FocusApp({super.key, this.controller});
  final HomeController? controller;
  @override
  State<FocusApp> createState() => _FocusAppState();
}

class _FocusAppState extends State<FocusApp> with WidgetsBindingObserver {
  late final HomeController controller;
  @override
  void initState() {
    super.initState();
    final clock = MockClock();
    controller =
        widget.controller ??
        HomeController(
          platform: MockRestrictionPlatform(clock: clock),
          clock: clock,
        );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) controller.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Focus · 我的空间',
    debugShowCheckedModeBanner: false,
    theme: focusTheme(),
    builder: (context, child) => ColoredBox(
      color: FocusTokens.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: FocusTokens.maxWidth),
          child: child!,
        ),
      ),
    ),
    home: _HomeShell(controller: controller),
  );
}

class _HomeShell extends StatefulWidget {
  const _HomeShell({required this.controller});
  final HomeController controller;
  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int tab = 0;
  void open(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  void rules() => open(RulesPage(controller: widget.controller));
  void settings() =>
      open(SettingsPage(controller: widget.controller, onRules: rules));
  void goTo(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => tab = index);
  }

  void restriction(String id) => open(
    RestrictionDetailsPage(
      controller: widget.controller,
      sessionId: id,
      onHome: () => goTo(0),
      onPool: () => goTo(1),
    ),
  );
  Future<void> setup() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => RestrictionSetupPage(controller: widget.controller),
      ),
    );
    if (mounted && id != null) restriction(id);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final state = widget.controller.state;
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 76,
          titleSpacing: 24,
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Text(
                'Focus',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              if (widget.controller.isMock)
                const Text(
                  '模拟',
                  style: TextStyle(fontSize: 10, color: FocusTokens.muted),
                ),
            ],
          ),
          actions: [
            Semantics(
              label: '金币 ${state.coins}',
              child: ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: FocusTokens.surface,
                    border: Border.all(color: FocusTokens.line),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 20,
                        color: FocusTokens.ink,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.coins}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Settings',
              onPressed: settings,
              icon: const Icon(Icons.settings_outlined, size: 22),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: switch (tab) {
            0 => Column(
              children: [
                if (widget.controller.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: InlineError(widget.controller.error),
                  ),
                Expanded(
                  child: HomePage(
                    state: state,
                    isMock: widget.controller.isMock,
                    onSetup: setup,
                    onRules: rules,
                    onRestriction: () {
                      if (state.activeSession != null) {
                        restriction(state.activeSession!.id);
                      }
                    },
                    onEvent: (event) => restriction(event.id),
                  ),
                ),
              ],
            ),
            1 => TimePoolPage(
              state: state,
              exchange: const UnavailableTimeCoinExchange(),
            ),
            _ => MorePage(onSettings: settings, onRules: rules),
          },
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: FocusTokens.line)),
          ),
          child: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (value) => setState(() => tab = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.water_outlined),
                selectedIcon: Icon(Icons.water_rounded),
                label: 'Time Pool',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'More',
              ),
            ],
          ),
        ),
      );
    },
  );
}
