# Prompt — componentă UI

```
Citește AGENTS.md și docs/design-system.md.

Componentă: <de ex. gauge vertical pentru temperatură>
Unde se folosește: <...>
Date afișate: <câmpuri din OBDData>

Reguli:
- Doar token-uri din LVTheme (Theme.swift / lv_theme.dart): culori, fonturi tier1–tier3, cardPadding,
  cardCornerRadius, minTouchTarget ≥ 60.
- Stil Liquid Glass: material translucid, bordură AngularGradient, .spring(response: 0.4),
  .contentTransition(.numericText()) pentru cifre.
- Componenta merge în Views/Components/ (iOS) și lib/src/ui/widgets/ (Flutter), cu #Preview pe iOS.
- Testează vizual în modul simulare pe iPhone 15 Pro Max; descrie ce ai verificat.
- Dacă ai nevoie de un token nou, adaugă-l în ambele fișiere de temă și în docs/design-system.md.
```
