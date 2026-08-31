# Tester IqraQuest depuis un GitHub Codespace

## Pourquoi pas expo.dev ?

Expo (expo.dev, Expo Go, Snack) est l'écosystème de **React Native**.
IqraQuest est une application **Flutter** : elle ne peut ni se charger
dans Expo Go, ni s'exécuter sur expo.dev — aucun pont n'existe entre les
deux. Les équivalents Flutter pour « tester vite sans machine locale »
sont :

| Besoin | Équivalent pour IqraQuest |
|---|---|
| Aperçu instantané dans le navigateur (façon Snack) | `flutter run -d web-server` dans le Codespace, port forwardé |
| Tester sur son téléphone sans câble (façon Expo Go) | Ouvrir l'URL forwardée du Codespace dans le navigateur du téléphone |
| Vraie build iOS sur l'appareil | Le pipeline **TestFlight** déjà en place (`store/apple/TESTFLIGHT_SETUP.md`) |
| Vraie build Android sur l'appareil | `flutter build apk`, puis installer l'APK téléchargé |

Le rendu web sert d'aperçu de développement ; les cibles de publication
restent iOS et Android (voir README).

## 1. Ouvrir le Codespace

Sur GitHub → bouton **Code** → onglet **Codespaces** → **Create
codespace on claude/iqraquest-mobile-app-s9g0gs**.

Le dossier `.devcontainer/` de ce dépôt installe automatiquement le SDK
Flutter 3.47.2, exécute `flutter pub get` et `flutter gen-l10n`. La
première création prend quelques minutes ; ensuite tout est prêt.

Si le Codespace a été créé **avant** l'ajout du devcontainer (ou pour
tout refaire à la main) :

```bash
sudo git clone --depth 1 --branch 3.47.2 https://github.com/flutter/flutter.git /opt/flutter
export PATH="$PATH:/opt/flutter/bin"
flutter pub get
flutter gen-l10n
```

## 2. Lancer l'app dans le navigateur

```bash
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
```

Le Codespace forwarde le port 3000 automatiquement : ouvre l'onglet
**Ports** (panneau du bas dans VS Code), clique sur l'icône « globe » de
la ligne 3000. Recharge la page après un hot-restart (`R` dans le
terminal ; le hot-reload `r` fonctionne aussi en mode web-server).

## 3. Tester sur ton téléphone (sans câble, sans build)

1. Onglet **Ports** → clic droit sur le port 3000 → **Port visibility**
   → **Public**.
2. Copie l'URL forwardée (`https://<codespace>-3000.app.github.dev`).
3. Ouvre-la dans le navigateur du téléphone. L'app est tactile,
   responsive et RTL comme sur mobile.

Repasse le port en **Private** après le test — une URL publique est
accessible à quiconque possède le lien.

## 4. Vérifications avant de pousser

```bash
flutter analyze                          # doit afficher 0 issue
flutter test                             # 82 tests, ~9 s
dart run tool/pre_release_check.dart     # porte de release (voir README)
```

Les 3 scènes de QA visuelle écrivent leurs PNG dans
`build/screenshots/` — ouvre-les directement dans l'éditeur du
Codespace pour juger l'art.

## 5. Builds embarquées

**Android (APK debug, installable directement) :**

```bash
sudo apt-get install -y openjdk-17-jdk
# Android SDK en ligne de commande — voir la doc officielle Flutter ;
# puis :
flutter build apk --debug
```

Récupère `build/app/outputs/flutter-apk/app-debug.apk` (clic droit →
Download dans l'explorateur), envoie-le sur le téléphone Android,
installe-le (autoriser « sources inconnues »).

**iOS :** impossible depuis un Codespace (Linux) — c'est précisément le
rôle du workflow GitHub Actions **iOS — build & upload to TestFlight**
(onglet Actions → Run workflow), documenté dans
`store/apple/TESTFLIGHT_SETUP.md`. Une fois tes secrets App Store
Connect renseignés dans le dépôt, chaque exécution pousse une build sur
TestFlight que tu installes depuis l'app TestFlight de ton iPhone.
