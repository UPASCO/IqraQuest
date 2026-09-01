# Screenshot plan (Apple & shared with Google — see store/google/screenshots_plan.md)

Per spec §115: screenshots must show the real product, and read as
genuine marketing material, not raw UI dumps. Capture on-device (or
simulator/emulator at required resolutions) once content is at release
scope. Shot list, in order — every frame is the real app captured
from the web build, composed into a marketing frame (device on the
board's teal-and-gold plate, one headline, one sub-line):

1. **Home** — the journey card in its ornate gold frame, Solo/Family/
   Daily Challenge/Progress. Communicates the whole concept in one
   frame. Headline: "Le voyage commence par ce que tu sais".
2. **The deck** — the cross board with the four stables and the
   face-down deck ready to tap. Communicates "this is the horse race
   board game, without the dice". Headline: "Pas de dé. Tu pioches
   une carte."
3. **Card drawn** — the turned card showing its value and "Vaut N
   cases": the value is the distance AND the difficulty. Headline:
   "La carte dit combien de cases… et quelle question."
4. **Question with source** — a question mid-answer with the citation
   visible. The app's core promise (spec §27). Headline: "Chaque
   question cite sa source".
5. **Results board** — the ornate score card after a win, with the
   Share button. Communicates the family/"again!" loop and the
   shareable moment. Headline: "Gagne, partage, rejoue."
6. **Mode selection / courses** — the three courses. Headline: "Trois
   parcours, visibles avant de partir".
7. **Daily Challenge summary** — the day's score card. Communicates the
   daily habit hook. Headline: "Le Défi du jour, cinq questions".
8. **Premium** — no ads, no account, one optional purchase. Headline:
   "Sans pub. Sans compte. Sans abonnement."

Required sizes to produce at submission time (verify against current
App Store Connect requirements, which change): iPhone 6.9", iPhone 6.5",
iPad 13" — see spec §111 (current platform rules always override this
document). The 6.5" set (1242×2688) is produced from the web build by
`tool/store/drive.js` (captures) and `tool/store/compose.js` (marketing
frames) — see `tool/store/README.md`.
