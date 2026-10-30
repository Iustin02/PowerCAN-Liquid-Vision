# Design system — Liquid Glass

Sursa de adevăr: `apps/ios/PowerCANLiquidVision/DesignSystem/Theme.swift` (iOS) și `apps/flutter/lib/src/theme/lv_theme.dart` (Flutter). Orice token nou se adaugă în ambele fișiere.

## Culori

| Token | Hex | Utilizare |
|---|---|---|
| `backgroundPrimary` | `#0A0A0A` | fundal OLED |
| `backgroundCard` | `#1A1A1E` | carduri (cu material translucid) |
| `backgroundElevated` | `#2C2C30` | elemente ridicate |
| `textPrimary` | `#FFFFFF` | text principal |
| `textSecondary` | `#A0A0A8` | etichete, text secundar |
| `neonGreen` | `#00FF88` | stare OK, valori normale |
| `neonCyan` | `#00DDFF` | accent principal, categoria Body |
| `neonBlue` | `#00AAFF` | categoria Network |
| `neonOrange` | `#FF8800` | avertizare, categoria Chassis |
| `neonRed` | `#FF2244` | critic, categoria Powertrain |
| `gaugeArcBg` | `#1E1E24` | fundalul arcelor de gauge |

**Harta termică** interpolează cyan → verde → portocaliu → roșu după `OBDData.heatLevel`, adică 0,4 · rpm + 0,3 · viteză + 0,3 · temperatura lichidului de răcire, normalizate.

## Tipografie (SF Pro Rounded, cifre monospațiate)

| Token | Mărime / greutate | Utilizare |
|---|---|---|
| `tier1` | 38 pt bold | viteză, RPM |
| `tier1Small` | 34 pt bold | variante compacte |
| `tier2` | 26 pt semibold | temperatură, fuel trim, consum |
| `tier3` | 14 pt medium | text de conținut |
| `label` | 12 pt medium | etichete |
| `status` | 16 pt medium | bara de conexiune |

## Layout

| Token | Valoare |
|---|---|
| `cardPadding` | 16 |
| `cardCornerRadius` | 20 |
| `sectionSpacing` | 16 |
| `minTouchTarget` | 60 (dimensiune mărită, pentru folosire în mașină) |

## Efecte și mișcare

- Carduri: `.ultraThinMaterial` peste `backgroundCard` semitransparent; bordură `AngularGradient` cu glow neon.
- Valori numerice: `.contentTransition(.numericText())`, ca cifrele să tranziteze fără sărituri.
- Animații: `.spring(response: 0.4)`.
- Ecran exclusiv portrait, optimizat pentru iPhone 12 Pro Max și modelele mai noi.
