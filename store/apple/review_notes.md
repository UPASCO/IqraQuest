# App Review Notes — IqraQuest

IqraQuest is a family/educational board game about Islamic knowledge,
designed for ages 7-99. Key points for review:

- **No account required.** The app is fully usable immediately after
  install, offline, with no sign-in of any kind.
- **No advertising, no third-party analytics, no tracking SDKs.** See
  THIRD_PARTY_NOTICES.md for the complete, short dependency list.
- **No backend server.** All game logic, content, and progress storage
  is local to the device.
- **Free content:** 21 of the 122 curated quiz questions in this build
  (the bank grows toward 500 across updates; free questions recycle so a
  free game is never blocked), unlimited Solo and Family play, both game
  variants (Quick/Classic), the daily challenge with the free question
  bank.
- **One-time purchase:** `iqraquest_full_access` (non-consumable)
  unlocks the remaining question bank. There is no subscription, no
  consumable, and no other IAP.
- **Restore Purchases** is available on the Premium screen.
- **Content sensitivity:** the app presents factual quiz questions about
  Islam sourced from the Qur'an and the two most authenticated hadith
  collections (Ṣaḥīḥ al-Bukhārī, Ṣaḥīḥ Muslim) — see
  CONTENT_SOURCE_POLICY.md for the sourcing discipline applied to every
  question. No sect-specific or doctrinally disputed content is
  included. Sacred sites (the Kaaba, referenced in decorative art only)
  are never used as game mechanics, rewards, or purchasable items — see
  DESIGN_SYSTEM.md and VISUAL_REFERENCE_NOTES.md.
- **No representation of Allah, the Prophets, or angels** appears
  anywhere in the app, in any form.

If a reviewer needs a Premium test purchase and does not have App Store
sandbox testing configured, please advise and we'll provide a sandbox
tester credential through App Store Connect's standard channel (not
included in this repository).
