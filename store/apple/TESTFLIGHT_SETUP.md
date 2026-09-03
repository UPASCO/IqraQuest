# Publier IqraQuest sur TestFlight depuis GitHub Actions

Ce dépôt contient un pipeline (`.github/workflows/ios-testflight.yml`) qui
build l'app iOS et l'envoie sur TestFlight automatiquement, sans avoir
besoin d'un Mac. Il te faut juste : un compte Apple Developer actif, et
5 secrets à renseigner une fois dans GitHub. Ce document explique
exactement quoi faire, dans l'ordre.

L'envoi vers TestFlight se déclenche **manuellement** (bouton
"Run workflow" dans l'onglet Actions de GitHub) — il ne se lance jamais
tout seul, pour éviter de consommer des minutes de build ou d'envoyer
des builds accidentels. S'il manque un secret, le pipeline s'arrête
immédiatement avec un message qui nomme le secret manquant.

Les pull requests, elles, lancent seulement un **build de
vérification** (analyse + tests + build iOS non signé) : aucun secret
n'est nécessaire, et rien n'est envoyé chez Apple.

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

Puis les deux secrets du certificat de distribution, décrits à l'étape
suivante :

| Nom du secret | Valeur |
|---|---|
| `IOS_DIST_CERT_P12` | le certificat de distribution exporté en `.p12`, encodé en base64 sur **une seule ligne** |
| `IOS_DIST_CERT_PASSWORD` | le mot de passe choisi à l'export du `.p12` |

Le provisioning profile, lui, reste géré automatiquement par Xcode via la
clé API (`-allowProvisioningUpdates`) : rien à télécharger ni à
renouveler à la main.

## 4bis. Le certificat de distribution (à faire **une seule fois**)

**Pourquoi.** Un runner GitHub démarre avec un trousseau vide. Sans
certificat fourni, Xcode en demande un **nouveau** à Apple à chaque
build — et Apple plafonne le nombre de certificats de distribution par
équipe. Le build 23 est mort là-dessus :

> `error: Choose a certificate to revoke. Your account has reached the
> maximum number of certificates.`

Pire : chacun de ces certificats est inutilisable, sa clé privée est
morte avec le runner qui l'a créé. La solution est d'en créer **un**,
dont on garde la clé privée, et de le réutiliser à chaque build.

### a. Faire le ménage dans le portail Apple

https://developer.apple.com/account/resources/certificates/list

Révoque tous les certificats **Apple Distribution** créés par la CI
(ils sont inutilisables). Garde uniquement celui dont tu possèdes la clé
privée sur ton Mac, s'il y en a un — c'est celui que tu exporteras à
l'étape b. Révoquer un certificat de distribution ne retire **aucune**
app déjà publiée sur l'App Store.

### b. Obtenir un `.p12`

**Si tu as un Mac et que le certificat est déjà dans ton trousseau :**

1. Ouvre **Trousseaux d'accès** → catégorie **Mes certificats**.
2. Trouve `Apple Distribution: … (TON_TEAM_ID)` — il doit avoir une
   flèche pour se déplier, signe que la clé privée est là.
3. Clic droit → **Exporter…** → format **Échange d'informations
   personnelles (.p12)** → enregistre sous `ios_dist.p12`.
4. Choisis un mot de passe et **note-le** : c'est
   `IOS_DIST_CERT_PASSWORD`.

**Sans Mac (ou sans certificat existant)**, avec `openssl` sur
n'importe quelle machine :

```bash
# 1. une clé privée + une demande de certificat (CSR)
openssl genrsa -out ios_dist.key 2048
openssl req -new -key ios_dist.key -out ios_dist.csr \
  -subj "/emailAddress=TON_EMAIL/CN=IqraQuest Distribution/C=FR"
```

2. Portail Apple → **Certificates** → **+** → **Apple Distribution** →
   téléverse `ios_dist.csr` → **Continue** → **Download** : tu obtiens
   `distribution.cer`.

```bash
# 3. recoller le certificat et la clé privée dans un .p12
openssl x509 -inform DER -in distribution.cer -out ios_dist.pem
openssl pkcs12 -export -inkey ios_dist.key -in ios_dist.pem \
  -name "Apple Distribution" -out ios_dist.p12 \
  -passout pass:CHOISIS_UN_MOT_DE_PASSE
```

Garde `ios_dist.key` et `ios_dist.p12` en lieu sûr (hors du dépôt) : ce
sont eux qui évitent d'avoir à recommencer.

### c. Encoder et enregistrer les secrets

```bash
# Linux
base64 -w0 ios_dist.p12 > ios_dist.p12.b64
# macOS
base64 -i ios_dist.p12 -o ios_dist.p12.b64
```

Dépôt GitHub → **Settings** → **Secrets and variables** → **Actions** :

- `IOS_DIST_CERT_P12` = tout le contenu de `ios_dist.p12.b64` (une seule
  ligne, sans retour à la ligne ni espace) ;
- `IOS_DIST_CERT_PASSWORD` = le mot de passe du `.p12`.

Ces deux fichiers ne doivent **jamais** être commités : `.p12`, `.key`,
`.cer` et `.b64` sont ignorés par `.gitignore`.

À partir de là, chaque build importe ce certificat dans un trousseau
temporaire et signe avec — Apple n'en crée plus aucun, le plafond n'est
plus jamais approché. Si le secret est absent, le workflow le signale en
warning et retombe sur l'ancien comportement (création d'un certificat,
donc échec une fois le plafond atteint).

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

## « Informations manquantes » sur le chiffrement

App Store Connect demande à chaque upload quel chiffrement l'app utilise,
et garde le build en **Informations manquantes** tant que personne n'a
répondu. La réponse est désormais donnée **dans le code**, une fois pour
toutes :

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

dans `ios/Runner/Info.plist`. C'est exact : IqraQuest n'embarque aucun
chiffrement à elle — le seul qu'elle touche est celui du système (TLS
pour les appels d'achat App Store, le Trousseau derrière
`flutter_secure_storage`), qui est exempté. `tool/pre_release_check.dart`
vérifie que la clé ne disparaît pas.

Les builds envoyés **avant** l'ajout de cette clé gardent l'avertissement :
il faut y répondre une fois à la main, dans TestFlight → le build →
*Gérer* → **« Aucun des algorithmes mentionnés ci-dessus »**.

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
