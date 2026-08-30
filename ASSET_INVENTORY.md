# IqraQuest — Asset Inventory

Every visual and font asset shipped in this repository, per spec §119.
IqraQuest ships **no raster image files** for its core visual identity —
the horse, board, dice, and landmark art are all original vector code
(`CustomPainter`), which scales losslessly and keeps the binary small.
This table will grow if raster assets (app icon PNGs, store screenshots)
are added during Store submission — see STORE_RELEASE_CHECKLIST.md.

| Asset | Type | Usage | Source / Original | Licence | Localized? |
|---|---|---|---|---|---|
| `HorsePainter` | Vector (Dart `CustomPainter`) | Board pawns, hero art, results screen | Original, drawn for IqraQuest | Proprietary (project) | No (script-neutral) |
| `BoardWidget` / `BoardLayout` | Vector | Game board | Original | Proprietary (project) | No |
| `DicePainter` | Vector | Dice roll UI | Original | Proprietary (project) | No |
| `HijazLandmarkPainter` | Vector | Home/onboarding backdrops, board zone corners | Original (see VISUAL_REFERENCE_NOTES.md) | Proprietary (project) | No |
| `GeometricMotifPainter` | Vector (procedural 8-point star lattice) | Card/screen texture | Original, procedurally generated (not traced) | Proprietary (project) | No |
| `NotoSans-Regular.ttf` | Font (variable, static instance used) | Latin-script UI (fr/en/es/pt/de/tr/id/ms/it/nl) | Google Fonts | SIL Open Font License 1.1 | N/A |
| `NotoSansArabic-Regular.ttf` | Font (variable) | Reserved for future use / fallback | Google Fonts | SIL Open Font License 1.1 | N/A |
| `NotoNaskhArabic-Regular.ttf` | Font | Arabic-script UI (ar, ur) | Google Fonts | SIL Open Font License 1.1 | N/A |
| App launcher icon (`android/app/src/main/res/mipmap-*`, `ios/Runner/Assets.xcassets`) | Raster (PNG) | OS home screen | **Placeholder from `flutter create`** — not final; see below | N/A | No |

## Known gap: final app icon

The launcher icon currently on disk is the default Flutter template icon
created by `flutter create`. A distinctive IqraQuest icon (spec §23 —
"horse profile + path/compass/star" concept, no Kaaba, no generic
crescent/mosque, works at small size and square-with-rounded-corners) has
**not** been finalized as exported PNG/ICO assets in this pass. The
in-app horse identity (`HorsePainter`) is ready to be adapted into an
icon; producing the required per-platform raster exports (iOS icon set,
Android adaptive icon foreground/background, Play Store 512×512, App
Store 1024×1024) is tracked in STORE_RELEASE_CHECKLIST.md as outstanding
work before submission.

## Question bank data

Not a visual asset, but inventoried for completeness: `assets/data/
questions/{master,fr,en,ar}/questions.json` are generated JSON data files
— see CONTENT_SOURCE_POLICY.md §9 for their generation pipeline and
`content_quality/` for their source registry.
