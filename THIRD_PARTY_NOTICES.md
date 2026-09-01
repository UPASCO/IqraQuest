# Third-Party Notices

IqraQuest is built with the Flutter SDK and the following open-source
packages and fonts. All are used under their respective licences, all are
commercially redistributable, and none require attribution to be shown
in-app beyond what's listed here (verify exact obligations against each
package's own LICENSE file before Store submission — see
STORE_RELEASE_CHECKLIST.md).

## Framework

- **Flutter** / **Dart** — Google LLC. BSD-3-Clause. https://flutter.dev

## Fonts (bundled in `assets/fonts/`)

- **Noto Sans** — Google Fonts. SIL Open Font License 1.1. Used for
  Latin-script UI text (fr, en, es, pt, de, tr, id, ms, it, nl).
- **Noto Naskh Arabic** — Google Fonts. SIL Open Font License 1.1. Used
  for Arabic-script UI text (ar, ur).
- **Noto Sans Arabic** — Google Fonts. SIL Open Font License 1.1.
  Bundled for future/fallback Arabic-script use.

No decorative or "faux calligraphy" fonts are used anywhere (spec §20).

## Dart/Flutter packages (see `pubspec.yaml` for exact resolved versions)

| Package | Purpose | Licence |
|---|---|---|
| `flutter_riverpod` | State management | MIT |
| `go_router` | Navigation/routing | BSD-3-Clause |
| `intl` | Localization/formatting | BSD-3-Clause |
| `shared_preferences` | Local key-value storage | BSD-3-Clause |
| `flutter_secure_storage` | Secure local storage (Premium entitlement) | BSD-3-Clause |
| `in_app_purchase` | StoreKit / Google Play Billing wrapper | BSD-3-Clause |
| `path_provider` | Local filesystem paths | BSD-3-Clause |
| `collection` | Collection utilities | BSD-3-Clause |
| `cupertino_icons` | iOS-style icon glyphs | MIT |
| `audioplayers` | Sound-effect playback | MIT |
| `flutter_lints` (dev only) | Static analysis rules | BSD-3-Clause |

## Original assets

The app's visuals are of two kinds, both fully documented in
ASSET_LICENSES.md: original vector code authored for this project
(`lib/widgets/` — see ASSET_INVENTORY.md and VISUAL_REFERENCE_NOTES.md),
and bitmap illustrations supplied by the project owner (AI-generated
concept art commissioned for IqraQuest, including the playable board
scene and its knight pieces under `assets/board/`). All sound effects
are synthesized in-repo (`tool/audio/gen_sfx.py`). No third-party
illustrations, stock art, samples, or existing board-game assets were
copied (spec §93).

## Content

Question text, sources, and translations are original compilations
sourced directly from the Qur'an and Ṣaḥīḥ al-Bukhārī / Ṣaḥīḥ Muslim, per
CONTENT_SOURCE_POLICY.md — these are religious primary sources, not
copyrighted third-party works.
