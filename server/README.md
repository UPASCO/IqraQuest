# Le serveur du mode Classe

Tout ce qu'IqraQuest fait sur un téléphone se passe hors ligne. Ce
dossier est la seule exception : il fait tourner le **mode Classe**, où
un enseignant projette une partie au tableau et où ses élèves répondent
depuis leur appareil.

Rien d'autre ne dépend de ce serveur. L'app entière — les 1 100
questions, les parties de famille, les sauvegardes, le défi de l'ordi —
continue de fonctionner sans réseau, sans compte et sans que ce projet
existe.

## Ce qui est stocké, et ce qui ne l'est pas

**Un élève n'a pas de compte.** Il entre un code de séance et un prénom.
Le serveur garde ce prénom, son équipe et ses réponses le temps de la
séance, plus un jeton aléatoire qui lui permet de revenir s'il perd le
wifi — un jeton propre à cette séance, qui ne le relie à rien d'autre.
Pas d'adresse e-mail, pas d'identifiant d'appareil, pas de trace après.

**À la fermeture, la séance est effacée**, avec les prénoms et les
réponses. Ce que l'enseignant garde est un rapport agrégé : « question 4,
9 réussites sur 24 ». Il ne nomme personne, sauf si l'enseignant a coché
« garder les scores par élève » à l'ouverture — ce n'est pas le défaut,
et c'est écrit à l'écran.

Une séance qu'on a oublié de fermer part d'elle-même au bout de deux
jours (`purge_old_sessions`).

**La seule identité du système est celle de l'enseignant** : l'adresse
e-mail qui a payé, sur laquelle arrive un lien de connexion. Pas de mot
de passe, pas de profil, pas de nom.

## L'installation, une fois

1. **Créer le projet.** Sur [supabase.com](https://supabase.com), un
   nouveau projet en **région Europe** (Francfort ou Paris) — les données
   d'élèves européens restent en Europe.

2. **Poser le schéma.** Dans l'éditeur SQL du projet, coller
   `supabase/migrations/0001_classroom.sql` puis
   `supabase/migrations/0002_classroom_teacher.sql`, dans cet ordre.
   Avec la CLI Supabase : `supabase db push` depuis ce dossier.

3. **Activer le lien magique.** Authentication → Providers → Email, avec
   « Confirm email » activé et les mots de passe désactivés : l'enseignant
   se connecte par un lien reçu sur l'adresse qui a payé, jamais par un
   mot de passe qu'il oubliera.

4. **Relever les deux clés.** Settings → API :
   - l'URL du projet,
   - la clé publique `anon`.

   Ces deux valeurs-là peuvent vivre dans l'app : elles n'ouvrent rien.
   Toutes les tables refusent le rôle anonyme, qui ne peut appeler que
   `join_session`, `submit_answer` et `board_state`.

   La clé `service_role`, elle, ouvre tout : elle ne sort jamais du
   tableau de bord Stripe/Supabase et n'entre jamais dans le dépôt.

5. **Les passer à la compilation** — jamais dans un fichier versionné :

   ```
   flutter run \
     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
   ```

   En CI, ce sont deux secrets GitHub de plus.

## Vérifier que ça tient

Le mode Classe est la première porte ouverte sur l'extérieur ; ces
vérifications-là comptent plus que les autres.

- **Le rôle anonyme ne lit rien.** Avec la clé `anon`, un
  `select * from participants` doit renvoyer zéro ligne, pas une erreur —
  c'est RLS qui fait son travail. De même pour `sessions`, `answers`,
  `licences` et `reports`.
- **Un code inconnu ne dit rien d'utile.** `board_state('AAAAAA')` renvoie
  `unknown_code`, jamais un indice sur l'existence d'autres séances.
- **Une réponse arrivée trop tard est refusée** (`not_open`, `too_late`),
  et deux envois de la même réponse n'en comptent qu'une.
- **Fermer une séance efface bien ses participants** : après
  `close_session`, la séance n'existe plus, et le rapport ne contient
  aucun prénom si la case n'était pas cochée.

## La console de l'enseignant

Une page web, et rien d'autre : `/#/teacher` sur le site. La console
n'existe pas dans l'application du magasin — une licence s'achète là, et
rien sur un téléphone ne renvoie vers une page de paiement.

La connexion est un lien envoyé à l'adresse qui a payé. Il n'y a aucun
mot de passe dans ce système, et rien d'autre qu'une adresse n'identifie
un enseignant. Le lien revient sur `teacher-callback.html`, une page
statique de trois lignes qui passe les jetons à la console à l'intérieur
du fragment d'URL — donc sans qu'aucun serveur, le nôtre compris, ne les
voie jamais. La console les efface de la barre d'adresse aussitôt lus.

Trois paramètres à la compilation, jamais dans le dépôt :

    flutter build web \
      --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
      --dart-define=SUPABASE_ANON_KEY=eyJ... \
      --dart-define=TEACHER_CALLBACK_URL=https://<site>/teacher-callback.html \
      --dart-define=STRIPE_CHECKOUT_URL=https://buy.stripe.com/xxxx

Le dernier est un lien de paiement Stripe : le prix vit chez Stripe, pas
ici, et l'app ne touche jamais une carte.

## Stripe, et la licence qu'il écrit

`server/supabase/functions/stripe-webhook/index.ts` reçoit le webhook et
inscrit la licence sur l'adresse qui a payé — avant même que l'acheteur
ne se soit connecté une première fois. À la première connexion,
`my_licence()` rattache la ligne au compte. C'est ce raccord qui évite de
demander un compte au moment de l'achat.

    supabase functions deploy stripe-webhook --no-verify-jwt
    supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
    supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...

`--no-verify-jwt` est nécessaire — c'est Stripe qui appelle, sans jeton
Supabase — et c'est la signature `Stripe-Signature`, vérifiée avant toute
lecture du corps, qui tient lieu de contrôle. Sans elle, cette URL
distribuerait des licences.

Côté Stripe, poser sur le produit deux métadonnées :

| clé               | valeur                              |
|-------------------|-------------------------------------|
| `iqraquest_plan`  | `classe` ou `ecole`                 |
| `iqraquest_rooms` | nombre de salles simultanées (1-100)|

Sans elles, la licence retombe sur la plus modeste : une salle.

**La clé `service_role` ne sort jamais du tableau de bord Supabase et des
secrets de la fonction.** Elle ne va ni dans le dépôt, ni dans l'app, ni
dans un `--dart-define` : c'est la seule clé capable d'écrire dans
`licences`, et la seule qui contourne RLS.

## Le tableau projeté

`board_state(code)` est tout ce que le mur consomme : la phase, l'index
de la carte ouverte, les prénoms du vestibule, les cases par équipe, et
deux compteurs par question — combien de réponses reçues, combien de
bonnes. Des nombres, jamais un prénom en face d'une réponse : c'est ce
qui permet de fermer la séance sur « à revoir ensemble » sans désigner
un enfant devant sa classe.

L'écran vit dans l'application elle-même, à l'adresse
`/classroom/board/<CODE>` — en web pour un vidéoprojecteur, ou sur la
tablette de l'enseignant renvoyée vers la télévision de la salle. Il ne
sait rien faire d'autre que lire : ni rejoindre, ni répondre, ni
avancer. Le rythme reste à la console de l'enseignant.

## Si pg_cron n'est pas disponible

La migration 0002 planifie le ménage quotidien avec `pg_cron` quand
l'extension existe. Si le palier choisi ne l'a pas, appeler
`purge_old_sessions(2)` une fois par jour depuis une fonction Edge
planifiée, ou depuis n'importe quel ordonnanceur ayant la clé
`service_role`. Ce n'est pas une commodité : c'est ce qui garantit que
les prénoms ne restent pas.

## Ce que ça coûte

Le palier gratuit tient environ six classes simultanées (200 connexions
en temps réel, une par appareil). À 25 $ par mois, une quinzaine. Les
écritures sont négligeables : une trentaine de lignes par question posée.
