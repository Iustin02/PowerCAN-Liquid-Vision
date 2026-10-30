import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip_record.dart';

class TripStorage {
  static const _tripsKey = 'powercan.trip.records.v1';

  Future<List<TripRecord>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tripsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(TripRecord.fromJson)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> saveTrips(List<TripRecord> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(trips.map((e) => e.toJson()).toList());
    await prefs.setString(_tripsKey, payload);
  }
}
