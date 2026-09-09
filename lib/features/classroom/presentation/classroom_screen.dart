import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_team.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../application/classroom_controller.dart';
import '../data/classroom_gateway.dart';
import 'classroom_countdown.dart';

/// The pupil's whole share of a class session: a code, a first name,
/// then four answers at a time.
///
/// Everything here is free and account-less. What the child gives is a
/// first name that lives as long as the lesson; what they get is the
/// same card as the projector, in their own language, with the answers
/// in an order of their own so the neighbour's screen is no help.
class ClassroomScreen extends ConsumerStatefulWidget {
  const ClassroomScreen({super.key, this.initialCode});

  /// The code carried by a scanned QR, already filled in so a child only
  /// has their own first name left to type.
  final String? initialCode;

  @override
  ConsumerState<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends ConsumerState<ClassroomScreen> {
  final _code = TextEditingController();
  final _nickname = TextEditingController();

  @override
  void initState() {
    super.initState();
    final scanned = widget.initialCode?.trim().toUpperCase();
    if (scanned != null && scanned.isNotEmpty) _code.text = scanned;
    // A pupil whose phone died mid-lesson comes straight back to the
    // room rather than to a form they would have to ask about.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(classroomControllerProvider.notifier).resume();
    });
  }

  @override
  void dispose() {
    _code.dispose();
    _nickname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(classroomControllerProvider);

    ref.listen<PupilSession>(classroomControllerProvider, (previous, next) {
      final error = next.error;
      if (error == null || error == previous?.error) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_errorText(error, l10n))));
      ref.read(classroomControllerProvider.notifier).clearError();
    });

    return PopScope(
      // Leaving a class is deliberate: a stray back gesture in the
      // middle of a lesson must not drop the child out of the room.
      canPop: session.stage == PupilStage.out,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave(l10n);
      },
      child: Scaffold(
        appBar: AppBar(
          // « Rejoindre une classe » n'est vrai qu'avant d'entrer, et
          // ce titre est trop long pour la barre d'un téléphone : il
          // s'y coupait en « Rejoindre une cla… ». Une fois dans la
          // salle, le titre devient le code — court, et c'est le seul
          // renseignement qu'on redemande à un enfant.
          title: Text(
            session.stage == PupilStage.out
                ? l10n.classroomJoin
                : (session.state?.code ?? l10n.classroomJoin),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                session.stage == PupilStage.out ? _goHome() : _confirmLeave(l10n),
          ),
          actions: [
            if (session.stage != PupilStage.out)
              TextButton(
                key: const Key('classroom-leave'),
                onPressed: () => _confirmLeave(l10n),
                child: ButtonLabel(l10n.classroomLeave),
              ),
          ],
        ),
        body: SafeArea(child: _body(session, l10n)),
      ),
    );
  }

  Widget _body(PupilSession session, AppLocalizations l10n) => switch (session
      .stage) {
    PupilStage.out => _JoinForm(
      code: _code,
      nickname: _nickname,
      l10n: l10n,
      onJoin: () => ref
          .read(classroomControllerProvider.notifier)
          .join(code: _code.text, nickname: _nickname.text),
    ),
    PupilStage.connecting => _Centered(
      key: const Key('classroom-connecting'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 18),
          Text(l10n.classroomReconnecting),
        ],
      ),
    ),
    PupilStage.waiting => _Waiting(session: session, l10n: l10n),
    PupilStage.answering ||
    PupilStage.answered ||
    PupilStage.revealed => _Playing(
      session: session,
      l10n: l10n,
      onAnswer: (i) => ref.read(classroomControllerProvider.notifier).answer(i),
    ),
    PupilStage.over => _Over(
      session: session,
      l10n: l10n,
      squares: ref.read(classroomControllerProvider.notifier).squaresBrought,
      onLeave: _goHome,
    ),
  };

  void _goHome() =>
      context.canPop() ? context.pop() : context.go('/home');

  Future<void> _confirmLeave(AppLocalizations l10n) async {
    final session = ref.read(classroomControllerProvider);
    if (session.stage == PupilStage.out || session.stage == PupilStage.over) {
      _goHome();
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.classroomLeave),
        content: Text(l10n.classroomPrivacyNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              MaterialLocalizations.of(dialogContext).cancelButtonLabel,
            ),
          ),
          FilledButton(
            key: const Key('classroom-leave-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: ButtonLabel(l10n.classroomLeave),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ref.read(classroomControllerProvider.notifier).leave();
    _goHome();
  }

  String _errorText(ClassroomError error, AppLocalizations l10n) =>
      switch (error) {
        ClassroomError.unknownCode => l10n.classroomUnknownCode,
        ClassroomError.sessionOver => l10n.classroomSessionOver,
        ClassroomError.sessionFull => l10n.classroomSessionFull,
        ClassroomError.emptyNickname => l10n.classroomNicknameLabel,
        ClassroomError.tooLate => l10n.classroomTooLate,
        ClassroomError.notOpen => l10n.classroomWaitingHint,
        ClassroomError.unknownParticipant ||
        ClassroomError.unreachable => l10n.classroomUnreachable,
      };
}

/// A code and a first name. Nothing else is asked, and the note under
/// the form says so plainly — a child should be able to read what the
/// app keeps of them.
class _JoinForm extends StatefulWidget {
  const _JoinForm({
    required this.code,
    required this.nickname,
    required this.l10n,
    required this.onJoin,
  });

  final TextEditingController code;
  final TextEditingController nickname;
  final AppLocalizations l10n;
  final VoidCallback onJoin;

  @override
  State<_JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<_JoinForm> {
  bool get _ready =>
      widget.code.text.trim().length >= 4 &&
      widget.nickname.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colors = context.colors;
    return FitOrScroll(
      padding: pagePadding(context, top: 20, bottom: 16),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(Icons.co_present_outlined, size: 56, color: colors.primary),
            const SizedBox(height: 18),
            TextField(
              key: const Key('classroom-code'),
              controller: widget.code,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              maxLength: 6,
              onChanged: (_) => setState(() {}),
              // The code is read off a whiteboard: it is typed in
              // capitals, spaced out, and never autocorrected into a word.
              inputFormatters: [UpperCaseFormatter()],
              autocorrect: false,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                letterSpacing: 6,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: l10n.classroomCodeLabel,
                counterText: '',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('classroom-nickname'),
              controller: widget.nickname,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              maxLength: 24,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _ready ? widget.onJoin() : null,
              decoration: InputDecoration(
                labelText: l10n.classroomNicknameLabel,
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 17, color: colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.classroomPrivacyNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
            ElevatedButton(
              key: const Key('classroom-join'),
              onPressed: _ready ? widget.onJoin : null,
              child: ButtonLabel(l10n.classroomJoin),
            ),
          ],
        ),
      ),
    );
  }
}

/// Types what a whiteboard shows: capitals only.
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => TextEditingValue(
    text: newValue.text.toUpperCase(),
    selection: newValue.selection,
  );
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.session, required this.l10n});

  final PupilSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final team = session.seat?.team ?? 0;
    return _Centered(
      key: const Key('classroom-waiting'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TeamBadge(team: team, l10n: l10n),
          const SizedBox(height: 22),
          Text(
            l10n.classroomWaiting,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.classroomWaitingHint,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 26),
          if (session.state != null)
            Text(
              '${session.state!.participants.length}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

/// The card, then the four answers as big targets. Once tapped, the
/// screen stops being a place to act and becomes a place to look: the
/// verdict belongs to the board, and to the teacher's voice.
class _Playing extends StatelessWidget {
  const _Playing({
    required this.session,
    required this.l10n,
    required this.onAnswer,
  });

  final PupilSession session;
  final AppLocalizations l10n;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final question = session.question;
    final room = session.state;
    if (question == null || room == null) {
      return const _Centered(child: CircularProgressIndicator());
    }
    final colors = context.colors;
    final answered = session.stage != PupilStage.answering;
    final revealed = session.stage == PupilStage.revealed;

    return FitOrScroll(
      padding: pagePadding(context, top: 12, bottom: 16),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // The badge yields first: a long team name on a narrow
                // phone shortens, it never pushes the counter off screen.
                Flexible(
                  child: _TeamBadge(
                    team: session.seat?.team ?? 0,
                    l10n: l10n,
                    small: true,
                  ),
                ),
                const SizedBox(width: 12),
                if (room.remaining() != null) ...[
                  ClassroomCountdown(room: room, fontSize: 15),
                  const SizedBox(width: 12),
                ],
                Text(
                  l10n.classroomQuestionOf(
                    room.currentIndex + 1,
                    room.questionCount,
                  ),
                  maxLines: 1,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              question.question,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(height: 1.3),
            ),
            const SizedBox(height: 18),
            for (var i = 0; i < question.answers.length; i++) ...[
              _AnswerTile(
                key: Key('classroom-answer-$i'),
                text: question.answers[i],
                chosen: session.chosenIndex == i,
                // The right answer appears only when the teacher shows
                // it — never a second before the rest of the class.
                right: revealed && i == question.correctAnswerIndex,
                revealed: revealed,
                dimmed: answered && session.chosenIndex != i,
                onTap: answered ? null : () => onAnswer(i),
              ),
              const SizedBox(height: 10),
            ],
            if (session.stage == PupilStage.answered) ...[
              const SizedBox(height: 6),
              _Note(
                icon: Icons.check_circle_outline,
                title: l10n.classroomAnswerSent,
                body: l10n.classroomAnswerSentHint,
              ),
            ],
            if (revealed) ...[
              const SizedBox(height: 6),
              _Note(
                icon: switch (session.wasCorrect) {
                  true => Icons.check_circle,
                  false => Icons.school_outlined,
                  // Personne n'a tapé : ni juste, ni faux. Dire « faux »
                  // à un enfant qui n'a pas eu le temps de répondre est
                  // une petite injustice, et elle se voit.
                  null => Icons.menu_book_outlined,
                },
                title: switch (session.wasCorrect) {
                  true => l10n.correctAnswer,
                  false => l10n.incorrectAnswer,
                  null => l10n.classroomAnswerMissed,
                },
                body: question.explanation,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Over extends StatelessWidget {
  const _Over({
    required this.session,
    required this.l10n,
    required this.squares,
    required this.onLeave,
  });

  final PupilSession session;
  final AppLocalizations l10n;
  final int squares;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return _Centered(
      key: const Key('classroom-over'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 56,
            color: context.colors.primary,
          ),
          const SizedBox(height: 18),
          Text(
            l10n.classroomSessionOver,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.classroomYourScore(squares),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            key: const Key('classroom-done'),
            onPressed: onLeave,
            child: ButtonLabel(l10n.backToHome),
          ),
        ],
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.team, required this.l10n, this.small = false});

  final int team;
  final AppLocalizations l10n;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final seat = kBoardSeats[team % kBoardSeats.length];
    final colour = seat.color(context.colors);
    final name = switch (seat) {
      AppTeam.emerald => l10n.teamEmerald,
      AppTeam.saphir => l10n.teamSaphir,
      AppTeam.grenat => l10n.teamGrenat,
      AppTeam.safran => l10n.teamSafran,
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 12 : 18,
        vertical: small ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colour, width: 1.6),
      ),
      child: Text(
        l10n.classroomTeamOf(name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (small
                ? Theme.of(context).textTheme.labelLarge
                : Theme.of(context).textTheme.titleMedium)
            ?.copyWith(color: colour, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    super.key,
    required this.text,
    required this.chosen,
    required this.right,
    required this.revealed,
    required this.dimmed,
    required this.onTap,
  });

  final String text;
  final bool chosen;
  final bool right;
  final bool revealed;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Au moment de la correction, la couleur doit dire la vérité. Un choix
    // faux mis en avant en vert — la couleur d'accord de l'application —
    // félicitait l'enfant pour son erreur, et laissait la bonne réponse en
    // retrait derrière sa coche. Le vert n'appartient donc qu'à la bonne
    // réponse ; un choix faux, une fois révélé, se signale en rouge.
    const rightGreen = Color(0xFF1F7A4D);
    final wrongChoice = chosen && revealed && !right;
    final border = right
        ? rightGreen
        : (wrongChoice
              ? colors.error
              : (chosen ? colors.primary : colors.divider));
    return Opacity(
      // La bonne réponse ne s'efface jamais : c'est elle qu'on est venu voir.
      opacity: dimmed && !right ? 0.5 : 1,
      child: Material(
        color: right
            ? rightGreen.withValues(alpha: 0.12)
            : (wrongChoice
                  ? colors.error.withValues(alpha: 0.10)
                  : (chosen
                        ? colors.primary.withValues(alpha: 0.12)
                        : colors.surfaceElevated)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: chosen || right ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            // A thumb, on a phone held by a nine-year-old in a hurry.
            constraints: const BoxConstraints(minHeight: 62),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(height: 1.25),
                    ),
                  ),
                  if (right)
                    const Icon(Icons.check_circle, color: rightGreen)
                  else if (wrongChoice)
                    Icon(Icons.cancel_outlined, color: colors.error),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: pagePadding(context, top: 20, bottom: 20),
      child: ContentWidth(child: child),
    ),
  );
}
