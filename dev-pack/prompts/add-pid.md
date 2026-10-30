# Prompt — PID OBD-II nou

```
Citește AGENTS.md, dev-pack/CONTEXT.md și docs/obd-protocol.md.

PID: <de ex. 0123 — presiune rampă combustibil>
Formula (sursa: SAE J1979 / Wikipedia „OBD-II PIDs”): <...>
Unitate și domeniu: <...>
Frecvență: <fiecare ciclu | la fiecare al 3-lea>
Unde apare în UI: <card nou pe Dashboard / doar înregistrat>

Pași:
1. Adaugă câmpul în OBDData (iOS) și ObdData (Flutter), cu același nume și aceeași unitate.
2. Adaugă comanda în polling și ramura în parser, în WiFiOBDManager.swift și wifi_obd_manager.dart.
3. Adaugă valori simulate plauzibile în MockDataManager (ambele platforme).
4. Dacă apare în UI, folosește componentele existente (MetricCardView / metric_card.dart) și token-urile din Theme.
5. Documentează PID-ul în tabelul din docs/obd-protocol.md și în CHANGELOG.md (Unreleased).
6. Verifică: xcodebuild + flutter analyze + flutter test.
7. Arată-mi un exemplu de răspuns ELM327 („41 xx ..”) și valoarea decodată, pentru verificare manuală.
```
