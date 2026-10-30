import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../models/trip_record.dart';
import '../../theme/lv_theme.dart';
import '../widgets/liquid_card.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key, required this.trip});

  final TripRecord trip;

  @override
  Widget build(BuildContext context) {
    final route = trip.routePoints;
    final center = route.isNotEmpty
        ? LatLng(route.first.latitude, route.first.longitude)
        : const LatLng(44.4268, 26.1025);

    return Scaffold(
      backgroundColor: LVTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Trip Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        children: [
          Text(
            DateFormat('dd MMM yyyy, HH:mm').format(trip.startDate),
            style: const TextStyle(color: LVTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          if (route.length > 1)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(initialCenter: center, initialZoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.powercan.liquidvision.flutter',
                    ),
                    PolylineLayer(
                      polylines: [
                        for (var i = 0; i < route.length - 1; i++)
                          Polyline(
                            points: [
                              LatLng(route[i].latitude, route[i].longitude),
                              LatLng(
                                route[i + 1].latitude,
                                route[i + 1].longitude,
                              ),
                            ],
                            strokeWidth: 5,
                            color: LVTheme.heatColor(route[i].speedNormalized),
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            route.first.latitude,
                            route.first.longitude,
                          ),
                          width: 36,
                          height: 36,
                          child: const Icon(
                            Icons.flag_circle,
                            color: LVTheme.neonGreen,
                            size: 30,
                          ),
                        ),
                        Marker(
                          point: LatLng(
                            route.last.latitude,
                            route.last.longitude,
                          ),
                          width: 36,
                          height: 36,
                          child: const Icon(
                            Icons.outlined_flag,
                            color: LVTheme.neonRed,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          _statsGrid(trip),
        ],
      ),
    );
  }

  Widget _statsGrid(TripRecord trip) {
    return Column(
      children: [
        Row(
          children: [
            _statCard(
              'Distance',
              trip.distanceKm.toStringAsFixed(1),
              'km',
              Icons.route,
              LVTheme.neonCyan,
            ),
            const SizedBox(width: 10),
            _statCard(
              'Duration',
              trip.durationFormatted,
              '',
              Icons.access_time,
              LVTheme.neonBlue,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(
              'Max Speed',
              trip.maxSpeed.toStringAsFixed(0),
              'km/h',
              Icons.speed,
              LVTheme.neonOrange,
            ),
            const SizedBox(width: 10),
            _statCard(
              'Avg Speed',
              trip.avgSpeed.toStringAsFixed(0),
              'km/h',
              Icons.dashboard,
              LVTheme.neonGreen,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(
              'Max RPM',
              trip.maxRpm.toStringAsFixed(0),
              'RPM',
              Icons.av_timer,
              LVTheme.neonRed,
            ),
            const SizedBox(width: 10),
            _statCard(
              'Fuel Cons.',
              trip.avgFuelConsumption.toStringAsFixed(1),
              'L/100km',
              Icons.local_gas_station,
              LVTheme.neonGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: LiquidCard(
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  color: LVTheme.textSecondary,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: LVTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
