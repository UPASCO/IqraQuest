# Publier IqraQuest sur l'App Store

La suite de `TESTFLIGHT_SETUP.md` : le build est sur TestFlight, il
faut maintenant le produit Premium à 8,99 €, un compte de test pour
l'acheter sans payer, puis la soumission à la revue Apple.

Tout se passe dans App Store Connect (<https://appstoreconnect.apple.com>).
L'achat lui-même se fait **dans l'app**, par la feuille d'achat d'Apple :
c'est la règle de l'App Store (aucun lien vers un paiement externe) et
c'est ce que l'écran Premium fait déjà. Le site, lui, renvoie vers la
fiche de l'app (§5).

## 0. Les accords (bloquant, souvent oublié)

*Accords, conditions et bancaire* : l'accord **Applications payantes**
doit être signé, avec les coordonnées bancaires et le formulaire fiscal
remplis, par le titulaire du compte. Sans lui, la boutique ne renvoie
aucun produit : l'écran Premium reste sur « Connexion à la boutique… »
puis « Boutique indisponible », en sandbox comme en production.

## 1. Créer l'achat intégré à 8,99 €

*Mes apps* → **IqraQuest** → *Monétisation* → *Achats intégrés* → **+** :

| Champ | Valeur |
| --- | --- |
| Type | **Non consommable** |
| Nom de référence | IqraQuest Premium (interne) |
| ID produit | `iqraquest_full_access` — exactement, il ne se change plus |
| Disponibilité | tous les pays |
| Prix | *Ajouter un prix* → pays de référence France → **8,99 €** ; Apple propose les autres pays à partir de ce point de prix |
| Localisation | au moins Français et Anglais : nom affiché « Premium » / « Premium », description « Débloque les 1 100 questions, les trois parcours, le niveau mixte et les sauvegardes nommées. Achat unique. » — les douze langues de l'app peuvent suivre |
| Capture pour la revue | une capture de l'écran Premium (`build/screenshots/audit_light_premium.png`, ou une capture d'appareil) |
| Notes de revue | « Non-consumable one-time unlock of the full question bank. No account needed. » |

Enregistre : l'état passe à **Prêt à envoyer**. Le produit est indépendant
du build (le n°38 le charge dès qu'il existe), mais il doit être
**joint à la version** lors de la première soumission (§4).

## 2. Un testeur sandbox pour acheter sans payer

*Utilisateurs et accès* → *Sandbox* → *Testeurs* → **+** : une adresse
e-mail **jamais utilisée comme identifiant Apple** (par exemple une
alias `+sandbox` de ta boîte), un mot de passe, le pays France.

Sur l'iPhone de test : *Réglages* → *App Store* → tout en bas, **Compte
sandbox** → se connecter avec cette adresse. Le compte Apple normal du
téléphone n'est pas touché.

Un build TestFlight utilise la sandbox automatiquement : la feuille
d'achat porte la mention *[Environnement : Sandbox]*, rien n'est débité,
et le produit renvoie bien 8,99 € (le prix que l'app affiche vient de
là — rien n'est codé en dur).

Pour rejouer l'achat : *Réglages* → *App Store* → *Compte sandbox* →
*Gérer* → **Effacer l'historique des achats**, puis relancer l'app.
Pour tester *Restaurer les achats* : supprimer l'app, la réinstaller
depuis TestFlight, ouvrir l'écran Premium, *Restaurer les achats*.

Le déroulé complet des alertes à voir et des deux façons de simuler le
déblocage est dans `docs/TEST_PREMIUM.md`.

## 3. Ce que le build n°38 contient

Le dernier build store (`a71061c`, TestFlight n°38, `tester_unlock`
décoché) : les 1 100 questions dont 50 gratuites, la limite de 50 pioches
par partie gratuite, les popups « tour des cartes gratuites » et « fin de
partie », l'écran Premium avec *Restaurer les achats*, la barrière
parentale avant l'achat. Aucun réglage « Mode testeur » n'y est compilé.

## 4. Soumettre à la revue

*Mes apps* → **IqraQuest** → *App Store* → version **1.0** :

1. **Fiche** : nom, sous-titre, texte promotionnel, description,
   mots-clés, URL d'assistance `https://iqraquest.org/support`, URL de
   marketing `https://iqraquest.org`. Les textes du site
   (`iqraquest-website/messages/<langue>.json`) servent de base, une
   fiche par langue si tu veux.
2. **Captures** : 6,7" et 6,5" (iPhone), 13" (iPad) — plan dans
   `screenshots_plan.md`.
3. **Achats intégrés** : dans la section *Achats intégrés* de la
   version, **ajouter `iqraquest_full_access`**. Obligatoire à la
   première soumission : un produit non joint n'est pas examiné et
   l'achat échoue en production.
4. **Build** : sélectionner le n°38 (ou plus récent).
5. **Informations générales** : classification par âge (questionnaire
   → 4+), copyright « © 2026 IqraQuest », catégorie *Jeux → Jeux de
   plateau* et *Éducation*.
6. **Confidentialité de l'app** (*Confidentialité* dans la barre
   latérale) : **Données non collectées** — l'app n'a ni compte, ni
   serveur, ni analytique. Politique de confidentialité :
   `https://iqraquest.org/privacy`.
7. **Chiffrement** : voir `TESTFLIGHT_SETUP.md`, section
   « Informations manquantes » (l'app n'utilise que le chiffrement
   standard d'iOS : exemption).
8. **Informations pour la revue** : coller `review_notes.md` ; *Connexion
   requise* : non ; contact téléphone et e-mail
   (`support@iqraquest.org`).
9. **Publication** : *Manuelle* la première fois (tu publies quand le
   site est prêt), *Automatique* ensuite.
10. **Ajouter pour la revue** → **Envoyer**.

La revue prend en général 24 à 48 heures. Une demande de précision arrive
dans *Résolution Center* ; les réponses courantes sont dans
`review_notes.md`.

## 5. Après l'approbation

Si publication manuelle : *Publier cette version*. L'app est en ligne en
quelques heures à l'adresse `https://apps.apple.com/app/id<numéro>` (le
numéro est dans *Informations sur l'app* → *ID Apple*).

Renseigne-la sur le site : dépôt `UPASCO/iqraquest-website` →
*Settings* → *Variables* → `NEXT_PUBLIC_APPLE_APP_URL` (cette adresse)
et `NEXT_PUBLIC_APP_AVAILABLE_IOS` = `true`, puis relance le workflow
*Deploy*. Les boutons « Télécharger dans l'App Store » s'activent dans
les douze langues. Même chose pour Google Play avec
`NEXT_PUBLIC_GOOGLE_PLAY_URL` et `NEXT_PUBLIC_APP_AVAILABLE_ANDROID`
(`store/google/PLAY_SETUP.md`).

## 6. Les mises à jour

Monte la version dans `pubspec.yaml` (`1.0.1+1`), relance le workflow
iOS (le numéro de build suit le numéro du run), crée la version 1.0.1
dans App Store Connect, sélectionne le build, *Envoyer*. Le produit
Premium n'a pas à être rejoint : il reste attaché à l'app.
