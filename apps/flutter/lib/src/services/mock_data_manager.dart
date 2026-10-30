import 'dart:async';
import 'dart:math';

import '../models/obd_data.dart';
import 'data_provider.dart';

class MockDataManager implements DataProvider {
  final _obdDataController = StreamController<OBDData>.broadcast();
  final _stateController = StreamController<ConnectionState>.broadcast();
  final _random = Random();

  OBDData _currentData = const OBDData();
  ConnectionState _state = ConnectionState.disconnected;
  Timer? _timer;
  double _elapsed = 0;

  @override
  Stream<OBDData> get obdDataStream => _obdDataController.stream;

  @override
  Stream<ConnectionState> get connectionStateStream => _stateController.stream;

  @override
  OBDData get currentData => _currentData;

  @override
  ConnectionState get connectionState => _state;

  @override
  Future<void> start() async {
    _elapsed = 0;
    _setState(ConnectionState.simulating);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _currentData = const OBDData();
    _obdDataController.add(_currentData);
    _setState(ConnectionState.disconnected);
  }

  void _tick() {
    _elapsed += 0.1;
    final rpmCycle = sin(_elapsed * 0.4) * sin(_elapsed * 0.15);
    final rpm = max<double>(800.0, 2800 + (2200 * rpmCycle) + _jitter(30));

    final accelPhase = min(_elapsed / 25, 1.0);
    var speed = max(
      0.0,
      (130 * accelPhase) + (sin(_elapsed * 0.2) * 20) + _jitter(2),
    );
    speed = min(speed, 220);

    var coolant =
        20 +
        (72 * min(_elapsed / 60, 1.0)) +
        (sin(_elapsed * 0.05) * 3) +
        _jitter(0.5);
    coolant = min(coolant, 110);

    final stft = (sin(_elapsed * 0.6) * 8) + _jitter(1);
    final ltft = (sin(_elapsed * 0.1) * 4) + _jitter(0.5);
    final intake = 25 + (sin(_elapsed * 0.08) * 10) + _jitter(1);
    final engineLoad = (40 + (30 * sin(_elapsed * 0.3)) + _jitter(3)).clamp(
      0,
      100,
    );
    final throttle = (30 + (40 * sin(_elapsed * 0.5)) + _jitter(2)).clamp(
      0,
      100,
    );
    final maf = max<double>(0.0, 8 + (6 * sin(_elapsed * 0.35)) + _jitter(0.5));
    final consumption = speed > 5
        ? ((maf * 3600) / (14.7 * 745.0 * speed) * 100).clamp(0, 30)
        : 0.0;

    _currentData = OBDData(
      rpm: rpm,
      speed: speed,
      coolantTemp: coolant,
      shortTermFuelTrim: stft,
      longTermFuelTrim: ltft,
      intakeTemp: intake,
      engineLoad: engineLoad.toDouble(),
      throttlePosition: throttle.toDouble(),
      mafRate: maf,
      fuelConsumptionRate: consumption.toDouble(),
    );
    _obdDataController.add(_currentData);
  }

  double _jitter(double amp) => (_random.nextDouble() * 2 * amp) - amp;

  void _setState(ConnectionState state) {
    _state = state;
    _stateController.add(_state);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _obdDataController.close();
    _stateController.close();
  }
}
