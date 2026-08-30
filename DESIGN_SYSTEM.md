# IqraQuest — Design System

Single source of truth for IqraQuest's visual language. Code must reference
the tokens in `lib/theme/` — no scattered color/spacing literals in feature
code.

## 1. Palette

| Token | Hex | Usage |
|---|---|---|
| Emerald | `#0E6B52` | Primary brand, Team Émeraude |
| Deep Emerald | `#084C3A` | Primary pressed/dark surfaces |
| Midnight Blue | `#14283D` | Night theme surface |
| Deep Night | `#0D1A29` | Night theme background |
| Soft Gold | `#C89B45` | Accent, protected squares, Premium |
| Sand | `#D9BD82` | Secondary accent (night) |
| Warm Cream | `#F7F0DF` | Surface (day) |
| Desert Ivory | `#FFF9ED` | Background (day) |
| Terracotta | `#A86443` | Secondary accent (day) |
| Date Palm | `#497351` | Madinah zone accent |

These raw values live only in `lib/theme/app_colors.dart`. Everywhere else,
code consumes **semantic tokens** from `AppSemanticColors`
(`lib/theme/app_semantic_colors.dart`), reachable as `context.colors`:

```text
primary, primaryDark, secondary, goldAccent,
background, surface, surfaceElevated,
textPrimary, textSecondary,
success, error, warning,
player1, player2, player3, player4,
divider, protectedSquare
```

A day (light) and night (dark) instance of every token exists. Never
hardcode `Colors.black`/`Colors.white` for UI chrome.

## 2. Team identity (colorblind-safe by construction)

A player is never identified by color alone. Every team is a triple:

| Team | Color token | Symbol | Horse coat |
|---|---|---|---|
| Émeraude | `player1` | ★ Star | Gray/white |
| Saphir | `player2` | 🧭 Compass | Bay |
| Grenat | `player3` | 🏮 Lantern | Chestnut |
| Safran | `player4` | 📖 Book | Black |

See `lib/theme/app_team.dart` (`AppTeam`, `TeamSymbol`, `HorseCoat`). Every
player badge, pawn, and board marker renders color + symbol together.

## 3. Typography

- Latin scripts (fr, en, es, pt, de, tr, id, ms, it, nl): **Noto Sans**
  (SIL OFL, variable font, bundled in `assets/fonts/`).
- Arabic-script (ar, ur): **Noto Naskh Arabic** (SIL OFL) — a clear, modern,
  non-decorative Naskh face. No faux-calligraphy fonts are used anywhere;
  they can render illegible or fabricated glyph shapes for real text.

Family selection is automatic via `AppFonts.familyFor(languageCode)`. Type
scale is defined in `AppTypography.textThemeFor` (display/headline/title/
body/label, each with fixed size + line height + weight — see source for
exact values). Do not introduce ad hoc `TextStyle`s outside this scale.

## 4. Spacing, radius, elevation

- Spacing: 4pt grid — `AppSpacing.{xs,sm,md,lg,xl,xxl,xxxl,huge}` (4→64).
- Minimum touch target: `AppSpacing.minTouchTarget` = 48dp.
- Radius: `AppRadius.{sm,md,lg,xl,pill}` (8→28, pill=999).
- Elevation: `AppElevation.{level0..level3}` — flat design with soft
  drop-shadows rather than Material default elevation tinting; cards use
  `level1`, dialogs `level2`, the question card `level3`.

## 5. Components

### Buttons
Primary = filled emerald, 56dp min height, `AppRadius.lg`, label type scale.
Secondary = outlined emerald. Text buttons for tertiary actions only. All
button states (default/pressed/disabled) are derived automatically by
`ThemeData` — never overridden ad hoc per screen.

### Cards
`CardTheme` sets flat elevation + `AppRadius.lg`; visual depth comes from a
soft shadow drawn by `AppElevatedSurface` (see `lib/widgets/`), not Material
tint elevation.

### Question card
The single most important component (spec §27). Structure, top to bottom:
category chip + difficulty dots → question text (`headlineMedium`) → 4
answer tiles (large touch targets, letter badge A–D) → after answering:
inline result band (`success`/`error` token, never a modal that blocks
reading the explanation) → explanation text → source citation in a quiet
`textSecondary` caption. Background uses a very low-opacity geometric motif
(see §7) suggesting parchment/travel-map without becoming decorative noise.
See `lib/widgets/question_card.dart`.

### Player badge
Color chip + team symbol glyph + name + (solo mode) AI difficulty tag.
Never symbol-less.

### Dice
Ivory/bone-toned rounded cube with soft gold pip dots — not a red casino
die. Roll animation ≤ 900ms, spring-eased settle. See
`lib/widgets/dice_widget.dart`.

### Horse token
See `VISUAL_REFERENCE_NOTES.md` for the full brief. Rendered with
`HorsePainter` (`lib/widgets/horse_painter.dart`) — vector, not a raster
import, so it scales losslessly from a 24dp board pawn to a full-bleed
home-screen hero illustration.

### Dialogs / sheets
Rounded top corners (`AppRadius.xl`), scrim at 45% opacity, content padded
`AppSpacing.xl`. Parental gate uses the same shell (see §Accessibility &
privacy).

### States
- Disabled: 38% opacity of the token's foreground, no interaction.
- Success: `colors.success` background wash + check glyph.
- Error: `colors.error` background wash + cross glyph — never combined with
  a shake/buzzer animation that could read as humiliating for a child.
- Premium: gold accent (`colors.goldAccent`) surfaces, never a red urgency
  badge, never a countdown timer.

## 6. Motion

- Idle horse: 2–3° head bob, 4s loop, eased.
- Selection: soft outward glow pulse, 600ms.
- Move: trot (1 square) / light gallop (2+ squares) with a faint dust puff
  that fades in 400ms — never a violent capture animation; a captured pawn
  fades and glides back to its stable with a soft golden trail, no impact.
- Dice roll: ≤ 900ms.
- All non-essential motion is skipped when the OS "Reduce Motion" /
  `MediaQuery.disableAnimations` flag is set — see
  `lib/core/utils/motion.dart`.

## 7. Islamic geometric motifs

Used only as a **subtle, low-contrast texture**: card backgrounds (≤6%
opacity), screen dividers, the Premium sheet border. Never as a dominant
foreground decoration, and never combined into "cliché stacking" (no
simultaneous crescent + lantern + arabesque + carpet motif on one screen —
see spec §22). Implemented procedurally via `GeometricMotifPainter`
(`lib/widgets/geometric_motif_painter.dart`) — an eight-point star lattice,
generated, not traced from a copyrighted source.

## 8. Accessibility

- All interactive elements carry `Semantics` labels (translated).
- Color is never the only differentiator (see §2).
- Dynamic Type / textScaleFactor is respected — layouts wrap rather than
  clip up to at least 1.6× scale.
- Contrast: body text maintains ≥4.5:1 against its surface token in both
  day and night themes.
- Reduce Motion is honored app-wide (see §6).

## 9. Dark / "night oasis" mode

Night is not an inverted palette — it's a distinct art direction (desert
night sky, lantern-lit surfaces) using `AppSemanticColors.night`. Triggered
by system theme; also user-selectable in Settings.

## 10. Non-negotiables carried from the product brief

- No casino/betting aesthetic anywhere (no red felt, chips, jackpot marks).
- No representation of Allah, the Prophets ﷺ, or angels, in any form
  (explicit, silhouette, implied light, or otherwise).
- The Kaaba and the first mosque of Madinah are landmarks only — never a
  capturable/ownable/animated-for-humor game object.
- No modern Makkah/Madinah imagery (no Abraj Al Bait, contemporary green
  dome, modern minarets) in the VIIth-century-inspired world — see
  `VISUAL_REFERENCE_NOTES.md`.
