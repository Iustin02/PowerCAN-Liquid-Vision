class DiagnosticTroubleCode {
  DiagnosticTroubleCode({
    required this.code,
    required this.category,
    required this.description,
    required this.severity,
    required this.timestamp,
  });

  final String code;
  final DTCCategory category;
  final String description;
  final DTCSeverity severity;
  final DateTime timestamp;
}

enum DTCCategory {
  powertrain('Powertrain', 'P'),
  chassis('Chassis', 'C'),
  body('Body', 'B'),
  network('Network', 'U');

  const DTCCategory(this.label, this.prefix);
  final String label;
  final String prefix;
}

enum DTCSeverity {
  critical('Critical'),
  warning('Warning'),
  info('Info');

  const DTCSeverity(this.label);
  final String label;
}

class DTCDecoder {
  static DTCCategory categoryFor(String code) {
    if (code.startsWith('C')) return DTCCategory.chassis;
    if (code.startsWith('B')) return DTCCategory.body;
    if (code.startsWith('U')) return DTCCategory.network;
    return DTCCategory.powertrain;
  }

  static DTCSeverity severityFor(String code) {
    if (code.length < 2) return DTCSeverity.info;
    final second = code[1];
    if (second == '0') return DTCSeverity.critical;
    if (second == '1') return DTCSeverity.warning;
    return DTCSeverity.info;
  }
}

class DTCDatabase {
  static const Map<String, String> descriptions = {
    'P0100': 'Mass Air Flow Circuit Malfunction',
    'P0101': 'Mass Air Flow Circuit Range/Performance',
    'P0115': 'Engine Coolant Temp Circuit Malfunction',
    'P0128': 'Coolant Thermostat Below Operating Temp',
    'P0135': 'O2 Sensor Heater Circuit Malfunction (B1S1)',
    'P0171': 'System Too Lean (Bank 1)',
    'P0172': 'System Too Rich (Bank 1)',
    'P0217': 'Engine Overtemp Condition',
    'P0300': 'Random/Multiple Cylinder Misfire Detected',
    'P0301': 'Cylinder 1 Misfire Detected',
    'P0302': 'Cylinder 2 Misfire Detected',
    'P0325': 'Knock Sensor 1 Circuit Malfunction',
    'P0340': 'Camshaft Position Sensor Circuit Malfunction',
    'P0420': 'Catalyst System Efficiency Below Threshold (B1)',
    'P0442': 'EVAP System Leak Detected (Small Leak)',
    'P0455': 'EVAP System Leak Detected (Large Leak)',
    'P0505': 'Idle Control System Malfunction',
    'P0507': 'Idle Control System RPM Higher Than Expected',
    'P0562': 'System Voltage Low',
    'P0700': 'Transmission Control System Malfunction',
    'C0035': 'Left Front Wheel Speed Circuit Malfunction',
    'C0050': 'Right Rear Wheel Speed Circuit Malfunction',
    'C0550': 'ECU Performance (Stability Control)',
    'B1000': 'ECU Malfunction (Body Control Module)',
    'U0100': 'Lost Communication with ECM/PCM',
    'U0121': 'Lost Communication with ABS Module',
  };

  static String describe(String code) =>
      descriptions[code] ?? 'Unknown fault — check service manual';
}
