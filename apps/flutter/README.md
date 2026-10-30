# PowerCAN Liquid Vision — Flutter (Android)

Portul Android al aplicației iOS, la paritate funcțională: Dashboard, Diagnostics, History, Settings, mod simulare și Live OBD peste Wi-Fi TCP.

```bash
flutter pub get
flutter run
flutter analyze && flutter test
```

```
lib/
├── main.dart
└── src/
    ├── models/        # obd_data, dtc, trip_record
    ├── services/      # wifi_obd_manager (TCP/ELM327), mock_data_manager, mock_dtc_generator,
    │                  # location_tracking_service, trip_storage, data_provider
    ├── state/         # obd_controller (ChangeNotifier + Provider)
    ├── theme/         # lv_theme (token-uri identice cu Theme.swift)
    └── ui/            # app_shell, screens/, widgets/
```

Stack: Provider · flutter_map + OpenStreetMap · geolocator · shared_preferences.

Ghid complet: [`../../docs/setup-flutter.md`](../../docs/setup-flutter.md) · corespondența cu iOS: [`../../docs/architecture.md`](../../docs/architecture.md#corespondență-ios--flutter).
