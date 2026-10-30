# Setup — iOS

## Cerințe

| | |
|---|---|
| macOS + Xcode | 15.0+ |
| Swift | 5.9+ |
| Deployment target | iOS 17.0 (SwiftData) |
| Generare proiect | [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `brew install xcodegen` |

## Generarea proiectului

Proiectul Xcode se generează din `apps/ios/project.yml`. Fișierul `.xcodeproj` e versionat, ca proiectul să se deschidă și fără XcodeGen. După orice fișier adăugat, șters sau redenumit, regenerează proiectul:

```bash
cd apps/ios
xcodegen generate
```

Nu edita `project.pbxproj` de mână; modificările se pierd la următoarea regenerare.

## Rulare

```bash
open PowerCANLiquidVision.xcodeproj
```

Alege un simulator iPhone și apasă **Cmd+R**. Aplicația pornește în modul simulare.

Build din linia de comandă, fără semnătură (util în CI):

```bash
xcodebuild -project PowerCANLiquidVision.xcodeproj -scheme PowerCANLiquidVision \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

## Pe dispozitiv

1. *Signing & Capabilities* → alege echipa ta (Apple ID). Bundle ID-ul implicit e `com.powercan.liquidvision`; schimbă-l dacă e deja folosit.
2. Conectează iPhone-ul și apasă Cmd+R.
3. Pe telefon: *Settings → General → VPN & Device Management → Trust*.

## Permisiuni (`Resources/Info.plist`)

| Cheie | De ce |
|---|---|
| `NSLocalNetworkUsageDescription` | conexiunea TCP la bridge-ul ESP32 |
| `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, `NSLocationAlwaysUsageDescription` | înregistrarea traseelor |
| `UIBackgroundModes: location` | înregistrarea traseului și cu ecranul blocat |

## Conectarea la adaptor

1. Alimentează ESP32 din priza OBD a mașinii.
2. Conectează iPhone-ul la rețeaua Wi-Fi a adaptorului. iOS poate afișa „No Internet Connection”; e normal.
3. În aplicație: *Settings → Live OBD (Wi-Fi)* și verifică endpoint-ul (implicit `192.168.4.1:35000`).
4. Bara de stare trece prin *Connecting → Initializing ELM327 → Connected*.
