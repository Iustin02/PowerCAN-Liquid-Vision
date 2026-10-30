# Prompt — release

```
Citește AGENTS.md, dev-pack/CONVENTIONS.md (secțiunea „Versionare”) și dev-pack/checklists/release.md.

Versiune nouă: <X.Y.Z> (justifică tipul: major / minor / patch)

Pași:
1. Mută intrările din „Unreleased” în CHANGELOG.md sub [X.Y.Z] — <data>.
2. Actualizează versiunea în apps/ios/project.yml (MARKETING_VERSION, CURRENT_PROJECT_VERSION+1)
   și în apps/flutter/pubspec.yaml (version: X.Y.Z+build), apoi xcodegen generate.
3. Rulează verificările complete (xcodebuild, flutter analyze, flutter test, flutter build apk --release).
4. Parcurge dev-pack/checklists/release.md și raportează fiecare punct.
5. Propune comenzile pentru commit și tag (vX.Y.Z), dar nu le rula fără confirmarea mea.
```
