import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/lv_theme.dart';

class LiquidCard extends StatelessWidget {
  const LiquidCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(LVTheme.cardPadding),
    this.radius = LVTheme.cardRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: LVTheme.backgroundCard,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
