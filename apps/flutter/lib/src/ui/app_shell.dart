import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/obd_controller.dart';
import '../theme/lv_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

enum AppTab {
  dashboard('Dashboard', Icons.speed),
  diagnostics('Errors', Icons.warning_amber_rounded),
  history('History', Icons.map),
  settings('Settings', Icons.settings);

  const AppTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.dashboard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OBDController>().startSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OBDController>();
    return Scaffold(
      body: Stack(
        children: [
          switch (_tab) {
            AppTab.dashboard => const DashboardScreen(),
            AppTab.diagnostics => const DiagnosticsScreen(),
            AppTab.history => const HistoryScreen(),
            AppTab.settings => const SettingsScreen(),
          },
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xCC0A0A0A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: AppTab.values.map((tab) {
                  final selected = _tab == tab;
                  final activeColor = _activeColor(tab);
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _tab = tab),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  tab.icon,
                                  size: selected ? 22 : 20,
                                  color: selected
                                      ? activeColor
                                      : LVTheme.textSecondary,
                                ),
                                if (tab == AppTab.diagnostics &&
                                    controller.dtcCodes.isNotEmpty)
                                  Positioned(
                                    right: -10,
                                    top: -6,
                                    child: Container(
                                      width: 17,
                                      height: 17,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: LVTheme.neonRed,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${controller.dtcCodes.length}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 10,
                                color: selected
                                    ? activeColor
                                    : LVTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _activeColor(AppTab tab) {
    switch (tab) {
      case AppTab.dashboard:
        return LVTheme.neonCyan;
      case AppTab.diagnostics:
        return LVTheme.neonOrange;
      case AppTab.history:
        return LVTheme.neonBlue;
      case AppTab.settings:
        return LVTheme.neonGreen;
    }
  }
}
