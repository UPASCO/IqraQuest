import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'build_flags.dart';

import '../features/classroom/presentation/classroom_board_screen.dart';
import '../features/classroom/presentation/teacher_console_screen.dart';
import '../features/classroom/presentation/classroom_screen.dart';
import '../features/daily_challenge/presentation/daily_challenge_screen.dart';
import '../features/game/presentation/game_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/mode_selection/presentation/mode_selection_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/players/presentation/player_setup_args.dart';
import '../features/players/presentation/player_setup_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/purchases/presentation/premium_screen.dart';
import '../features/results/presentation/results_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tutorial/presentation/tutorial_screen.dart';

/// Les seules routes qu'un binaire d'école sert.
///
/// Tout le reste — le jeu, la boutique, la progression — appartient à
/// l'application des familles, pas au sous-domaine des écoles.
const Set<String> _schoolRoutes = {
  '/teacher',
  '/classroom',
  '/classroom/board',
};

bool _allowedInSchoolBuild(String location) {
  final path = Uri.parse(location).path;
  return _schoolRoutes.any((r) => path == r || path.startsWith('$r/'));
}

/// [classroom] ouvre les routes du mode École. Par défaut, le drapeau du
/// binaire ; les tests du mode en réserve passent `true` pour continuer
/// à le vérifier sans qu'il existe dans le produit.
GoRouter buildAppRouter({
  required String initialLocation,
  bool classroom = kClassroomEnabled,
}) => GoRouter(
  initialLocation: initialLocation,
  // Sur le binaire d'école, une adresse tapée à la main ne sort pas de
  // la classe : `#/home`, `#/premium`, `#/game` ramènent à la console.
  // Sans cela, l'adresse donnée aux écoles servait aussi le jeu
  // familial et son écran d'achat.
  redirect: (context, state) {
    if (!kSchoolBuild) return null;
    return _allowedInSchoolBuild(state.uri.toString()) ? null : '/teacher';
  },
  routes: [
    if (!kSchoolBuild) ...[
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(
        path: '/mode-selection',
        builder: (c, s) =>
            ModeSelectionScreen(mode: s.extra as String? ?? 'solo'),
      ),
      GoRoute(
        path: '/player-setup',
        // A cold entry (state restoration, programmatic go) carries no
        // args: never crash on the cast, go back to the start of the flow.
        redirect: (c, s) =>
            s.extra is PlayerSetupArgs ? null : '/mode-selection',
        builder: (c, s) => PlayerSetupScreen(args: s.extra! as PlayerSetupArgs),
      ),
      GoRoute(path: '/game', builder: (c, s) => const GameScreen()),
      GoRoute(path: '/results', builder: (c, s) => const ResultsScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/premium', builder: (c, s) => const PremiumScreen()),
      GoRoute(
        path: '/daily-challenge',
        builder: (c, s) => const DailyChallengeScreen(),
      ),
      GoRoute(path: '/progress', builder: (c, s) => const ProgressScreen()),
      GoRoute(path: '/tutorial', builder: (c, s) => const TutorialScreen()),
    ],
    // Le mode École est en réserve : sans le drapeau, ces trois routes
    // n'existent pas, et une adresse tapée à la main tombe sur la page
    // introuvable comme n'importe quelle autre.
    if (classroom) ...[
      // `?code=G4KEPW` is what a scanned QR carries: the join form opens
      // with the code already in place.
      GoRoute(
        path: '/classroom',
        builder: (c, s) =>
            ClassroomScreen(initialCode: s.uri.queryParameters['code']),
      ),
      // The projector's own page: opened by the teacher's console with the
      // session code, and read by a room full of children who never touch
      // it. `/classroom/board/G4KEPW` on the web build, cast to the TV on
      // a phone or a tablet.
      // La console de l'enseignant existe partout — sur un téléphone elle
      // sert à se connecter, à lire sa licence et à ouvrir une séance. Ce
      // qui n'existe QUE sur le web, ce sont les surfaces d'achat : bouton
      // d'abonnement, portail, lien de paiement. Elles sont compilées
      // derrière `kIsWeb` dans l'écran lui-même, et un contrôle de
      // pré-livraison le vérifie — rien dans une build de magasin ne mène
      // à un paiement hors magasin.
      GoRoute(
        path: '/teacher',
        builder: (c, s) => const TeacherConsoleScreen(),
      ),
      GoRoute(
        path: '/classroom/board/:code',
        builder: (c, s) => ClassroomBoardScreen(
          code: (s.pathParameters['code'] ?? '').toUpperCase(),
        ),
      ),
    ],
  ],
);

final appRouterProvider = Provider<GoRouter>(
  (ref) => throw UnimplementedError('Override in main()'),
);

/// Où mène une adresse tapée à la main sur le sous-domaine des écoles.
/// `null` veut dire « elle a le droit d'être là ».
@visibleForTesting
String? schoolRedirectForTest(String location) =>
    _allowedInSchoolBuild(location) ? null : '/teacher';
