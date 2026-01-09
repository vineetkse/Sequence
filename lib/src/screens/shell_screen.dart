import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'reports/reports_screen.dart';
import 'routines/routines_screen.dart';
import 'settings/settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = const [
      RoutinesScreen(),
      ReportsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 420),
          reverse: false,
          transitionBuilder: (child, animation, secondaryAnimation) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          ),
          child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.grid_view_rounded), label: l10n.tabRoutines),
          NavigationDestination(icon: const Icon(Icons.insights_rounded), label: l10n.tabReports),
          NavigationDestination(icon: const Icon(Icons.settings_rounded), label: l10n.tabSettings),
        ],
      ),
    );
  }
}

