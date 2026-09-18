# Tester le blocage Premium et son déblocage

Le déroulé à suivre avant la version finale : voir chaque alerte que
rencontre un joueur de la version gratuite, puis vérifier que l'achat
(ou sa simulation) les fait toutes disparaître. Les captures de
référence sont dans `build/screenshots/` après
`UX_AUDIT=1 flutter test --tags=manual test/manual_ux_audit_test.dart`
(et, pour les deux popups, les deux commandes en tête de ce fichier de
test avec `UX_AUDIT_SOLO=1`).

## Ce que voit un joueur gratuit

| Où | Ce qui s'affiche | Ce qui l'ouvre | Capture |
| --- | --- | --- | --- |
| Accueil | bandeau doré « Passer à Premium — Toutes les cartes, tous les parcours, les sauvegardes » | toujours, tant que rien n'est acheté | `audit_light_home.png` |
| Réglages | première ligne « Passer à Premium » | idem | `audit_light_settings.png` |
| Nouvelle partie | parcours **Animé** et **Intense** grisés avec un cadenas ; **Charger** avec un cadenas | un tap ouvre l'écran Premium | `audit_light_mode_selection.png` |
| Les cavaliers | niveau **Mixte** avec un cadenas | un tap ouvre l'écran Premium | `audit_light_player_setup.png` |
| Plateau | compteur **0/50 cartes** dans le HUD ; bouton *Sauvegarder* avec un cadenas | toute la partie | `audit_light_game_gait.png` |
| Plateau | popup **« Tu as fait le tour des cartes gratuites »** : les 50 cartes gratuites ont toutes été vues sur cet appareil, bouton *Débloquer les 1 100 cartes* | à la première pioche d'une partie, une fois par partie, dès que les 50 cartes gratuites ont été vues (environ trois parties) | `premium_free_tour_popup.png` |
| Résultats | popup **« Limite de 50 pioches »** : la partie s'est arrêtée à la 50ᵉ carte, bouton vers Premium | à la fin d'une partie gratuite arrêtée par la limite (pas à une arrivée) | `premium_free_limit_popup.png` |
| Écran Premium | les six avantages, le bouton **« Débloquer — 8,99 € »** (prix lu dans la boutique), *Restaurer les achats* | tous les points d'entrée ci-dessus | `audit_light_premium.png` |

Tous ces éléments disparaissent dès que l'appareil est Premium :
bandeau, ligne des réglages, cadenas, compteur de cartes, popups. Le
bouton *Sauvegarder* du plateau devient actif et *Charger* aussi.

## Parcours A — l'expérience gratuite (build store)

Sur le build store (TestFlight n°38 ou APK du workflow Android, case
`tester_unlock` décochée), sans rien acheter :

1. Accueil : le bandeau est là, la ligne existe dans Réglages.
2. Nouvelle partie : tap sur *Animé* → écran Premium ; retour ; tap sur
   *Charger* → écran Premium.
3. Les cavaliers : tap sur *Mixte* → écran Premium.
4. Sur le plateau : le compteur lit « 0/50 cartes » ; tap sur le bouton
   *Sauvegarder* (cadenas) → écran Premium.
5. Joue une partie courte jusqu'au bout : à la 50ᵉ pioche la partie
   s'arrête et l'écran des résultats s'ouvre sur la popup « Limite de 50
   pioches ». *Plus tard* la ferme ; *Débloquer* ouvre l'écran Premium.
6. Enchaîne deux ou trois parties : quand les 50 cartes gratuites ont
   toutes été vues, la première pioche de la partie suivante ouvre la
   popup « tour des cartes gratuites ». Elle ne revient pas dans la même
   partie ; elle revient à la partie suivante tant que rien n'est
   acheté.
7. Écran Premium : le prix affiché est celui de la boutique (8,99 € une
   fois le produit créé, sinon « Connexion à la boutique… » puis
   « Boutique indisponible »).

## Parcours B — simuler le déblocage sans payer (build testeur)

Pour dérouler tout le contenu sans passer par une boutique, un **build
testeur** : case `tester_unlock` **cochée** au lancement du workflow
(iOS → TestFlight, Android → APK à installer à la main). Il gagne une
ligne *Réglages › Mode testeur* qui bascule le même droit local qu'un
achat :

1. *Réglages › Mode testeur* → **activé** : le bandeau et la ligne
   Premium disparaissent, les cadenas s'ouvrent, le compteur de cartes
   quitte le HUD, le réglage affiche « 1 100 / 1 100 cartes ».
2. **Démarre une nouvelle partie** (la pioche et la limite sont fixées
   au lancement d'une course) : plus de limite de 50, les cartes
   viennent de toute la banque, *Sauvegarder* fonctionne.
3. *Mode testeur* → **désactivé** puis nouvelle partie : tout le
   parcours A revient. C'est ainsi qu'on revoit les alertes sans
   réinstaller.

Un build testeur ne va jamais en revue Apple ni sur Play : ce réglage
n'existe pas dans un build store (`lib/app/build_flags.dart`).

## Parcours C — l'achat réel, sans être débité

Le vrai parcours, avec la feuille d'achat de la boutique, sur le build
store :

- **iOS** : un testeur sandbox (`store/apple/APP_STORE_PUBLISH.md` §2)
  connecté dans *Réglages › App Store › Compte sandbox*, sur un build
  TestFlight.
- **Android** : un compte ajouté aux *testeurs de licence* de la Play
  Console (`store/google/PLAY_SETUP.md` §6), sur l'app installée depuis
  la piste de tests internes.

1. Écran Premium → **Débloquer — 8,99 €** → la barrière parentale
   (un petit calcul) → la feuille de la boutique, marquée *Sandbox* /
   *Carte de test* → confirmer.
2. Le bouton passe à « Achat en cours… » avec l'indicateur, puis l'écran
   affiche « Merci ! » : l'appareil est Premium. Vérifie les points du
   parcours A dans l'autre sens : plus de bandeau, plus de cadenas, plus
   de compteur, plus de popups, *Sauvegarder* et *Charger* ouverts,
   nouvelle partie sans limite.
3. Supprime l'app, réinstalle-la : elle est à nouveau gratuite. Écran
   Premium → **Restaurer les achats** → Premium revient sans nouvel
   achat.
4. Pour rejouer l'achat : iOS, *Compte sandbox → Effacer l'historique
   des achats* ; Android, rembourser et révoquer l'achat test dans la
   Play Console (ou un autre compte testeur).

## Prêt pour la version finale quand

- [ ] Parcours A : les huit alertes vues sur un appareil, dans la langue
      du téléphone.
- [ ] Parcours B : le mode testeur ouvre et referme tout ; le build
      envoyé en revue est un build store (`tester_unlock` décoché).
- [ ] Parcours C : achat sandbox réussi sur iOS, achat test réussi sur
      Android, *Restaurer les achats* vérifié après réinstallation.
- [ ] Le prix 8,99 € vient de la boutique dans les deux stores.
- [ ] Le produit `iqraquest_full_access` est joint à la version 1.0
      dans App Store Connect et actif dans la Play Console.
