import 'dart:math';

import '../models/dtc.dart';

class MockDTCGenerator {
  static const _commonCodes = [
    'P0171',
    'P0300',
    'P0420',
    'P0442',
    'P0507',
    'P0128',
    'P0135',
    'P0301',
    'P0172',
    'P0562',
    'P0340',
    'P0325',
    'P0455',
    'P0700',
    'P0505',
    'C0035',
    'C0050',
    'C0550',
    'B1000',
    'U0100',
    'U0121',
  ];

  static final _random = Random();

  static List<DiagnosticTroubleCode> generate() {
    final shuffled = [..._commonCodes]..shuffle();
    final count = 2 + _random.nextInt(5);
    final selected = shuffled.take(count);
    final generated = selected.map((code) {
      final category = DTCDecoder.categoryFor(code);
      final severity = DTCDecoder.severityFor(code);
      return DiagnosticTroubleCode(
        code: code,
        category: category,
        description: DTCDatabase.describe(code),
        severity: severity,
        timestamp: DateTime.now().subtract(
          Duration(minutes: _random.nextInt(60)),
        ),
      );
    }).toList();

    generated.sort((a, b) {
      if (a.severity == DTCSeverity.critical &&
          b.severity != DTCSeverity.critical)
        return -1;
      if (a.severity != DTCSeverity.critical &&
          b.severity == DTCSeverity.critical)
        return 1;
      return a.code.compareTo(b.code);
    });
    return generated;
  }
}
