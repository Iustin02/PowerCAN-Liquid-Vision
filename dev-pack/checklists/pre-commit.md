# Checklist înainte de commit

- [ ] iOS: `xcodegen generate` + `xcodebuild … build` → **BUILD SUCCEEDED**
- [ ] Flutter: `flutter analyze` → **No issues found!** și `flutter test` → **All tests passed!**
- [ ] paritate: modificarea există pe ambele platforme sau diferența e notată în `CHANGELOG.md`
- [ ] nicio valoare de design direct în view-uri (doar `LVTheme`)
- [ ] formulele noi sau modificate sunt în `docs/obd-protocol.md`
- [ ] tabelul de corespondență din `docs/architecture.md` e la zi, dacă au apărut fișiere noi
- [ ] `CHANGELOG.md` → *Unreleased* actualizat
- [ ] fără `local.properties`, `build/`, `.dart_tool/`, `DerivedData/`, IP-uri sau chei personale
- [ ] mesaj de commit cu prefix (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`)
