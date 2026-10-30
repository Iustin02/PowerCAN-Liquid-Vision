# Checklist release

- [ ] versiunea e identică în `apps/ios/project.yml` și `apps/flutter/pubspec.yaml`
- [ ] `CHANGELOG.md` are secțiunea `[X.Y.Z] — AAAA-LL-ZZ`
- [ ] toate verificările din `pre-commit.md` trec
- [ ] `flutter build apk --release` reușește
- [ ] testat manual în modul simulare: toate cele 4 tab-uri, pornirea și oprirea unui traseu, scan/clear DTC
- [ ] testat pe vehicul în modul live (dacă e posibil): handshake, valori plauzibile la ralanti și în mers, reconectare după oprirea adaptorului
- [ ] tag `vX.Y.Z` creat după commit
