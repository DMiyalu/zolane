# Zolane

MVP Flutter (offline-first SQLite + sync Firestore) avec authentification Google via Firebase Auth.

## Pré-requis

- Flutter SDK installé
- Un projet Firebase configuré (ce repo contient déjà `lib/firebase_options.dart`, `android/app/google-services.json`, et `ios/Runner/GoogleService-Info.plist`)

## Lancer l'app

```bash
flutter pub get
flutter run
```

## Dépannage Firebase / Firestore

Si tu vois dans les logs Android :

`PERMISSION_DENIED: Cloud Firestore API has not been used in project ... or it is disabled`

alors il manque l'activation de Firestore côté projet Google Cloud / Firebase.

À faire :

1) Firebase Console → **Build** → **Firestore Database** → **Create database** (crée la base)
2) (si nécessaire) Google Cloud Console → **APIs & Services** → activer **Cloud Firestore API**

Une fois Firestore activé, la sync utilise ces collections :

- `users/{uid}/properties`
- `users/{uid}/operations`

