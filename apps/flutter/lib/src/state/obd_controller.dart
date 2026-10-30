import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dtc.dart';
import '../models/obd_data.dart';
import '../models/trip_record.dart';
import '../services/data_provider.dart';
import '../services/location_tracking_service.dart';
import '../services/mock_data_manager.dart';
import '../services/mock_dtc_generator.dart';
import '../services/trip_storage.dart';
import '../services/wifi_obd_manager.dart';

class OBDController extends ChangeNotifier {
  OBDController() {
    _bindProvider();
    _bootstrap();
  }

  OBDData obdData = const OBDData();
  ConnectionState connectionState = ConnectionState.disconnected;
  DataMode dataMode = DataMode.simulated;

  String wifiHost = '192.168.4.1';
  String wifiPort = '35000';
  String? wifiConfigStatus;

  bool isTripActive = false;
  List<DiagnosticTroubleCode> dtcCodes = [];
  List<TripRecord> trips = [];

  final LocationTrackingService locationService = LocationTrackingService();
  final TripStorage tripStorage = TripStorage();

  final MockDataManager _mockProvider = MockDataManager();
  final WiFiOBDManager _wifiProvider = WiFiOBDManager();
  DataProvider? _provider;

  StreamSubscription<OBDData>? _obdSub;
  StreamSubscription<ConnectionState>? _stateSub;
  Timer? _tripTimer;

  DateTime? _tripStartDate;
  final List<double> _tripSpeedSamples = [];
  final List<RoutePoint> _tripRoutePoints = [];
  double _tripMaxSpeed = 0;
  double _tripMaxRpm = 0;

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    wifiHost = prefs.getString('wifi.obd.host') ?? wifiHost;
    wifiPort = prefs.getString('wifi.obd.port') ?? wifiPort;
    _wifiProvider.updateEndpoint(
      host: wifiHost,
      port: int.tryParse(wifiPort) ?? 35000,
    );
    trips = await tripStorage.loadTrips();
    _provider?.start();
    notifyListeners();
  }

  void _bindProvider() {
    _provider = dataMode == DataMode.simulated ? _mockProvider : _wifiProvider;
    _obdSub?.cancel();
    _stateSub?.cancel();
    _obdSub = _provider!.obdDataStream.listen((data) {
      obdData = data;
      notifyListeners();
    });
    _stateSub = _provider!.connectionStateStream.listen((state) {
      connectionState = state;
      notifyListeners();
    });
  }

  Future<void> setDataMode(DataMode mode) async {
    if (mode == dataMode) return;
    await _provider?.stop();
    dataMode = mode;
    _bindProvider();
    await _provider?.start();
    notifyListeners();
  }

  Future<void> startSession() async {
    await _provider?.start();
  }

  Future<void> stopSession() async {
    await _provider?.stop();
  }

  Future<void> updateWifiConfig({
    required String host,
    required String port,
  }) async {
    final normalizedHost = host.trim();
    final parsedPort = int.tryParse(port.trim());

    if (normalizedHost.isEmpty) {
      wifiConfigStatus = 'Host invalid. Introdu o adresa IP sau hostname.';
      notifyListeners();
      return;
    }
    if (parsedPort == null || parsedPort < 1 || parsedPort > 65535) {
      wifiConfigStatus = 'Port invalid. Foloseste un numar intre 1 si 65535.';
      notifyListeners();
      return;
    }

    wifiHost = normalizedHost;
    wifiPort = parsedPort.toString();
    _wifiProvider.updateEndpoint(host: wifiHost, port: parsedPort);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wifi.obd.host', wifiHost);
    await prefs.setString('wifi.obd.port', wifiPort);

    wifiConfigStatus = 'Endpoint actualizat la $wifiHost:$wifiPort.';
    if (dataMode == DataMode.liveObd) {
      await _provider?.start();
    }
    notifyListeners();
  }

  void scanDTCs() {
    if (dataMode == DataMode.simulated) {
      dtcCodes = MockDTCGenerator.generate();
    } else {
      dtcCodes = _simulateLiveDtcSnapshot();
    }
    notifyListeners();
  }

  List<DiagnosticTroubleCode> _simulateLiveDtcSnapshot() {
    final random = Random();
    final base = MockDTCGenerator.generate();
    if (base.isNotEmpty && random.nextBool())
      return base.take(max(1, base.length - 1)).toList();
    return base;
  }

  void clearDTCs() {
    dtcCodes = [];
    notifyListeners();
  }

  Future<void> startTrip() async {
    final granted = await locationService.requestPermission();
    if (!granted) {
      wifiConfigStatus = 'Permisiunea de locatie este necesara pentru traseu.';
      notifyListeners();
      return;
    }

    _tripStartDate = DateTime.now();
    _tripSpeedSamples.clear();
    _tripRoutePoints.clear();
    _tripMaxSpeed = 0;
    _tripMaxRpm = 0;
    isTripActive = true;

    await locationService.startTracking();
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _recordTripPoint(),
    );
    notifyListeners();
  }

  void _recordTripPoint() {
    _tripSpeedSamples.add(obdData.speed);
    _tripMaxSpeed = max(_tripMaxSpeed, obdData.speed);
    _tripMaxRpm = max(_tripMaxRpm, obdData.rpm);

    final current = locationService.currentPosition;
    if (current != null) {
      _tripRoutePoints.add(
        RoutePoint(
          latitude: current.latitude,
          longitude: current.longitude,
          speed: obdData.speed,
          rpm: obdData.rpm,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> endTrip() async {
    isTripActive = false;
    _tripTimer?.cancel();
    _tripTimer = null;
    await locationService.stopTracking();

    final avgSpeed = _tripSpeedSamples.isEmpty
        ? 0.0
        : _tripSpeedSamples.reduce((a, b) => a + b) / _tripSpeedSamples.length;
    var distanceMeters = 0.0;
    for (var i = 1; i < _tripRoutePoints.length; i++) {
      final prev = _tripRoutePoints[i - 1];
      final curr = _tripRoutePoints[i];
      distanceMeters += Geolocator.distanceBetween(
        prev.latitude,
        prev.longitude,
        curr.latitude,
        curr.longitude,
      );
    }

    final trip = TripRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startDate: _tripStartDate ?? DateTime.now(),
      endDate: DateTime.now(),
      routePoints: List<RoutePoint>.from(_tripRoutePoints),
      maxSpeed: _tripMaxSpeed,
      avgSpeed: avgSpeed,
      maxRpm: _tripMaxRpm,
      avgFuelConsumption: obdData.fuelConsumptionRate,
      distanceKm: distanceMeters / 1000,
      isActive: false,
    );
    trips = [trip, ...trips];
    await tripStorage.saveTrips(trips);
    notifyListeners();
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    _obdSub?.cancel();
    _stateSub?.cancel();
    _provider?.stop();
    _mockProvider.dispose();
    _wifiProvider.dispose();
    locationService.dispose();
    super.dispose();
  }
}
