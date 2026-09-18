# Les testeurs obligatoires de Google Play

Google impose aux **comptes développeur personnels créés après le
13 novembre 2023** un test fermé avant toute publication en production :
au moins **12 testeurs** inscrits, qui gardent l'app installée pendant
**14 jours consécutifs**, puis un questionnaire pour obtenir l'accès à
la production. Un compte d'**organisation** n'y est pas soumis. Apple
n'a rien d'équivalent : TestFlight est facultatif.

Deux points à savoir avant de chercher des testeurs :

- Il faut de **vraies personnes**, avec un vrai compte Google, sur un
  vrai téléphone Android, qui installent l'app depuis Play et
  l'ouvrent pendant les deux semaines. Google compte les inscriptions
  et l'activité ; des comptes créés pour l'occasion ou des testeurs
  qui n'ouvrent jamais l'app conduisent à un refus de l'accès à la
  production, et des comptes factices exposent le compte développeur
  à une suspension. Aucun automate ne peut tenir ce rôle.
- Le test fermé se lance dès maintenant, en parallèle de tout le reste :
  les 14 jours courent à partir du moment où les 12 testeurs sont
  inscrits, pas à partir de la fin de la fiche du store.

## Option 1 — un compte d'organisation (pas de testeurs requis)

Si tu publies au nom d'une structure (auto-entreprise, association,
société), crée le compte développeur comme **organisation** : il faut
un numéro **D-U-N-S** (gratuit, délivré par Dun & Bradstreet en quelques
jours : <https://www.dnb.com/duns.html>), un site avec un e-mail au
même domaine (`support@iqraquest.org` convient), et la vérification de
l'identité du responsable. Un compte personnel déjà ouvert ne se
convertit pas : c'est un second compte (25 $), et l'app se crée dans
celui-là. C'est la voie la plus rapide si aucun testeur n'est à portée.

## Option 2 — réunir 12 à 15 testeurs

Vise **15** pour garder de la marge : Google ne compte que ceux qui se
sont bien inscrits *et* ont installé l'app.

**Où les trouver**

- Famille et amis avec un Android : le plus sûr, et ce sont les vrais
  joueurs du jeu.
- Une école, une mosquée, un groupe WhatsApp de parents : un message et
  le lien suffisent (modèle ci-dessous).
- Les communautés d'entraide entre développeurs, où chacun teste l'app
  des autres : les subreddits *r/AndroidClosedTesting* et
  *r/TestMyApp*, et les groupes « closed testing » sur Discord et
  Telegram. Ce sont des personnes réelles ; en échange tu installes
  leurs apps.

**Dans la Play Console**

1. *Tests* → *Tests fermés* → *Créer une piste* (nom : « Bêta »).
2. *Testeurs* → **Créer une liste par e-mail** avec les adresses Gmail
   des testeurs, ou — plus simple pour en ajouter au fil de l'eau —
   un **groupe Google** (<https://groups.google.com>, groupe
   `iqraquest-beta`) que tu renseignes à la place : toute personne qui
   rejoint le groupe devient testeur.
3. Envoie le bundle (`PLAY_SETUP.md` §3 et §6) sur cette piste,
   *Démarrer le déploiement*.
4. Copie le **lien d'inscription** (« Copier le lien ») et envoie-le
   aux testeurs. Chacun doit : ouvrir le lien avec son compte Google,
   accepter de devenir testeur, puis installer l'app depuis Play par le
   lien « Télécharger sur Google Play » de la même page. Le Mode
   testeur n'a rien à voir avec ceci : la piste reçoit le build store.
5. Après 14 jours avec 12 testeurs inscrits en continu : *Tableau de
   bord* → **Demander l'accès à la production** → questionnaire (comment
   les testeurs ont été recrutés, ce qu'ils ont remonté, ce que tu as
   corrigé). Réponds concrètement ; la réponse arrive en quelques jours.

**Message à envoyer aux testeurs**

> Bonjour ! J'ai besoin de toi pour tester IqraQuest, un jeu de plateau
> familial (petits chevaux + questions sur l'Islam) avant sa sortie sur
> Google Play. Ça prend deux minutes :
> 1. Ouvre ce lien avec ton compte Google sur ton téléphone Android :
>    <LIEN D'INSCRIPTION>
> 2. Appuie sur « Devenir testeur », puis sur « Télécharger sur Google
>    Play » et installe le jeu.
> 3. Garde-le installé deux semaines et fais une partie de temps en
>    temps (une partie dure cinq minutes). Google exige que les
>    testeurs restent inscrits 14 jours.
> Si quelque chose te semble bizarre ou faux dans une question, écris-moi
> ou réponds à ce message. Merci !

**Ce que les testeurs voient** : le build store, gratuit avec ses 50
cartes et sa limite de 50 pioches. Pour qu'ils puissent acheter le
Premium sans être débités, ajoute leurs adresses dans *Paramètres →
Test de licence* (`PLAY_SETUP.md` §6) ; ce n'est pas nécessaire pour le
test fermé.

## Pendant les 14 jours

- Vérifie dans *Tests fermés → Testeurs* que le compteur d'inscrits
  reste ≥ 12 ; relance ceux qui n'ont pas installé.
- Note les retours (questions signalées, bugs) : le questionnaire de
  Google demande ce qui a été corrigé. Un nouveau bundle sur la même
  piste ne remet pas le compteur de jours à zéro.
- Termine en parallèle la fiche, les déclarations et le produit à
  8,99 € (`PLAY_SETUP.md` §4 et §5) : le jour où l'accès à la
  production est accordé, il ne reste qu'à promouvoir la version.
