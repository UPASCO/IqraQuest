import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/models.dart';
import '../../../theme/app_team.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/knight_sprite.dart';
import '../application/classroom_board_controller.dart';
import '../data/classroom_gateway.dart';
import '../domain/classroom_state.dart';
import '../domain/lesson.dart';
import 'classroom_countdown.dart';
import 'lesson_labels.dart';

/// The board the class watches, on the projector or the classroom TV.
///
/// It is read from the back row: no control, no small print, nothing to
/// tap. The code stays on the wall the whole lesson so a latecomer can
/// still join; the question fills the screen; the answers are in an
/// order of the board's own, so the wall is never the place where the
/// right answer is always the first line.
///
/// Nothing here names a child against a score. What moves is a team's
/// horse — one square per correct answer, so the quietest pupil in the
/// room can see their own answer push it forward.
class ClassroomBoardScreen extends ConsumerWidget {
  const ClassroomBoardScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final view = ref.watch(classroomBoardProvider(code));
    final lessons = ref.watch(lessonsProvider).valueOrNull ?? const <Lesson>[];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Read from the back of the room: everything on this screen
            // is sized off the projected width, not off a phone.
            final scale = (constraints.maxWidth / 1280).clamp(0.55, 1.7);
            final room = view.room;

            if (view.error != null && room == null) {
              return _BoardMessage(
                key: const Key('board-error'),
                scale: scale,
                title: switch (view.error!) {
                  ClassroomError.unknownCode ||
                  ClassroomError.sessionOver => l10n.classroomUnknownCode,
                  _ => l10n.classroomUnreachable,
                },
              );
            }
            if (room == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: EdgeInsets.all(28 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    room: room,
                    lessons: lessons,
                    l10n: l10n,
                    scale: scale,
                  ),
                  SizedBox(height: 20 * scale),
                  Expanded(
                    child: switch (room.phase) {
                      ClassroomPhase.lobby => _Lobby(
                        room: room,
                        l10n: l10n,
                        scale: scale,
                      ),
                      ClassroomPhase.asking ||
                      ClassroomPhase.revealing => _Card(
                        view: view,
                        room: room,
                        l10n: l10n,
                        scale: scale,
                      ),
                      ClassroomPhase.over => _Over(
                        view: view,
                        room: room,
                        l10n: l10n,
                        scale: scale,
                      ),
                    },
                  ),
                  if (room.phase != ClassroomPhase.over) ...[
                    SizedBox(height: 18 * scale),
                    if (room.scoring == ClassroomScoring.individual)
                      _Ranking(room: room, l10n: l10n, scale: scale)
                    else
                      _Track(room: room, l10n: l10n, scale: scale),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The lesson on the left, the code on the right — the code never leaves
/// the wall, because a child arriving at ten past still has to get in.
class _Header extends StatelessWidget {
  const _Header({
    required this.room,
    required this.lessons,
    required this.l10n,
    required this.scale,
  });

  final ClassroomState room;
  final List<Lesson> lessons;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lesson = lessons.where((l) => l.id == room.lessonId).firstOrNull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson == null ? l10n.lesson : lessonTitle(l10n, lesson),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 30 * scale,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                room.phase == ClassroomPhase.lobby
                    ? l10n.classroomPupilCount(room.participants.length)
                    : l10n.classroomQuestionOf(
                        room.currentIndex + 1,
                        room.questionCount,
                      ),
                style: TextStyle(
                  fontSize: 22 * scale,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // In the lobby the code is already on the wall, in the size a
        // child reads from the door: printing it twice only makes the
        // header shout over it.
        if (room.phase != ClassroomPhase.lobby) ...[
          SizedBox(width: 24 * scale),
          _CodeChip(code: room.code, l10n: l10n, scale: scale),
        ],
      ],
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip({
    required this.code,
    required this.l10n,
    required this.scale,
    this.large = false,
  });

  final String code;
  final AppLocalizations l10n;
  final double scale;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: const Key('board-code'),
      padding: EdgeInsets.symmetric(
        horizontal: (large ? 44 : 22) * scale,
        vertical: (large ? 22 : 12) * scale,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: colors.goldAccent, width: 2 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.classroomBoardCode,
            style: TextStyle(
              fontSize: (large ? 22 : 15) * scale,
              letterSpacing: 1.2,
              color: colors.textSecondary,
            ),
          ),
          Text(
            code,
            style: TextStyle(
              fontSize: (large ? 96 : 34) * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: (large ? 14 : 6) * scale,
              color: colors.goldAccent,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Where a pupil's device lands when the QR is scanned: the join form,
/// with the code already filled in. Anything that is not a real web
/// origin (a phone casting to the class TV, a test) falls back to the
/// published address, so the code on screen is never a dead link.
String classroomJoinUrl(String code) {
  final base = Uri.base;
  final origin = base.scheme == 'http' || base.scheme == 'https'
      ? base.origin
      : 'https://school.iqraquest.org';
  return '$origin/#/classroom?code=$code';
}

/// The same room, as a square a phone camera understands.
class _JoinQr extends StatelessWidget {
  const _JoinQr({required this.code, required this.l10n, required this.scale});

  final String code;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final side = 190.0 * scale;
    return Column(
      key: const Key('board-qr'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            // The quiet zone has to be light whatever the room's theme:
            // a camera reads contrast, not intentions.
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: colors.goldAccent, width: 2 * scale),
          ),
          child: QrImageView(
            data: classroomJoinUrl(code),
            version: QrVersions.auto,
            size: side,
            gapless: true,
            backgroundColor: Colors.white,
            // Error correction high: a projector is dusty, a screen has
            // glare, and a child scans from four metres away.
            errorCorrectionLevel: QrErrorCorrectLevel.H,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          l10n.classroomScanToJoin,
          style: TextStyle(fontSize: 18 * scale, color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// Before the first card: the code, big enough to read from the door,
/// and the names as they arrive — the first thing a class does is look
/// for their own.
class _Lobby extends StatelessWidget {
  const _Lobby({required this.room, required this.l10n, required this.scale});

  final ClassroomState room;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      key: const Key('board-lobby'),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 28 * scale,
            runSpacing: 20 * scale,
            children: [
              _CodeChip(code: room.code, l10n: l10n, scale: scale, large: true),
              // Scanned by whoever has a camera, typed by everyone else:
              // the six characters never leave the wall.
              _JoinQr(code: room.code, l10n: l10n, scale: scale),
            ],
          ),
          SizedBox(height: 16 * scale),
          Text(
            l10n.classroomBoardHowToJoin,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24 * scale,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 28 * scale),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12 * scale,
            runSpacing: 12 * scale,
            children: [
              for (final p in room.participants)
                _NameChip(participant: p, scale: scale),
            ],
          ),
          if (room.participants.isNotEmpty) ...[
            SizedBox(height: 24 * scale),
            Text(
              l10n.classroomBoardWaitingFirst,
              style: TextStyle(
                fontSize: 22 * scale,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NameChip extends StatelessWidget {
  const _NameChip({required this.participant, required this.scale});

  final ClassroomParticipant participant;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colour = kBoardSeats[participant.team % kBoardSeats.length].color(
      context.colors,
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colour, width: 1.6 * scale),
      ),
      child: Text(
        participant.nickname,
        style: TextStyle(
          fontSize: 22 * scale,
          fontWeight: FontWeight.w700,
          color: colour,
        ),
      ),
    );
  }
}

/// The card on the wall. While the class answers, the board says only
/// how many have answered — never who, and never what. When the teacher
/// reveals, the right answer lights up and the source is named, because
/// a lesson that cannot be checked is not a lesson.
class _Card extends StatelessWidget {
  const _Card({
    required this.view,
    required this.room,
    required this.l10n,
    required this.scale,
  });

  final BoardView view;
  final ClassroomState room;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final question = view.question;
    if (question == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final revealed = room.phase == ClassroomPhase.revealing;

    return SingleChildScrollView(
      key: const Key('board-question'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40 * scale,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 22 * scale),
          LayoutBuilder(
            builder: (context, constraints) {
              // Two columns on a projector, one on a narrow screen.
              final columns = constraints.maxWidth > 700 * scale ? 2 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 16 * scale) / columns;
              return Wrap(
                spacing: 16 * scale,
                runSpacing: 16 * scale,
                children: [
                  for (var i = 0; i < question.answers.length; i++)
                    SizedBox(
                      width: width,
                      child: _BoardAnswer(
                        key: Key('board-answer-$i'),
                        text: question.answers[i],
                        right: revealed && i == question.correctAnswerIndex,
                        dimmed: revealed && i != question.correctAnswerIndex,
                        scale: scale,
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 20 * scale),
          if (!revealed)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.classroomAnsweredCount(
                    room.answeredCurrent,
                    room.participants.length,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
                // Rien quand l'enseignant révèle à la main, ce qui est
                // le réglage par défaut.
                if (room.remaining() != null) ...[
                  SizedBox(width: 22 * scale),
                  ClassroomCountdown(room: room, fontSize: 26 * scale),
                ],
              ],
            )
          else
            Container(
              key: const Key('board-reveal'),
              padding: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18 * scale),
                border: Border.all(color: colors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.explanation,
                    style: TextStyle(
                      fontSize: 24 * scale,
                      height: 1.35,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    question.sourceDisplay,
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontStyle: FontStyle.italic,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BoardAnswer extends StatelessWidget {
  const _BoardAnswer({
    super.key,
    required this.text,
    required this.right,
    required this.dimmed,
    required this.scale,
  });

  final String text;
  final bool right;
  final bool dimmed;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.symmetric(
        horizontal: 22 * scale,
        vertical: 18 * scale,
      ),
      decoration: BoxDecoration(
        color: right
            ? colors.success.withValues(alpha: 0.18)
            : colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: right ? colors.success : colors.divider,
          width: right ? 3 * scale : 1.4 * scale,
        ),
      ),
      child: Opacity(
        opacity: dimmed ? 0.45 : 1,
        child: Row(
          children: [
            if (right) ...[
              Icon(
                Icons.check_circle,
                color: colors.success,
                size: 30 * scale,
              ),
              SizedBox(width: 12 * scale),
            ],
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 28 * scale,
                  fontWeight: right ? FontWeight.w800 : FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One lane per team, and a horse on it. The lanes are the whole point
/// of playing this in a class rather than answering a worksheet: a right
/// answer from anyone moves a horse everybody can see.
class _Track extends StatelessWidget {
  const _Track({required this.room, required this.l10n, required this.scale});

  final ClassroomState room;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    // The finish line is the lesson answered by everyone — far enough
    // that a horse never runs off the wall mid-lesson.
    final target = (room.questionCount * (room.participants.length))
        .clamp(1, 1 << 30);
    return Column(
      children: [
        for (var team = 0; team < room.teamCount; team++)
          Padding(
            padding: EdgeInsets.only(bottom: 10 * scale),
            child: _Lane(
              key: Key('board-lane-$team'),
              team: team,
              squares: room.squaresOf(team),
              heads: room.headCountOf(team),
              target: target,
              l10n: l10n,
              scale: scale,
            ),
          ),
      ],
    );
  }
}

class _Lane extends StatelessWidget {
  const _Lane({
    super.key,
    required this.team,
    required this.squares,
    required this.heads,
    required this.target,
    required this.l10n,
    required this.scale,
  });

  final int team;
  final int squares;
  final int heads;
  final int target;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final seat = kBoardSeats[team % kBoardSeats.length];
    final colour = seat.color(colors);
    final progress = (squares / target).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 150 * scale,
          child: Text(
            l10n.classroomSquaresCount(squares),
            style: TextStyle(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w800,
              color: colour,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horse = 46 * scale;
              final travel = (constraints.maxWidth - horse).clamp(0.0, 1e6);
              return SizedBox(
                height: horse + 8 * scale,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: horse / 2,
                      child: Container(
                        height: 6 * scale,
                        decoration: BoxDecoration(
                          color: colour.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      left: travel * progress,
                      child: KnightSprite(team: seat, height: horse),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(width: 12 * scale),
        SizedBox(
          width: 130 * scale,
          child: Text(
            l10n.classroomPupilCount(heads),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 20 * scale,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Every pupil, ranked, when the teacher asked for it. Kept to a single
/// band at the foot of the wall so the question above it stays the
/// biggest thing in the room: a lesson is not a scoreboard with a
/// question attached.
class _Ranking extends StatelessWidget {
  const _Ranking({required this.room, required this.l10n, required this.scale});

  final ClassroomState room;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (room.pupilScores.isEmpty) return const SizedBox.shrink();

    return Column(
      key: const Key('board-ranking'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.classroomRanking,
          style: TextStyle(
            fontSize: 20 * scale,
            letterSpacing: 1.4,
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: 8 * scale),
        SizedBox(
          height: 62 * scale,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: room.pupilScores.length,
            separatorBuilder: (_, _) => SizedBox(width: 10 * scale),
            itemBuilder: (context, index) {
              final pupil = room.pupilScores[index];
              final colour = kBoardSeats[pupil.team % kBoardSeats.length]
                  .color(colors);
              return Container(
                key: Key('board-rank-$index'),
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 10 * scale,
                ),
                decoration: BoxDecoration(
                  color: colour.withValues(alpha: index == 0 ? 0.22 : 0.10),
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(
                    color: colour,
                    width: index == 0 ? 2.4 * scale : 1.2 * scale,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w900,
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    Text(
                      pupil.nickname,
                      style: TextStyle(
                        fontSize: 24 * scale,
                        fontWeight: FontWeight.w800,
                        color: colour,
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Text(
                      l10n.classroomPointsCount(pupil.correct),
                      style: TextStyle(
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The end of the lesson: who rode furthest, and — the part that makes
/// this worth a teacher's time — the cards the class got wrong most
/// often, named so they can be gone over on the spot.
class _Over extends StatelessWidget {
  const _Over({
    required this.view,
    required this.room,
    required this.l10n,
    required this.scale,
  });

  final BoardView view;
  final ClassroomState room;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hardest = room.hardestQuestions();

    return SingleChildScrollView(
      key: const Key('board-over'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.classroomSessionOver,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38 * scale,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            l10n.classroomPodium,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24 * scale,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 18 * scale),
          if (room.scoring == ClassroomScoring.individual)
            _Ranking(room: room, l10n: l10n, scale: scale),
          if (room.scoring == ClassroomScoring.individual)
            SizedBox(height: 18 * scale),
          for (final (rank, team) in room.standings.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: 10 * scale),
              child: _PodiumRow(
                key: Key('board-podium-$rank'),
                rank: rank,
                team: team,
                squares: room.squaresOf(team),
                l10n: l10n,
                scale: scale,
              ),
            ),
          if (hardest.isNotEmpty) ...[
            SizedBox(height: 24 * scale),
            Text(
              l10n.classroomToReview,
              style: TextStyle(
                fontSize: 26 * scale,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: 10 * scale),
            for (final (position, index) in hardest.indexed)
              Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: _ReviewRow(
                  key: Key('board-review-$position'),
                  question: view.cardAt(index),
                  percent: ((room.successOf(index) ?? 0) * 100).round(),
                  l10n: l10n,
                  scale: scale,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({
    super.key,
    required this.rank,
    required this.team,
    required this.squares,
    required this.l10n,
    required this.scale,
  });

  final int rank;
  final int team;
  final int squares;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final seat = kBoardSeats[team % kBoardSeats.length];
    final colour = seat.color(colors);
    final name = switch (seat) {
      AppTeam.emerald => l10n.teamEmerald,
      AppTeam.saphir => l10n.teamSaphir,
      AppTeam.grenat => l10n.teamGrenat,
      AppTeam.safran => l10n.teamSafran,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: rank == 0 ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: colour,
          width: rank == 0 ? 2.6 * scale : 1.2 * scale,
        ),
      ),
      child: Row(
        children: [
          KnightSprite(team: seat, height: 44 * scale),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Text(
              l10n.classroomTeamOf(name),
              style: TextStyle(
                fontSize: 26 * scale,
                fontWeight: FontWeight.w800,
                color: colour,
              ),
            ),
          ),
          Text(
            l10n.classroomSquaresCount(squares),
            style: TextStyle(
              fontSize: 26 * scale,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    super.key,
    required this.question,
    required this.percent,
    required this.l10n,
    required this.scale,
  });

  final Question? question;
  final int percent;
  final AppLocalizations l10n;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.school_outlined, size: 26 * scale, color: colors.warning),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Text(
            question?.question ?? '',
            style: TextStyle(fontSize: 22 * scale, color: colors.textPrimary),
          ),
        ),
        SizedBox(width: 12 * scale),
        Text(
          l10n.classroomSuccessRate(percent),
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _BoardMessage extends StatelessWidget {
  const _BoardMessage({super.key, required this.title, required this.scale});

  final String title;
  final double scale;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 34 * scale,
        fontWeight: FontWeight.w700,
        color: context.colors.textSecondary,
      ),
    ),
  );
}
