# Le mode École, en réserve

Le mode École (console de l'enseignant, tableau projeté, écran « rejoindre
une classe », serveur Supabase, fonctions Stripe) a été retiré du produit
le 16 septembre 2026, sans être supprimé. Tout est conservé :

- **le code**, dans ce dépôt (`lib/features/classroom/`, `server/`, les
  tests `test/features/classroom/`), compilé mais inaccessible ;
- **l'état complet au moment du retrait**, sur la branche
  `archive/school-mode` de ce dépôt et de `UPASCO/iqraquest-website`
  (les pages Écoles et Mon espace du site, leurs textes en douze langues).

## Ce qui a été fermé

| où | comment |
|---|---|
| Application | `kClassroomEnabled = false` dans `lib/app/build_flags.dart` : aucune route `/classroom`, `/teacher`, `/classroom/board`, aucune entrée sur l'étagère d'accueil |
| Builds Android / iOS | plus de `--dart-define=SUPABASE_*` |
| school.iqraquest.org | `.github/workflows/web-school-offline.yml` publie une page qui renvoie vers iqraquest.org |
| Site vitrine | pages Écoles et Mon espace retirées, menus et pied de page nettoyés, politique de confidentialité revenue à « aucun serveur » |

Le projet Supabase et le compte Stripe ne sont pas touchés par le dépôt :
les mettre en pause (ou supprimer le projet Supabase) se fait dans leurs
tableaux de bord.

## Pour rouvrir

1. `kClassroomEnabled = true` ; `flutter test` et
   `dart run tool/pre_release_check.dart` reprennent les contrôles du mode
   École (surfaces d'achat derrière `kIsWeb`, aucun prix dans la console).
2. Restaurer `.github/workflows/web-classroom.yml` depuis
   `archive/school-mode` (`git checkout archive/school-mode -- .github/workflows/web-classroom.yml`)
   et supprimer `web-school-offline.yml`.
3. Remettre les `--dart-define=SUPABASE_URL` / `SUPABASE_ANON_KEY` dans les
   workflows Android et iOS.
4. Sur le site : `git checkout archive/school-mode -- components/pages/index.tsx scripts/gen-routes.mjs lib/seo.ts scripts/verify-export.mjs components/layout config/site.config.ts messages`
   puis `npm run routes`, et relire les textes.
5. Suivre `server/RUNBOOK.md` pour la partie serveur (migrations,
   fonctions, SMTP, Stripe).
