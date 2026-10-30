enum ConnectionState {
  disconnected('Disconnected'),
  scanning('Scanning...'),
  connecting('Connecting...'),
  initializing('Initializing ELM327...'),
  connected('Connected'),
  simulating('Simulation Mode'),
  error('Connection Error');

  const ConnectionState(this.label);
  final String label;
}

enum DataMode {
  simulated('Simulated Data'),
  liveObd('Live OBD (Wi-Fi)');

  const DataMode(this.label);
  final String label;
}

class OBDData {
  const OBDData({
    this.rpm = 0,
    this.speed = 0,
    this.coolantTemp = 20,
    this.shortTermFuelTrim = 0,
    this.longTermFuelTrim = 0,
    this.intakeTemp = 20,
    this.engineLoad = 0,
    this.throttlePosition = 0,
    this.mafRate = 0,
    this.fuelConsumptionRate = 0,
  });

  final double rpm;
  final double speed;
  final double coolantTemp;
  final double shortTermFuelTrim;
  final double longTermFuelTrim;
  final double intakeTemp;
  final double engineLoad;
  final double throttlePosition;
  final double mafRate;
  final double fuelConsumptionRate;

  double get rpmNormalized => (rpm / 7000).clamp(0, 1);
  double get speedNormalized => (speed / 260).clamp(0, 1);
  double get coolantNormalized => ((coolantTemp - 20) / 100).clamp(0, 1);
  double get heatLevel =>
      (0.4 * rpmNormalized) +
      (0.3 * speedNormalized) +
      (0.3 * coolantNormalized);

  OBDData copyWith({
    double? rpm,
    double? speed,
    double? coolantTemp,
    double? shortTermFuelTrim,
    double? longTermFuelTrim,
    double? intakeTemp,
    double? engineLoad,
    double? throttlePosition,
    double? mafRate,
    double? fuelConsumptionRate,
  }) {
    return OBDData(
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      coolantTemp: coolantTemp ?? this.coolantTemp,
      shortTermFuelTrim: shortTermFuelTrim ?? this.shortTermFuelTrim,
      longTermFuelTrim: longTermFuelTrim ?? this.longTermFuelTrim,
      intakeTemp: intakeTemp ?? this.intakeTemp,
      engineLoad: engineLoad ?? this.engineLoad,
      throttlePosition: throttlePosition ?? this.throttlePosition,
      mafRate: mafRate ?? this.mafRate,
      fuelConsumptionRate: fuelConsumptionRate ?? this.fuelConsumptionRate,
    );
  }
}
