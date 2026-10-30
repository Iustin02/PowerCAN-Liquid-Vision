# Instrucțiuni GitHub Copilot

Urmează [`AGENTS.md`](../AGENTS.md) și [`dev-pack/CONVENTIONS.md`](../dev-pack/CONVENTIONS.md).

- Monorepo: `apps/ios` (SwiftUI, referința) și `apps/flutter` (port Android). Orice modificare de logică se face pe ambele.
- Transportul se face prin protocolul `DataProvider`: `MockDataManager` (simulare) sau `WiFiOBDManager` (TCP ELM327).
- Culorile și fonturile vin numai din `LVTheme` (`Theme.swift` / `lv_theme.dart`).
- Formulele OBD sunt documentate în `docs/obd-protocol.md`; nu le modifica fără sursă.
- iOS: nu edita `project.pbxproj`; folosește `project.yml` + `xcodegen generate`.
