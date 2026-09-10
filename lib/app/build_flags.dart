/// Flags fixed when the binary is compiled, not settings a player can
/// change.
library;

/// Whether this binary is a *tester* build.
///
/// A tester build carries one extra switch (Settings › Tester mode) that
/// unlocks the full question bank locally, so the 450 Premium questions
/// can be played through and checked without a sandbox purchase.
///
/// It is OFF unless the build was compiled with
/// `--dart-define=IQRAQUEST_TESTER=true`, which only the TestFlight
/// workflow's "tester_unlock" input does. That matters: the switch must
/// not exist in the binary that goes to the App Store, where it would be
/// a way around the purchase — so the gate is the compiler, not a hidden
/// gesture somebody could find and share.
const bool kTesterBuild = bool.fromEnvironment('IQRAQUEST_TESTER');

/// Whether this binary is the *school* build — the one served at
/// school.iqraquest.org.
///
/// Cette adresse est celle des écoles, et elle ne doit rien offrir
/// d'autre : la console de l'enseignant, le tableau projeté, et la page
/// par laquelle un élève rejoint une classe. Le jeu familial, la
/// boutique, la progression, le défi du jour n'ont rien à y faire —
/// c'est le même binaire Flutter, et sans ce drapeau toutes leurs
/// routes répondaient sur le sous-domaine des écoles.
///
/// Ce n'est pas une protection de données : rien de ce qui compte n'est
/// accessible sans se connecter, et le serveur refuse tout à la clé
/// publique. C'est une question de surface — une école ne doit pas
/// tomber sur un écran d'achat en cherchant sa console.
///
/// OFF sauf compilation avec `--dart-define=IQRAQUEST_SCHOOL=true`, ce
/// que seul le workflow web fait.
const bool kSchoolBuild = bool.fromEnvironment('IQRAQUEST_SCHOOL');
