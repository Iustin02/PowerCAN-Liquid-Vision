# Setup — Flutter (Android)

## Cerințe

| | |
|---|---|
| Flutter | stabil, Dart SDK ^3.11 |
| Android SDK | instalat prin Android Studio sau cu `ANDROID_HOME` setat |
| Application ID | `com.powercan.liquidvision` |

## Rulare

```bash
cd apps/flutter
flutter pub get
flutter run                  # pe un emulator sau un dispozitiv conectat
```

## Verificare și build

```bash
flutter analyze              # trebuie să afișeze "No issues found!"
flutter test
flutter build apk --release  # APK în build/app/outputs/flutter-apk/
```

## Dependențe

| Pachet | Rol |
|---|---|
| `provider` | state management (`ObdController`) |
| `flutter_map`, `latlong2` | hartă OpenStreetMap pentru trasee |
| `geolocator` | GPS |
| `shared_preferences` | trasee și configurarea endpoint-ului |
| `intl` | formatarea datelor |

## Permisiuni Android

Declarate în `android/app/src/main/AndroidManifest.xml`: `INTERNET` și `ACCESS_NETWORK_STATE` pentru TCP, `ACCESS_FINE_LOCATION` și `ACCESS_COARSE_LOCATION` pentru trasee.

> Pe Android, când rețeaua Wi-Fi a adaptorului nu are Internet, sistemul poate muta traficul pe date mobile. Dacă conexiunea eșuează, alege „Rămâi conectat” în dialogul Wi-Fi.
