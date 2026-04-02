# Ma Ferme Pro

Version Flutter mobile-first prête pour GitHub et Codemagic.

## Points clés
- thème agricole premium
- navigation Material 3
- dashboard plus lisible
- gros boutons d'action
- centre de gestion intégré
- compatible Android / Web via Codemagic

## Build local
```bash
flutter create . --platforms=android,web
flutter pub get
flutter run
```

## Build release
```bash
flutter build apk --release
flutter build web --release
```
