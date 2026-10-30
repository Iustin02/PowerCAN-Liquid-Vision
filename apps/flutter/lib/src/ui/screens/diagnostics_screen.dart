import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dtc.dart';
import '../../state/obd_controller.dart';
import '../../theme/lv_theme.dart';
import '../widgets/liquid_card.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  bool _scanning = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OBDController>();
    final codes = vm.dtcCodes;
    final grouped = {
      for (final category in DTCCategory.values)
        category: codes.where((code) => code.category == category).toList(),
    }..removeWhere((_, list) => list.isEmpty);

    return Container(
      color: LVTheme.backgroundPrimary,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 110),
          child: Column(
            children: [
              _statusHeader(codes),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _scanning
                          ? null
                          : () async {
                              setState(() => _scanning = true);
                              vm.clearDTCs();
                              await Future<void>.delayed(
                                const Duration(seconds: 2),
                              );
                              vm.scanDTCs();
                              if (mounted) setState(() => _scanning = false);
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          LVTheme.minTouchTarget,
                        ),
                        backgroundColor: LVTheme.neonCyan.withOpacity(0.8),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.search),
                      label: Text(_scanning ? 'Scanning...' : 'Scan DTCs'),
                    ),
                  ),
                  if (codes.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => vm.clearDTCs(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(
                            LVTheme.minTouchTarget,
                          ),
                          backgroundColor: LVTheme.neonRed.withOpacity(0.75),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear'),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (codes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Column(
                    children: [
                      Icon(Icons.verified, color: LVTheme.neonGreen, size: 56),
                      SizedBox(height: 12),
                      Text(
                        'All Clear',
                        style: TextStyle(
                          fontSize: 20,
                          color: LVTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...grouped.entries.map((entry) {
                  return _CategorySection(
                    category: entry.key,
                    codes: entry.value,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusHeader(List<DiagnosticTroubleCode> codes) {
    final criticalCount = codes
        .where((e) => e.severity == DTCSeverity.critical)
        .length;
    final color = _scanning
        ? LVTheme.neonCyan
        : criticalCount > 0
        ? LVTheme.neonRed
        : codes.isNotEmpty
        ? LVTheme.neonOrange
        : LVTheme.neonGreen;

    final title = _scanning
        ? 'Scanning ECU...'
        : codes.isEmpty
        ? 'No Faults Detected'
        : '${codes.length} Fault${codes.length == 1 ? '' : 's'} Found';

    final subtitle = _scanning
        ? 'Reading diagnostic trouble codes from vehicle ECU...'
        : criticalCount > 0
        ? '$criticalCount critical issue(s) require attention.'
        : codes.isEmpty
        ? 'Vehicle systems are operating normally.'
        : 'Review the codes below for details.';

    return LiquidCard(
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 16),
              ],
            ),
            alignment: Alignment.center,
            child: _scanning
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    codes.isEmpty
                        ? Icons.gpp_good
                        : Icons.warning_amber_rounded,
                    color: color,
                    size: 34,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: LVTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.codes});

  final DTCCategory category;
  final List<DiagnosticTroubleCode> codes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          category.label.toUpperCase(),
          style: const TextStyle(
            color: LVTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        ...codes.map((code) => _DtcCard(code: code)),
      ],
    );
  }
}

class _DtcCard extends StatelessWidget {
  const _DtcCard({required this.code});

  final DiagnosticTroubleCode code;

  @override
  Widget build(BuildContext context) {
    final categoryColor = switch (code.category) {
      DTCCategory.powertrain => LVTheme.neonRed,
      DTCCategory.chassis => LVTheme.neonOrange,
      DTCCategory.body => LVTheme.neonCyan,
      DTCCategory.network => LVTheme.neonBlue,
    };

    final severityColor = switch (code.severity) {
      DTCSeverity.critical => LVTheme.neonRed,
      DTCSeverity.warning => LVTheme.neonOrange,
      DTCSeverity.info => LVTheme.neonCyan,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LiquidCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 72,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code.code,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          code.severity.label,
                          style: TextStyle(
                            color: severityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    code.description,
                    style: const TextStyle(
                      color: LVTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
