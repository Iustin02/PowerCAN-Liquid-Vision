# PowerCAN Liquid Vision — iOS

Aplicația de referință: SwiftUI, SwiftData, Combine, MapKit, CoreLocation, Network. Țintă: iOS 17+, iPhone, portrait.

```bash
xcodegen generate                 # regenerează PowerCANLiquidVision.xcodeproj din project.yml
open PowerCANLiquidVision.xcodeproj
```

```
PowerCANLiquidVision/
├── PowerCANLiquidVisionApp.swift   # @main, ModelContainer SwiftData
├── Models/                         # OBDData, DTC, TripRecord (@Model), DataProvider
├── Services/                       # WiFiOBDManager (TCP/ELM327), MockDataManager, MockDTCGenerator, LocationManager
├── ViewModels/                     # OBDViewModel (@MainActor)
├── DesignSystem/                   # Theme (token-uri), GlassModifiers
├── Views/                          # Dashboard, Diagnostics, History, Settings, Components
└── Resources/                      # Info.plist, entitlements, Assets.xcassets
```

Ghid complet: [`../../docs/setup-ios.md`](../../docs/setup-ios.md) · arhitectură: [`../../docs/architecture.md`](../../docs/architecture.md).
