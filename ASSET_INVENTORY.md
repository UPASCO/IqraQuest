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
| App launcher icon (`android/app/src/main/res/mipmap-*`, `ios/Runner/Assets.xcassets`, `web/icons`) | Raster (PNG), rendered from original vector code | OS home screen | Original — rendered by `tool/app_icon_renderer_test.dart` (arabian horse head under a gold mihrab arch, with a crescent and an eight-point star burst; regenerate with that tool, then `python3 tool/strip_icon_alpha.py` for iOS) | Proprietary (project) | No |

## App icon

The launcher icon is now an original IqraQuest design: an ivory arabian
horse head with a gold mane, framed by a gold mihrab arch with a
crescent in its sky and an eight-point star burst behind the head — no depiction of any person, no Kaaba-as-object, no
text (spec §23 + religious constraints). It is generated, never
hand-edited: change `AppIconPainter` in
`tool/app_icon_renderer_test.dart`, re-run it, then run
`tool/strip_icon_alpha.py` (App Store icons must not carry an alpha
channel). A 1024px review copy lands in
`build/screenshots/app_icon_1024.png`. A final on-device review pass
before Store submission is still recommended, as for any icon.
