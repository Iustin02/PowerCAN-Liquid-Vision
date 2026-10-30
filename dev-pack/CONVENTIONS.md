# Convenții

## Paritate iOS ↔ Flutter

- Fiecare fișier iOS are un corespondent Flutter (tabelul din `docs/architecture.md`). Un fișier nou se creează pe ambele platforme, iar tabelul se actualizează.
- Nume de câmpuri identice în sens: `coolantTemp` ↔ `coolantTemp`, nu `engineTemp`.
- Formulele, pragurile și intervalele de timp au aceleași valori. Dacă un număr apare în ambele coduri, documentează-l în `docs/` sau `dev-pack/CONTEXT.md`.

## Swift (iOS)

- Swift 5.9, iOS 17. SwiftUI + Combine; `@MainActor` pe ViewModel.
- Structură: `Models/`, `Services/`, `ViewModels/`, `DesignSystem/`, `Views/<Ecran>/`, `Views/Components/`.
- Un tip principal per fișier; numele fișierului = numele tipului.
- Fără valori de design direct în view-uri: `LVTheme.Colors.*`, `LVTheme.Fonts.*`, `LVTheme.Layout.*`.
- Sarcinile asincrone (polling, reconectare) se anulează în `stop()`.
- Comentariile sunt în română fără diacritice; identificatorii, în engleză.

## Dart (Flutter)

- `flutter analyze` fără probleme (`flutter_lints`).
- Structură: `lib/src/{models,services,state,theme,ui/screens,ui/widgets}`.
- Starea se ține în `ObdController` (`ChangeNotifier`), expus prin `provider`.
- Fișierele se numesc în `snake_case`, clasele în `PascalCase`.

## Proiectul iOS

- `apps/ios/project.yml` e sursa de adevăr. După un fișier nou: `xcodegen generate`. `.xcodeproj` regenerat se commitează.

## Versionare și commit-uri

- [SemVer](https://semver.org/): MAJOR pentru schimbări de protocol incompatibile, MINOR pentru funcționalități, PATCH pentru corecturi.
- Versiunea se actualizează în `apps/ios/project.yml` (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`) **și** în `apps/flutter/pubspec.yaml` (`version`).
- Fiecare modificare vizibilă intră în `CHANGELOG.md` ([Keep a Changelog](https://keepachangelog.com/)).
- Mesajele de commit au prefix: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, plus scope opțional (`feat(ios):`, `fix(flutter):`, `feat(obd):`).
