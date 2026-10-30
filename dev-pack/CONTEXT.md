# CONTEXT — faptele proiectului

## Identitate

- **Nume:** PowerCAN Liquid Vision. Display name iOS: „PowerCAN LV”.
- **Autor:** Iustin Iulian Dodiță (GitHub `Iustin02`).
- **Tip:** proiect personal, prototip funcțional. Nu e publicat în App Store sau Play Store.
- **Bundle / application ID:** `com.powercan.liquidvision` (iOS și Android).

## Hardware și protocol

| Fapt | Valoare |
|---|---|
| Adaptor | ESP32 cu firmware de bridge ELM327; face access point Wi-Fi |
| Endpoint implicit | `192.168.4.1:35000` (TCP), configurabil și persistat |
| Handshake | `ATZ`, `ATE0`, `ATL1`, `ATSP0`, la 500 ms |
| Delimitator de răspuns | promptul `>` |
| PID-uri live | `0C 0D` la fiecare ciclu; `05 04 06 07 0F 10 11` la fiecare al 3-lea; 120 ms între comenzi |
| Simulare | 10 Hz, sinusoide corelate (RPM 800–5500, warmup lichid de răcire 20→92 °C în 60 s) |
| Puncte de traseu | la fiecare 2 s, cu GPS + viteză + RPM |

Toate formulele sunt în [`docs/obd-protocol.md`](../docs/obd-protocol.md).

## Decizii

| Decizie | Motiv |
|---|---|
| Wi-Fi TCP în loc de BLE (v1.1.0) | bridge-ul ESP32 expune ELM327 pe TCP; e mai simplu, fără pairing și fără entitlement Bluetooth. BLE e păstrat în tag-ul `v1.0.0-ble` |
| iOS ca referință, Flutter ca port | design-ul Liquid Glass e nativ SwiftUI; Flutter acoperă Android |
| SwiftData (iOS 17+) | persistență declarativă, fără Core Data boilerplate |
| XcodeGen | `project.pbxproj` nu mai produce conflicte; proiectul se reproduce din `project.yml` |
| Ținte tactile ≥ 60 pt | folosire în mașină |

## Invarianți

- Câmpurile `OBDData` au aceleași nume și unități pe ambele platforme: `rpm`, `speed` (km/h), `coolantTemp` (°C), `shortTermFuelTrim` / `longTermFuelTrim` (%), `intakeTemp` (°C), `engineLoad` (%), `throttlePosition` (%), `mafRate` (g/s), `fuelConsumptionRate` (L/100 km).
- Consumul: `MAF · 3600 / (14,7 · 745 · v) · 100`, numai pentru v > 5 km/h, plafonat la 40 (live) sau 30 (simulare).
- `DataProvider` are exact: `obdDataPublisher`, `connectionStatePublisher`, `currentData`, `connectionState`, `start()`, `stop()`.
- Starea de conexiune: `disconnected / scanning / connecting / initializing / connected / simulating / error`.

## Limitări cunoscute

- DTC live (`03` / `04`) nu sunt implementate; scanarea e doar simulată.
- Nu există teste pentru parserul PID; testul Flutter e doar un smoke test.
- Parserul presupune un singur ECU care răspunde (fără headere `ATH1`) și răspunsuri pe o singură linie.
- Consumul e valabil numai pentru benzină, la amestec stoechiometric.
