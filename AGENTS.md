# AGENTS.md

Instrucțiuni pentru asistenți AI de programare (Claude Code, Codex, Cursor, Copilot, Aider). Citește acest fișier înainte de orice modificare.

## Proiectul pe scurt

- Aplicație mobilă de diagnoză OBD-II pentru un adaptor **ESP32 cu bridge ELM327 peste Wi-Fi (TCP, 192.168.4.1:35000)**.
- **`apps/ios/`**: aplicația de referință (SwiftUI, SwiftData, iOS 17, MVVM, proiect generat cu XcodeGen).
- **`apps/flutter/`**: portul Android (Flutter + Provider), care trebuie să rămână la paritate funcțională cu iOS.
- Transportul e abstractizat de protocolul `DataProvider` (`MockDataManager` pentru simulare, `WiFiOBDManager` pentru date live).

## Înainte să începi

1. [`dev-pack/CONTEXT.md`](dev-pack/CONTEXT.md): faptele proiectului, deciziile și invarianții.
2. [`dev-pack/CONVENTIONS.md`](dev-pack/CONVENTIONS.md): stilul Swift și Dart, regula de paritate, protocolul de commit.
3. Pentru sarcini frecvente: [`dev-pack/prompts/`](dev-pack/prompts/).

## Reguli obligatorii

- **Paritate:** o funcționalitate, un PID sau o formulă se modifică în ambele aplicații, în același commit. Tabelul de corespondență a fișierelor e în [`docs/architecture.md`](docs/architecture.md#corespondență-ios--flutter). Dacă paritatea nu e posibilă, notează explicit diferența în `CHANGELOG.md`.
- **iOS:** nu edita `project.pbxproj` de mână. Modifici `apps/ios/project.yml`, apoi rulezi `xcodegen generate`.
- **UI:** culorile, fonturile și spațierile vin numai din `Theme.swift` / `lv_theme.dart`. Nu folosi valori hex direct în view-uri.
- **Formule OBD:** orice formulă nouă sau modificată se documentează în [`docs/obd-protocol.md`](docs/obd-protocol.md), cu sursa ei (standardul SAE J1979 sau Wikipedia „OBD-II PIDs”).
- Nu adăuga dependențe noi fără să justifici necesitatea.
- **Nu face commit sau push** fără cererea explicită a autorului. Nu pune în repo IP-uri personale, chei sau fișiere `local.properties`.

## Comenzi de verificare

```bash
# iOS
cd apps/ios && xcodegen generate && xcodebuild -project PowerCANLiquidVision.xcodeproj \
  -scheme PowerCANLiquidVision -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build   # → BUILD SUCCEEDED

# Flutter
cd apps/flutter && flutter analyze && flutter test                               # → No issues found! / All tests passed!
```

O modificare e gata numai dacă ambele comenzi trec.
