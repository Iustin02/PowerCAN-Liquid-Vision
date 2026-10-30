import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/obd_controller.dart';
import '../../theme/lv_theme.dart';
import '../widgets/arc_gauge.dart';
import '../widgets/car_heat_map.dart';
import '../widgets/connection_status_bar.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OBDController>();
    final data = vm.obdData;
    final rpmColor = LVTheme.heatColor(data.rpmNormalized);
    final coolantColor = data.coolantTemp < 70
        ? LVTheme.neonCyan
        : data.coolantTemp < 95
        ? LVTheme.neonGreen
        : LVTheme.neonRed;

    return Container(
      color: LVTheme.backgroundPrimary,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConnectionStatusBar(
                state: vm.connectionState,
                dataMode: vm.dataMode,
              ),
              Row(
                children: [
                  Expanded(
                    child: ArcGauge(
                      value: data.rpm,
                      maxValue: 7000,
                      label: 'ENGINE',
                      unit: 'RPM',
                      accentColor: rpmColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ArcGauge(
                      value: data.speed,
                      maxValue: 260,
                      label: 'SPEED',
                      unit: 'km/h',
                      accentColor: LVTheme.neonBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LVTheme.sectionSpacing),
              const _SectionTitle(title: 'VEHICLE THERMAL MAP'),
              const SizedBox(height: 8),
              CarHeatMap(
                heatLevel: data.heatLevel,
                coolantTemp: data.coolantTemp,
                rpm: data.rpm,
                speed: data.speed,
              ),
              const SizedBox(height: LVTheme.sectionSpacing),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                ),
                children: [
                  MetricCard(
                    title: 'Coolant',
                    value: data.coolantTemp.toStringAsFixed(0),
                    unit: '°C',
                    icon: Icons.thermostat,
                    accentColor: coolantColor,
                    trend: data.coolantTemp > 90 ? 1 : null,
                  ),
                  MetricCard(
                    title: 'Engine Load',
                    value: data.engineLoad.toStringAsFixed(0),
                    unit: '%',
                    icon: Icons.tune,
                    accentColor: LVTheme.neonBlue,
                  ),
                  MetricCard(
                    title: 'Fuel Trim S-T',
                    value: data.shortTermFuelTrim.toStringAsFixed(1),
                    unit: '%',
                    icon: Icons.local_gas_station_outlined,
                    accentColor: LVTheme.neonGreen,
                  ),
                  MetricCard(
                    title: 'Fuel Trim L-T',
                    value: data.longTermFuelTrim.toStringAsFixed(1),
                    unit: '%',
                    icon: Icons.local_gas_station,
                    accentColor: LVTheme.neonCyan,
                  ),
                  MetricCard(
                    title: 'Throttle',
                    value: data.throttlePosition.toStringAsFixed(0),
                    unit: '%',
                    icon: Icons.trending_up,
                    accentColor: LVTheme.neonOrange,
                  ),
                  MetricCard(
                    title: 'Consumption',
                    value: data.fuelConsumptionRate.toStringAsFixed(1),
                    unit: 'L/100km',
                    icon: Icons.opacity,
                    accentColor: LVTheme.neonGreen,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: vm.isTripActive ? vm.endTrip : vm.startTrip,
                  icon: Icon(
                    vm.isTripActive
                        ? Icons.stop_circle
                        : Icons.radio_button_checked,
                  ),
                  label: Text(
                    vm.isTripActive
                        ? 'End Trip Recording'
                        : 'Start Trip Recording',
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(LVTheme.minTouchTarget),
                    backgroundColor: vm.isTripActive
                        ? LVTheme.neonRed.withOpacity(0.78)
                        : LVTheme.neonGreen.withOpacity(0.70),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        color: LVTheme.textSecondary,
        letterSpacing: 1.4,
      ),
    );
  }
}
