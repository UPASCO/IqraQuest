# IqraQuest

A family board game about Islamic knowledge: the classic *jeu des petits
chevaux* with a deck of question cards in place of the die. On each turn
a player draws a card worth 1 to 6 squares and must answer its question
— at the level they chose before the game (easy, intermediate, expert) —
to actually move. Four horses per stable, out on a 6, captures, a 6
replays. The free edition is a race of fifty cards; Premium runs to
Mecca. Built with Flutter, fully offline, no account, no backend, no
ads.

> See **Content scope** and **What is genuinely done vs. what remains**
> below — this is a real, working, tested app, built to the full
> architecture and design system the product brief calls for, shipped in
> this pass with a smaller, rigorously-sourced content bank than the
> eventual 500-question×12-language target. Nothing here is a mockup:
> every screen, every rule, every test described below runs.

## Quick start

```bash
flutter pub get
flutter gen-l10n          # regenerates lib/l10n/generated/ from lib/l10n/*.arb
flutter run
```

No local machine? `CODESPACE_TESTING.md` covers testing from a GitHub
Codespace (browser preview on desktop and phone, APK builds, and the
TestFlight pipeline). The `.devcontainer/` in this repo installs the
right Flutter automatically.

Requires a recent Flutter stable (developed against Flutter 3.47,
Dart 3.13). Android and iOS platforms are configured
(`flutter create --platforms android,ios`); a `web` target is also
present purely as a convenience preview surface for contributors without
a device/simulator, not a release target (spec targets iOS/iPadOS and
Android only).

## Architecture

```text
lib/
  app/            bootstrap, go_router config, Riverpod provider wiring
  core/            (reserved for cross-cutting utils as the app grows)
  models/          Question, Player, HorseState, PawnPosition (sealed),
                    MovementChoice, GaitCycle, KnowledgeStreak, Circuit,
                    RewardInventory, GameState, enums
  services/        QuestionRepository, GameSaveService, ProgressService,
                    PurchaseService, EntitlementService, SettingsService,
                    DailyChallengeService, LocalStorageService
  theme/           design tokens (colors, type, spacing, radius) + AppTeam
  l10n/            *.arb source + flutter gen-l10n output
  widgets/         shared UI: QuestionCard, HorseToken/HorsePainter,
                    GaitSelector, BoardWidget, landmark & motif painters,
                    ParentalGate
  features/
    onboarding/ home/ mode_selection/ players/ settings/
    purchases/ daily_challenge/ progress/ tutorial/   (presentation only)
    game/
      domain/        GameEngine, HorseAi — pure Dart, no Flutter
                      imports, no randomness, fully unit-testable
      application/   GameController (Riverpod StateNotifier) — wires the
                      engine to question selection, AI turns, autosave
      presentation/  GameScreen
assets/
  data/questions/    master/ (canonical facts) + one folder per UI language (12)
  fonts/             Noto Sans, Noto Naskh Arabic (bundled, offline-first)
content_quality/      source_registry.json, question_sources.csv
legal/                privacy_policy_{en,fr}.md
store/                apple/, google/ submission metadata
tool/
  pre_release_check.dart   the spec's release gate (see below)
  content/gen_questions.py the question bank's single source of truth
test/
  features/game/           GameEngine unit tests
  content/                 question bank integrity tests
  integration/             controller-level end-to-end flow
  widget_test.dart         app-boot smoke test
```

### The game engine

`lib/features/game/domain/game_engine.dart` is the single source of
truth for the rules and is completely decoupled from rendering: it takes
a `GameState` and returns a new one, using logical board positions
(`HomePosition` / `TrackPosition(index)` / `FinalLanePosition(step)` /
`FinishedPosition` — a Dart 3 `sealed class`), never screen coordinates.
`lib/widgets/board/board_layout.dart` is the only place that maps those
logical positions to pixels.

Nothing in the engine is random. It contains no `Random` and does not
import `dart:math`, and a test asserts exactly that: how far a horse
moves is the gait its player chose, and whether it moves at all is
whether they answered correctly.

The rules are the classic *jeu des petits chevaux* with the deck in place
of the die, played **answer first, then place**. The turn is:

1. **draw a card** — it turns over onto its **stake** ("Carte à 5
   galops"): the player knows what a right answer is worth before the
   question opens, and the stake stays pinned over the question while it
   is played for. The question is at the rider's own level (chosen
   before the game, the same whatever the card);
2. **answer** — a wrong answer moves nothing (the sheet still says what
   the card was worth); a right one wins the card's **galops**, revealed
   as an event, never as a fact read off the card: a gold medallion drops
   onto the board, throws a shockwave through a crown of rays, and the
   number counts up under "Gagné 5 galops";
3. **place** — every horse that can ride those galops is unmistakable: a
   gold chevron above it, its own pool of light and a breathing halo
   below, all pulsing on one beat while every other piece stays quiet;
   touching one lights its destination (and the squares between, with a
   tag: capture, arrival, bonus…); the player compares freely, then picks
   a horse up and sets it down on its square. **The drop is the move**:
   nothing moves before it, and nothing asks to confirm after it. A horse
   dropped anywhere else glides back. Even a single legal horse waits
   for the player — no automatic move, ever;
4. **bonus squares** — sixteen medallions are dealt onto the circuit at
   the start of every game (`BonusLayout`): four per quadrant, +5 (×8),
   +10 (×6), +20 (×2, always in opposite quadrants), never adjacent,
   never on a start or effect square, every quadrant worth the same +35.
   A horse that stops *exactly* on one flares and rides on by its value,
   in a second, clearly separate ride — and if that ride sets it down
   exactly on another bonus square, **that one fires too**: bonuses
   chain. Each square pays at most once per turn (`firedBonusTracks`,
   which is also what makes the chain terminate) and stays in play for
   everyone. The layout is generated once from the game's seed, lives in
   the save, and is never recomputed;
5. **a capture pays** — sending an opponent home is worth
   `kCaptureBonus` = 20 extra squares, ridden exactly like a bonus, and
   a capture made *by* a bonus ride pays its own twenty in turn;
6. **the finish is exact** — three squares from the oasis you need
   exactly a 3. A card that would carry a horse past the finish is not
   offered for that horse at all, and neither is a bonus ride that would:
   the horse waits for the right card. If no horse can play the card, the
   turn simply passes.

Every rider's **first horse already stands on its start square**: the
classic opening — four horses shut in and a 6 to find — spends the first
minutes waiting, so one horse is out from the start and there is always
something to ride from the very first card. The other three still come
out of the stable on a 6, which also lets the same player draw again
(right or wrong); while the first horse sits on the start square it
keeps its own gate shut, exactly as the classic rule says. Landing
exactly on an opponent sends it home (a horse coming out captures on its
start square, oasis or not); two horses of a colour never share a square,
on a bonus ride as on any other; a Grand Galop is spent by itself, only
when its two squares turn a ride into an arrival. A card that can move
nothing passes the turn. The free edition ends after 50 draws on the
leader (most arrived horses, then distance, then knowledge); Premium
runs to the end.

Rules encoded and tested (`test/features/game/game_engine_test.dart`,
`placement_test.dart`, `bonus_layout_test.dart`): no randomness and no
surviving dice API; the answer-first turn (nothing moves until the drop,
an illegal horse is refused, state untouched); the preview matching what
actually happens (destination, square effect, capture); capture, oasis
safety and knowledge shields (the shield of a fresh streak goes to the
horse set down); the streak rewards at 3 / 5 / 10 and the fact that an
error never revokes one; every special square applying exactly its
announced effect; the bonus layout invariants (16 squares, 4 per
quadrant, values only 5/10/20 in 8/6/2, opposite +20s, no adjacency, no
start or effect square, seed determinism, save round-trip, never
recomputed); the bonus ride (fires only on an exact stop, once per turn,
never chains, captures, can arrive, survives a save); structural
quadrant fairness across all three circuits; overshoot at the finish and
the Question du voyage that validates an arrival; per-profile difficulty
so a child and an adult can share a board; and save round-tripping.

`test/quality/game_length_simulation_test.dart` measures the design:
120 whole games per format through the real engine, with and without
the bonus squares (70% accuracy). Bonuses shorten every format by about
40% (a two-rider quick race from a mean of 56 cards to 35; a two-rider
classic from 209 to 124) without deciding it — the assertion holds the
gain between 8% and 50%.

The same engine drives AI opponents (`HorseAi`) — difficulty only models
how often the opponent *knows* an answer, plus how well it picks which
horse takes the squares. It draws from the same deck, places through
the same `placeHorse`, and never sees information a human player
couldn't.

**Questions** are dealt by `QuestionDeck`: one pile per level, shuffled
once, drawn *without replacement* until spent; a resumed game excludes
what it already asked; a refilled pile keeps the last cards seen at the
bottom; and each deal weighs the top few cards for a change of category
and of subject (no three Qur'an cards in a row, no two Musa cards in a
row). Linear in the pile, built for a bank of thousands
(`test/services/question_deck_test.dart` deals 5 000 cards twice).

### State management & navigation

Riverpod (`StateNotifierProvider`/`Provider`/`FutureProvider`) +
`go_router`. Services are constructed once in `main()` (they need an
`await`) and injected via `ProviderScope(overrides: ...)` — see
`lib/app/providers.dart` and `lib/main.dart`.

### Persistence

Everything is local (spec: no backend). `shared_preferences` (via a thin
`LocalStorageService` wrapper) for settings, progress, and the
in-progress game save; `flutter_secure_storage` specifically for the
Premium entitlement flag. A corrupted save is discarded, never crashes
the app (`GameSaveService.load()`).

## Content scope — read this before judging "500 questions"

The product brief specifies 500 canonical questions × 12 languages
(6,000 localized records), sourced under a strict "Qur'an or Ṣaḥīḥ
al-Bukhārī/Ṣaḥīḥ Muslim only, non-controversial, reject on any doubt"
policy (`CONTENT_SOURCE_POLICY.md`).

**This pass ships 60 canonical questions, fully written and verified
against every rule in that policy, in 3 languages (French, English,
Arabic)** — not 500×12. This is a deliberate, disclosed scope decision,
not an oversight:

- Verifying 500 individual religious facts against precise Qur'an/hadith
  references at the sourcing discipline the spec itself demands (§52:
  "at the slightest doubt, reject the question") is not something that
  can be batch-generated responsibly in one pass without a real
  human/scholarly review pipeline.
- Fabricating plausible-looking references at scale to hit "500" would
  directly violate the spec's own strongest and most explicit constraint.
  A smaller, honestly-verified bank was judged the only responsible
  option.
- Every piece of supporting infrastructure — the JSON schema, the
  `QuestionRepository` selection/gating logic, the free/Premium split
  logic, the `source_registry.json`/`question_sources.csv` traceability
  files, `tool/pre_release_check.dart`'s validation gate, the 12-language
  ARB/UI localization scaffold — is built to the **full 500×12 target**.
  Extending the content bank means running
  `python3 tool/content/gen_questions.py` (or its logical extension)
  with more entries; it requires no application code changes.

`tool/pre_release_check.dart` **intentionally and correctly fails right
now** against the full 500/12/50-free/450-premium/category/difficulty
targets — see its own header comment. That failure is the honest,
designed behavior of the gate, not a bug.

### UI translation vs. content translation — also different scopes

All **interactive UI chrome** (58 strings — buttons, labels, feedback
messages, settings, Premium screen, errors, accessibility labels) is
translated into all 12 target languages via `lib/l10n/*.arb` →
`flutter gen-l10n`. **Long-form text** (the in-app rules/tutorial screen,
the legal privacy policy) currently ships in English/French only — see
each file's own note. This split is disclosed rather than papered over
with machine-translated legal text.

## Design system

See `DESIGN_SYSTEM.md` for the full palette/type/spacing/component
specification. Every visual is original vector code
(`lib/widgets/horse_painter.dart`, `board/`, `landmarks/`,
`geometric_motif_painter.dart`, `gait_selector.dart`) — no raster art was
copied or generated from an external source. See
`VISUAL_REFERENCE_NOTES.md` for the historical-inspiration research
behind the Makkah/Madinah/horse/architecture treatment, and
`ASSET_INVENTORY.md` for the full asset table and `ASSET_LICENSES.md`
for licences. The launcher icon is artwork supplied by the project owner
(`tool/art/source/app_icon_source.webp`: three horses racing across the
board's tiles toward an open book with a glowing question mark, a
crescent and star above); `tool/art/bake_app_icon.py` prepares it (the
painted frame cropped away so the platform mask frames the art, small
sizes sharpened) and writes every platform size.

## Tests

```bash
flutter analyze     # 0 issues
flutter test         # the whole suite, ~9s
flutter test --exclude-tags=manual     # same, minus the screenshot helper
dart run tool/pre_release_check.dart   # release gate (see Content scope)
```

As of this pass: `flutter analyze` reports zero issues and `flutter test`
passes the whole suite (300+ tests) in about half a minute — the
`GameEngine`/rules, placement and bonus-layout tests, the controller
integration tests (turn flow, no-repeat questions, save & resume at
every phase of the placement turn, legacy-save migration, free vs.
Premium, whole games to victory), the question-deck tests, the
question-bank integrity tests across all 12 languages, the widget turn
loop (draw → answer → drag a horse onto its lit square → bonus ride,
through the real screen), the game-length simulation, and the visual-QA
scenes that render art to `build/screenshots/` for human review.

Those last three are tagged `manual` — they write files for a person to
look at rather than asserting behaviour — so CI can drop them with
`--exclude-tags=manual`. They used to hang for ten minutes each and then
fail: `toImage`/`toByteData` hand work to the raster thread, which the
fake async zone a widget test runs in never drains, so the futures
completed but the test never did. Wrapping the capture in
`tester.runAsync()` turns each one into an instant capture.

`dart run tool/pre_release_check.dart` additionally gates the rules
change itself: it fails if the engine ever imports `dart:math` or
instantiates a `Random`, if any dice API reappears in `lib/`, or if the
three circuits stop keying their effects per quadrant (which is what
makes every starting corner structurally equal).

## Accessibility

- `Semantics` labels on interactive elements: each gait announces its
  distance, its difficulty and its knowledge points
  (`gaitSemanticLabel`), plus horses and answer tiles.
- Color is never the sole differentiator: every team is
  color+symbol+horse-coat (`lib/theme/app_team.dart`).
- Reduce Motion is read from `MediaQuery.disableAnimations` and honored
  app-wide (idle horse bob, horse movement along the track).
- Difficulty is never conveyed by color alone: each gait shows its
  number, a pip count and a used/unused shape.
- Body text targets ≥4.5:1 contrast in both day and night themes
  (`AppSemanticColors`).
- RTL: Arabic and Urdu render right-to-left via `Directionality` in
  `lib/app/app.dart`; the board's game *logic* never mirrors (only
  presentation does).

## Purchases

One non-consumable product, `iqraquest_full_access`, via
`package:in_app_purchase` (StoreKit on iOS, Play Billing on Android —
never Stripe/PayPal/web checkout). Price is always read from the
platform's own `ProductDetails`, never hardcoded (verified by
`tool/pre_release_check.dart`). See `lib/services/purchase_service.dart`
and `lib/features/purchases/presentation/premium_screen.dart`. A
`ParentalGate` (simple logic question, collects no personal data) gates
the purchase and restore buttons.

## Privacy

No account, no backend, no ads, no analytics/tracking SDK. See
`legal/privacy_policy_en.md` / `legal/privacy_policy_fr.md` and
`THIRD_PARTY_NOTICES.md`.

## Builds & release

- Android: `flutter build appbundle` produces the `.aab` Google Play
  expects; `android/app/build.gradle.kts` already sets
  `applicationId = "com.IqraQuest.com"` (update if a different org is
  intended) and tracks Flutter's own `targetSdkVersion`/`compileSdk` —
  verify these meet Google's current minimum at build time (spec §112).
  The release build currently signs with the debug config; a real
  signing config must be added before shipping.
- iOS: build via Xcode with a toolchain meeting Apple's current minimum
  at submission time (spec §113). A GitHub Actions pipeline
  (`.github/workflows/ios-testflight.yml`, macOS runner) builds and
  uploads to TestFlight via `fastlane` with no local Mac required —
  triggered manually from the Actions tab. See
  `store/apple/TESTFLIGHT_SETUP.md` for the one-time setup (App Store
  Connect API key + Team ID as GitHub secrets).
- Neither platform has been built end-to-end *in this development
  environment* (no Android SDK / Xcode available here) — `flutter
  analyze`, `flutter test`, and a `flutter build web` compile-and-link
  pass were used instead to verify the full codebase compiles and wires
  together correctly. The iOS TestFlight pipeline above runs the real
  build on a real macOS runner once its secrets are configured.
- See `STORE_RELEASE_CHECKLIST.md` for the full submission checklist for
  both stores.

## What is genuinely done vs. what remains

**Done and tested:** architecture, design system, full game engine with
its complete rule set, AI opponents at 3 difficulties, the 12-language UI
localization scaffold, the 60-question sourced content bank in 3
languages with its full verification pipeline, all core screens
(onboarding → home → mode selection → player setup → game → results →
settings → premium → daily challenge → progress → tutorial), local save/
resume, progress tracking, the Premium purchase flow (integration-level;
not sandbox-tested against a live Store), original vector art for every
visual element, accessibility basics, RTL, and privacy documentation.

**Remaining, disclosed:** scaling content to 500×12, translating
long-form text (tutorial/legal) beyond en/fr, producing a final launcher
icon and Store screenshot assets, an actual signed Android `.aab` /
Xcode-built `.ipa`, and live Store sandbox purchase testing. See
`STORE_RELEASE_CHECKLIST.md` and `tool/pre_release_check.dart`'s current
(intentionally failing) output for the precise, itemized list.
