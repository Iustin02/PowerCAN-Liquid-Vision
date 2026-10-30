import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/state/obd_controller.dart';
import 'src/theme/lv_theme.dart';
import 'src/ui/app_shell.dart';

void main() {
  runApp(const PowerCanLiquidVisionApp());
}

class PowerCanLiquidVisionApp extends StatelessWidget {
  const PowerCanLiquidVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OBDController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PowerCAN Liquid Vision',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: LVTheme.backgroundPrimary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: LVTheme.neonCyan,
            brightness: Brightness.dark,
            surface: LVTheme.backgroundCard,
          ),
          useMaterial3: true,
          textTheme: Typography.whiteMountainView.apply(
            bodyColor: LVTheme.textPrimary,
            displayColor: LVTheme.textPrimary,
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}
