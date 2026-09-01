import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';

/// A team identity: color + symbol + horse coat, so no two identifying
/// channels ever rely on color alone (colorblind-safe by construction),
/// plus the place its camp occupies on the board.
///
/// The enum names are colours and stay that way: they are written into
/// every save file, and renaming them would strand games in progress.
/// The colour-to-place pairing below follows the board reference —
/// Medina green, Al-Aqsa red, Arafat blue, Mina gold.
enum AppTeam {
  emerald(symbol: TeamSymbol.star, coat: HorseCoat.grayWhite, place: HolyPlace.medina),
  saphir(symbol: TeamSymbol.compass, coat: HorseCoat.bay, place: HolyPlace.arafat),
  grenat(symbol: TeamSymbol.lantern, coat: HorseCoat.chestnut, place: HolyPlace.alAqsa),
  safran(symbol: TeamSymbol.book, coat: HorseCoat.black, place: HolyPlace.mina);

  const AppTeam({required this.symbol, required this.coat, required this.place});

  final TeamSymbol symbol;
  final HorseCoat coat;

  /// The holy place this team rides out from. Mecca is not here: it is
  /// the shared destination at the centre, not anyone's corner.
  final HolyPlace place;

  Color color(AppSemanticColors colors) => switch (this) {
    AppTeam.emerald => colors.player1,
    AppTeam.saphir => colors.player2,
    AppTeam.grenat => colors.player3,
    AppTeam.safran => colors.player4,
  };
}

/// Seat order, and with it corner order: the player in seat n rides out
/// of corner n (top-left, top-right, bottom-right, bottom-left). This is
/// what puts each colour in the corner the reference board gives it, and
/// it is the ONLY place that order is written down — deriving a corner
/// from [AppTeam]'s own enum order instead is what mislabelled the two
/// bottom corners whenever fewer than four people were playing.
const List<AppTeam> kBoardSeats = [
  AppTeam.emerald, // Medina, green, top-left
  AppTeam.grenat, // Al-Aqsa, red, top-right
  AppTeam.safran, // Mina, gold, bottom-right
  AppTeam.saphir, // Arafat, blue, bottom-left
];

/// One of the four corners of the board. Mecca sits at the centre as the
/// destination and belongs to no team.
enum HolyPlace { medina, alAqsa, arafat, mina }

/// Geometric marker shown on a player's saddle-cloth and UI badges —
/// the non-color channel that keeps teams distinguishable.
enum TeamSymbol { star, compass, lantern, book }

/// A cosmetic horse coat variant. Purely visual; never the sole identifier
/// of a team (see DESIGN_SYSTEM.md §Identité des équipes).
enum HorseCoat { grayWhite, bay, chestnut, black }
