# Publier IqraQuest sur TestFlight depuis GitHub Actions

Ce dépôt contient un pipeline (`.github/workflows/ios-testflight.yml`) qui
build l'app iOS et l'envoie sur TestFlight automatiquement, sans avoir
besoin d'un Mac. Il te faut juste : un compte Apple Developer actif, et
5 secrets à renseigner une fois dans GitHub. Ce document explique
exactement quoi faire, dans l'ordre.

Le pipeline se déclenche **manuellement** (bouton "Run workflow" dans
l'onglet Actions de GitHub) — il ne se lance jamais tout seul, pour
éviter de consommer des minutes de build ou d'envoyer des builds
accidentels.

## 1. Créer l'app dans App Store Connect

1. Va sur https://appstoreconnect.apple.com → **Mes Apps** → **+** →
   **Nouvelle app**.
2. Bundle ID : choisis (ou crée dans le [Developer
   Portal](https://developer.apple.com/account/resources/identifiers/list))
   `com.IqraQuest.com` — c'est déjà l'identifiant configuré dans le
   projet Xcode (`ios/Runner.xcodeproj`). Si tu préfères un autre
   identifiant (par ex. avec ton propre nom d'organisation), dis-le-moi
   et je le change dans le projet — mais il doit être identique des deux
   côtés.
3. Nom de l'app, langue principale, SKU (n'importe quel identifiant
   unique interne, ex. `iqraquest-001`) : remplis normalement.

## 2. Créer une clé API App Store Connect (recommandé, évite les soucis de 2FA en CI)

1. App Store Connect → **Utilisateurs et accès** → onglet **Clés** (Keys).
2. **+** pour générer une nouvelle clé. Rôle : **App Manager** suffit
   (pas besoin d'Admin).
3. Apple ne te laisse **télécharger le fichier `.p8` qu'une seule fois** —
   télécharge-le tout de suite et garde-le en lieu sûr.
4. Note aussi, affichés à côté de la clé :
   - **Key ID** (ex. `ABCD123XYZ`)
   - **Issuer ID** (un UUID, le même pour toutes tes clés)

## 3. Trouver ton Apple Team ID

Developer Portal → https://developer.apple.com/account → **Membership**
(ou **Compte** → en bas de page) → **Team ID** (10 caractères, ex.
`AB12CD34EF`).

## 4. Ajouter les secrets dans GitHub

Dans le dépôt GitHub → **Settings** → **Secrets and variables** →
**Actions** → **New repository secret**, crée ces 4 secrets :

| Nom du secret | Valeur |
|---|---|
| `ASC_KEY_ID` | le Key ID de l'étape 2 |
| `ASC_ISSUER_ID` | l'Issuer ID de l'étape 2 |
| `ASC_KEY_CONTENT` | le contenu **texte brut** du fichier `.p8` téléchargé (ouvre-le avec un éditeur de texte, copie tout, y compris les lignes `-----BEGIN PRIVATE KEY-----` / `-----END PRIVATE KEY-----`) |
| `APPLE_TEAM_ID` | le Team ID de l'étape 3 |

Rien d'autre à faire côté certificats/profils : le pipeline utilise la
signature automatique de Xcode pilotée par la clé API
(`-allowProvisioningUpdates`), donc pas de fichier `.p12` ni de
provisioning profile à gérer manuellement.

## 5. Lancer le build

1. Onglet **Actions** du dépôt GitHub → workflow **"iOS — build & upload
   to TestFlight"** → **Run workflow** → branche à builder → **Run
   workflow**.
2. Le pipeline : installe Flutter, relance `flutter analyze` et
   `flutter test` (le build s'arrête si l'un des deux échoue), build
   l'app iOS, puis l'envoie sur TestFlight via `fastlane`.
3. Une fois terminé (~15-25 minutes en général), le build apparaît dans
   App Store Connect → ton app → **TestFlight**, généralement après
   quelques minutes de traitement supplémentaires côté Apple.
4. La première fois, Apple peut demander de répondre à un questionnaire
   d'export compliance pour ce build — réponds-y directement dans
   TestFlight avant de pouvoir l'assigner à des testeurs.

## Ce que le pipeline ne fait pas (volontairement, pour l'instant)

- Il n'ajoute pas automatiquement de testeurs ni ne soumet pour la revue
  Beta externe (`skip_submission: true` dans `ios/fastlane/Fastfile`) —
  tu ajoutes tes testeurs internes/externes toi-même dans App Store
  Connect.
- Il ne se déclenche pas automatiquement sur chaque push. Pour activer un
  déclenchement automatique (par ex. sur un tag `v*`), édite le bloc `on:`
  de `.github/workflows/ios-testflight.yml`.
- Il ne gère pas encore l'icône finale de l'app ni les métadonnées/
  screenshots complets de la fiche App Store — voir
  `STORE_RELEASE_CHECKLIST.md` et `ASSET_INVENTORY.md` pour ce qui reste
  avant une vraie soumission publique. TestFlight lui-même ne bloque pas
  sur ces éléments pour les tests internes.

## En cas d'échec

- Le job upload automatiquement les logs (`ios-build-logs`) en artifact
  GitHub Actions si le build échoue — regarde-les en premier.
- Une erreur de signing la plupart du temps = Bundle ID pas encore créé
  dans App Store Connect (retour à l'étape 1), ou clé API avec un rôle
  insuffisant (retour à l'étape 2, rôle App Manager minimum).
- Une erreur "no account found"/Team ID = vérifie `APPLE_TEAM_ID` (10
  caractères, pas le nom de l'équipe).
