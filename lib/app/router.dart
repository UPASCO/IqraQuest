import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

GoRouter buildAppRouter({required String initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
    GoRoute(
      path: '/mode-selection',
      builder: (c, s) => ModeSelectionScreen(mode: s.extra as String? ?? 'solo'),
    ),
    GoRoute(
      path: '/player-setup',
      builder: (c, s) => PlayerSetupScreen(args: s.extra as PlayerSetupArgs),
    ),
    GoRoute(path: '/game', builder: (c, s) => const GameScreen()),
    GoRoute(path: '/results', builder: (c, s) => const ResultsScreen()),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
    GoRoute(path: '/premium', builder: (c, s) => const PremiumScreen()),
    GoRoute(path: '/daily-challenge', builder: (c, s) => const DailyChallengeScreen()),
    GoRoute(path: '/progress', builder: (c, s) => const ProgressScreen()),
    GoRoute(path: '/tutorial', builder: (c, s) => const TutorialScreen()),
  ],
);

final appRouterProvider = Provider<GoRouter>(
  (ref) => throw UnimplementedError('Override in main()'),
);
