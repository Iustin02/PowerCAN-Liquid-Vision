import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  Position? currentPosition;
  bool isTracking = false;
  final List<Position> routePositions = [];

  StreamSubscription<Position>? _positionSubscription;

  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> startTracking() async {
    routePositions.clear();
    isTracking = true;
    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10,
          ),
        ).listen((position) {
          currentPosition = position;
          if (isTracking) {
            routePositions.add(position);
          }
        });
  }

  Future<void> stopTracking() async {
    isTracking = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> dispose() async {
    await _positionSubscription?.cancel();
  }
}
