# COPIL Selligent × Mutuelle Viasanté — 14 septembre 2026

Deck client « prêt à présenter » (19 slides, français), écrit du point de vue du
Customer Success Manager Selligent. Il remplace la v4 générée par ChatGPT, qui
était rédigée comme un mémo interne (« message à porter », « décision attendue »,
« owner suggéré »).

## Contenu

| Fichier | Rôle |
| --- | --- |
| `COPIL_Selligent_Mutuelle_Viasante_14092026_v5.pptx` | Le deck à présenter (notes présentateur incluses, préfixées « NOTE INTERNE »). |
| `COPIL_Selligent_Mutuelle_Viasante_14092026_v5.pdf` | Export PDF sans notes, pour envoi au client après la séance. |
| `build.js` | Générateur pptxgenjs : toutes les données et tous les textes sont dans ce fichier. |
| `logo_teal.png`, `logo_white.png` | Logo Selligent by Zeta utilisé dans le deck. |

## Structure du deck

1. Titre · 2. Ordre du jour · 3. Vue d'ensemble (santé / activité)
4. Intercalaire CDM · 5. SLA Gold · 6. Base de données · 7. Audience unique (Ucount) · 8. Navigation asynchrone (rapidité) · 9. Correctif SSO AdminTool et ConfigTool · 10. Roadmap CDM (frise fin 2026 → Q4 2027)
11. Intercalaire Engage · 12. Selligent by Zeta · 13. Performance email · 14. SMS et RCS · 15. SSO Engage · 16. Pixel d'ouverture et CNIL · 17. Prochaines exigences CNIL · 18. Roadmap Engage (frise aujourd'hui → Q4 2027)
19. Vos arbitrages (cinq questions au client) · 20. Plan d'actions · 21. Contacts

## À confirmer avant la séance

- **SLA** : le deck retient les chiffres du dashboard, soit 7,9 h décomptées sur 50 (16 %) et 36,7 h de temps
  de support. Faire qualifier les 4 tickets « None » (4,35 h, dont le 550647) si le détail est demandé.
- **Redevance base de données** : 6 900 €/an par tranche de 100 GB est affiché sur la slide. Montant à confirmer.
- **Les deux correctifs en cours** : mettre à jour les pastilles « En cours de résolution » sur la navigation asynchrone (redescente du 10/09) et sur le correctif SSO AdminTool / ConfigTool dès que leur statut évolue.
- **Base de données et Ucount** : les dashboards sources sont filtrés sur la SaaS « Viasante » ;
  si ces métriques relèvent d'Engage plutôt que de CDM, déplacer les slides 6 et 7 dans la section Engage.
- **Email** : le rapport est en mode « toutes interactions » (ouvertures bots incluses) ; re-tirer en « hors bots » si possible.
- **SMS** : connaître la raison de la baisse depuis juin 2025 avant de la présenter.
- **RCS** : confirmer que LinkMobility (API) et Infobip sont bien les deux options supportées.
- **CNIL** : connaître le statut réel de Viasanté (consentement collecté, tracking activé) pour la slide 15.
- **Échéances** du plan d'actions : ce sont des propositions à valider en séance.

## Regénérer le deck

```bash
npm install pptxgenjs react react-dom react-icons sharp
node build.js [chemin/de/sortie.pptx]
```

## Sources

- Extract SLA Gold 01/07/2026–30/06/2027 (mise à jour 03/09/2026).
- Dashboards Selligent : Database Sizes (24/08), Compliance Count / Ucount (24/08), Deliverability Client vs Industry (23/08), SMS Deliveries (23/08).
- Deck « CDM Roadmap 2026–2027 » ; session roadmap Selligent by Zeta (juin 2026).
- CNIL, recommandation pixels de suivi (délibération 2026-042 du 12/03/2026, publiée le 14/04/2026) : elle vise l'ouverture et le clic, avec des recommandations complémentaires annoncées sur le clic.
- CNIL, programme de contrôle 2026 : cybersécurité (environ la moitié des contrôles), recrutement et décisions automatisées, répertoire électoral, fédérations sportives.
