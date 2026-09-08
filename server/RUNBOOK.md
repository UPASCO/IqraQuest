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

Vérification : dans **Table Editor**, cinq tables existent (`licences`,
`sessions`, `participants`, `answers`, `reports`), toutes avec RLS
activé et **aucune politique** — c'est normal, et c'est la protection :
la clé publique ne lit rien, tout passe par les fonctions.

Puis, depuis votre machine, la vérification qui compte vraiment — celle
qui regarde le socle de l'extérieur, avec la clé publique, comme le
ferait n'importe qui :

```bash
SUPABASE_URL=https://xxxx.supabase.co \
SUPABASE_ANON_KEY=sb_publishable_... \
bash server/smoke-test.sh
```

Il vérifie que les cinq tables ne rendent rien, qu'un code inconnu ne
raconte rien, et que les quatre fonctions de l'enseignant sont hors de
portée. Un échec sur les deux premiers points signifierait que des
données d'élèves sont lisibles : ne pas ouvrir de classe avant de
l'avoir corrigé.

## 2. L'authentification de l'enseignant — 10 minutes

Dans **Authentication → URL Configuration** :

| champ | valeur |
|---|---|
| Site URL | `https://school.iqraquest.org` |
| Redirect URLs | `https://school.iqraquest.org/teacher-callback.html` |

Sans cette seconde ligne, le lien de connexion arrive mais refuse de
revenir sur la console.

**Le courrier.** Le service d'e-mail intégré de Supabase est bridé à
quelques envois par heure : suffisant pour tester, pas pour une rentrée.
Dès qu'il y a plus d'un enseignant, configurer un SMTP dans
**Authentication → Emails** (Resend, Brevo, Postmark…). C'est la panne
la plus probable le jour où ça compte, et elle est silencieuse : le lien
n'arrive jamais.

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
| `STRIPE_CHECKOUT_URL` | le lien de paiement (étape 6 ; laisser vide pour l'instant) | la console |

Puis **Actions → Web — classroom console & board → Run workflow**.

Au bout de quelques minutes : `https://school.iqraquest.org/#/teacher`
répond.

> Les deux premiers secrets servent aussi aux builds mobiles. Une build
> TestFlight ou APK faite **avant** qu'ils existent parle à une salle
> vide : refaire la build après les avoir posés.

## 6. Une première séance, sans attendre Stripe — 10 minutes

Une licence peut s'écrire à la main. C'est le moyen le plus rapide de
voir le mode Classe tourner pour de vrai, et c'est aussi ce qu'on fera
pour une école en essai.

Dans le **SQL Editor** :

```sql
insert into public.licences (email, plan, concurrent_sessions, expires_at)
values ('votre.adresse@example.org', 'essai', 1, now() + interval '90 days');
```

Ensuite, dans l'ordre :

1. Ouvrir `https://school.iqraquest.org/#/teacher`, entrer **cette même
   adresse**, demander le lien.
2. Ouvrir le lien reçu **sur le même appareil**. La console affiche
   « Licence valable jusqu'au… » : la ligne vient d'être rattachée au
   compte créé par le lien.
3. Choisir un thème, un niveau, une leçon. Régler le comptage (équipes
   ou individuel), le chronomètre, la longueur. **Ouvrir la séance.**
4. Un code à six caractères s'affiche. Cliquer **Ouvrir le tableau** :
   la page à projeter s'ouvre dans un second onglet, avec le code en
   grand et un QR code.
5. Sur un téléphone : ouvrir IqraQuest → **Classe**, taper le code et un
   prénom. (Ou scanner le QR : le code est alors déjà rempli. Ou, sans
   installer l'app, ouvrir `https://school.iqraquest.org/#/classroom`.)
6. Le prénom apparaît sur le tableau. Depuis la console : **Question
   suivante** → la carte s'affiche partout ; répondre sur le téléphone →
   le compteur du tableau passe à 1 ; **Montrer la réponse** → la bonne
   s'allume, la source apparaît, le cheval avance.
7. **Terminer la séance** : les prénoms sont effacés, le bilan par
   question est écrit dans `reports`.

Si l'étape 6 marche, le mode Classe est opérationnel.

## 7. Stripe — 30 minutes

Le compte existant convient (il est déjà vérifié, avec son compte
bancaire). Il faut seulement de quoi vendre une licence de classe, ce
qui n'existe pas encore : le lien IqraTime est un don à montant libre,
sans abonnement ni webhook.

1. **Produit** : « Licence Classe IqraQuest », prix annuel.
2. **Lien de paiement** (Payment Link) sur ce produit, avec **deux
   métadonnées posées sur le lien** — ce sont celles du lien que Stripe
   recopie sur la session de paiement, donc les seules que la fonction
   reçoit :

   | clé | valeur |
   |---|---|
   | `iqraquest_plan` | `classe` ou `ecole` |
   | `iqraquest_rooms` | nombre de salles simultanées (1 à 100) |

3. **La fonction webhook** :

   ```bash
   supabase functions deploy stripe-webhook --no-verify-jwt
   supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...
   ```

4. **Webhook Stripe** vers l'URL de la fonction, abonné à
   `checkout.session.completed`, `customer.subscription.updated` et
   `customer.subscription.deleted`.
5. Poser le lien de paiement dans le secret `STRIPE_CHECKOUT_URL` et
   relancer le workflow web.

Test : payer une fois en **mode test** de Stripe, puis vérifier qu'une
ligne est apparue dans `licences` avec le bon `concurrent_sessions`.

## 8. Le site vitrine

La page « Écoles » attend sur la branche `claude/schools-page` du dépôt
`UPASCO/iqraquest-website`. Elle se publie en la fusionnant dans `main` :
le déploiement part tout seul.

---

## Ce qui peut mal se passer, et ce que ça veut dire

| symptôme | cause la plus probable |
|---|---|
| L'app dit « aucune classe joignable » | build faite sans les deux `--dart-define` (étape 5) |
| Le lien de connexion n'arrive jamais | quota d'e-mails Supabase atteint → configurer un SMTP (étape 2) |
| Le lien arrive mais la console reste déconnectée | `Redirect URLs` ne contient pas `teacher-callback.html` (étape 2) |
| « Aucune licence » alors que Stripe a été payé | métadonnées posées sur le produit et non sur le lien (étape 7) |
| Le tableau reste sur « code inconnu » | la séance a été fermée, ou le code appartient à un autre projet Supabase |
| `school.iqraquest.org` renvoie un 404 GitHub | domaine personnalisé non renseigné dans Pages (étape 4) |

## Ce que ce montage coûte

Le palier gratuit de Supabase tient environ six classes simultanées. À
25 $ par mois, une quinzaine. GitHub Pages est gratuit. Stripe prélève sa
commission sur les licences vendues, et rien d'autre.
