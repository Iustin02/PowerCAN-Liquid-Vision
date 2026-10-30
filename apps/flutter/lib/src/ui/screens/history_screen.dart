import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/trip_record.dart';
import '../../state/obd_controller.dart';
import '../../theme/lv_theme.dart';
import '../widgets/liquid_card.dart';
import 'trip_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<OBDController>().trips;
    return Container(
      color: LVTheme.backgroundPrimary,
      child: SafeArea(
        bottom: false,
        child: trips.isEmpty
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, size: 64, color: LVTheme.neonCyan),
                    SizedBox(height: 14),
                    Text(
                      'No Trips Recorded',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start a trip from Dashboard to see route history.',
                      style: TextStyle(color: LVTheme.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 110),
                itemCount: trips.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TripCard(trip: trips[index]),
                ),
              ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final TripRecord trip;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, HH:mm').format(trip.startDate);
    return InkWell(
      borderRadius: BorderRadius.circular(LVTheme.cardRadius),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip)));
      },
      child: LiquidCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            if (trip.routePoints.length > 1)
              SizedBox(
                height: 140,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      trip.routePoints.first.latitude,
                      trip.routePoints.first.longitude,
                    ),
                    initialZoom: 13,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.powercan.liquidvision.flutter',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: trip.routePoints
                              .map(
                                (point) =>
                                    LatLng(point.latitude, point.longitude),
                              )
                              .toList(),
                          strokeWidth: 4,
                          color: LVTheme.neonCyan,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(LVTheme.cardPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: LVTheme.neonCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          trip.durationFormatted,
                          style: const TextStyle(
                            color: LVTheme.neonCyan,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _stat(
                        Icons.speed,
                        trip.maxSpeed.toStringAsFixed(0),
                        'km/h max',
                      ),
                      _stat(
                        Icons.route,
                        trip.distanceKm.toStringAsFixed(1),
                        'km',
                      ),
                      _stat(
                        Icons.av_timer,
                        trip.maxRpm.toStringAsFixed(0),
                        'RPM max',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: LVTheme.neonCyan, size: 16),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: LVTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
