# Intégration du module Vente Moutons Aïd

Ce ZIP contient déjà l'intégration faite dans l'application Flutter.

## Ce qui a été ajouté
- Nouvel écran : `lib/screens/aid_sales_screen.dart`
- Nouveau modèle : `AidMouton` dans `lib/models/models.dart`
- Nouvelles méthodes Provider : `aidMoutons`, `addAidMouton`, `updateAidMouton`, `deleteAidMouton`
- Nouvelle table SQLite : `aid_moutons`
- Nouveau tab bas : `Aïd`

## Workflow
- Saisie : ajout avec numéro unique
- Stock : filtres Tous / Disponibles / Réservés
- Bottom sheet : réserver ou vendre
- Vendus : historique + bénéfice

## Pour l'intégrer dans ton repo
1. Dézippe ce projet
2. Remplace le contenu de ton repo GitHub par cette version
3. Commit + push
4. Sur ta machine locale :
   - `flutter pub get`
   - `flutter run`
5. Sur Codemagic : rebuild sur le dernier commit

## Important
La base SQLite passe en version 2 pour créer la table `aid_moutons`.
Si l'app était déjà installée sur ton téléphone, la migration crée la table au prochain lancement.
