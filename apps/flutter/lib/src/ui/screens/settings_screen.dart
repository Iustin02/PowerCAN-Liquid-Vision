import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/obd_data.dart';
import '../../state/obd_controller.dart';
import '../../theme/lv_theme.dart';
import '../widgets/liquid_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<OBDController>();
    _hostController = TextEditingController(text: vm.wifiHost);
    _portController = TextEditingController(text: vm.wifiPort);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OBDController>();
    return Container(
      color: LVTheme.backgroundPrimary,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 110),
          children: [
            Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [LVTheme.neonCyan, LVTheme.neonBlue],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.directions_car_filled,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'PowerCAN Liquid Vision',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'v1.0.0 — ESP32 OBD-II Diagnostics',
                  style: TextStyle(color: LVTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('DATA SOURCE', Icons.wifi_tethering),
            const SizedBox(height: 8),
            LiquidCard(
              child: Column(
                children: DataMode.values.map((mode) {
                  final selected = vm.dataMode == mode;
                  final color = mode == DataMode.simulated
                      ? LVTheme.neonCyan
                      : LVTheme.neonGreen;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 2,
                    ),
                    onTap: () => vm.setDataMode(mode),
                    leading: Icon(
                      mode == DataMode.simulated
                          ? Icons.graphic_eq
                          : Icons.wifi,
                      color: color,
                    ),
                    title: Text(mode.label),
                    subtitle: Text(
                      mode == DataMode.simulated
                          ? 'Realistic generated data for testing'
                          : 'Connect to ESP32 bridge over Wi-Fi (TCP)',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: selected
                        ? Icon(Icons.check_circle, color: color)
                        : const Icon(
                            Icons.circle_outlined,
                            color: LVTheme.textSecondary,
                          ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('WIFI ENDPOINT', Icons.router),
            const SizedBox(height: 8),
            LiquidCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Host / IP',
                    style: TextStyle(
                      color: LVTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _hostController,
                    decoration: _inputDecoration('192.168.4.1'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Port',
                    style: TextStyle(
                      color: LVTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('35000'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => vm.updateWifiConfig(
                        host: _hostController.text,
                        port: _portController.text,
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          LVTheme.minTouchTarget,
                        ),
                        backgroundColor: LVTheme.neonBlue.withOpacity(0.78),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Apply Wi-Fi Endpoint'),
                    ),
                  ),
                  if (vm.wifiConfigStatus != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      vm.wifiConfigStatus!,
                      style: TextStyle(
                        fontSize: 12,
                        color: vm.wifiConfigStatus!.contains('invalid')
                            ? LVTheme.neonRed
                            : LVTheme.neonGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('CONNECTION STATUS', Icons.link),
            const SizedBox(height: 8),
            LiquidCard(
              child: Column(
                children: [
                  _infoRow('State', vm.connectionState.label),
                  _infoRow('Mode', vm.dataMode.label),
                  _infoRow('Adapter', 'ESP32 OBD Wi-Fi Bridge'),
                  _infoRow('Endpoint', '${vm.wifiHost}:${vm.wifiPort}'),
                  _infoRow('Protocol', 'ELM327 over TCP'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('OBD-II PROTOCOL', Icons.description_outlined),
            const SizedBox(height: 8),
            const LiquidCard(
              child: Column(
                children: [
                  _StaticInfoRow('Init Sequence', 'ATZ → ATE0 → ATL1 → ATSP0'),
                  _StaticInfoRow('RPM Formula', '((256×A)+B)/4'),
                  _StaticInfoRow('Coolant Formula', 'A − 40'),
                  _StaticInfoRow('Speed Formula', 'A (direct)'),
                  _StaticInfoRow('Polling Rate', '~250ms (Tier 1)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 13, color: LVTheme.neonCyan),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: LVTheme.textSecondary,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: LVTheme.textSecondary),
      filled: true,
      fillColor: LVTheme.backgroundElevated.withOpacity(0.35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: LVTheme.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _StaticInfoRow extends StatelessWidget {
  const _StaticInfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: LVTheme.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
