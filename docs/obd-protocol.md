# Protocol OBD-II și ELM327

## Transport

| | |
|---|---|
| Legătură | TCP peste Wi-Fi; telefonul se conectează la access point-ul ESP32 |
| Endpoint implicit | `192.168.4.1:35000` (configurabil din Settings) |
| Codificare | ASCII; fiecare comandă se termină cu `\r`; adaptorul termină răspunsul cu promptul `>` |
| Reconectare | până la 5 încercări, cu backoff exponențial de 2ⁿ s (maximum 30 s) |

## Inițializare ELM327

| Comandă | Efect |
|---|---|
| `ATZ` | resetează adaptorul |
| `ATE0` | dezactivează ecoul comenzilor |
| `ATL1` | activează linefeed-urile |
| `ATSP0` | detectează automat protocolul OBD al vehiculului |

Comenzile se trimit la 500 ms una după alta, apoi începe polling-ul.

## PID-uri citite (mod 01)

Răspunsul are forma `41 <PID> A B …`. A și B sunt octeții de date, în hex.

| PID | Mărime | Formula | Unitate | Frecvență |
|---|---|---|---|---|
| `0C` | turație motor | `(256·A + B) / 4` | rpm | fiecare ciclu |
| `0D` | viteză vehicul | `A` | km/h | fiecare ciclu |
| `05` | temperatură lichid de răcire | `A − 40` | °C | la fiecare al 3-lea ciclu |
| `04` | sarcină motor calculată | `A · 100 / 255` | % | la fiecare al 3-lea ciclu |
| `06` | fuel trim pe termen scurt (bank 1) | `(A − 128) · 100 / 128` | % | la fiecare al 3-lea ciclu |
| `07` | fuel trim pe termen lung (bank 1) | `(A − 128) · 100 / 128` | % | la fiecare al 3-lea ciclu |
| `0F` | temperatură aer admisie | `A − 40` | °C | la fiecare al 3-lea ciclu |
| `10` | debit masic de aer (MAF) | `(256·A + B) / 100` | g/s | la fiecare al 3-lea ciclu |
| `11` | poziție clapetă | `A · 100 / 255` | % | la fiecare al 3-lea ciclu |

Intervalul dintre comenzi este de 120 ms. Un ciclu complet durează ~0,24 s, iar unul cu toate PID-urile ~1,1 s.

## Consum instantaneu (estimat)

Pentru un motor pe benzină, cu raport stoechiometric aer/combustibil AFR = 14,7 și densitatea benzinei ρ ≈ 745 g/L:

```
consum [L/100 km] = MAF[g/s] · 3600 · 100 / (AFR · ρ[g/L] · viteză[km/h])
                  = MAF · 3600 / (14,7 · 745 · v) · 100
```

Consumul se calculează numai pentru viteză > 5 km/h și se limitează la 40 L/100 km. Valoarea e o estimare: presupune amestec stoechiometric și ignoră fuel trim-ul. Pentru motoarele diesel (AFR variabil) nu e valabilă.

> **Corectură (v1.1.0):** versiunile anterioare foloseau ρ = 0,745 (kg/L) într-o formulă cu MAF în g/s. Rezultatul ieșea de 1000× prea mare și era tăiat mereu la plafon. Formula e corectată acum pe ambele platforme.

## Coduri de eroare (DTC)

Formatul este `Xnnnn`. Prima literă dă categoria:

| Literă | Categorie | Exemplu |
|---|---|---|
| `P` | Powertrain (motor, transmisie) | P0300: rateuri aleatoare |
| `C` | Chassis | C0035: senzor de viteză roată |
| `B` | Body | B0001: airbag șofer |
| `U` | Network (comunicație CAN) | U0100: comunicație pierdută cu ECM |

Severitatea (*critical / warning / info*) se derivă din cod, în `DTCDecoder` / `dtc.dart`.

> **Limitare actuală:** citirea DTC funcționează doar în modul simulare. Modul live nu trimite încă `03` (citire DTC stocate) și `04` (ștergere). Implementarea lor este primul punct din roadmap.
