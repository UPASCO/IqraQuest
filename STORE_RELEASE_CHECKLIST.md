# IqraQuest — Store Release Checklist

Per spec §111: **current Apple/Google policy always overrides this
document.** Re-verify every item against the live App Store Connect /
Play Console UI at submission time — requirements shift.

This checklist also assumes the content bank has been scaled from this
v1's 60 curated questions to the full 500×12 target (see README.md
§Content scope and `tool/pre_release_check.dart`, which currently and
correctly fails against that full target).

## Apple

See `store/apple/TESTFLIGHT_SETUP.md` for the GitHub Actions pipeline
that builds and uploads to TestFlight without a local Mac.

```text
[ ] Final bundle ID confirmed (currently com.upasco.iqraquest — placeholder org, update if needed)
[ ] ASC_KEY_ID / ASC_ISSUER_ID / ASC_KEY_CONTENT / APPLE_TEAM_ID secrets set in GitHub (store/apple/TESTFLIGHT_SETUP.md)
[ ] App Store Connect record created
[ ] In-App Purchase "iqraquest_full_access" configured as Non-Consumable
[ ] Price tier set in App Store Connect (never hardcoded in-app — verified by pre_release_check.dart)
[ ] Sandbox purchase tested on a real device/sandbox tester account
[ ] Restore Purchases tested (fresh install, sandbox account)
[ ] Privacy Policy URL live and reachable (host legal/privacy_policy_en.md)
[ ] App Privacy questionnaire completed in App Store Connect (matches THIRD_PARTY_NOTICES.md — no tracking, no ad SDKs, no analytics)
[ ] Age Rating questionnaire completed (educational/religious content, no violence — see spec §12-13 constraints already enforced in content pipeline)
[ ] Audience correctly declared (7+ per spec §86, not exclusively a Kids Category app given the 7-99 audience — confirm against current Apple Kids Category rules)
[ ] Screenshots captured on real/simulated devices per required sizes (see store/apple/screenshots_plan.md)
[ ] Metadata (title/subtitle/description/keywords) localized for shipped languages (see store/apple/metadata/)
[ ] Review Notes submitted (see store/apple/review_notes.md)
[ ] Final launcher icon (1024×1024 + full icon set) replaces the flutter template default (ASSET_INVENTORY.md known gap)
[ ] Build produced on an Xcode/iOS SDK version meeting Apple's current minimum at submission time (spec §113)
[ ] Tested on a real iPhone and a real iPad
[ ] No placeholder/TODO/Lorem ipsum strings shipped (tool/pre_release_check.dart)
[ ] Question bank passes tool/pre_release_check.dart at full 500×12 scope
```

## Google Play

```text
[ ] Final Application ID confirmed (com.upasco.iqraquest)
[ ] Play Console app record created
[ ] In-app product "iqraquest_full_access" configured as a one-time product
[ ] Google Play Billing integration tested (license-tester account)
[ ] Restore/re-query entitlement tested after reinstall
[ ] Data Safety form completed (matches THIRD_PARTY_NOTICES.md — no data collected/shared)
[ ] Target Audience & Content settings completed (7-99, not exclusively Designed for Families given the adult-inclusive audience — confirm current Play policy)
[ ] Families Policy reviewed if the Designed for Families program is opted into
[ ] IARC content rating questionnaire completed
[ ] Privacy Policy URL set in Play Console listing
[ ] Signed .aab produced (release keystore — never the debug signing config currently in build.gradle.kts)
[ ] targetSdkVersion meets Google's current minimum at submission time (spec §112: ≥36 for a post-2026-08-31 submission, or higher if Google has since raised it — verify against `flutter.targetSdkVersion` resolved by the Flutter version used to build)
[ ] Screenshots (phone + tablet) + Feature Graphic prepared (see store/google/screenshots_plan.md)
[ ] Store listing metadata localized (see store/google/metadata/)
[ ] Tested on a real Android phone and a real Android tablet
[ ] No placeholder/TODO/Lorem ipsum strings shipped (tool/pre_release_check.dart)
[ ] Question bank passes tool/pre_release_check.dart at full 500×12 scope
```

## Cross-cutting, before either submission

```text
[ ] dart format . — clean
[ ] flutter analyze — zero issues
[ ] flutter test — all green
[ ] dart run tool/pre_release_check.dart — all green (requires full content scale-out)
[ ] Manual RTL pass on ar and ur across: onboarding, home, question card, game screen, results, settings, premium
[ ] Manual accessibility pass: large text (1.6x+), VoiceOver/TalkBack spot-check, Reduce Motion honored
[ ] Manual visual QA per spec §97 on every screen at phone and tablet sizes
[ ] Corrupted-save recovery path exercised manually (spec §83)
```
