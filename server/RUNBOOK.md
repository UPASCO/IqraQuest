# De zéro à une séance en classe

Ce que le dépôt contient est complet et testé. Ce qui suit est ce qui ne
peut pas vivre dans un dépôt : un projet Supabase, des enregistrements
DNS, des secrets. Tant que ces étapes ne sont pas faites, l'application
ouvre l'écran « Classe » et dit franchement qu'aucune classe n'est
joignable — c'est voulu, et c'est le comportement correct d'une build
faite avant que le serveur existe.

Comptez une heure pour les étapes 1 à 5, puis une demi-heure pour
Stripe. Les étapes sont dans l'ordre : chacune s'appuie sur la
précédente.

---

## 1. Le projet Supabase — 15 minutes

1. <https://supabase.com> → **New project**. Région : **Europe (UE)**,
   et pour toutes les écoles du monde. C'est une décision de protection
   des données, pas de latence : voir [RGPD.md](RGPD.md).
2. Noter les deux valeurs dans **Settings → API** :
   - **Project URL** → `https://xxxx.supabase.co`
   - **la clé publique** → `sb_publishable_...` (ou `eyJ...` sur les
     projets plus anciens). Publique par conception : elle est embarquée
     dans l'application, ne peut appeler que les fonctions de séance, et
     toutes les tables la refusent. C'est elle qui va dans
     `SUPABASE_ANON_KEY`.
   - Ne jamais confondre avec la clé **secrète** (`sb_secret_...` ou
     `service_role`) : celle-là contourne RLS et ne quitte pas le
     tableau de bord.
3. **La clé `service_role` reste dans le tableau de bord.** Elle ne va ni
   dans le dépôt, ni dans l'app, ni dans un secret de build. Une seule
   chose la reçoit : la fonction Stripe (étape 6).
4. **SQL Editor** → coller et exécuter, dans cet ordre :
   - `server/supabase/migrations/0001_classroom.sql`
   - `server/supabase/migrations/0002_classroom_teacher.sql`
   - `server/supabase/migrations/0003_retention.sql`
   - `server/supabase/migrations/0004_licence_domain.sql`
   - `server/supabase/migrations/0005_school_name.sql`
   - `server/supabase/migrations/0006_review_fixes.sql`
   - `server/supabase/migrations/0007_plans_and_account.sql`
   - `server/supabase/migrations/0008_school_accounts.sql`
   - `server/supabase/migrations/0009_account_review.sql`

   (Ou, en une fois : le fichier `iqraquest-socle-complet.sql`, qui est
   la concaténation des neuf. Rejouable : chaque migration est écrite
   pour l'être, et `server/supabase/tests/run_local.sh` le vérifie en
   les jouant deux fois de suite sur un PostgreSQL 16 local, puis en
   déroulant le parcours compte — inscription, cinq parties, deux
   appareils, impayé, résiliation, suppression, clé publique, et deux
   consoles qui se disputent le dernier crédit.)

Vérification : dans **Table Editor**, huit tables existent (`licences`,
`sessions`, `participants`, `answers`, `reports`, `plans`, `profiles`,
`stripe_events`), toutes avec RLS activé. Sept n'ont **aucune
politique** — c'est normal, et c'est la protection : la clé publique ne
lit rien, tout passe par les fonctions. Seule `profiles` en porte deux,
qui laissent un compte lire et modifier **sa propre ligne** et rien
d'autre.

La migration 0008 pose aussi un déclencheur sur `auth.users` : chaque
compte créé reçoit un profil et une licence **découverte** (cinq
parties, deux salles). C'est ce qui rend l'inscription libre possible
sans qu'aucune ligne ne soit écrite à la main.

Puis, depuis votre machine, la vérification qui compte vraiment — celle
qui regarde le socle de l'extérieur, avec la clé publique, comme le
ferait n'importe qui :

```bash
SUPABASE_URL=https://xxxx.supabase.co \
SUPABASE_ANON_KEY=sb_publishable_... \
bash server/smoke-test.sh
```

Il vérifie que les tables ne rendent rien, qu'un code inconnu ne
raconte rien, que les fonctions de l'enseignant sont hors de portée de
la clé publique, et que les migrations 0007 et 0008 sont passées. Un échec sur les deux premiers points signifierait que des
données d'élèves sont lisibles : ne pas ouvrir de classe avant de
l'avoir corrigé.

## 2. L'authentification de l'enseignant — 15 minutes

Dans **Authentication → URL Configuration** :

| champ | valeur |
|---|---|
| Site URL | `https://school.iqraquest.org` |
| Redirect URLs | `https://school.iqraquest.org/teacher-callback.html` |
| Redirect URLs (2e ligne) | `https://school.iqraquest.org/**` |

Sans la première ligne de redirection, le lien de confirmation ou de
connexion arrive mais refuse de revenir sur la console.

Dans **Authentication → Providers → Email** :

| réglage | valeur |
|---|---|
| Enable Email provider | activé |
| Confirm email | **activé** — un compte non confirmé ne se connecte pas et ne reçoit pas de licence |
| Secure email change | activé |
| Minimum password length | 6 (la valeur par défaut ; la console exige la même) |

Dans **Authentication → Emails**, les trois modèles utilisés sont
*Confirm signup*, *Magic Link* et *Reset password*. Les modèles par
défaut conviennent ; changer l'expéditeur suffit.

**Le courrier.** Le service d'e-mail intégré de Supabase est bridé à
**deux envois par heure** et n'écrit qu'aux adresses membres de
l'organisation du projet. Il ne sert à rien d'utile : poser un SMTP à
soi tout de suite. C'est la panne la plus probable le jour où ça
compte, et elle est silencieuse : le courrier n'arrive jamais.

### Envoyer depuis support@iqraquest.org — 5 minutes

La boîte `support@iqraquest.org` existe déjà chez OVH (les MX du domaine
y pointent). Son serveur d'envoi suffit pour le volume d'une console :
un courrier par enseignant à l'inscription, un par mot de passe oublié.

**Authentication → Emails → SMTP Settings → Enable custom SMTP** :

| champ | valeur |
|---|---|
| Sender email | `support@iqraquest.org` |
| Sender name | `IqraQuest` |
| Host | `ssl0.ovh.net` |
| Port | `465` |
| Username | `support@iqraquest.org` |
| Password | le mot de passe de la boîte (celui du webmail OVH) |

Le mot de passe se tape dans ce formulaire et nulle part ailleurs : ni
dans le dépôt, ni dans un secret GitHub, ni dans une conversation.

Puis **Authentication → Rate Limits → Email sent per hour** : `30` (la
valeur que Supabase propose dès qu'un SMTP est posé).

Vérification : depuis la console, « Mot de passe oublié ? » sur votre
adresse. Le courrier arrive en moins d'une minute, signé
`support@iqraquest.org`. S'il n'arrive pas, **Authentication → Logs**
porte l'erreur SMTP exacte (mot de passe refusé, port bloqué). Chez OVH,
si le compte refuse l'envoi, vérifier dans l'espace client que la boîte
n'est pas une redirection : seule une vraie boîte a un mot de passe SMTP.

Au-delà de quelques centaines d'envois par mois, ou si la délivrabilité
devient un sujet, passer à Resend ou Brevo (compte gratuit) : même
formulaire, avec en plus trois enregistrements DNS (SPF, DKIM, DMARC)
que le prestataire donne, à poser chez OVH à côté des MX.

### Comment une école entre

La console se connecte avec **une adresse et un mot de passe**. C'est la
porte de tous les jours, et elle ne dépend d'aucun courrier une fois le
compte confirmé.

1. **Créer un compte** (bouton sous le formulaire de connexion) : une
   adresse, un mot de passe de six caractères au moins, le nom de
   l'établissement (facultatif). La console dit « Confirmez votre
   adresse », avec un bouton « Renvoyer l'e-mail » si rien n'arrive.
   Une adresse qui a déjà un compte le lit tout de suite ; une
   connexion tentée avant la confirmation ramène à cet écran.
2. **Le courrier de confirmation** ramène sur la console, connectée.
   Le déclencheur de la migration 0008 a déjà écrit le profil et la
   licence découverte : l'école voit « Offre découverte — 0 partie sur
   5 » et peut ouvrir sa première séance.
3. **Cinq parties plus tard**, la console affiche l'offre et le bouton
   « S'abonner » (étape 7). Rien n'est effacé : l'historique reste.

**Mot de passe oublié** : sous le formulaire, « Mot de passe oublié ? »
envoie un lien de connexion à l'adresse (une adresse sans compte lit
« aucun compte », pas « lien envoyé »). Le lien ramène sur la console,
qui ouvre d'elle-même **Mon compte** sur « Changer le mot de passe ».
C'est le seul endroit où un e-mail reste nécessaire après la
confirmation.

**Supprimer le compte** : **Mon espace → Supprimer mon compte**, avec
confirmation. La fonction `delete-school-account` résilie d'abord
l'abonnement chez Stripe (sans facture), puis `delete_my_account()`
efface le profil, la licence, les séances, les bilans et le compte
d'authentification. Seules les factures restent chez Stripe, qui a
l'obligation légale de les conserver. Sans la fonction déployée, la base
refuse de supprimer un compte encore facturé : la console dit de
résilier d'abord depuis « Gérer mon abonnement ».

### Créer le compte d'une école à la main — 2 minutes, sans e-mail

Pour une école que vous inscrivez vous-même (ou tant qu'aucun SMTP n'est
posé), **Authentication → Users → Add user → Create new user** :

| champ | valeur |
|---|---|
| Email | l'adresse de l'école |
| Password | celui que vous lui transmettez |
| Auto Confirm User | **coché** |

« Auto Confirm User » compte : sans lui, l'adresse reste non confirmée
et la console répond « Adresse ou mot de passe incorrect ». Le
déclencheur écrit la licence découverte comme pour une inscription
libre.

Si un compte a été créé **avant** par un lien de connexion qui n'est
jamais arrivé, il existe sans mot de passe et refuse d'entrer. Le
vérifier, puis le refaire :

```sql
select email, email_confirmed_at,
       length(coalesce(encrypted_password, '')) as hash
  from auth.users where email = 'ecole@example.org';
-- hash = 60 : le mot de passe est là. 0 : compte fantôme, à refaire :
delete from auth.users where email = 'ecole@example.org';
```

Pour une école qui a payé autrement que par la caisse en ligne (bon de
commande, virement), la licence se pose à la main sur son compte :

```sql
update public.licences
   set plan = 'ecole', concurrent_sessions = 2, status = 'active',
       expires_at = now() + interval '1 year'
 where email = 'ecole@example.org';
```

### Le courrier ne part pas : où regarder, dans l'ordre

La console dit « Lien envoyé » ou « Confirmez votre adresse » dès que
Supabase a répondu 2xx — donc qu'il a **accepté** la demande. Entre
cette acceptation et une boîte de réception, quatre choses peuvent
manquer.

1. **Les indésirables.** L'expéditeur par défaut est
   `noreply@mail.app.supabase.io`, inconnu de tous les filtres. Chez
   Gmail, regarder aussi l'onglet *Promotions*.
2. **Les journaux d'authentification** — *Authentication → Logs* dans le
   tableau de bord. C'est la seule réponse qui ne se devine pas : soit
   l'envoi y figure, et le problème est côté boîte de réception, soit il
   porte une erreur SMTP, et c'est l'étape 4 ci-dessous.
3. **Le destinataire.** Le service intégré n'écrit qu'aux adresses
   membres de l'organisation du projet. Une adresse d'école qui n'est pas
   dans l'équipe ne recevra jamais rien tant qu'un SMTP n'est pas posé —
   sans la moindre erreur affichée.
4. **Le plafond horaire.** Quelques envois par heure, pas davantage. La
   console dit « Trop de liens demandés » plutôt que « le serveur ne
   répond pas » : c'est un refus du service d'e-mail, pas une panne.

Les points 3 et 4 ont la même réponse, et c'est la seule qui tienne pour
de vraies écoles : un SMTP à soi dans **Authentication → Emails**.

## 3. Le DNS chez OVHcloud — 5 minutes, plus la propagation

Un seul enregistrement à ajouter, dans la zone `iqraquest.org` :

| sous-domaine | type | cible |
|---|---|---|
| `school` | CNAME | `upasco.github.io.` |

**Ne touchez à rien d'autre.** Les quatre `A` de l'apex servent le site
vitrine, les `MX` servent `support@iqraquest.org`. Les casser est la
seule erreur vraiment coûteuse de cette page.

## 4. GitHub Pages sur `UPASCO/IqraQuest` — 5 minutes

**Settings → Pages** :

- Source : **GitHub Actions**
- Custom domain : `school.iqraquest.org`
- Cocher **Enforce HTTPS** dès que le certificat est émis (quelques
  minutes après le DNS)

Le fichier `web/CNAME` du dépôt porte déjà ce domaine ; Flutter le
recopie dans la build et Pages le lit là.

## 5. Les secrets, puis la publication — 10 minutes

**Settings → Secrets and variables → Actions** du dépôt `UPASCO/IqraQuest` :

| secret | valeur | qui l'utilise |
|---|---|---|
| `SUPABASE_URL` | l'URL de l'étape 1 | le web **et** les builds iOS/Android |
| `SUPABASE_ANON_KEY` | la clé anon de l'étape 1 | idem |
| `TEACHER_CALLBACK_URL` | `https://school.iqraquest.org/teacher-callback.html` | la console |

Aucun lien ni prix Stripe n'est compilé dans l'application : la caisse
et le portail sont des adresses que le serveur fabrique à la demande
(étape 7), et la vérification de pré-publication refuse une build qui
en contiendrait un.

Puis **Actions → Web — classroom console & board → Run workflow**, en
choisissant la branche par défaut. (Toute poussée sur cette branche le
relance ensuite toute seule.)

> Vérifier que l'exécution apparaît bien dans l'onglet Actions. Un
> workflow qui n'a jamais tourné ne publie rien, et Pages reste vide sans
> le dire : c'est exactement ce qui s'est produit la première fois.

Au bout de quelques minutes : `https://school.iqraquest.org/#/teacher`
répond.

> Les deux premiers secrets servent aussi aux builds mobiles. Une build
> TestFlight ou APK faite **avant** qu'ils existent parle à une salle
> vide : refaire la build après les avoir posés.

## 6. Une première séance, sans attendre Stripe — 10 minutes

Aucune ligne à écrire : un compte suffit, et il donne cinq parties.

1. Ouvrir `https://school.iqraquest.org/#/teacher` → **Créer un
   compte** (ou le créer depuis le tableau de bord, étape 2, si le
   courrier n'est pas encore configuré). Se connecter.
2. La console affiche « Offre découverte » et une jauge « 0 partie sur
   5 ». Choisir un thème, un niveau, une leçon. Régler le comptage
   (équipes ou individuel), le chronomètre, la longueur. **Ouvrir la
   séance.**
3. Un code à six caractères s'affiche. Cliquer **Ouvrir le tableau** :
   la page à projeter s'ouvre dans un second onglet, avec le code en
   grand et un QR code.
4. Sur un téléphone : ouvrir IqraQuest → **Mode École**, taper le code
   et un prénom. (Ou scanner le QR : le code est alors déjà rempli. Ou,
   sans installer l'app, ouvrir `https://school.iqraquest.org/#/classroom`.)
5. Le prénom apparaît sur le tableau. Depuis la console : **Question
   suivante** → la carte s'affiche partout ; répondre sur le téléphone →
   le compteur du tableau passe à 1 ; **Montrer la réponse** → la bonne
   s'allume, la source apparaît, le cheval avance.
6. **Terminer la séance** : les prénoms sont effacés, le bilan par
   question est écrit dans `reports`, et la jauge passe à « 1 partie sur
   5 ».

Si l'étape 5 marche, le mode École est opérationnel. Deux choses valent
la peine d'être vues une fois :

- **Deux appareils.** Ouvrir une seconde séance depuis un autre
  navigateur : elle s'ouvre (deux salles). Une troisième est refusée
  avec « Deux appareils sont déjà en séance ». Fermer un onglet sans
  terminer la séance : cinq minutes plus tard, sa place est libre —
  c'est le bail des appareils, et **Mon espace → Appareils** permet de
  la libérer tout de suite.
- **La sixième partie.** Après cinq séances, « Ouvrir la séance »
  disparaît au profit de l'offre. L'historique est toujours là.

## 7. Stripe — 45 minutes

Le compte existant convient (il est déjà vérifié, avec son compte
bancaire). Il faut de quoi vendre **une** offre en abonnement annuel, un
portail pour la gérer, trois fonctions serveur, et un webhook.

**Une règle avant tout : le tarif de test est 1 €, le tarif de production
est 89 €, et 1 € ne passe jamais en production.** Le code le refuse deux
fois — `STRIPE_MODE=live` avec un Price ID de test est rejeté, et la
caisse refuse en live tout prix inférieur à 50 € — mais la règle vaut
d'abord pour la main qui configure.

### 7.1 Le produit et ses deux prix

Dans Stripe, **Product catalog → Add product** :

| champ | valeur |
|---|---|
| Name | IqraQuest École |
| Description | Parties illimitées, deux sessions simultanées, un an |
| Pricing | Recurring, **Yearly** |

Le produit se crée **deux fois**, une par mode :

| mode Stripe (bascule en haut à droite) | prix | Price ID → secret |
|---|---|---|
| **Test mode** | **1,00 € / an** | `STRIPE_SCHOOL_PRICE_TEST` |
| **Live mode** | **89,00 € / an** | `STRIPE_SCHOOL_PRICE_LIVE` |

Le Price ID (`price_…`) se lit sur la page du prix. Les prix vivent
**dans Stripe et nulle part ailleurs** : aucun fichier de ce dépôt n'en
porte, et changer un tarif ne demande aucune livraison.

Aucune promotion, aucun code promo, aucun essai gratuit côté Stripe :
l'essai, ce sont les cinq parties du compte, et il est déjà là.

### 7.2 Le portail client

**Settings → Billing → Customer portal** (à faire en test **et** en
live) :

| réglage | valeur |
|---|---|
| Cancel subscriptions | activé, **at end of billing period** |
| Update payment method | activé |
| Invoice history | activé |
| Switch plans / Update quantities | désactivé — il n'y a qu'une offre |
| Business information | nom, adresse de support `support@iqraquest.org` |

La résiliation à l'échéance est ce que la console attend : l'école garde
son accès jusqu'à `current_period_end`, la console affiche « prend fin
le … », et Stripe envoie `customer.subscription.deleted` ce jour-là.

### 7.3 Les fonctions serveur

Depuis votre machine, avec la CLI Supabase (`npm i -g supabase`) :

```bash
supabase login
supabase link --project-ref <ref du projet>

cd server
supabase functions deploy create-school-checkout
supabase functions deploy create-customer-portal
supabase functions deploy delete-school-account
supabase functions deploy stripe-webhook --no-verify-jwt
```

`--no-verify-jwt` ne concerne que le webhook — c'est Stripe qui appelle,
sans jeton Supabase — et c'est la signature `Stripe-Signature`, vérifiée
avant toute lecture du corps, qui tient lieu de contrôle. Les trois
autres exigent le jeton de l'enseignant connecté : elles ne font rien
pour un anonyme.

Puis les secrets, **tapés sur votre machine, jamais dans le dépôt** :

```bash
supabase secrets set \
  STRIPE_MODE=test \
  STRIPE_SECRET_KEY=sk_test_... \
  STRIPE_SCHOOL_PRICE_TEST=price_... \
  STRIPE_SCHOOL_PRICE_LIVE=price_... \
  STRIPE_WEBHOOK_SECRET=whsec_... \
  IQRAQUEST_SERVICE_KEY=sb_secret_... \
  TEACHER_CONSOLE_URL=https://school.iqraquest.org
```

| secret | valeur | où la trouver |
|---|---|---|
| `STRIPE_MODE` | `test` d'abord, `live` à l'étape 7.6 | — |
| `STRIPE_SECRET_KEY` | `sk_test_…` puis `sk_live_…` | Stripe → Developers → API keys, dans le mode correspondant |
| `STRIPE_SCHOOL_PRICE_TEST` | `price_…` du prix à 1 € | le produit, en Test mode |
| `STRIPE_SCHOOL_PRICE_LIVE` | `price_…` du prix à 89 € | le produit, en Live mode |
| `STRIPE_WEBHOOK_SECRET` | `whsec_…` | le webhook de l'étape 7.4, dans le mode correspondant |
| `IQRAQUEST_SERVICE_KEY` | `sb_secret_…` | Supabase → Settings → API. Le préfixe `SUPABASE_` est réservé par la CLI, d'où ce nom |
| `TEACHER_CONSOLE_URL` | `https://school.iqraquest.org` | là où Stripe ramène après paiement |

La clé secrète Supabase ne sort du tableau de bord que par cette
commande. Elle ne va ni dans le dépôt, ni dans l'app, ni dans un secret
GitHub.

### 7.4 Le webhook

**Developers → Webhooks → Add endpoint**, dans le mode courant (un
endpoint en test, un autre en live, chacun avec son `whsec_`) :

| champ | valeur |
|---|---|
| Endpoint URL | `https://<ref>.supabase.co/functions/v1/stripe-webhook` |
| Events | `checkout.session.completed` |
| | `checkout.session.async_payment_succeeded` |
| | `checkout.session.async_payment_failed` |
| | `customer.subscription.created` |
| | `customer.subscription.updated` |
| | `customer.subscription.deleted` |
| | `invoice.paid` |
| | `invoice.payment_failed` |

Ce que chaque événement fait à la licence :

| événement | `licences.status` | effet |
|---|---|---|
| `checkout.session.completed` | `active` | plan `ecole`, deux salles, échéance provisoire à un an, client et abonnement Stripe notés — sur la licence **du compte** qui a ouvert la caisse |
| `invoice.paid` | `active` | renouvellement : l'échéance suit la période payée |
| `invoice.payment_failed` | `past_due` | plus de nouvelle séance ; une séance en cours va au bout |
| `customer.subscription.updated` | celui de Stripe | `cancel_at_period_end`, période, prix |
| `customer.subscription.deleted` | `canceled` | fin d'accès à l'instant ; l'historique reste |
| `async_payment_failed` | `canceled` | virement SEPA refusé |

Un événement reçu deux fois ne s'applique qu'une fois : sa clé est
inscrite dans `stripe_events` avant toute écriture — et rendue si
l'écriture échoue, pour que la nouvelle tentative de Stripe ne soit pas
prise pour un doublon. L'échéance écrite est la fin de période **plus
trois jours** : le renouvellement Stripe tombe à l'échéance, parfois
quelques heures après, et une école ne trouve pas porte close le matin
de la reconduction. Une résiliation coupe à l'instant même.

### 7.5 Le parcours complet, en test, pour 1 €

`STRIPE_MODE=test`, avec un compte découverte dont les cinq parties sont
utilisées (ou pas — le bouton « S'abonner » est aussi dans Mon espace) :

1. **S'abonner** → la caisse Stripe s'ouvre, à 1 €. Carte de test
   `4242 4242 4242 4242`, n'importe quelle date future, n'importe quel
   CVC.
2. Retour sur la console, qui redemande le compte quelques secondes le
   temps que le webhook passe : « IqraQuest École », « Renouvellement
   le … », parties illimitées. Dans **Table Editor**, `licences.status =
   'active'`, `stripe_events` porte l'événement.
3. **Gérer l'abonnement** → le portail. Résilier : la console affiche
   « prend fin le … » et une séance s'ouvre encore. Réactiver depuis le
   portail : la mention disparaît.
4. **Simuler l'échéance** : dans Stripe (test), sur l'abonnement,
   *Cancel subscription → Immediately*. La console : « Votre abonnement
   est terminé », « Ouvrir la séance » a disparu, l'historique est
   toujours là, et « Renouveler » rouvre la caisse.
5. **Simuler un impayé** : *Customers → le client → Payment methods*,
   remplacer par la carte `4000 0000 0000 0341`, puis sur l'abonnement
   *Actions → Update subscription → renouveler maintenant*. La console
   dit « Paiement en échec » et refuse une nouvelle séance.

Si l'étape 2 montre autre chose — surtout « Offre découverte » qui ne
bouge pas — regarder **Developers → Webhooks → l'endpoint → Events** :
un 400 signifie un `STRIPE_WEBHOOK_SECRET` qui n'est pas celui de ce
mode ; un 500, la fonction ne joint pas Supabase (`IQRAQUEST_SERVICE_KEY`).
Un événement se rejoue depuis cette page une fois le secret corrigé.

### 7.6 Passer en production

Quand 7.5 est vert de bout en bout :

```bash
supabase secrets set \
  STRIPE_MODE=live \
  STRIPE_SECRET_KEY=sk_live_... \
  STRIPE_WEBHOOK_SECRET=whsec_...   # celui de l'endpoint LIVE (7.4)
```

`STRIPE_SCHOOL_PRICE_LIVE` est déjà posé : la fonction bascule sur lui,
et refuse de démarrer si ce prix est sous 50 €. Puis, sur le site
vitrine, poser la variable `NEXT_PUBLIC_CLASSROOM_CHECKOUT=true` (étape
8) : la page Écoles cesse de dire que le paiement en ligne « ouvre
bientôt ».

Un premier paiement réel à 89 €, depuis une adresse à soi, puis un
remboursement depuis Stripe, est la vérification qui compte.

## 8. Le site vitrine

Deux pages parlent des écoles sur `iqraquest.org`, et elles sont
publiées :

- **`/schools`** — comment se déroule une séance, ce que l'école garde,
  les deux formules (Offre découverte, gratuite, cinq parties ;
  IqraQuest École, 89 € par an, deux sessions simultanées) et la FAQ.
- **`/account`** — « Mon espace » : ce qu'on trouve derrière la porte, et
  le bouton qui ouvre la console. La page porte l'en-tête et le pied du
  site, pour qu'une école ne découvre pas la console par un lien nu vers
  un autre domaine.

Deux variables de dépôt gouvernent ces pages, dans
*Settings → Secrets and variables → Actions → Variables* du dépôt
`UPASCO/iqraquest-website` :

| variable | effet | valeur aujourd'hui |
|---|---|---|
| `NEXT_PUBLIC_CLASSROOM_AVAILABLE` | la console est joignable | non posée = vraie |
| `NEXT_PUBLIC_CLASSROOM_CHECKOUT` | on peut payer en ligne | non posée = fausse |

La première n'est à poser (`false`) que pour refermer l'accès si le
service tombe. La seconde passe à `true` à l'étape 7.6 : d'ici là, une
école qui a utilisé ses cinq parties lit qu'on lui répond par courrier,
ce qui est vrai.

---

## Ce qui peut mal se passer, et ce que ça veut dire

| symptôme | cause la plus probable |
|---|---|
| L'app dit « aucune classe joignable » | build faite sans les deux `--dart-define` (étape 5) |
| Le lien de connexion n'arrive jamais | quota d'e-mails Supabase atteint → configurer un SMTP (étape 2). La connexion par mot de passe, elle, n'en dépend pas |
| « Adresse ou mot de passe incorrect » sur un compte qui existe | « Auto Confirm User » n'était pas coché à la création : le compte existe mais son adresse n'est pas confirmée |
| Le lien arrive mais la console reste déconnectée | `Redirect URLs` ne contient pas `teacher-callback.html` (étape 2) |
| « Confirmez votre adresse » mais rien n'arrive | (a) l'adresse avait déjà un compte — Supabase ne renvoie alors rien, et la console dit désormais « Cette adresse a déjà un compte » ; (b) courrier intégré bridé aux membres de l'organisation et à quelques envois par heure → SMTP (étape 2). En attendant, confirmer ou créer le compte à la main dans Authentication → Users |
| Payé, mais la console reste sur « Offre découverte » | le webhook n'a pas atteint la fonction : Stripe → Webhooks → l'endpoint → Events (secret du mauvais mode = 400) ; rejouer l'événement |
| « S'abonner » dit que le paiement est indisponible | fonction `create-school-checkout` non déployée, ou un secret `STRIPE_*` manquant, ou prix live sous 50 € (étape 7) |
| « Paiement en échec » alors que la carte est bonne | `invoice.payment_failed` reçu, puis pas d'`invoice.paid` : vérifier l'endpoint (7.4) et rejouer ; la console redemande son compte au bouton Actualiser |
| « Deux appareils sont déjà en séance » alors qu'un seul joue | un onglet fermé sans terminer la séance garde sa place cinq minutes ; Mon espace → Appareils → Libérer |
| « Vos cinq parties sont utilisées » sur un compte qui a payé | `licences.status` n'est pas `active` : voir la ligne précédente |
| « Votre abonnement est terminé » alors qu'il court | l'horloge du serveur fait foi, pas celle du navigateur : vérifier `expires_at` dans `licences` |
| Le tableau reste sur « code inconnu » | la séance a été fermée, ou le code appartient à un autre projet Supabase |
| `school.iqraquest.org` renvoie un 404 GitHub | domaine personnalisé non renseigné dans Pages (étape 4) |

## Ce que ce montage coûte

Le palier gratuit de Supabase tient environ six classes simultanées. À
25 $ par mois, une quinzaine. GitHub Pages est gratuit. Stripe prélève sa
commission sur les licences vendues, et rien d'autre.
