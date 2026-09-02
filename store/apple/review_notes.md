# App Review Notes — IqraQuest

IqraQuest is a family/educational board game about Islamic knowledge,
designed for ages 7-99. Key points for review:

- **No account required.** The app is fully usable immediately after
  install, offline, with no sign-in of any kind.
- **No advertising, no third-party analytics, no tracking SDKs.** See
  THIRD_PARTY_NOTICES.md for the complete, short dependency list.
- **No backend server.** All game logic, content, and progress storage
  is local to the device.
- **Free content:** 50 of the 500 curated quiz questions in this build
  (free questions recycle so a free game is never blocked), unlimited Solo and Family play, both game
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
  included. The board is set among four holy places — Medina, Jerusalem
  (al-Aqsa), Mount Arafat and Mina — with Mecca at the centre as the
  shared destination. They are the setting the journey passes through,
  depicted respectfully as places; they are never pieces a player moves,
  captures, trades, wins as a reward, or buys. Nothing about a sacred
  site is unlockable or sold — see DESIGN_SYSTEM.md and
  VISUAL_REFERENCE_NOTES.md.
- **No representation of Allah, the Prophets, or angels** appears
  anywhere in the app, in any form.

If a reviewer needs a Premium test purchase and does not have App Store
sandbox testing configured, please advise and we'll provide a sandbox
tester credential through App Store Connect's standard channel (not
included in this repository).
