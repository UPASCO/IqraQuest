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

### Playable board scene (`assets/board/`)

The live game board is the owner's own board illustration (supplied
AI-generated concept art commissioned for IqraQuest), surgically cleaned
and extended by `tool/art/board_from_ref.py`; the four knight pieces are
extracted from the same illustration (one sculpt, recoloured per team).
Same origin and diligence notes as the bitmap illustrations above: no
human figures, no depictions of Allah, prophets, or angels, no Kaaba.

| Asset | File | Origin | Licence |
|---|---|---|---|
| Oasis-route board scene (941x2080) | `assets/board/scene_oasis.webp` | Owner-supplied AI board illustration, cleaned/extended in-repo | Project |
| Knight piece, emerald | `assets/board/horses/horse_emerald.webp` | Extracted from the same illustration, matted + disc base drawn in-repo | Project |
| Knight piece, sapphire | `assets/board/horses/horse_saphir.webp` | Recoloured from the emerald sculpt in-repo | Project |
| Knight piece, garnet | `assets/board/horses/horse_grenat.webp` | Recoloured from the emerald sculpt in-repo | Project |
| Knight piece, saffron | `assets/board/horses/horse_safran.webp` | Recoloured from the emerald sculpt in-repo | Project |

`assets/board/pack/` holds build-time sprite intermediates from the same
owner-supplied pack; they are not declared in `pubspec.yaml` and do not
ship in the app binary.

### 3D pipeline inputs (`assets_3d/` — build-time only, not shipped in the app)

Used by the Blender render pipeline (`tool/art3d/`) to bake the board
scene and sprites; the app ships only the rendered images.

| Asset | File | Origin | Licence |
|---|---|---|---|
| Venice sunset HDRI | `assets_3d/hdri/venice_sunset_1k.hdr` | Poly Haven (via three.js repo) | CC0 |
| Blouberg sunrise HDRI | `assets_3d/hdri/blouberg_sunrise_1k.hdr` | Poly Haven (via three.js repo) | CC0 |
| Wood PBR set (diffuse/bump/roughness) | `assets_3d/textures/wood_*.jpg` | three.js examples | MIT (three.js repo) |
| Water normals | `assets_3d/textures/waternormals.jpg` | three.js examples | MIT (three.js repo) |
| Brick diffuse/bump | `assets_3d/textures/brick_*.jpg` | three.js examples | MIT (three.js repo) |
| Sand, rock (+normal), grass, wood2, waterbump | `assets_3d/textures/*.{jpg,png}` | BabylonJS/Assets | Apache-2.0 |

## Fonts

| Font | Files | Origin | Licence |
|---|---|---|---|
| Noto Sans | `assets/fonts/NotoSans-Regular.ttf` | Google Fonts | SIL Open Font License 1.1 |
| Noto Sans Arabic | `assets/fonts/NotoSansArabic-Regular.ttf` | Google Fonts | SIL Open Font License 1.1 |
| Noto Naskh Arabic | `assets/fonts/NotoNaskhArabic-Regular.ttf` | Google Fonts | SIL Open Font License 1.1 |

The OFL licence text ships in `THIRD_PARTY_NOTICES.md`.

## Audio

All shipped sounds are **synthesized from scratch** by
`tool/audio/gen_sfx.py` (pure sine/noise synthesis, NumPy + the Python
`wave` module — no third-party samples, no recordings). They are
original works of this project and carry the project's licence.

| File | Cue | Origin | Licence |
|---|---|---|---|
| `assets/audio/tap.wav` | UI tap | synthesized in-repo | project |
| `assets/audio/gait_select.wav` | gait armed | synthesized in-repo | project |
| `assets/audio/gait_confirm.wav` | gait committed | synthesized in-repo | project |
| `assets/audio/move_hoofs.wav` | horse moves | synthesized in-repo | project |
| `assets/audio/correct.wav` | right answer | synthesized in-repo | project |
| `assets/audio/wrong.wav` | wrong answer (gentle) | synthesized in-repo | project |
| `assets/audio/chest.wav` | cell offer appears | synthesized in-repo | project |
| `assets/audio/streak.wav` | streak reward unlocked | synthesized in-repo | project |
| `assets/audio/water.wav` | oasis arrival | synthesized in-repo | project |
| `assets/audio/victory.wav` | game won (short warm flourish) | synthesized in-repo | project |

Spec prohibitions honoured by construction: **no Quranic recitation** as
a game effect, **no adhan** as a notification sound, and **no
casino-style win sounds** (the victory cue is a short warm instrumental
arpeggio, no coin cascades or slot bells).

## Question content

The question bank's sourcing is governed separately and more strictly —
see `CONTENT_SOURCE_POLICY.md` and `content_quality/`.
