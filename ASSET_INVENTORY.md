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
| App launcher icon (`android/app/src/main/res/mipmap-*`, `ios/Runner/Assets.xcassets`, `web/icons`) | Raster (PNG), baked from `tool/art/source/app_icon_source.webp` | OS home screen | Owner-supplied artwork (three horses racing across the board's tiles toward an open book with a glowing question mark, crescent and star above, gold frame); prepared and resized by `tool/art/bake_app_icon.py`, which blends the source's black corners to the frame's green and writes the iOS set without an alpha channel | Proprietary (project) | No |

## App icon

The launcher icon is artwork supplied by the project owner, kept as
the single source `tool/art/source/app_icon_source.webp`: three horses
racing across the board's coloured tiles toward an open book with a
glowing question mark, a crescent and star in the sky, inside a gold
frame on deep green — the game in one glance. No depiction of any
person, no Kaaba-as-object, no text (the question mark is a glyph, not a
word; spec §23 + religious constraints). The platform PNGs are never
hand-edited: `tool/art/bake_app_icon.py` blends the source's black
corners to the frame's green (so no dark wedge shows under the iOS
squircle or an Android circle), crops a hair of the edge and writes
every Android, iOS and web size, the iOS set without an alpha channel
(App Store icons must not carry one). A 1024px review copy and a
home-screen size sheet land in `build/screenshots/`.
A final on-device review pass before Store submission is still
recommended, as for any icon.
