# Prompt — review critic

```
Citește AGENTS.md și dev-pack/CONVENTIONS.md, apoi fă un review al modificărilor curente (git diff).

Caută, în ordine:
1. Corectitudine OBD: formule greșite (unități, octeți A/B inversați, offset −40, scalare /255),
   PID-uri parsate fără verificarea lungimii, răspunsuri pe mai multe linii, „NO DATA” / „?” netratate.
2. Paritate: o modificare făcută doar pe iOS sau doar în Flutter; nume de câmpuri sau praguri diferite.
3. Concurență și resurse: task-uri de polling / reconectare neanulate în stop(), conexiuni TCP lăsate deschise,
   actualizări UI în afara main actor.
4. Design: valori hex sau fonturi direct în view-uri, ținte tactile < 60.
5. Proiect: project.pbxproj editat de mână, dependențe noi nejustificate, local.properties sau IP-uri personale.

Pentru fiecare problemă: fișier:linie, scenariul concret, corectura propusă. Fără observații pur stilistice.
```
