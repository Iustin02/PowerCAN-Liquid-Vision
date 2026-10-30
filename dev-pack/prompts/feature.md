# Prompt — funcționalitate nouă (ambele platforme)

```
Citește AGENTS.md, dev-pack/CONTEXT.md, dev-pack/CONVENTIONS.md și docs/architecture.md.

Funcționalitate: <descriere>
Ecran(e) afectat(e): <Dashboard / Diagnostics / History / Settings / ecran nou>
Comportament în modul simulare: <...>
Comportament în modul live: <...>

Pași:
1. Plan: listează fișierele iOS și corespondentele Flutter pe care le vei modifica sau crea.
   Așteaptă confirmarea mea.
2. Implementează pe iOS (referința), apoi portează în Flutter cu aceeași logică și aceleași praguri.
3. Fișiere noi: adaugă-le în tabelul de corespondență din docs/architecture.md; pe iOS rulează xcodegen generate.
4. Verifică: xcodebuild (BUILD SUCCEEDED) + flutter analyze + flutter test.
5. Actualizează CHANGELOG.md (Unreleased) și docs/ dacă e cazul.
6. Nu face commit.
```
