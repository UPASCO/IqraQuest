import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/question_category.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/button_label.dart';
import '../../../widgets/content_width.dart';
import '../../../widgets/fit_or_scroll.dart';
import '../application/classroom_board_controller.dart';
import '../application/teacher_console_controller.dart';
import '../data/classroom_config.dart';
import '../data/teacher_gateway.dart';
import '../domain/classroom_state.dart';
import '../domain/lesson.dart';
import 'lesson_labels.dart';

/// The teacher's console — the web page, and only the web page.
///
/// It is where a licence is bought and a lesson is run, which is why it
/// lives on the web and not in the app: nothing on a phone ever links to
/// a payment page, and nothing in this file ships in a store build (the
/// route exists on the web alone).
///
/// The console is the only signed-in thing in IqraQuest, and what it
/// knows about a teacher is one address — the one that paid. Their
/// pupils remain what they were: a first name for the length of a
/// lesson.
class TeacherConsoleScreen extends ConsumerStatefulWidget {
  const TeacherConsoleScreen({super.key, this.fragment});

  /// What the address bar carried on arrival — the sign-in link's
  /// tokens, when a teacher has just clicked one. Passed in so the flow
  /// can be walked in a test without a browser.
  final String? fragment;

  @override
  ConsumerState<TeacherConsoleScreen> createState() =>
      _TeacherConsoleScreenState();
}

class _TeacherConsoleScreenState extends ConsumerState<TeacherConsoleScreen> {
  final _email = TextEditingController();

  QuestionCategory _category = QuestionCategory.prophets;
  QuestionDifficulty _difficulty = QuestionDifficulty.beginner;
  Lesson? _lesson;
  int _teamCount = 3;
  ClassroomScoring _scoring = ClassroomScoring.teams;
  int _secondsPerQuestion = 0;
  int? _cardCount;
  bool _shuffle = false;

  /// The board follows the console's own language until a teacher says
  /// otherwise — a French classroom projects in French without touching
  /// anything, and the pupils' phones stay in each pupil's language.
  String? _boardLanguage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(teacherConsoleProvider.notifier)
          .start(fragment: widget.fragment ?? Uri.base.fragment);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final console = ref.watch(teacherConsoleProvider);

    ref.listen<ConsoleState>(teacherConsoleProvider, (previous, next) {
      final error = next.error;
      if (error == null || error == previous?.error) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(_errorText(error, next.errorLimit, l10n))),
        );
      ref.read(teacherConsoleProvider.notifier).clearError();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teacherConsole),
        actions: [
          if (console.stage != ConsoleStage.signedOut &&
              console.stage != ConsoleStage.loading)
            TextButton(
              key: const Key('teacher-signout'),
              onPressed: () =>
                  ref.read(teacherConsoleProvider.notifier).signOut(),
              child: ButtonLabel(l10n.teacherSignOut),
            ),
        ],
      ),
      body: SafeArea(
        child: FitOrScroll(
          padding: pagePadding(context, top: 16, bottom: 20),
          child: ContentWidth(
            maxWidth: 720,
            child: switch (console.stage) {
              ConsoleStage.loading => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              ConsoleStage.signedOut ||
              ConsoleStage.linkSent => _SignIn(
                controller: _email,
                console: console,
                l10n: l10n,
                onSend: () => ref
                    .read(teacherConsoleProvider.notifier)
                    .sendLink(_email.text),
              ),
              ConsoleStage.noLicence => _NoLicence(console: console, l10n: l10n),
              ConsoleStage.ready => _Setup(
                console: console,
                l10n: l10n,
                category: _category,
                difficulty: _difficulty,
                lesson: _lesson,
                teamCount: _teamCount,
                scoring: _scoring,
                secondsPerQuestion: _secondsPerQuestion,
                cardCount: _cardCount,
                shuffle: _shuffle,
                boardLanguage: _boardLanguage ?? ref.watch(effectiveLanguageProvider),
                onCategory: (v) => setState(() {
                  _category = v;
                  _lesson = null;
                }),
                onDifficulty: (v) => setState(() {
                  _difficulty = v;
                  _lesson = null;
                }),
                onLesson: (v) => setState(() => _lesson = v),
                onTeamCount: (v) => setState(() => _teamCount = v),
                onScoring: (v) => setState(() => _scoring = v),
                onSeconds: (v) => setState(() => _secondsPerQuestion = v),
                onCardCount: (v) => setState(() => _cardCount = v),
                onShuffle: (v) => setState(() => _shuffle = v),
                onBoardLanguage: (v) => setState(() => _boardLanguage = v),
                // The lesson comes back from the picker: the list shows
                // its first entry until a teacher touches it, and that
                // one is what opening runs.
                onOpen: (lesson) => ref
                    .read(teacherConsoleProvider.notifier)
                    .openSession(
                      lesson: lesson,
                      teamCount: _teamCount,
                      scoring: _scoring,
                      secondsPerQuestion: _secondsPerQuestion,
                      cardCount: _cardCount,
                      shuffle: _shuffle,
                      boardLanguage:
                          _boardLanguage ??
                          ref.read(effectiveLanguageProvider),
                    ),
              ),
              ConsoleStage.running => _Running(console: console, l10n: l10n),
            },
          ),
        ),
      ),
    );
  }

  String _errorText(TeacherError error, int? limit, AppLocalizations l10n) =>
      switch (error) {
        TeacherError.invalidEmail => l10n.teacherInvalidEmail,
        TeacherError.noLicence => l10n.teacherNoLicence,
        TeacherError.licenceExpired => l10n.teacherLicenceExpired,
        TeacherError.tooManySessions => l10n.teacherTooManySessions(limit ?? 1),
        TeacherError.notSignedIn => l10n.teacherSignInHint,
        _ => l10n.teacherUnreachable,
      };
}

/// One address, one link. There is no password to forget, and nothing to
/// create: the address that paid is the address that gets in.
class _SignIn extends StatefulWidget {
  const _SignIn({
    required this.controller,
    required this.console,
    required this.l10n,
    required this.onSend,
  });

  final TextEditingController controller;
  final ConsoleState console;
  final AppLocalizations l10n;
  final VoidCallback onSend;

  @override
  State<_SignIn> createState() => _SignInState();
}

class _SignInState extends State<_SignIn> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sent = widget.console.stage == ConsoleStage.linkSent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.l10n.teacherSignInHint,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        TextField(
          key: const Key('teacher-email'),
          controller: widget.controller,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: widget.l10n.teacherEmailLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          key: const Key('teacher-send'),
          onPressed:
              widget.console.busy || widget.controller.text.trim().isEmpty
              ? null
              : widget.onSend,
          child: ButtonLabel(widget.l10n.teacherSendLink),
        ),
        if (sent) ...[
          const SizedBox(height: 18),
          Text(
            key: const Key('teacher-link-sent'),
            widget.l10n.teacherLinkSent(widget.console.email ?? ''),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.success),
          ),
        ],
      ],
    );
  }
}

/// Signed in, nothing bought. The payment happens on Stripe's own page —
/// the app never sees a card, and this repository never sees a price.
class _NoLicence extends ConsumerWidget {
  const _NoLicence({required this.console, required this.l10n});

  final ConsoleState console;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Column(
      key: const Key('teacher-no-licence'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (console.email != null)
          Text(
            console.email!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        const SizedBox(height: 12),
        Text(l10n.teacherNoLicence, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        // The commonest way to be stuck here is to have paid with one
        // address and signed in with another — so the screen says that
        // before it offers to sell anything.
        Text(
          l10n.teacherNoLicenceHint,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.teacherLicencePaidElsewhere,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 20),
        if (ClassroomConfig.stripeCheckoutUrl.isNotEmpty)
          ElevatedButton(
            key: const Key('teacher-buy'),
            onPressed: () => launchUrl(
              Uri.parse(ClassroomConfig.stripeCheckoutUrl),
              webOnlyWindowName: '_blank',
            ),
            child: ButtonLabel(l10n.teacherGetLicence),
          ),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const Key('teacher-refresh'),
          onPressed: console.busy
              ? null
              : () => ref.read(teacherConsoleProvider.notifier).refreshLicence(),
          child: ButtonLabel(l10n.teacherRefresh),
        ),
      ],
    );
  }
}

/// The lesson to run, and how the class is split. Everything here is a
/// choice a teacher makes in the ten seconds before the bell.
class _Setup extends ConsumerWidget {
  const _Setup({
    required this.console,
    required this.l10n,
    required this.category,
    required this.difficulty,
    required this.lesson,
    required this.teamCount,
    required this.scoring,
    required this.secondsPerQuestion,
    required this.cardCount,
    required this.shuffle,
    required this.boardLanguage,
    required this.onCategory,
    required this.onDifficulty,
    required this.onLesson,
    required this.onTeamCount,
    required this.onScoring,
    required this.onSeconds,
    required this.onCardCount,
    required this.onShuffle,
    required this.onBoardLanguage,
    required this.onOpen,
  });

  final ConsoleState console;
  final AppLocalizations l10n;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;
  final Lesson? lesson;
  final int teamCount;
  final ClassroomScoring scoring;
  final int secondsPerQuestion;
  final int? cardCount;
  final bool shuffle;
  final String boardLanguage;
  final ValueChanged<QuestionCategory> onCategory;
  final ValueChanged<QuestionDifficulty> onDifficulty;
  final ValueChanged<Lesson> onLesson;
  final ValueChanged<int> onTeamCount;
  final ValueChanged<ClassroomScoring> onScoring;
  final ValueChanged<int> onSeconds;
  final ValueChanged<int?> onCardCount;
  final ValueChanged<bool> onShuffle;
  final ValueChanged<String> onBoardLanguage;
  final ValueChanged<Lesson> onOpen;

  static const _languages = [
    ('fr', 'Français'),
    ('en', 'English'),
    ('ar', 'العربية'),
    ('es', 'Español'),
    ('pt', 'Português'),
    ('de', 'Deutsch'),
    ('tr', 'Türkçe'),
    ('id', 'Bahasa Indonesia'),
    ('ur', 'اردو'),
    ('ms', 'Bahasa Melayu'),
    ('it', 'Italiano'),
    ('nl', 'Nederlands'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final all = ref.watch(lessonsProvider).valueOrNull ?? const <Lesson>[];
    final choices = [
      for (final l in all)
        if (l.category == category && l.difficulty == difficulty) l,
    ];
    final selected =
        lesson ?? (choices.isEmpty ? null : choices.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (console.licence != null)
          Text(
            l10n.teacherLicenceUntil(
              MaterialLocalizations.of(
                context,
              ).formatFullDate(console.licence!.expiresAt),
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        const SizedBox(height: 18),
        Text(
          l10n.teacherChooseLesson,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<QuestionCategory>(
          key: const Key('teacher-category'),
          isExpanded: true,
          initialValue: category,
          decoration: InputDecoration(
            labelText: l10n.category,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final c in QuestionCategory.values)
              DropdownMenuItem(value: c, child: Text(categoryLabel(l10n, c))),
          ],
          onChanged: (v) => v == null ? null : onCategory(v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<QuestionDifficulty>(
          key: const Key('teacher-difficulty'),
          isExpanded: true,
          initialValue: difficulty,
          decoration: InputDecoration(
            labelText: l10n.levelLabel,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final d in QuestionDifficulty.values)
              DropdownMenuItem(value: d, child: Text(difficultyLabel(l10n, d))),
          ],
          onChanged: (v) => v == null ? null : onDifficulty(v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const Key('teacher-lesson'),
          isExpanded: true,
          initialValue: selected?.id,
          decoration: InputDecoration(
            labelText: l10n.lesson,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final l in choices)
              DropdownMenuItem(
                value: l.id,
                child: Text(
                  '${lessonTitle(l10n, l)} · ${l10n.lessonCardCount(l.questionCount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (id) {
            for (final l in choices) {
              if (l.id == id) onLesson(l);
            }
          },
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<ClassroomScoring>(
          key: const Key('teacher-scoring'),
          isExpanded: true,
          initialValue: scoring,
          decoration: InputDecoration(
            labelText: l10n.teacherScoringMode,
            border: const OutlineInputBorder(),
            helperMaxLines: 3,
            helperText: scoring == ClassroomScoring.individual
                ? l10n.teacherScoringIndividualHint
                : null,
          ),
          items: [
            DropdownMenuItem(
              value: ClassroomScoring.teams,
              child: Text(l10n.teacherScoringTeams),
            ),
            DropdownMenuItem(
              value: ClassroomScoring.individual,
              child: Text(l10n.teacherScoringIndividual),
            ),
          ],
          onChanged: (v) => v == null ? null : onScoring(v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: const Key('teacher-timer'),
          isExpanded: true,
          initialValue: secondsPerQuestion,
          decoration: InputDecoration(
            labelText: l10n.teacherTimer,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 0, child: Text(l10n.teacherTimerNone)),
            for (final seconds in [20, 30, 45, 60, 90])
              DropdownMenuItem(
                value: seconds,
                child: Text(l10n.teacherTimerSeconds(seconds)),
              ),
          ],
          onChanged: (v) => v == null ? null : onSeconds(v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: const Key('teacher-length'),
          isExpanded: true,
          initialValue: cardCount ?? 0,
          decoration: InputDecoration(
            labelText: l10n.teacherLength,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(
                l10n.teacherLengthAll(selected?.questionCount ?? 0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            for (final n in [5, 8])
              if ((selected?.questionCount ?? 0) > n)
                DropdownMenuItem(
                  value: n,
                  child: Text(l10n.teacherLengthShort(n)),
                ),
          ],
          onChanged: (v) => onCardCount(v == null || v == 0 ? null : v),
        ),
        const SizedBox(height: 4),
        SwitchListTile.adaptive(
          key: const Key('teacher-shuffle'),
          contentPadding: EdgeInsets.zero,
          value: shuffle,
          onChanged: onShuffle,
          title: Text(l10n.teacherShuffle),
          subtitle: Text(
            l10n.teacherShuffleHint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
        ),
        if (scoring == ClassroomScoring.teams) ...[
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: const Key('teacher-teams'),
          isExpanded: true,
          initialValue: teamCount,
          decoration: InputDecoration(
            labelText: l10n.teacherTeams(teamCount),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final n in [2, 3, 4])
              DropdownMenuItem(value: n, child: Text(l10n.teacherTeams(n))),
          ],
          onChanged: (v) => v == null ? null : onTeamCount(v),
        ),
        ],
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const Key('teacher-board-language'),
          isExpanded: true,
          initialValue: boardLanguage,
          decoration: InputDecoration(
            labelText: l10n.teacherBoardLanguage,
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final (code, name) in _languages)
              DropdownMenuItem(value: code, child: Text(name)),
          ],
          onChanged: (v) => v == null ? null : onBoardLanguage(v),
        ),
        const SizedBox(height: 22),
        ElevatedButton(
          key: const Key('teacher-open'),
          onPressed: console.busy || selected == null
              ? null
              : () => onOpen(selected),
          child: ButtonLabel(l10n.teacherOpenSession),
        ),
      ],
    );
  }
}

/// A room is open. The code is the biggest thing on the page, because a
/// teacher reads it out loud; the three buttons under it are the whole
/// of the lesson.
class _Running extends ConsumerWidget {
  const _Running({required this.console, required this.l10n});

  final ConsoleState console;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final code = console.code!;
    final room = ref.watch(classroomBoardProvider(code)).room;
    final phase = room?.phase ?? ClassroomPhase.lobby;

    return Column(
      key: const Key('teacher-running'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.teacherSessionRunning,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          code,
          key: const Key('teacher-code'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: colors.goldAccent,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('teacher-open-board'),
          onPressed: () => launchUrl(
            Uri.parse('${Uri.base.origin}/#/classroom/board/$code'),
            webOnlyWindowName: '_blank',
          ),
          icon: const Icon(Icons.cast),
          label: ButtonLabel(l10n.teacherOpenBoard),
        ),
        const SizedBox(height: 18),
        if (room != null) ...[
          Text(
            phase == ClassroomPhase.lobby
                ? l10n.classroomPupilCount(room.participants.length)
                : '${l10n.classroomQuestionOf(room.currentIndex + 1, room.questionCount)}'
                      ' · ${l10n.classroomAnsweredCount(room.answeredCurrent, room.participants.length)}',
            key: const Key('teacher-live'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
        ],
        // Only the gesture that means something right now: a teacher in
        // front of a class must not have to work out which of three
        // buttons the room will accept.
        if (phase == ClassroomPhase.asking)
          ElevatedButton(
            key: const Key('teacher-reveal'),
            onPressed: console.busy
                ? null
                : () => ref.read(teacherConsoleProvider.notifier).reveal(),
            child: ButtonLabel(l10n.teacherRevealAnswer),
          )
        else if (phase != ClassroomPhase.over)
          ElevatedButton(
            key: const Key('teacher-ask'),
            onPressed: console.busy
                ? null
                : () => ref.read(teacherConsoleProvider.notifier).ask(),
            child: ButtonLabel(l10n.teacherNextQuestion),
          ),
        const SizedBox(height: 22),
        Text(
          l10n.teacherEndSessionHint,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('teacher-end'),
          onPressed: console.busy
              ? null
              : () => ref.read(teacherConsoleProvider.notifier).endSession(),
          child: ButtonLabel(l10n.teacherEndSession),
        ),
      ],
    );
  }
}
