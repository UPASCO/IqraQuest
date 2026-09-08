/// Where the classroom server lives, if it lives anywhere.
///
/// Both values are compiled in with `--dart-define` and never committed:
///
///     flutter build web \
///       --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///       --dart-define=SUPABASE_ANON_KEY=eyJ...
///
/// The anon key is a public key by design — it can do nothing on its own,
/// because every table refuses it (row-level security with no policy for
/// `anon`) and the only surface it reaches is the handful of functions in
/// `server/supabase/migrations/`. The `service_role` key is the opposite
/// of that and never leaves the Supabase dashboard.
///
/// A build without these two opens the classroom screen all the same and
/// says, honestly, that no class can be reached — rather than hiding a
/// feature the shop already lists.
class ClassroomConfig {
  const ClassroomConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Where the teacher's sign-in link comes back to — the console's own
  /// address, ending in `teacher-callback.html`. Compiled in because
  /// only the deployment knows where it is hosted.
  static const String consoleCallbackUrl = String.fromEnvironment(
    'TEACHER_CALLBACK_URL',
  );

  /// The Stripe payment page for a classroom licence.
  ///
  /// A Stripe payment link, so the price lives in Stripe and never in
  /// this repository — and so nothing in the app ever handles a card.
  /// The console shows the button only when this is compiled in, and
  /// only on the web: nothing on iOS ever links to it.
  static const String stripeCheckoutUrl = String.fromEnvironment(
    'STRIPE_CHECKOUT_URL',
  );
}
