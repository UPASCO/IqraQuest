# IqraQuest — Asset licences (spec §30)

Every asset shipped in this repository, with its origin and licence.
Policy: **no asset enters the app without a row here.** Anything not
listed is not shipped.

## Visuals

All core visuals are **original vector code** written for IqraQuest —
Dart `CustomPainter`s, not imported or traced artwork. They are covered
by the project's own licence and require no third-party attribution.

| Asset | File | Origin | Licence |
|---|---|---|---|
| Horse (4 coats × 4 poses) | `lib/widgets/horse_painter.dart` | Original | Project |
| Game board & circuits | `lib/widgets/board/` | Original | Project |
| Gait selector horseshoes | `lib/widgets/gait_selector.dart` | Original | Project |
| Hijaz landmark backdrops | `lib/widgets/landmarks/hijaz_landmark_painter.dart` | Original (see `VISUAL_REFERENCE_NOTES.md`) | Project |
| Geometric star lattice | `lib/widgets/geometric_motif_painter.dart` | Original, procedurally generated | Project |
| App launcher icon (all Android/iOS/web sizes) | Rendered by `tool/app_icon_renderer_test.dart` | Original | Project |

The historical-inspiration research behind the Makkah/Madinah/horse
treatment is documented in `VISUAL_REFERENCE_NOTES.md`; nothing was
copied, traced, or generated from photographs.

### Bitmap illustrations (`assets/images/`)

Painterly concept art supplied by the project owner (AI-generated
reference art commissioned for IqraQuest), cropped and re-encoded for
in-app use by `lib/widgets/illustration.dart` consumers. As
AI-generated imagery it carries no third-party copyright claim, but
store-listing diligence should note its origin. No human figures, no
depictions of Allah, prophets, or angels, and no Kaaba imagery appear
in any crop.

| Asset | File | Origin | Licence |
|---|---|---|---|
| Dawn-over-Hijaz region card | `assets/images/region_dawn.webp` | Owner-supplied AI concept art (crop) | Project |
| Verdant-oasis region card | `assets/images/region_oasis.webp` | Owner-supplied AI concept art (crop) | Project |
| Madinah-mountains region card | `assets/images/region_mountains.webp` | Owner-supplied AI concept art (crop) | Project |
| Glowing reward chest | `assets/images/chest_glow.webp` | Owner-supplied AI concept art (crop) | Project |
| Oasis waterfall vignette | `assets/images/oasis_falls.webp` | Owner-supplied AI concept art (crop) | Project |
| Arrival at the palace oasis | `assets/images/oasis_arrival.webp` | Owner-supplied AI concept art (crop) | Project |
| 2.5D world band (mode selection hero) | `assets/images/world_band.webp` | Owner-supplied AI concept art (crop) | Project |

## Fonts

| Font | Files | Origin | Licence |
|---|---|---|---|
| Noto Sans | `assets/fonts/NotoSans-Regular.ttf` | Google Fonts | SIL Open Font License 1.1 |
| Noto Sans Arabic | `assets/fonts/NotoSansArabic-Regular.ttf` | Google Fonts | SIL Open Font License 1.1 |
| Noto Naskh Arabic | `assets/fonts/NotoNaskhArabic-Regular.ttf` | Google Fonts | SIL Open Font License 1.1 |

The OFL licence text ships in `THIRD_PARTY_NOTICES.md`.

## Audio

**None shipped yet.** The sound design pass (spec §26–§27) is still
open. When audio lands, every file gets a row here with its exact
origin and licence *before* it is committed, honouring the spec's
prohibitions: no Quranic recitation as a game effect, no adhan as a
notification sound, no casino-style win sounds.

## Question content

The question bank's sourcing is governed separately and more strictly —
see `CONTENT_SOURCE_POLICY.md` and `content_quality/`.
