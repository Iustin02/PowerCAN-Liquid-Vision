# Changelog

Formatul urmează [Keep a Changelog](https://keepachangelog.com/ro/1.1.0/), iar versionarea respectă [SemVer](https://semver.org/).

## [Unreleased]

## [1.1.0] — 2026-10-30

### Adăugat
- Portul **Flutter (Android)** în `apps/flutter`, la paritate funcțională cu aplicația iOS.
- Transport **Wi-Fi TCP** (`WiFiOBDManager`) pentru bridge-ul ESP32 ELM327, cu endpoint configurabil din Settings (implicit `192.168.4.1:35000`) și reconectare cu backoff exponențial.
- PID-uri live suplimentare: sarcina motorului (`04`), temperatura aerului de admisie (`0F`), MAF (`10`), poziția clapetei (`11`).
- Documentație în `docs/` (arhitectură, protocol OBD, design system, setup) și dev-pack pentru lucrul cu asistenți AI.

### Modificat
- Structura de monorepo: aplicația iOS s-a mutat în `apps/ios`; proiectul Xcode e generat din `project.yml` (XcodeGen).
- Application ID-ul Android: `com.example.powercan_liquid_vision_flutter` → `com.powercan.liquidvision`.

### Eliminat
- Transportul Bluetooth LE (`BLEManager`) și permisiunile Bluetooth. Implementarea e păstrată în tag-ul `v1.0.0-ble`.

### Corectat
- Formula consumului instantaneu folosea densitatea benzinei în kg/L (0,745) în loc de g/L (745). Valoarea ieșea de 1000× prea mare și era plafonată permanent la maxim (iOS + Flutter).

## [1.0.0] — 2026-04-18

### Adăugat
- Aplicația iOS inițială: Dashboard, Diagnostics, History, Settings; mod simulare; transport Bluetooth LE; trasee cu SwiftData și MapKit; design Liquid Glass.
