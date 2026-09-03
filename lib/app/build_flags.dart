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
