import 'package:flutter/material.dart' hide ConnectionState;

import '../../models/obd_data.dart';
import '../../theme/lv_theme.dart';

class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({
    super.key,
    required this.state,
    required this.dataMode,
  });

  final ConnectionState state;
  final DataMode dataMode;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(state);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC0A0A0A),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.7), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(_statusIcon(state), size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            state.label,
            style: const TextStyle(color: LVTheme.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withOpacity(0.25), width: 0.8),
            ),
            child: Text(
              dataMode.label,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ConnectionState state) {
    switch (state) {
      case ConnectionState.connected:
        return LVTheme.neonGreen;
      case ConnectionState.simulating:
        return LVTheme.neonCyan;
      case ConnectionState.scanning:
      case ConnectionState.connecting:
      case ConnectionState.initializing:
        return LVTheme.neonOrange;
      case ConnectionState.error:
        return LVTheme.neonRed;
      case ConnectionState.disconnected:
        return LVTheme.textSecondary;
    }
  }

  IconData _statusIcon(ConnectionState state) {
    switch (state) {
      case ConnectionState.connected:
        return Icons.wifi_tethering;
      case ConnectionState.simulating:
        return Icons.graphic_eq;
      case ConnectionState.scanning:
        return Icons.radar;
      case ConnectionState.connecting:
      case ConnectionState.initializing:
        return Icons.sync;
      case ConnectionState.error:
        return Icons.warning_amber_rounded;
      case ConnectionState.disconnected:
        return Icons.portable_wifi_off;
    }
  }
}
