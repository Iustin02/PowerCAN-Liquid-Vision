class RoutePoint {
  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.rpm,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double speed;
  final double rpm;
  final DateTime timestamp;

  double get speedNormalized => (speed / 160).clamp(0, 1);

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'speed': speed,
    'rpm': rpm,
    'timestamp': timestamp.toIso8601String(),
  };

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      rpm: (json['rpm'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class TripRecord {
  TripRecord({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.routePoints,
    required this.maxSpeed,
    required this.avgSpeed,
    required this.maxRpm,
    required this.avgFuelConsumption,
    required this.distanceKm,
    required this.isActive,
  });

  final String id;
  final DateTime startDate;
  DateTime? endDate;
  final List<RoutePoint> routePoints;
  final double maxSpeed;
  final double avgSpeed;
  final double maxRpm;
  final double avgFuelConsumption;
  final double distanceKm;
  final bool isActive;

  String get durationFormatted {
    final end = endDate ?? DateTime.now();
    final secs = end.difference(startDate).inSeconds;
    final hours = secs ~/ 3600;
    final mins = (secs % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '$mins min';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'routePoints': routePoints.map((e) => e.toJson()).toList(),
    'maxSpeed': maxSpeed,
    'avgSpeed': avgSpeed,
    'maxRpm': maxRpm,
    'avgFuelConsumption': avgFuelConsumption,
    'distanceKm': distanceKm,
    'isActive': isActive,
  };

  factory TripRecord.fromJson(Map<String, dynamic> json) {
    return TripRecord(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      routePoints: ((json['routePoints'] as List<dynamic>?) ?? <dynamic>[])
          .cast<Map<String, dynamic>>()
          .map(RoutePoint.fromJson)
          .toList(),
      maxSpeed: (json['maxSpeed'] as num?)?.toDouble() ?? 0,
      avgSpeed: (json['avgSpeed'] as num?)?.toDouble() ?? 0,
      maxRpm: (json['maxRpm'] as num?)?.toDouble() ?? 0,
      avgFuelConsumption: (json['avgFuelConsumption'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}
