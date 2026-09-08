# Le serveur du mode Classe

Tout ce qu'IqraQuest fait sur un téléphone se passe hors ligne. Ce
dossier est la seule exception : il fait tourner le **mode Classe**, où
un enseignant projette une partie au tableau et où ses élèves répondent
depuis leur appareil.

Rien d'autre ne dépend de ce serveur. L'app entière — les 1 100
questions, les parties de famille, les sauvegardes, le défi de l'ordi —
continue de fonctionner sans réseau, sans compte et sans que ce projet
existe.

> **Pour mettre tout ça en route, dans l'ordre : [RUNBOOK.md](RUNBOOK.md).**
> Ce fichier-ci explique comment le mode Classe est construit ; le
> runbook dit quoi faire, étape par étape, jusqu'à la première séance.
>
> **Pour ce qu'un délégué à la protection des données demandera :
> [RGPD.md](RGPD.md)** — ce qui est enregistré, combien de temps, où, et
> ce qui reste à signer avant la première école.

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

## Publier la console et le tableau

`.github/workflows/web-classroom.yml` construit l'application pour le web
et la publie sur GitHub Pages à chaque poussée sur `main`, à l'adresse
**https://school.iqraquest.org**.

C'est un sous-domaine du site vitrine (`UPASCO/iqraquest-website`, qui
sert l'apex depuis son propre site Pages). Les deux sont indépendants :
publier ici ne peut pas toucher `iqraquest.org`, et ni l'un ni l'autre
n'approche les enregistrements de messagerie du domaine.

Trois réglages, une fois :

1. **OVHcloud** — ajouter un seul enregistrement, sans toucher aux
   autres :

   | sous-domaine | type  | cible               |
   |--------------|-------|---------------------|
   | `school`     | CNAME | `upasco.github.io.` |

   Ne rien changer aux quatre `A` de l'apex ni aux MX : ce sont le site
   vitrine et la messagerie.

2. **GitHub Pages** sur `UPASCO/IqraQuest` — Settings → Pages, source
   « GitHub Actions », domaine personnalisé `school.iqraquest.org`, puis
   cocher « Enforce HTTPS » une fois le certificat émis (quelques
   minutes). Le fichier `web/CNAME` du dépôt porte déjà ce domaine :
   Flutter le recopie dans le build, et Pages le lit là.

3. **Les secrets** ci-dessous. Aucun n'est dans le code :

| secret                 | à quoi il sert                                   |
|------------------------|--------------------------------------------------|
| `SUPABASE_URL`         | l'adresse du projet                              |
| `SUPABASE_ANON_KEY`    | la clé publique (elle n'atteint que les fonctions)|
| `STRIPE_CHECKOUT_URL`  | le lien de paiement Stripe                        |
| `TEACHER_CALLBACK_URL` | `https://school.iqraquest.org/teacher-callback.html` |

La clé `service_role` n'en fait pas partie et n'en fera jamais partie.

Une fois publié :

- la console est à `https://school.iqraquest.org/#/teacher` ;
- le tableau à `https://school.iqraquest.org/#/classroom/board/<CODE>`.

Sans les deux valeurs Supabase, le site se construit quand même : il
montre une salle vide et le dit franchement.

## Stripe, et la licence qu'il écrit

`server/supabase/functions/stripe-webhook/index.ts` reçoit le webhook et
inscrit la licence sur l'adresse qui a payé — avant même que l'acheteur
ne se soit connecté une première fois. À la première connexion,
`my_licence()` rattache la ligne au compte. C'est ce raccord qui évite de
demander un compte au moment de l'achat.

    supabase functions deploy stripe-webhook --no-verify-jwt
    supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
    supabase secrets set IQRAQUEST_SERVICE_KEY=sb_secret_...

`--no-verify-jwt` est nécessaire — c'est Stripe qui appelle, sans jeton
Supabase — et c'est la signature `Stripe-Signature`, vérifiée avant toute
lecture du corps, qui tient lieu de contrôle. Sans elle, cette URL
distribuerait des licences.

Côté Stripe : un produit, puis un **lien de paiement** (Payment Link)
portant ces deux métadonnées — sur le lien, pas sur le produit, car ce
sont celles du lien que Stripe recopie sur la session de paiement, donc
les seules que le webhook reçoit :

| clé               | valeur                              |
|-------------------|-------------------------------------|
| `iqraquest_plan`  | `classe` ou `ecole`                 |
| `iqraquest_rooms` | nombre de salles simultanées (1-100)|

Sans elles, la licence retombe sur la plus modeste : une salle.

Un compte Stripe déjà utilisé pour une autre application convient : il
faut seulement un produit et un lien de paiement **nouveaux** pour la
licence Classe (les métadonnées ci-dessus lui sont propres), et un
webhook pointant vers cette fonction. Un même compte peut servir
plusieurs applications ; c'est le lien payé qui dit ce qui est acheté.

Pour un abonnement, le renouvellement ne porte pas l'adresse de
l'acheteur : la fonction retrouve la licence par l'identifiant
d'abonnement inscrit au moment du paiement, et repousse simplement son
échéance. Une résiliation arrête la licence à la date du jour sans
effacer la ligne — l'école qui revient l'an prochain retrouve ses
rapports.

**La clé `service_role` ne sort jamais du tableau de bord Supabase et des
secrets de la fonction.** Elle ne va ni dans le dépôt, ni dans l'app, ni
dans un `--dart-define` : c'est la seule clé capable d'écrire dans
`licences`, et la seule qui contourne RLS.

## Ce que l'enseignant règle avant d'ouvrir

| réglage | valeurs | ce que ça change |
|---|---|---|
| Leçon | thème + niveau | les cartes de la séance |
| Comptage | **par équipes** (défaut) ou **individuel** | équipes : 2 à 4 chevaux, la bonne réponse de chaque enfant pousse le sien. Individuel : chaque prénom est classé au tableau |
| Chronomètre | aucun (défaut), 20 à 90 s | zéro = l'enseignant révèle à la main ; une classe n'est pas un tournoi |
| Longueur | leçon entière, 5 ou 8 cartes | une demi-heure ou dix minutes de fin de cours |
| Mélanger | oui / non | une classe qui rejoue la même leçon ne répond plus de mémoire |
| Équipes | 2 à 4 | en mode équipes seulement |
| Langue du tableau | 12 langues | celle du mur ; chaque élève garde la sienne sur son appareil |

Longueur et mélange sont décidés par la console : le serveur ne reçoit
qu'une liste d'identifiants de cartes, dans l'ordre voulu.

Le mode individuel est le seul cas où un prénom voyage avec un score.
`board_state` ne renvoie `pupilScores` que si `scoring_mode = 'individual'` ;
en mode équipes, ce tableau est vide côté serveur, pas seulement masqué
côté écran.

## Le tableau projeté

`board_state(code)` est tout ce que le mur consomme : la phase, l'index
de la carte ouverte, les prénoms du vestibule, les cases par équipe, et
deux compteurs par question — combien de réponses reçues, combien de
bonnes. Des nombres, jamais un prénom en face d'une réponse : c'est ce
qui permet de fermer la séance sur « à revoir ensemble » sans désigner
un enfant devant sa classe.

Le vestibule affiche le code **et** un QR code qui porte
`https://school.iqraquest.org/#/classroom?code=<CODE>` : les grands
scannent, les autres tapent les six caractères, qui restent au mur toute
la séance. Comme l'application se compile aussi pour le web, un
Chromebook ou une tablette d'école rejoint sans rien installer.

L'écran vit dans l'application elle-même, à l'adresse
`/classroom/board/<CODE>` — en web pour un vidéoprojecteur, ou sur la
tablette de l'enseignant renvoyée vers la télévision de la salle. Il ne
sait rien faire d'autre que lire : ni rejoindre, ni répondre, ni
avancer. Le rythme reste à la console de l'enseignant.

## Les durées de conservation

| donnée | durée | tenue par |
|---|---|---|
| Séance, participants, réponses | 2 jours au plus, et effacée à la fermeture | `purge_old_sessions` (0001) |
| Prénoms dans un rapport (mode individuel) | 90 jours | `strip_old_report_names` (0003) |
| Rapport lui-même (compteurs par question) | 24 mois | `purge_old_reports` (0003) |

La deuxième ligne est celle qui manquait : un rapport gardait les prénoms
sans limite dès que l'enseignant avait choisi le classement individuel.
Une promesse d'anonymat qui tient « sauf si on coche une case, et alors
pour toujours » n'est pas une promesse.

## Si pg_cron n'est pas disponible

La migration 0002 planifie le ménage quotidien avec `pg_cron` quand
l'extension existe. Si le palier choisi ne l'a pas, appeler
`purge_old_sessions(2)`, `strip_old_report_names(90)` et
`purge_old_reports(24)` une fois par jour depuis une fonction Edge
planifiée, ou depuis n'importe quel ordonnanceur ayant la clé
`service_role`. Ce n'est pas une commodité : c'est ce qui garantit que
les prénoms ne restent pas.

## Comment l'abonnement d'une école est reconnu

Sans compte à créer, la question devient légitime : qui dit que cette
école a payé ? **L'adresse e-mail est le fil**, et il tient en cinq
étapes.

1. **L'école paie** sur la page de Stripe, avec une adresse — celle de
   la direction, du secrétariat, de l'enseignant. Aucun compte n'existe
   encore, et rien n'est demandé de plus.
2. **Stripe prévient la fonction Edge**, qui écrit une ligne dans
   `licences` : l'adresse, le plan, le nombre de salles simultanées, la
   date d'échéance. `owner_id` est **nul** : l'abonnement existe,
   rattaché à une adresse, sans que personne se soit connecté.
3. **L'enseignant ouvre la console** et entre cette adresse. Il reçoit
   un lien ; le clic crée son compte Supabase — un identifiant et une
   adresse, sans mot de passe. C'est tout ce que ce compte contient.
4. **`my_licence()` fait la soudure**, à la première connexion : ne
   trouvant aucune licence rattachée au compte, elle lit l'adresse du
   compte connecté et réclame la ligne portant la même adresse
   (`owner_id is null`). L'abonnement et le compte ne font plus qu'un.
5. **Ensuite, tout passe par là.** `open_session` appelle `my_licence()`
   avant d'ouvrir quoi que ce soit : pas de licence → `no_licence` ;
   échue → `licence_expired` ; déjà autant de salles ouvertes que payées
   → `too_many_sessions`.

Ce sens de lecture — payer d'abord, se connecter ensuite — n'est pas un
détail d'implémentation. La page de paiement appartient à Stripe : on ne
peut pas y créer de compte chez nous. Faire de l'adresse le point de
jonction évite donc d'imposer une inscription avant l'achat, et évite
surtout à un acheteur de devoir se souvenir de ce qu'il aurait tapé.

**La panne à connaître** : payer avec une adresse et se connecter avec
une autre. La console affiche alors « aucune licence » et le dit
explicitement — c'est le premier message de cet écran. Le remède, si
l'école a réellement changé d'adresse, tient en une ligne dans le SQL
Editor :

```sql
update public.licences
   set email = 'la.nouvelle@ecole.fr', owner_id = null
 where email = 'lancienne@ecole.fr';
```

Remettre `owner_id` à nul est la partie qui compte : c'est ce qui permet
au prochain compte connecté de réclamer la licence.

## Ce qui empêche une licence de se promener

La question vient toujours, et elle est légitime : sans compte à créer,
qu'est-ce qui empêche deux écoles de se transmettre une adresse ?

**Ce qui est vendu n'est pas un accès, c'est un nombre de salles
simultanées.** `open_session` compte les séances ouvertes de la licence
avant d'en ouvrir une de plus, et refuse au-delà
(`too_many_sessions`). Deux écoles qui partagent une licence à une salle
ne peuvent pas faire cours en même temps — et le samedi matin, elles
veulent toutes les deux faire cours en même temps. Le partage ne devient
pas interdit : il devient inutile.

**Une licence peut porter un domaine** (migration 0004) plutôt qu'une
seule adresse. Dix enseignants d'une même école se connectent alors
chacun avec son adresse professionnelle, sur la même licence et le même
plafond. C'est meilleur pour eux — plus de boîte commune dont on se
passe le mot de passe — et plus étanche pour nous : une adresse
extérieure au domaine n'entre pas.

Ce qui reste possible, et qu'il faut assumer plutôt que prétendre
l'empêcher : deux écoles aux horaires disjoints peuvent se partager une
petite licence. C'est visible — `reports` garde une ligne par séance
avec sa licence, et une licence à une salle qui tient quarante séances
par semaine se remarque — mais ce n'est pas bloqué, et le prix d'une
licence de classe ne justifie pas d'en faire une police.

Ce qui n'est **pas** un moyen de contrôle, et ne doit pas le devenir :
compter les élèves. Le mode Classe ne sait pas combien d'enfants
existent, seulement combien de prénoms sont dans la salle à cet instant,
et ces prénoms disparaissent le soir même. Une tarification au nombre
d'élèves demanderait de les compter durablement — c'est-à-dire de défaire
tout ce que [RGPD.md](RGPD.md) promet.

## Une région, un monde

Une séance est une île. Elle a un code, soixante élèves au plus, dix
questions, vingt minutes — puis elle est effacée. Rien dans ce schéma ne
joint deux séances, et il n'existe aucune donnée globale à répliquer.
Cela décide de presque tout ce qui suit.

**La latence n'est pas un problème, parce que le rythme est humain.** Un
appareil interroge la salle toutes les deux secondes ; l'enseignant, lui,
décide quand la carte s'ouvre et quand la réponse se montre. Trois cents
millisecondes de traversée entre Jakarta et Francfort ne se voient pas
dans ce rythme-là.

**Une seule règle protège cette propriété, et il faut la garder :
personne ne gagne parce qu'il a répondu plus vite.** Une case par bonne
réponse, sans prime à la vitesse. Cette règle a été choisie pour des
raisons pédagogiques — un enfant lent n'est pas un enfant qui a tort —
et elle a un effet secondaire précieux : elle rend le jeu équitable
quelle que soit la distance au serveur. Le jour où quelqu'un proposera
un bonus au premier qui répond, ce sera aussi la fin de l'équité entre
un élève de Lyon et un élève de Kuala Lumpur.

**La résidence des données, elle, se décide autrement — et la réponse
est : tout en Europe.** Non pour la latence, mais pour n'avoir jamais à
défendre un transfert. Le RGPD étant le régime le plus exigeant, une base
européenne convient partout : les régimes scolaires américains (FERPA,
COPPA) portent sur ce qui est collecté et consenti, pas sur le lieu, et
les lois du Golfe autorisent les transferts vers un pays offrant une
protection adéquate. Une école américaine ou saoudienne joue donc sans
obstacle sur un serveur européen. Le raisonnement complet, et ce qu'il
faut signer, sont dans [RGPD.md](RGPD.md).

Une seule chose ne se règle pas par la région : Supabase Inc. est une
société américaine. Le DPA et les clauses contractuelles types couvrent
ce point pour un établissement ordinaire ; pour un établissement public
qui exclut tout prestataire de droit américain, la même base se
réinstalle chez un hébergeur européen — les trois migrations sont du
PostgreSQL standard, sans extension propriétaire, et l'application n'en
saurait rien.

**Grandir se fait par ajout, pas par réécriture.** Le palier gratuit
tient environ six classes simultanées, 25 $ par mois une quinzaine. Trois
leviers, dans cet ordre :

1. espacer le sondage, ou passer les élèves au temps réel de Supabase
   (websocket) — c'est le sondage qui coûte, pas les écritures ;
2. monter de palier ;
3. ouvrir un second projet dans une autre région et y rejouer les deux
   migrations. Comme les séances sont des îles, rien n'a besoin d'être
   répliqué : chaque salle vit entièrement dans son projet.

Le troisième levier a une seule vraie contrainte, qu'il vaut mieux
connaître d'avance : un code de séance n'est unique qu'à l'intérieur
d'un projet. Le QR code règle le cas courant, puisqu'il porte l'adresse
complète de la console qui a ouvert la salle ; c'est la saisie manuelle
du code qui devra alors dire dans quelle région chercher.

**Pourquoi Supabase, et quand en changer.** Postgres avec RLS donne la
garantie d'anonymat par construction plutôt que par discipline : le rôle
anonyme n'a aucune politique, donc il ne lit rien, et la promesse tient
même si une requête est écrite de travers un jour. Les alternatives
sérieuses sont Cloudflare Durable Objects (une salle est littéralement
un objet, placé près de sa classe : techniquement le meilleur ajustement
à ce problème, au prix d'un serveur à écrire et à maintenir) et Firebase
(mondial et poussé en temps réel, mais la démonstration d'anonymat y
demande plus de travail que quatre fonctions et une suppression).

Le jour où l'un d'eux devient nécessaire, l'application n'en saura rien :
elle ne parle qu'à `ClassroomGateway`, une interface qui a déjà deux
implémentations (le serveur et une salle en mémoire). En ajouter une
troisième ne touche à aucun écran.

## Ce que les tests prouvent, et ce qu'ils ne prouvent pas

Quatre-vingt-dix tests couvrent le mode Classe, et il faut savoir
exactement ce qu'ils regardent : **la salle en mémoire**
(`FakeClassroomGateway`), pas le SQL. Les deux implémentent le même
contrat, et rien d'automatique ne les tient synchronisées — c'est une
relecture humaine qui le fait, fichier contre fichier.

Autrement dit : « 606 tests au vert » ne dit rien de la correction du
serveur. Le SQL n'a jamais été exécuté par la CI, faute de base ; la
première exécution est celle du SQL Editor, chez vous.

Trois conséquences pratiques :

1. **Jouer les migrations est un test**, pas une formalité : une erreur
   de syntaxe ou une signature ratée s'y voit immédiatement.
2. **`smoke-test.sh` est le seul contrôle qui interroge le vrai
   serveur.** Il est écrit pour échouer bruyamment, y compris quand une
   migration n'est pas passée — le distinguer d'un refus de droits est
   précisément ce qu'il fait.
3. **Quand une règle change d'un côté, elle change des deux.** La
   fermeture d'une séance, par exemple : le serveur garde la séance en
   phase `over` et supprime les participants ; la salle en mémoire fait
   exactement la même chose, et un test le vérifie. Si l'un des deux
   dérive, c'est la classe qui l'apprend.

## Ce que ça coûte

Le palier gratuit tient environ six classes simultanées (200 connexions
en temps réel, une par appareil). À 25 $ par mois, une quinzaine. Les
écritures sont négligeables : une trentaine de lignes par question posée.
