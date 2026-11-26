import 'package:flutter/material.dart';

import 'demo_controller.dart';
import 'pages/activity_page.dart';
import 'pages/home_page.dart';
import 'pages/identity_page.dart';
import 'pages/messages_page.dart';
import 'pages/session_page.dart';
import 'theme.dart';

class CrispExampleApp extends StatefulWidget {
  const CrispExampleApp({super.key, required this.controller});

  final DemoController controller;

  @override
  State<CrispExampleApp> createState() => _CrispExampleAppState();
}

class _CrispExampleAppState extends State<CrispExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(Brightness current) => setState(() {
        _themeMode =
            current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
      });

  @override
  Widget build(BuildContext context) {
    return DemoScope(
      controller: widget.controller,
      child: MaterialApp(
        title: 'Crisp Chat Example',
        debugShowCheckedModeBanner: false,
        theme: CrispTheme.light,
        darkTheme: CrispTheme.dark,
        themeMode: _themeMode,
        home: _Shell(onToggleTheme: _toggleTheme),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon, this.page);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

const _destinations = [
  _Destination(
    'Home',
    Icons.chat_bubble_outline_rounded,
    Icons.chat_bubble_rounded,
    HomePage(),
  ),
  _Destination(
    'Identity',
    Icons.person_outline_rounded,
    Icons.person_rounded,
    IdentityPage(),
  ),
  _Destination(
    'Session',
    Icons.tune_rounded,
    Icons.tune_rounded,
    SessionPage(),
  ),
  _Destination(
    'Messages',
    Icons.widgets_outlined,
    Icons.widgets_rounded,
    MessagesPage(),
  ),
  _Destination(
    'Activity',
    Icons.history_rounded,
    Icons.history_rounded,
    ActivityPage(),
  ),
];

class _Shell extends StatefulWidget {
  const _Shell({required this.onToggleTheme});

  final ValueChanged<Brightness> onToggleTheme;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final activityCount = DemoScope.of(context).activity.length;

    final body = IndexedStack(
      index: _index,
      children: [for (final d in _destinations) d.page],
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const _Logo(),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Crisp Chat'),
                Text(
                  _destinations[_index].label,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle dark mode',
            onPressed: () => widget.onToggleTheme(theme.brightness),
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: _icon(d, d.icon, activityCount),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: wide
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: [
                  for (final d in _destinations)
                    NavigationDestination(
                      icon: _icon(d, d.icon, activityCount),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ),
                ],
              ),
            ),
    );
  }

  /// Shows the number of log entries on the Activity tab.
  Widget _icon(_Destination d, IconData icon, int activityCount) {
    if (d.label != 'Activity' || activityCount == 0) return Icon(icon);
    return Badge.count(
      count: activityCount,
      maxCount: 99,
      backgroundColor: CrispColors.blue,
      child: Icon(icon),
    );
  }
}

/// Chat-bubble mark in Crisp blue.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A90FF), CrispColors.blue],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.chat_bubble_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
