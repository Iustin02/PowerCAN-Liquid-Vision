# PowerCAN Liquid Vision

Aplicatie iOS de diagnosticare OBD-II cu design Liquid Glass, compatibila cu **Mister Diy PowerCAN ESP32**.

## Cerinte

| Cerinta | Valoare |
|---------|---------|
| Xcode | 15.0+ |
| Swift | 5.9+ |
| iOS Deployment Target | 17.0 |
| Dispozitiv tinta | iPhone 12 Pro Max |
| Frameworks | SwiftUI, SwiftData, CoreBluetooth, MapKit, CoreLocation |

## Setup Xcode — Pas cu Pas

### 1. Creeaza Proiectul

1. Deschide **Xcode** → **File** → **New** → **Project**
2. Selecteaza **App** sub iOS → **Next**
3. Completeaza:
   - Product Name: `PowerCANLiquidVision`
   - Team: (contul tau de developer)
   - Organization Identifier: `com.powercan`
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Language: **Swift**
4. Apasa **Next** → alege locatia → **Create**

### 2. Seteaza Deployment Target

1. Click pe proiect in Project Navigator (iconita albastra de sus)
2. Tab-ul **General** → **Minimum Deployments** → seteaza **iOS 17.0**

### 3. Adauga Fisierele Sursa

1. In Xcode: **File** → **Add Files to "PowerCANLiquidVision"**
2. Selecteaza tot continutul din folderul `PowerCANLiquidVision/`:
   - `Models/` (OBDData.swift, TripRecord.swift, DataProvider.swift)
   - `Services/` (MockDataManager.swift, BLEManager.swift, LocationManager.swift)
   - `ViewModels/` (OBDViewModel.swift)
   - `DesignSystem/` (Theme.swift, GlassModifiers.swift)
   - `Views/` (toate sub-folderele)
   - `PowerCANLiquidVisionApp.swift`
3. Bifeaza **"Copy items if needed"** si **"Create groups"**
4. Sterge fisierele `ContentView.swift` si App-ul generat automat de Xcode (cele default)

### 4. Configureaza Info.plist

Mergi in tab-ul **Info** al target-ului si adauga manual aceste chei:

| Cheie | Valoare |
|-------|---------|
| `NSBluetoothAlwaysUsageDescription` | PowerCAN Liquid Vision necesita acces Bluetooth pentru a comunica cu adaptorul OBD-II ESP32 PowerCAN si a citi datele de diagnosticare ale vehiculului in timp real. |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | PowerCAN Liquid Vision foloseste locatia pentru a inregistra traseele tale, a calcula distanta parcursa si a afisa ruta pe harta cu date de viteza colorate dinamic. |
| `NSLocationWhenInUseUsageDescription` | Accesul la locatie este necesar pentru inregistrarea traseelor si afisarea pozitiei pe harta. |

Alternativ, inlocuieste fisierul Info.plist cu cel din `Resources/Info.plist`.

### 5. Activeaza Background Modes

1. Click pe target-ul proiectului
2. Tab **Signing & Capabilities**
3. Apasa **"+ Capability"**
4. Cauta si adauga **Background Modes**
5. Bifeaza:
   - [x] **Uses Bluetooth LE accessories** (pentru comunicare continua cu ESP32)
   - [x] **Location updates** (pentru inregistrarea rutelor in fundal)

### 6. Ruleaza pe Simulator

1. Selecteaza **iPhone 15 Pro Max** (sau iPhone 12 Pro Max) din dropdown-ul de dispozitive
2. Apasa **Cmd + R**
3. Aplicatia porneste automat in **Simulation Mode** cu date pulsante

### 7. Instaleaza pe Telefon

1. Conecteaza iPhone-ul prin cablu USB
2. Selecteaza dispozitivul din lista Xcode
3. Asigura-te ca ai setat **Signing** cu un Apple ID valid
4. Apasa **Cmd + R**
5. Pe telefon: **Settings** → **General** → **VPN & Device Management** → Trust developer certificate

## Arhitectura

```
MVVM + DataProvider Protocol
│
├── DataProvider (protocol)
│   ├── MockDataManager  → date simulate sinusoidale
│   └── BLEManager       → Core Bluetooth + ELM327
│
├── OBDViewModel (@MainActor, ObservableObject)
│   ├── Published obdData, connectionState
│   ├── Trip recording cu SwiftData
│   └── Switch intre simulated/live
│
└── Views
    ├── DashboardView    → gauge-uri + heat map masina
    ├── HistoryView      → trips cu harti MapKit colorate
    └── SettingsView     → toggle simulare/live + info
```

## Mod Simulare (Mock Engine)

`MockDataManager` genereaza date realiste la fiecare **0.1 secunde**:

- **RPM** (PID 0C): Oscilatie sinusoidala 800–5500 RPM cu micro-noise
- **Viteza** (PID 0D): Accelerare graduala 0–130+ km/h
- **Temp. Motor** (PID 05): Warmup de la 20°C la ~92°C in 60 secunde
- **Fuel Trim**: Oscilatie naturala in jurul zero-ului
- **Engine Load, Throttle, MAF**: Date corelate cu RPM si viteza

Switch-ul **Simulated Data / Live OBD** se gaseste in tab-ul **Settings**.

## Formule OBD-II

| Metric | PID | Formula |
|--------|-----|---------|
| RPM | `010C` | `((256 * A) + B) / 4` |
| Speed | `010D` | `A` |
| Coolant Temp | `0105` | `A - 40` |
| Fuel Trim | `0106`/`0107` | `(A - 128) * (100 / 128)` |

## Initializare ELM327

Secventa de handshake trimisa la conectare:

```
ATZ    → Reset adapter
ATE0   → Echo off
ATL1   → Linefeeds on
ATSP0  → Auto-detect protocol
```

## Design System — Liquid Glass

- Fundal: OLED Black (`#0A0A0A`)
- Carduri: `.ultraThinMaterial` + `background.card` semitransparent
- Borduri: `AngularGradient` cu glow neon
- Tier 1 (Speed/RPM): **38pt Bold SF Pro Rounded** `.monospacedDigit()`
- Tier 2 (Coolant/Fuel): **26pt Semibold**
- Heat Map: Cyan → Green → Orange → Red in functie de load
- Animatii: `.spring(response: 0.4)` + `.contentTransition(.numericText())`
