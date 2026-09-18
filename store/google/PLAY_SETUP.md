# Publier IqraQuest sur Google Play

Le pendant Android de `store/apple/TESTFLIGHT_SETUP.md` et
`store/apple/APP_STORE_PUBLISH.md`. Tout se fait depuis GitHub Actions
(le bundle) et la Play Console (la fiche, le produit à 8,99 €, les
testeurs, la publication). Aucune clé ne passe par le dépôt.

Ce qui est déjà en place côté code :

- `android/app/build.gradle.kts` signe la version *release* avec la clé
  d'upload dès qu'un fichier `android/key.properties` existe, et avec la
  clé de debug sinon (APK de test, `flutter run --release`).
- Le workflow **Android — build & verify** produit, sur un lancement
  manuel en configuration store, un bundle `app-release.aab` signé avec
  cette clé, numéroté par le numéro du run (Play exige un
  `versionCode` strictement croissant à chaque envoi).
- L'identifiant du produit Premium est `iqraquest_full_access`
  (`lib/services/purchase_service.dart`). Le prix n'est **jamais** dans
  l'app : elle affiche celui que Play lui renvoie.

## 1. Créer la clé d'upload (une seule fois)

Sur ton Mac ou PC, avec un JDK installé (celui d'Android Studio suffit) :

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Deux mots de passe te sont demandés (le keystore, puis la clé `upload` ;
tu peux mettre le même). Garde le fichier `upload-keystore.jks` et les
mots de passe dans un gestionnaire de mots de passe : **perdre cette clé
empêche toute mise à jour de l'app** tant que Google n'en a pas
enregistré une nouvelle (procédure de réinitialisation, plusieurs
jours). Ne mets jamais ce fichier dans le dépôt : `android/.gitignore`
l'ignore et le contrôle pré-release refuse un arbre qui le contient.

## 2. Enregistrer les quatre secrets GitHub

Dépôt `UPASCO/IqraQuest` → *Settings* → *Secrets and variables* →
*Actions* → *New repository secret* :

| Secret | Valeur |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | le fichier encodé : `base64 -w0 upload-keystore.jks` (Linux) ou `base64 -i upload-keystore.jks \| tr -d '\n'` (macOS) |
| `ANDROID_KEYSTORE_PASSWORD` | le mot de passe du keystore |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | le mot de passe de la clé |

## 3. Produire le bundle

*Actions* → **Android — build & verify** → *Run workflow*, branche
`claude/iqraquest-mobile-app-s9g0gs`, case **tester_unlock décochée**.
Le run produit deux artefacts :

- `iqraquest-release-apk` : l'APK à installer directement sur un
  téléphone (signé debug, jamais pour Play) ;
- `iqraquest-play-bundle` : `app-release.aab`, signé avec la clé
  d'upload, à envoyer dans la Play Console.

Sans les secrets, le bundle est simplement sauté et le run reste vert :
le message le dit dans l'étape « Write the upload keystore ».

Un build testeur (case cochée) ne produit **jamais** de bundle : ce qui
part vers Play est toujours la configuration store, sans le réglage
« Mode testeur ».

## 4. Créer l'application dans la Play Console

<https://play.google.com/console> (compte développeur : 25 $ une fois,
identité vérifiée).

1. *Créer une application* : nom **IqraQuest**, langue par défaut
   *Français (France)*, type **Jeu**, **Gratuite** (le Premium est un
   achat intégré, pas un prix d'app — un jeu payant ne peut plus
   redevenir gratuit ensuite).
2. Tableau de bord → *Configurer votre application*, toutes les
   déclarations :
   - **Règles de confidentialité** : `https://iqraquest.org/privacy`.
   - **Accès à l'application** : tout est accessible sans identifiant
     (pas de compte). Pour le Premium, indique que le produit est
     testable avec les comptes de test de licence (§6).
   - **Annonces** : non, l'app n'en contient pas.
   - **Classification du contenu** : questionnaire IARC ; réponds
     « non » partout (pas de violence, pas d'achats hasardeux, pas de
     partage de position). Résultat attendu : PEGI 3 / tout public.
   - **Audience cible et contenu** : l'app est conçue pour les familles
     dès 7 ans. Déclarer une tranche incluant les moins de 13 ans
     engage le programme *Families* de Google ; l'app y satisfait déjà
     (aucune publicité, aucune donnée collectée, aucun SDK tiers de
     suivi), mais la revue est plus lente. L'autre option, courante,
     est de cocher 13 ans et plus uniquement, avec « conçue pour un
     public général ». Choisis en connaissance de cause ; le contenu
     est le même.
   - **Sécurité des données** : *aucune donnée collectée, aucune
     donnée partagée* ; les données de jeu restent sur l'appareil.
     Les achats passent par Google Play Billing (déclaré par Google
     lui-même).
   - **Applications gouvernementales / financières / d'actualités /
     de santé** : non.
3. *Fiche Play Store principale* : titre, description courte (80
   caractères), description longue, icône 512×512, image de
   présentation 1024×500, captures téléphone et tablette
   (`store/google/screenshots_plan.md`). Les textes du site
   (`iqraquest-website/messages/fr.json`) sont la base ; une fiche par
   langue est possible plus tard.

## 5. Créer le produit Premium à 8,99 €

*Monétiser avec Play* → *Produits* → *Produits intégrés* → *Créer un
produit* :

| Champ | Valeur |
| --- | --- |
| ID produit | `iqraquest_full_access` — exactement, il ne se change plus |
| Nom | IqraQuest Premium |
| Description | Débloque les 1 100 questions, les trois parcours, le niveau mixte et les sauvegardes nommées. Achat unique, sans abonnement. |
| Prix | *Définir le prix* → **8,99 €** pour la France ; Google propose les autres pays convertis, à vérifier et arrondir |

Puis **Activer** le produit. Deux conditions pour qu'il apparaisse dans
l'app : un bundle envoyé sur au moins une piste (§6) et le compte
marchand (*Paramètres → Profil de paiement*) configuré. Tant qu'elles
ne sont pas remplies, l'app affiche « Boutique indisponible » sur
l'écran Premium.

## 6. Tester avant la production

1. *Tests* → *Tests internes* → *Créer une version* : envoie
   `app-release.aab`, notes de version, *Enregistrer* puis *Examiner la
   version* → *Démarrer le déploiement*. Ajoute une liste de testeurs
   (adresses Gmail) et copie le lien d'inscription à leur envoyer.
   L'app se télécharge alors depuis Play sur leur téléphone, comme la
   vraie.
2. **Achats sans être facturé** : *Paramètres* → *Test de licence* :
   ajoute les mêmes adresses Gmail, réponse de licence *RESPOND_NORMALLY*.
   Pour ces comptes, la feuille d'achat Google indique « Carte de test »
   et rien n'est débité. C'est le moyen de dérouler le parcours complet
   (`docs/TEST_PREMIUM.md`, parcours C) : bouton « Débloquer 8,99 € »,
   feuille Google, « Achat en cours… », déblocage, puis *Restaurer les
   achats* après réinstallation.
3. Pour revoir l'expérience gratuite avec le même compte : Play Console
   → *Gestion des commandes* → rembourser et **révoquer** l'achat test,
   ou utiliser un autre compte testeur.
4. Pour simuler le déblocage sans passer par Play du tout : un build
   testeur (case `tester_unlock` cochée, APK à installer à la main) et
   *Réglages › Mode testeur* (`docs/TEST_PREMIUM.md`, parcours B).

## 7. Publier en production

*Production* → *Créer une version* → **Ajouter depuis la bibliothèque**
(le bundle déjà envoyé en tests internes) → notes de version → *Examiner
la version* → *Démarrer le déploiement en production*. La revue Google
prend de quelques heures à quelques jours pour une première publication.

Une fois l'app en ligne, son adresse est
`https://play.google.com/store/apps/details?id=com.IqraQuest.com`.
Renseigne-la sur le site : dépôt `UPASCO/iqraquest-website` →
*Settings* → *Variables* → `NEXT_PUBLIC_GOOGLE_PLAY_URL` (cette adresse)
et `NEXT_PUBLIC_APP_AVAILABLE_ANDROID` = `true`, puis relance le
workflow *Deploy*. Les boutons « Disponible sur Google Play »
s'activent dans les douze langues.

## 8. Les mises à jour

Monte la version dans `pubspec.yaml` (`1.0.1+1` : le `+1` est remplacé
par le numéro du run), relance le workflow, envoie le nouveau bundle
sur la piste voulue. Le `versionCode` croît tout seul avec le numéro du
run ; Play refuse un bundle plus bas que le précédent, jamais plus haut.
