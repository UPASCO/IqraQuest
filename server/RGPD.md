# Mode Classe — protection des données

Ce que ce document sert : répondre, sans négocier, aux questions qu'un
délégué à la protection des données pose avant de laisser une classe
utiliser un outil. Il est écrit à partir du schéma lui-même
(`supabase/migrations/`), pas d'une intention — chaque affirmation ci-
dessous correspond à une colonne, une fonction ou une planification qu'on
peut aller lire.

Il ne remplace pas un avis juridique. Il donne à un juriste de quoi
travailler en une lecture.

---

## 1. Qui fait quoi

| rôle | qui | pourquoi |
|---|---|---|
| Responsable de traitement | **l'établissement** | c'est lui qui décide de faire jouer sa classe, et qui choisit les prénoms saisis |
| Sous-traitant | **IqraQuest** | il fournit l'outil et n'utilise les données pour rien d'autre |
| Sous-traitants ultérieurs | Supabase (base et authentification), Stripe (paiement des licences), l'hébergeur de courrier transactionnel, GitHub Pages (pages statiques) | listés ici pour qu'un DPO n'ait pas à les deviner |

IqraQuest est également responsable de traitement pour une seule donnée :
l'adresse e-mail de l'enseignant qui achète et ouvre les séances.

## 2. Ce qui est réellement enregistré

Rien d'autre que ceci n'existe dans la base.

| donnée | table | qui la fournit | durée |
|---|---|---|---|
| Prénom de l'élève | `participants.nickname` | l'élève, au moment de rejoindre | effacé à la fermeture de la séance, et au plus tard **2 jours** |
| Équipe | `participants.team` | attribuée automatiquement | idem |
| Jeton de séance | `participants.token` | tiré au hasard par le serveur | idem |
| Réponse (numéro de case, juste/faux) | `answers` | l'élève | idem |
| Code, leçon, langue, rythme | `sessions` | l'enseignant | idem |
| Bilan par question (compteurs) | `reports.per_question` | calculé à la fermeture | **24 mois** |
| Classement nominatif, **si l'enseignant l'a demandé** | `reports.per_pupil` | calculé à la fermeture | prénoms retirés à **90 jours**, ligne effacée à 24 mois |
| Adresse e-mail de l'enseignant | `licences.email` | l'acheteur | durée de la licence |
| Identifiants Stripe de la licence | `licences.stripe_*` | Stripe | idem |
| Domaine de l'établissement, si licence d'école | `licences.domain` | l'acheteur | durée de la licence |

**Ce qui n'existe nulle part** : compte élève, mot de passe élève,
adresse e-mail d'élève, nom de famille, classe, date de naissance,
identifiant d'appareil, adresse IP conservée, cookie de mesure d'audience,
traceur publicitaire, réseau publicitaire.

Les durées ne sont pas déclaratives : elles sont tenues par
`purge_old_sessions`, `strip_old_report_names` et `purge_old_reports`,
planifiées quotidiennement (migrations 0001 et 0003).

## 3. Base légale

- **Élèves** : exécution de la mission d'intérêt public / d'enseignement
  de l'établissement, sous sa responsabilité. Le prénom est saisi par
  l'élève, ne sert qu'à l'affichage pendant la séance, et disparaît avec
  elle. Aucun profilage, aucune décision automatisée, aucun transfert à
  un tiers.
- **Enseignant** : exécution du contrat (la licence).

## 4. Minimisation, par construction plutôt que par discipline

Trois choix techniques font le gros du travail, et ils sont vérifiables :

1. **Le rôle anonyme n'a aucun droit de lecture.** RLS est actif sur les
   cinq tables et aucune politique n'est définie pour `anon` : la clé
   publique embarquée dans l'application ne peut lire aucune ligne. Elle
   n'atteint que quatre fonctions, qui exigent le code de la séance et,
   pour écrire, le jeton de l'élève.
2. **Le tableau projeté ne reçoit pas ce qu'il ne doit pas montrer.** En
   mode équipes, `board_state` renvoie une liste de prénoms **vide** : ce
   n'est pas masqué à l'écran, ça ne sort pas de la base. Le nombre
   d'élèves ayant répondu circule ; jamais qui, jamais quoi.
3. **Fermer une séance efface les élèves.** `close_session` écrit le
   bilan puis supprime la séance ; les participants et leurs réponses
   partent avec elle (`on delete cascade`).

## 5. Localisation et transferts

Le projet est hébergé dans la **région européenne** de Supabase : les
données sont écrites et lues en Europe.

À déclarer honnêtement : Supabase Inc. est une société américaine. Ses
équipes de support peuvent, pour intervenir, accéder à l'infrastructure.
Cela relève du chapitre V du RGPD et se couvre par l'accord de
sous-traitance (DPA) et les clauses contractuelles types que Supabase
publie — **à signer avant la première classe**, pas après.

Pour un établissement public dont la doctrine exclut tout prestataire de
droit américain, la même base se réinstalle telle quelle chez un
hébergeur européen : les trois migrations sont du PostgreSQL standard et
ne dépendent d'aucune extension propriétaire. C'est le seul changement à
faire, et il ne touche pas à l'application.

## 6. Hors d'Europe

Rien n'empêche une école américaine, du Golfe ou d'ailleurs d'utiliser un
service hébergé en Europe, et l'inverse serait plus difficile à défendre :
le RGPD est le régime le plus exigeant, s'y conformer satisfait
généralement les autres.

- **États-Unis** : FERPA et COPPA portent sur ce qui est collecté,
  divulgué et consenti, pas sur le lieu d'hébergement. Un prénom effacé
  en deux jours, sans compte ni publicité, est à peu près le minimum
  imaginable. Certaines académies (districts) imposent contractuellement
  un hébergement national : c'est le cas où l'on ouvre un second projet
  régional, ce que l'architecture permet sans réécriture.
- **Golfe** : les lois saoudienne (PDPL) et émirienne autorisent les
  transferts vers des pays offrant une protection adéquate ou assortis de
  garanties ; l'Union européenne est du bon côté de cette ligne. Un
  marché public ministériel peut néanmoins exiger un hébergement local —
  même réponse que ci-dessus.

## 7. Droits des personnes

- **Effacement** : obtenu par construction pour les élèves (deux jours au
  plus, sans démarche). Sur demande d'un établissement, une séance ou un
  rapport se supprime immédiatement.
- **Accès, rectification** : l'enseignant voit dans sa console tout ce
  que l'établissement conserve. Il n'y a rien d'autre.
- **Opposition au classement nominatif** : le mode par équipes est le
  mode par défaut, et il ne fait sortir aucun prénom de la base.

## 8. Sécurité

Chiffrement en transit (HTTPS partout) et au repos (chiffrement du
disque par l'hébergeur). Aucune clé secrète dans l'application : la clé
publiée ne peut appeler que les quatre fonctions de séance. La clé
`service_role`, seule à contourner RLS, ne réside que dans les secrets de
la fonction Stripe. Les paiements n'entrent jamais dans l'application :
ils se font sur une page hébergée par Stripe.

## 9. Ce qui reste à faire avant la première école

- [ ] Signer le DPA de Supabase et archiver les clauses contractuelles types
- [ ] Signer le DPA de Stripe (déjà fourni pour tout compte)
- [ ] Choisir le prestataire d'e-mail transactionnel et signer le sien
- [ ] Préparer un contrat de sous-traitance à remettre aux établissements
      (ce document en est la matière)
- [ ] Tenir le registre des traitements (article 30) — une page
- [ ] Ajouter une section « mode Classe » à la politique de
      confidentialité publiée sur le site
