import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';

/// A team identity: color + symbol + horse coat, so no two identifying
/// channels ever rely on color alone (colorblind-safe by construction).
enum AppTeam {
  emerald(symbol: TeamSymbol.star, coat: HorseCoat.grayWhite),
  saphir(symbol: TeamSymbol.compass, coat: HorseCoat.bay),
  grenat(symbol: TeamSymbol.lantern, coat: HorseCoat.chestnut),
  safran(symbol: TeamSymbol.book, coat: HorseCoat.black);

  const AppTeam({required this.symbol, required this.coat});

  final TeamSymbol symbol;
  final HorseCoat coat;

  Color color(AppSemanticColors colors) => switch (this) {
    AppTeam.emerald => colors.player1,
    AppTeam.saphir => colors.player2,
    AppTeam.grenat => colors.player3,
    AppTeam.safran => colors.player4,
  };
}

/// Geometric marker shown on a player's saddle-cloth and UI badges —
/// the non-color channel that keeps teams distinguishable.
enum TeamSymbol { star, compass, lantern, book }

/// A cosmetic horse coat variant. Purely visual; never the sole identifier
/// of a team (see DESIGN_SYSTEM.md §Identité des équipes).
enum HorseCoat { grayWhite, bay, chestnut, black }
