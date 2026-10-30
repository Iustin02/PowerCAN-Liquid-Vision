import 'package:flutter/material.dart';

import '../../theme/lv_theme.dart';
import 'liquid_card.dart';

class CarHeatMap extends StatefulWidget {
  const CarHeatMap({
    super.key,
    required this.heatLevel,
    required this.coolantTemp,
    required this.rpm,
    required this.speed,
  });

  final double heatLevel;
  final double coolantTemp;
  final double rpm;
  final double speed;

  @override
  State<CarHeatMap> createState() => _CarHeatMapState();
}

class _CarHeatMapState extends State<CarHeatMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heatColor = LVTheme.heatColor(widget.heatLevel);
    final coolantNorm = ((widget.coolantTemp - 20) / 90).clamp(0.0, 1.0);
    final rpmNorm = (widget.rpm / 6000).clamp(0.0, 1.0);
    final speedNorm = (widget.speed / 180).clamp(0.0, 1.0);

    return LiquidCard(
      radius: 24,
      child: SizedBox(
        height: 170,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final pulse = 0.25 + (_controller.value * 0.55);
            return Stack(
              alignment: Alignment.center,
              children: [
                _ambient(heatColor, pulse),
                Image.asset('assets/images/car_top.png', fit: BoxFit.contain),
                _spot(
                  Alignment(0.68, 0),
                  LVTheme.heatColor(coolantNorm),
                  58,
                  pulse * 0.85,
                ),
                _spot(
                  Alignment(-0.86, 0),
                  LVTheme.heatColor(rpmNorm),
                  40,
                  pulse * 0.6,
                ),
                _spot(
                  Alignment(0.40, -0.78),
                  LVTheme.heatColor(speedNorm),
                  36,
                  pulse * 0.55,
                ),
                _spot(
                  Alignment(0.40, 0.78),
                  LVTheme.heatColor(speedNorm),
                  36,
                  pulse * 0.55,
                ),
                _spot(
                  Alignment(-0.40, -0.78),
                  LVTheme.heatColor(speedNorm * 0.6),
                  32,
                  pulse * 0.40,
                ),
                _spot(
                  Alignment(-0.40, 0.78),
                  LVTheme.heatColor(speedNorm * 0.6),
                  32,
                  pulse * 0.40,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _ambient(Color color, double pulse) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color.withOpacity(0.08 + pulse * 0.04), Colors.transparent],
          radius: 0.9,
        ),
      ),
    );
  }

  Widget _spot(Alignment align, Color color, double size, double intensity) {
    return Align(
      alignment: align,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(intensity * 0.7),
              color.withOpacity(intensity * 0.25),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
