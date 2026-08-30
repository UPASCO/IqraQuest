# IqraQuest — Visual Reference Notes

Design-research notes behind every historically-inspired visual element,
per spec §94. This is **not** a claim of archaeological accuracy — see
each entry's "established / interpretation" split. Nothing here was
copied from a reference image; references were used only to understand
period-appropriate forms, materials, and proportions, then redrawn from
scratch as original vector art (`lib/widgets/`).

> **Framing used throughout the app:** "an artistic universe inspired by
> the Hijaz of the early Islamic era" — never "an exact historical
> reconstruction." See DESIGN_SYSTEM.md §10 and CONTENT_SOURCE_POLICY.md
> for the parallel discipline applied to written content.

## Makkah

- **Established:** a rocky valley setting; the Kaaba as a cuboid
  structure at its center; an arid, mineral landscape; low, simple
  masonry construction predating modern urban development.
- **Interpretation:** exact stone coloring, precise valley topology, and
  surrounding building density are stylized for board/screen legibility.
- **Implementation:** `HijazLandmarkPainter` (`lib/widgets/landmarks/`)
  renders the Kaaba as a small, deliberately abstract dark cuboid
  silhouette with a single quiet gold band — never large, never a game
  object, never interactive (spec §8–§9). No contemporary Makkah imagery
  (Abraj Al Bait, modern towers, modern lighting, asphalt, crowds) is
  depicted anywhere in the app.

## Madinah

- **Established:** an oasis identity — date palms, low earthen/mud-brick
  architecture, courtyards, a markedly greener environment than Makkah's
  surrounding desert.
- **Interpretation:** exact building layout and palm density are
  stylized.
- **Deliberate omission:** the app does **not** attempt to depict the
  first mosque of Madinah at all, in any era-specific form. Spec §11
  flags this as the highest anachronism-risk element (a VIIth-century
  structure easily conflated with the contemporary Masjid an-Nabawi's
  green dome and modern minarets). Rather than assert unestablished
  architectural detail, `HijazLandmarkPainter`'s `madinahOasis` scene
  renders only palms, low generic dwellings, and warm shade — the oasis
  identity without the mosque.

## Architecture (general)

- **Established:** sobriety — stone, sun-dried earth/mud-brick, wood,
  palm-fiber elements; flat or simple roof lines; small window openings
  suited to a hot climate.
- **Interpretation:** specific ornamentation is generic/abstracted, never
  presented as a copy of any documented building.
- Anachronisms explicitly avoided everywhere (spec §95): no modern
  buildings, vehicles, electric lighting, Ottoman-era domes/minarets
  presented as VIIth-century, modern textiles, paved roads, signage.

## The Arabian horse (`lib/widgets/horse_painter.dart`)

- **Established (breed characteristics, not a VIIth-century specific
  animal):** a refined, "dished" head profile; large, expressive eyes;
  an arched neck; a naturally high tail carriage; fine but sturdy legs;
  overall silhouette read as elegant/energetic rather than heavy/draft.
- **Interpretation:** `HorsePainter` is an original stylized vector
  illustration built from these characteristics — it is not a copy of
  any specific photograph, breed-standard diagram, or existing game's
  horse asset. See DESIGN_SYSTEM.md §"Non-negotiables" for the explicit
  exclusion list (no racing/jockey/betting aesthetic, no cartoon/toy
  treatment, no anthropomorphism).

## Saddle cloths / team markers

- **Established:** simple woven/felted saddle-cloth forms existed
  broadly across the region and era in various materials.
- **Interpretation:** the specific geometric team-symbol appliqués (star,
  compass, lantern, book — `lib/theme/app_team.dart`) are IqraQuest's own
  invented identity system for colorblind-safe team recognition (spec
  §4), not a claim that these specific emblems are historical.

## Palms, wells, low walls, lanterns, tents

- **Established:** these are standard, well-documented elements of
  Hijazi oasis and desert-travel life across the relevant period.
- **Interpretation:** used sparingly as landscape texture (spec §16: "do
  not overload the board with 20 monuments"), never as named/labelled
  "real" sites.

## People

IqraQuest's decor contains **no human figures at all** — not even
generic, faceless, or distant silhouettes. This is a deliberate
simplification beyond what spec §12–§13 strictly requires (which permits
distant/anonymous generic figures): removing human figures entirely
removes any risk of a decor figure being read as a companion or
historical personage, at zero cost to the travel/oasis/valley visual
narrative the landscape already carries on its own.
