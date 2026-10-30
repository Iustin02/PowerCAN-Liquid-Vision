import 'package:flutter/material.dart';

import '../../theme/lv_theme.dart';
import 'liquid_card.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    this.trend,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final double? trend;

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: LVTheme.textSecondary,
                ),
              ),
              const Spacer(),
              if (trend != null)
                Icon(
                  trend! >= 0 ? Icons.north_east : Icons.south_east,
                  size: 12,
                  color: trend! >= 0 ? LVTheme.neonOrange : LVTheme.neonGreen,
                ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: LVTheme.textPrimary,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: LVTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
