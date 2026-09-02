# IqraQuest — Asset Inventory

Every visual and font asset shipped in this repository, per spec §119.
IqraQuest ships **no raster image files** for its core visual identity —
the horse, board, horseshoe gaits, and landmark art are all original
vector code
(`CustomPainter`), which scales losslessly and keeps the binary small.
This table will grow if raster assets (app icon PNGs, store screenshots)
are added during Store submission — see STORE_RELEASE_CHECKLIST.md.

| Asset | Type | Usage | Source / Original | Licence | Localized? |
|---|---|---|---|---|---|
| `HorsePainter` | Vector (Dart `CustomPainter`) | Board horse tokens, hero art, results screen | Original, drawn for IqraQuest | Proprietary (project) | No (script-neutral) |
| `BoardWidget` / `BoardLayout` | Vector | Game board | Original | Proprietary (project) | No |
| `HorseshoePainter` (`gait_selector.dart`) | Vector | The six gait choices | Original | Proprietary (project) | No |
| `HijazLandmarkPainter` | Vector | Home/onboarding backdrops, board zone corners | Original (see VISUAL_REFERENCE_NOTES.md) | Proprietary (project) | No |
| `GeometricMotifPainter` | Vector (procedural 8-point star lattice) | Card/screen texture | Original, procedurally generated (not traced) | Proprietary (project) | No |
| `NotoSans-Regular.ttf` | Font (variable, static instance used) | Latin-script UI (fr/en/es/pt/de/tr/id/ms/it/nl) | Google Fonts | SIL Open Font License 1.1 | N/A |
| `NotoSansArabic-Regular.ttf` | Font (variable) | Reserved for future use / fallback | Google Fonts | SIL Open Font License 1.1 | N/A |
| `NotoNaskhArabic-Regular.ttf` | Font | Arabic-script UI (ar, ur) | Google Fonts | SIL Open Font License 1.1 | N/A |
| App launcher icon (`android/app/src/main/res/mipmap-*`, `ios/Runner/Assets.xcassets`, `web/icons`) | Raster (PNG), baked from original code | OS home screen | Original — baked by `tool/art/bake_app_icon.py` (a golden horse at full gallop racing up a petits-chevaux track of tiles in the four stable colours toward a radiant fan of question cards, a crescent above, on emerald; regenerate with that script, which writes the iOS set without an alpha channel) | Proprietary (project) | No |

## App icon

The launcher icon is an original emblem, the game in one glance: a
golden horse at full gallop racing up a petits-chevaux track — square
tiles in the four stable colours — toward a radiant fan of question
cards, a crescent in the sky above: the race for Islamic knowledge, won
by answering, on an emerald ground. No depiction of any person, no
Kaaba-as-object, no text (the question mark is a glyph, not a word;
spec §23 + religious constraints). It is
generated, never hand-edited: change `tool/art/bake_app_icon.py` and
re-run it; it writes every Android, iOS and web size, the iOS set
without an alpha channel (App Store icons must not carry one). A 1024px
review copy and a home-screen size sheet land in `build/screenshots/`.
A final on-device review pass before Store submission is still
recommended, as for any icon.
