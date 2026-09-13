import 'package:flutter/foundation.dart' show kIsWeb;
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

  /// L'historique occupe l'écran entier plutôt qu'un bloc sous le
  /// bouton : glissé dans la page de préparation, il repoussait
  /// « Ouvrir la séance » hors de vue — et le bouton que l'on vient
  /// chercher doit rester visible sans faire défiler.
  bool _history = false;

  /// L'espace du compte — abonnement, appareils, mot de passe,
  /// suppression — sur sa propre vue, pour la même raison que
  /// l'historique : rien de tout cela ne doit repousser « Ouvrir la
  /// séance » hors de l'écran.
  bool _account = false;

  /// Le site vitrine envoie « Créer un compte » ici avec `?signup=1` :
  /// le formulaire s'ouvre alors directement sur l'inscription.
  bool get _wantsSignUp => Uri.base.queryParameters['signup'] == '1';

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
          .start(
            fragment: widget.fragment ?? Uri.base.fragment,
            afterCheckout: Uri.base.queryParameters['checkout'] == 'success',
          );
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

    final colors = context.colors;
    final stage = console.stage;
    final showNav =
        !_history &&
        !_account &&
        (stage == ConsoleStage.ready ||
            stage == ConsoleStage.quotaExhausted ||
            stage == ConsoleStage.expired ||
            stage == ConsoleStage.noLicence);
    // Rien à quitter tant que personne n'est entré. `linkSent` affiche
    // encore le champ d'adresse : proposer « Se déconnecter » au-dessus
    // d'un formulaire de connexion n'a aucun sens.
    final showSignOut =
        !_history &&
        !_account &&
        stage != ConsoleStage.signedOut &&
        stage != ConsoleStage.linkSent &&
        stage != ConsoleStage.awaitingConfirmation &&
        stage != ConsoleStage.loading;

    Widget page(Widget child, {double maxWidth = 720}) => FitOrScroll(
      padding: pagePadding(context, top: 16, bottom: 20),
      child: ContentWidth(maxWidth: maxWidth, child: child),
    );

    final Widget body;
    if (_history) {
      body = page(_History(console: console, l10n: l10n));
    } else if (_account) {
      body = page(_AccountView(console: console, l10n: l10n), maxWidth: 960);
    } else {
      body = switch (stage) {
        ConsoleStage.loading => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        ),
        ConsoleStage.signedOut || ConsoleStage.linkSent => _Welcome(
          l10n: l10n,
          panel: _SignIn(
            controller: _email,
            console: console,
            l10n: l10n,
            initialSignUp: _wantsSignUp,
            onSend: () =>
                ref.read(teacherConsoleProvider.notifier).sendLink(_email.text),
            onSignIn: (password) => ref
                .read(teacherConsoleProvider.notifier)
                .signIn(_email.text, password),
            onSignUp: (password) => ref
                .read(teacherConsoleProvider.notifier)
                .signUp(_email.text, password),
          ),
        ),
        ConsoleStage.awaitingConfirmation => _Welcome(
          l10n: l10n,
          panel: _AwaitingConfirmation(
            console: console,
            l10n: l10n,
            onBack: () => ref.read(teacherConsoleProvider.notifier).signOut(),
          ),
        ),
        ConsoleStage.noLicence => _Welcome(
          l10n: l10n,
          panel: _NoLicence(console: console, l10n: l10n),
        ),
        ConsoleStage.quotaExhausted => _Welcome(
          l10n: l10n,
          panel: _QuotaExhausted(console: console, l10n: l10n),
        ),
        ConsoleStage.expired => _Welcome(
          l10n: l10n,
          panel: _Expired(console: console, l10n: l10n),
        ),
        ConsoleStage.ready => page(
          _Setup(
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
            boardLanguage:
                _boardLanguage ?? ref.watch(effectiveLanguageProvider),
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
                      _boardLanguage ?? ref.read(effectiveLanguageProvider),
                ),
          ),
        ),
        ConsoleStage.running => page(_Running(console: console, l10n: l10n)),
      };
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              l10n: l10n,
              title: _history
                  ? l10n.teacherHistory
                  : _account
                  ? l10n.teacherAccountSection
                  : null,
              onBack: _history || _account
                  ? () => setState(() {
                      _history = false;
                      _account = false;
                    })
                  : null,
              onAccount: showNav
                  ? () {
                      setState(() => _account = true);
                      ref.read(teacherConsoleProvider.notifier).loadSessions();
                    }
                  : null,
              onHistory: showNav
                  ? () {
                      setState(() => _history = true);
                      if (console.reports == null) {
                        ref.read(teacherConsoleProvider.notifier).loadReports();
                      }
                    }
                  : null,
              onSignOut: showSignOut
                  ? () => ref.read(teacherConsoleProvider.notifier).signOut()
                  : null,
            ),
            Expanded(child: body),
          ],
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
        TeacherError.tooManyLinks => l10n.teacherTooManyLinks,
        TeacherError.badCredentials => l10n.teacherBadCredentials,
        TeacherError.quotaExhausted => l10n.teacherQuotaBody,
        TeacherError.emailTaken => l10n.teacherEmailTaken,
        TeacherError.weakPassword => l10n.teacherWeakPassword,
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
    required this.onSignIn,
    required this.onSignUp,
    this.initialSignUp = false,
  });

  final TextEditingController controller;
  final ConsoleState console;
  final AppLocalizations l10n;

  /// Ouvrir directement sur l'inscription (venu du site vitrine).
  final bool initialSignUp;

  /// Envoyer le lien : la porte de secours, quand le mot de passe est
  /// perdu.
  final VoidCallback onSend;

  /// La porte de tous les jours.
  final ValueChanged<String> onSignIn;

  /// Créer un compte — gratuit, cinq parties.
  final ValueChanged<String> onSignUp;

  @override
  State<_SignIn> createState() => _SignInState();
}

class _SignInState extends State<_SignIn> {
  final _password = TextEditingController();

  /// Le lien de connexion n'est proposé qu'à qui le demande. Deux portes
  /// côte à côte laissent choisir la mauvaise : une école qui a un mot
  /// de passe n'a aucune raison d'attendre un courrier.
  bool _forgot = false;

  /// Le formulaire d'inscription : les mêmes deux champs, un autre
  /// bouton. Une école arrive ici sans compte ; c'est le premier geste.
  bool _signUp = false;

  @override
  void initState() {
    super.initState();
    _signUp = widget.initialSignUp;
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !widget.console.busy &&
      widget.controller.text.trim().isNotEmpty &&
      (_forgot || _password.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sent = widget.console.stage == ConsoleStage.linkSent;

    final text = Theme.of(context).textTheme;

    return Column(
      key: const Key('teacher-sign-in'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _forgot
              ? widget.l10n.teacherForgotPassword
              : _signUp
              ? widget.l10n.teacherCreateAccount
              : widget.l10n.teacherSignIn,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          _forgot
              ? widget.l10n.teacherSignInHint
              : _signUp
              ? widget.l10n.teacherSignUpHint
              : widget.l10n.teacherSignInPasswordHint,
          style: text.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 18),
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
        if (!_forgot) ...[
          const SizedBox(height: 12),
          TextField(
            key: const Key('teacher-password'),
            controller: _password,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_canSubmit) widget.onSignIn(_password.text);
            },
            decoration: InputDecoration(
              labelText: widget.l10n.teacherPasswordLabel,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          key: const Key('teacher-send'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: !_canSubmit
              ? null
              : _forgot
              ? widget.onSend
              : _signUp
              ? () => widget.onSignUp(_password.text)
              : () => widget.onSignIn(_password.text),
          child: ButtonLabel(
            _forgot
                ? widget.l10n.teacherSendLink
                : _signUp
                ? widget.l10n.teacherSignUpButton
                : widget.l10n.teacherSignIn,
          ),
        ),
        if (!_forgot && !sent) ...[
          const SizedBox(height: 8),
          // Les deux autres portes sur une ligne : elles restent sous
          // le bouton, jamais sous le pli.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (!_signUp)
                TextButton(
                  key: const Key('teacher-forgot'),
                  onPressed: () => setState(() => _forgot = true),
                  child: ButtonLabel(widget.l10n.teacherForgotPassword),
                ),
              TextButton(
                key: const Key('teacher-toggle-signup'),
                onPressed: () => setState(() => _signUp = !_signUp),
                child: ButtonLabel(
                  _signUp
                      ? widget.l10n.teacherHaveAccount
                      : widget.l10n.teacherCreateAccount,
                ),
              ),
            ],
          ),
        ],
        if (_forgot) ...[
          const SizedBox(height: 8),
          TextButton(
            key: const Key('teacher-forgot-back'),
            onPressed: () => setState(() => _forgot = false),
            child: ButtonLabel(widget.l10n.teacherHaveAccount),
          ),
        ],
        if (sent) ...[
          const SizedBox(height: 18),
          Text(
            key: const Key('teacher-link-sent'),
            widget.l10n.teacherLinkSent(widget.console.email ?? ''),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.success),
          ),
          const SizedBox(height: 6),
          // Un lien de connexion signé par un expéditeur que personne ne
          // connaît finit très souvent dans les indésirables. Le dire
          // ici évite une école qui conclut que le service ne marche pas.
          Text(
            key: const Key('teacher-link-spam-hint'),
            widget.l10n.teacherLinkSpamHint,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Signed in, nothing bought. The payment happens on Stripe's own page —
/// the app never sees a card, and this repository never sees a price.
/// L'abonnement, tel qu'une école le lit : ce qu'elle a, ce qui tourne,
/// et combien de temps il reste.
///
/// Volontairement une carte et pas un écran : un enseignant vient ici
/// pour ouvrir une séance, pas pour consulter sa facturation. Elle ne
/// prend de la place que lorsqu'elle a quelque chose à dire — la fin qui
/// approche.
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
    required this.l10n,
    this.showSchoolName = false,
  });

  final Account account;
  final AppLocalizations l10n;

  /// L'école se nomme-t-elle ici ? Non lorsque le titre de la page le
  /// fait déjà : la carte se glisse alors sous ce titre, et répéter le
  /// nom à deux centimètres d'intervalle ne renseigne personne.
  final bool showSchoolName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      key: const Key('teacher-account'),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: account.endingSoon ? colors.goldAccent : colors.divider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showSchoolName && account.schoolName?.isNotEmpty == true
                  ? account.schoolName!
                  : l10n.teacherAccount,
              style: text.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              account.free ? l10n.teacherOfferDiscovery : account.planLabel,
              style: text.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.teacherAccountRooms(account.roomsInUse, account.rooms),
              style: text.bodyMedium,
            ),
            // Un compte découverte n'a pas d'échéance qui compte : sa
            // limite est la jauge des parties, pas un nombre de jours.
            if (!account.free) ...[
              const SizedBox(height: 2),
              Text(
                // Un abonnement fini ne compte pas « encore zéro jour » :
                // il dit la date à laquelle il s'est arrêté. Le décompte
                // n'a de sens que sur ce qui court encore.
                account.locked
                    ? l10n.teacherAccountEndedOn(
                        account.expiresAt == null
                            ? ''
                            : MaterialLocalizations.of(context)
                                  .formatFullDate(account.expiresAt!),
                      )
                    : l10n.teacherAccountDaysLeft(account.daysLeft),
                key: const Key('teacher-account-days'),
                style: text.bodyMedium?.copyWith(
                  color: account.endingSoon
                      ? colors.goldAccent
                      : colors.textSecondary,
                  fontWeight: account.endingSoon ? FontWeight.w700 : null,
                ),
              ),
            ],
            if (account.endingSoon && !account.cancelAtPeriodEnd) ...[
              const SizedBox(height: 6),
              Text(
                account.subscribed
                    ? l10n.teacherAccountRenews
                    : l10n.teacherAccountEndingSoon,
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
            // Le renouvellement annulé ne coupe rien : la licence court
            // jusqu'à l'échéance, et la carte le dit avec la date.
            if (account.cancelAtPeriodEnd && account.expiresAt != null) ...[
              const SizedBox(height: 6),
              Text(
                key: const Key('teacher-cancel-at-period-end'),
                l10n.teacherCancelAtPeriodEnd(
                  MaterialLocalizations.of(context)
                      .formatFullDate(account.expiresAt!),
                ),
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
            if (account.free && account.freeGames != null) ...[
              const SizedBox(height: 10),
              // La barre : ce qui reste, en un coup d'œil. Le compte vient
              // du serveur — un téléphone réinstallé ne redonne rien.
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  key: const Key('teacher-quota-bar'),
                  value: account.freeGamesUsed / account.freeGames!,
                  minHeight: 8,
                  backgroundColor: colors.divider,
                  color: account.freeGamesLeft == 0
                      ? colors.error
                      : colors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.teacherFreeGamesLeft(
                  account.freeGamesLeft,
                  account.freeGames!,
                ),
                key: const Key('teacher-quota-text'),
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
            if (account.paymentFailed) ...[
              const SizedBox(height: 8),
              Text(
                l10n.teacherPaymentFailedTitle,
                key: const Key('teacher-payment-failed'),
                style: text.bodyMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.teacherPaymentFailedBody,
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// L'inscription est faite, la confirmation attend dans une boîte.
class _AwaitingConfirmation extends StatelessWidget {
  const _AwaitingConfirmation({
    required this.console,
    required this.l10n,
    required this.onBack,
  });

  final ConsoleState console;
  final AppLocalizations l10n;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      key: const Key('teacher-awaiting-confirmation'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_unread_outlined, size: 40, color: colors.primary),
        const SizedBox(height: 12),
        Text(
          l10n.teacherAwaitingConfirmationTitle,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.teacherAwaitingConfirmationBody(console.email ?? ''),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.teacherLinkSpamHint,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          key: const Key('teacher-awaiting-back'),
          onPressed: onBack,
          child: ButtonLabel(l10n.teacherSignIn),
        ),
      ],
    );
  }
}

/// Les cinq parties sont consommées. L'espace reste ouvert ; la
/// prochaine séance demande une licence.
///
/// Le bouton d'abonnement n'existe que sur le web : sur un téléphone on
/// dit où l'abonnement se gère, sans lien et sans prix — c'est la règle
/// des magasins, et une école n'achète pas depuis une tablette de toute
/// façon.
class _QuotaExhausted extends ConsumerWidget {
  const _QuotaExhausted({required this.console, required this.l10n});

  final ConsoleState console;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final account = console.account;
    return Column(
      key: const Key('teacher-quota-exhausted'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (account != null) ...[
          _AccountCard(account: account, l10n: l10n, showSchoolName: true),
          const SizedBox(height: 18),
        ],
        Text(
          l10n.teacherQuotaTitle,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.teacherQuotaBody,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 20),
        _SubscribeButton(console: console, l10n: l10n),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const Key('teacher-refresh-quota'),
          onPressed: console.busy
              ? null
              : () =>
                    ref.read(teacherConsoleProvider.notifier).refreshLicence(),
          child: ButtonLabel(l10n.teacherRefresh),
        ),
      ],
    );
  }
}

/// « S'abonner » — le serveur fabrique la page de paiement, le prix y
/// est affiché là-bas et nulle part ici. Web seulement.
class _SubscribeButton extends ConsumerWidget {
  const _SubscribeButton({
    required this.console,
    required this.l10n,
    this.label,
  });

  final ConsoleState console;
  final AppLocalizations l10n;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) {
      return Text(
        key: const Key('teacher-subscribe-on-site'),
        l10n.teacherSubscribeOnSite,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return ElevatedButton(
      key: const Key('teacher-subscribe'),
      onPressed: console.busy
          ? null
          : () async {
              final target = await ref
                  .read(teacherConsoleProvider.notifier)
                  .checkoutUrl();
              if (target != null) {
                await launchUrl(target, webOnlyWindowName: '_self');
              }
            },
      child: ButtonLabel(label ?? l10n.teacherSubscribe),
    );
  }
}

/// Mon compte : ce que l'école a, ses appareils, son abonnement, son
/// mot de passe — et la porte de sortie.
class _AccountView extends ConsumerStatefulWidget {
  const _AccountView({required this.console, required this.l10n});

  final ConsoleState console;
  final AppLocalizations l10n;

  @override
  ConsumerState<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<_AccountView> {
  final _newPassword = TextEditingController();
  bool _changed = false;
  bool _confirmDelete = false;

  @override
  void dispose() {
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final console = widget.console;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final account = console.account;
    final sessions = console.activeSessions;

    Widget panel(String title, List<Widget> children) => _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );

    // L'abonnement.
    final subscription = panel(l10n.teacherSubscriptionTitle, [
      if (account != null) ...[
        _AccountCard(account: account, l10n: l10n, showSchoolName: true),
        const SizedBox(height: 12),
        if (account.state == AccountState.quotaExhausted)
          _SubscribeButton(console: console, l10n: l10n)
        else if (account.paymentFailed)
          _PortalButton(
            console: console,
            l10n: l10n,
            label: l10n.teacherUpdatePayment,
          )
        else if (account.hasCustomer)
          _PortalButton(console: console, l10n: l10n),
      ],
    ]);

    // Les appareils.
    final devices = panel(l10n.teacherManageDevices, [
      if (account != null)
        Text(
          l10n.teacherDevicesActive(account.roomsInUse, account.rooms),
          key: const Key('teacher-devices-count'),
          style: text.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
      const SizedBox(height: 8),
      if (sessions == null)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
        )
      else if (sessions.isEmpty)
        Text(
          l10n.teacherNoActiveDevices,
          key: const Key('teacher-no-devices'),
          style: text.bodyMedium?.copyWith(color: colors.textSecondary),
        )
      else
        for (final s in sessions)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.code, style: text.titleSmall),
                      Text(
                        s.alive
                            ? l10n.teacherDeviceSince(
                                MaterialLocalizations.of(context)
                                    .formatTimeOfDay(
                                      TimeOfDay.fromDateTime(s.openedAt),
                                    ),
                              )
                            : l10n.teacherDeviceStale,
                        style: text.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  key: Key('teacher-revoke-${s.sessionId}'),
                  onPressed: console.busy
                      ? null
                      : () => ref
                            .read(teacherConsoleProvider.notifier)
                            .revokeSession(s.sessionId),
                  child: ButtonLabel(l10n.teacherDisconnectDevice),
                ),
              ],
            ),
          ),
    ]);

    // Le mot de passe.
    final password = panel(l10n.teacherChangePassword, [
      TextField(
        key: const Key('teacher-new-password'),
        controller: _newPassword,
        obscureText: true,
        onChanged: (_) => setState(() => _changed = false),
        decoration: InputDecoration(
          labelText: l10n.teacherNewPassword,
          border: const OutlineInputBorder(),
          helperText: _changed ? l10n.teacherPasswordChanged : null,
        ),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        key: const Key('teacher-change-password'),
        onPressed: console.busy || _newPassword.text.isEmpty
            ? null
            : () async {
                final ok = await ref
                    .read(teacherConsoleProvider.notifier)
                    .updatePassword(_newPassword.text);
                if (ok && mounted) {
                  _newPassword.clear();
                  setState(() => _changed = true);
                }
              },
        child: ButtonLabel(l10n.teacherChangePassword),
      ),
    ]);

    // La sortie.
    final deletion = panel(l10n.teacherDeleteAccount, [
      Text(
        l10n.teacherDeleteAccountHint,
        style: text.bodySmall?.copyWith(color: colors.textSecondary),
      ),
      const SizedBox(height: 8),
      if (!_confirmDelete)
        OutlinedButton(
          key: const Key('teacher-delete-account'),
          onPressed: console.busy
              ? null
              : () => setState(() => _confirmDelete = true),
          child: ButtonLabel(l10n.teacherDeleteAccount),
        )
      else
        ElevatedButton(
          key: const Key('teacher-confirm-delete'),
          style: ElevatedButton.styleFrom(backgroundColor: colors.error),
          onPressed: console.busy
              ? null
              : () => ref.read(teacherConsoleProvider.notifier).deleteAccount(),
          child: ButtonLabel(l10n.teacherConfirmDelete),
        ),
    ]);

    // Quatre panneaux, deux par ligne dès qu'il y a la place : tout
    // l'espace tient alors sur un écran, sans faire défiler pour
    // atteindre un bouton.
    // La largeur se lit sur l'écran, pas dans un LayoutBuilder : la page
    // vit sous un FitOrScroll, qui mesure sa hauteur intrinsèque, et un
    // LayoutBuilder ne sait pas la donner.
    final wide = MediaQuery.sizeOf(context).width >= 760;
    if (!wide) {
      return Column(
        key: const Key('teacher-account-view'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          subscription,
          const SizedBox(height: 14),
          devices,
          const SizedBox(height: 14),
          password,
          const SizedBox(height: 14),
          deletion,
        ],
      );
    }
    Widget row(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 16),
          Expanded(child: b),
        ],
      ),
    );
    return Column(
      key: const Key('teacher-account-view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(subscription, devices),
        const SizedBox(height: 16),
        row(password, deletion),
      ],
    );
  }
}

/// « Gérer mon abonnement » — le portail Stripe, fabriqué par le
/// serveur. Web seulement : sur un téléphone on n'affiche ni lien ni
/// prix.
class _PortalButton extends ConsumerWidget {
  const _PortalButton({required this.console, required this.l10n, this.label});

  final ConsoleState console;
  final AppLocalizations l10n;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) {
      return Text(
        l10n.teacherSubscribeOnSite,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return OutlinedButton(
      key: const Key('teacher-portal'),
      onPressed: console.busy
          ? null
          : () async {
              final target = await ref
                  .read(teacherConsoleProvider.notifier)
                  .portalUrl();
              if (target != null) {
                await launchUrl(target, webOnlyWindowName: '_self');
              }
            },
      child: ButtonLabel(label ?? l10n.teacherManageSubscription),
    );
  }
}

/// L'abonnement est fini.
///
/// Ce n'est pas l'écran « aucune licence » : l'école a payé, elle a un
/// historique, et ce qu'elle attend ici est un bouton pour repartir —
/// pas une découverte de l'offre. Le verrou lui-même n'est pas ici : le
/// serveur refuse d'ouvrir une séance expirée. Cet écran l'explique.
class _Expired extends ConsumerWidget {
  const _Expired({required this.console, required this.l10n});

  final ConsoleState console;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final account = console.account;
    return Column(
      key: const Key('teacher-expired'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (account != null) ...[
          _AccountCard(account: account, l10n: l10n, showSchoolName: true),
          const SizedBox(height: 18),
        ],
        Text(
          l10n.teacherExpired,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.teacherExpiredHint,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 20),
        if (kIsWeb && (console.account?.hasCustomer ?? false))
          _PortalButton(console: console, l10n: l10n, label: l10n.teacherRenew)
        else if (kIsWeb)
          _SubscribeButton(
            console: console,
            l10n: l10n,
            label: l10n.teacherRenew,
          )
        else
          // Tant qu'il n'y a pas de lien de paiement, une école dont
          // l'abonnement est fini n'avait que « Actualiser » — une
          // impasse. Elle a maintenant quelqu'un à qui écrire.
          Text(
            key: const Key('teacher-renew-by-email'),
            l10n.teacherRenewByEmail,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.textPrimary),
          ),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const Key('teacher-refresh-expired'),
          onPressed: console.busy
              ? null
              : () =>
                    ref.read(teacherConsoleProvider.notifier).refreshLicence(),
          child: ButtonLabel(l10n.teacherRefresh),
        ),
      ],
    );
  }
}

/// Les séances passées, et les notes qu'on en tire.
///
/// Rien n'est chargé tant qu'on ne le demande pas : la console s'ouvre
/// pour lancer une séance, et aller chercher un an de bilans pour
/// afficher un bouton serait payer une attente que personne n'a
/// demandée.
class _History extends ConsumerWidget {
  const _History({required this.console, required this.l10n});

  final ConsoleState console;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final reports = console.reports;
    return Column(
      key: const Key('teacher-history'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.teacherHistory,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        if (reports == null)
          const Center(
            key: Key('teacher-history-loading'),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          )
        else if (reports.isEmpty)
          Text(
            l10n.teacherHistoryEmpty,
            key: const Key('teacher-history-empty'),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.textSecondary),
          )
        else
          for (final report in reports) ...[
            _ReportTile(report: report, l10n: l10n),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _ReportTile extends ConsumerWidget {
  const _ReportTile({required this.report, required this.l10n});

  final SessionReport report;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final success = report.success;
    // Une leçon peut avoir disparu du catalogue depuis : la banque se
    // recoupe, les identifiants bougent. Un bilan d'il y a six mois doit
    // rester lisible — à défaut de titre, son code de séance.
    final lesson = ref
        .watch(lessonsProvider)
        .valueOrNull
        ?.where((l) => l.id == report.lessonId)
        .firstOrNull;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson == null ? report.code : lessonTitle(l10n, lesson),
              style: text.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              '${_shortDate(report.playedAt)} · '
              '${l10n.classroomPupilCount(report.pupils)}',
              style: text.bodySmall?.copyWith(color: colors.textSecondary),
            ),
            if (success != null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.teacherHistorySuccess((success * 100).round()),
                style: text.bodyMedium,
              ),
            ],
            // Les notes, seulement quand la séance comptait par élève et
            // que les prénoms n'ont pas encore été effacés.
            if (report.perPupil case final pupils?) ...[
              const SizedBox(height: 10),
              Text(l10n.teacherMarksTitle, style: text.titleSmall),
              Text(
                l10n.teacherMarksHint(report.perQuestion.length),
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 6),
              for (final pupil in pupils)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(pupil.nickname, style: text.bodyMedium),
                      ),
                      Text(
                        _mark(pupil, report.perQuestion.length),
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ] else if (report.pupils > 0) ...[
              const SizedBox(height: 6),
              Text(
                l10n.teacherHistoryNamesGone,
                style: text.bodySmall?.copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// « 14 / 20 », ou « 13,5 / 20 » — la demi-note s'écrit comme on
  /// l'écrit à la main, pas « 13.5 ».
  static String _mark(ReportPupil pupil, int cards) {
    final mark = pupil.mark(cards: cards);
    if (mark == null) return '—';
    final body = mark == mark.roundToDouble()
        ? '${mark.round()}'
        : mark.toStringAsFixed(1).replaceAll('.', ',');
    return '$body / 20';
  }

  static String _shortDate(DateTime at) =>
      '${at.day.toString().padLeft(2, '0')}/'
      '${at.month.toString().padLeft(2, '0')}/${at.year}';
}

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
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.textSecondary),
          ),
        const SizedBox(height: 12),
        Text(
          l10n.teacherNoLicence,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        // The commonest way to be stuck here is to have paid with one
        // address and signed in with another — so the screen says that
        // before it offers to sell anything.
        Text(
          l10n.teacherNoLicenceHint,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.teacherLicencePaidElsewhere,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 20),
        // Sur le web, la caisse ; sur un téléphone, ni lien ni prix —
        // une phrase qui dit où l'abonnement se gère.
        if (kIsWeb)
          _SubscribeButton(
            console: console,
            l10n: l10n,
            label: l10n.teacherGetLicence,
          )
        else
          Text(
            key: const Key('teacher-subscribe-on-site'),
            l10n.teacherSubscribeOnSite,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const Key('teacher-refresh'),
          onPressed: console.busy
              ? null
              : () =>
                    ref.read(teacherConsoleProvider.notifier).refreshLicence(),
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
    final selected = lesson ?? (choices.isEmpty ? null : choices.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (console.licence?.schoolName != null)
          Text(
            console.licence!.schoolName!,
            key: const Key('teacher-school'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        // L'échéance tient sur la ligne qui existe déjà, et n'ajoute rien
        // à la hauteur de la page. Une carte d'abonnement glissée ici
        // repoussait « Ouvrir la séance » hors de l'écran : un
        // avertissement qui cache le bouton qu'on est venu chercher est
        // un mauvais échange. Quand la fin approche, cette ligne change
        // de ton et compte les jours ; l'espace client complet est à un
        // geste, dans l'historique.
        if (console.licence != null)
          Text(
            switch (console.account) {
              final a? when a.endingSoon => l10n.teacherAccountDaysLeft(
                a.daysLeft,
              ),
              _ => l10n.teacherLicenceUntil(
                MaterialLocalizations.of(context)
                    .formatFullDate(console.licence!.expiresAt),
              ),
            },
            key: const Key('teacher-licence-line'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: console.account?.endingSoon ?? false
                  ? colors.goldAccent
                  : colors.textSecondary,
              fontWeight: (console.account?.endingSoon ?? false)
                  ? FontWeight.w700
                  : null,
            ),
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
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.textSecondary),
          ),
        ),
        if (scoring == ClassroomScoring.teams) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: const Key('teacher-teams'),
            isExpanded: true,
            initialValue: teamCount,
            decoration: InputDecoration(
              labelText: l10n.teacherTeamsLabel,
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
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: colors.textSecondary),
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
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.textSecondary),
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

/// La barre du haut : la marque, et les trois portes d'une école
/// entrée. Pas de `AppBar` Material — elle vit sur un sous-domaine, mais
/// elle appartient au site, et sa barre le dit.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.l10n,
    this.title,
    this.onBack,
    this.onAccount,
    this.onHistory,
    this.onSignOut,
  });

  final AppLocalizations l10n;
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onAccount;
  final VoidCallback? onHistory;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    // Trois boutons à texte demandent de la place ; en dessous, des
    // icônes avec leur infobulle.
    final narrow = MediaQuery.sizeOf(context).width < 820;

    Widget action(Key key, IconData icon, String label, VoidCallback? onTap) =>
        narrow
        ? IconButton(
            key: key,
            tooltip: label,
            onPressed: onTap,
            icon: Icon(icon, color: colors.textPrimary),
          )
        : TextButton.icon(
            key: key,
            onPressed: onTap,
            icon: Icon(icon, size: 18),
            label: ButtonLabel(label),
          );

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              key: const Key('teacher-history-back'),
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
          // La marque ramène au site : une école venue de iqraquest.org
          // ne doit pas croire avoir changé de maison.
          Flexible(
            child: InkWell(
              key: const Key('teacher-brand'),
              borderRadius: BorderRadius.circular(8),
              onTap: () => launchUrl(Uri.https('iqraquest.org')),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: colors.goldAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    // Étroit : un seul mot — le titre de la vue, sinon
                    // la marque. Large : la marque, puis la vue.
                    Flexible(
                      child: Text(
                        narrow ? (title ?? 'IqraQuest') : 'IqraQuest',
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!narrow) ...[
                      Text(
                        ' · ',
                        style: text.titleMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          title ?? l10n.schoolMode,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          if (onAccount != null)
            action(
              const Key('teacher-account-open'),
              Icons.person_outline,
              l10n.teacherAccountSection,
              onAccount,
            ),
          if (onHistory != null)
            action(
              const Key('teacher-history-open'),
              Icons.history,
              l10n.teacherHistory,
              onHistory,
            ),
          if (onSignOut != null)
            action(
              const Key('teacher-signout'),
              Icons.logout,
              l10n.teacherSignOut,
              onSignOut,
            ),
        ],
      ),
    );
  }
}

/// La carte qui porte un formulaire ou une offre : une surface claire,
/// un bord fin, une ombre courte.
class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: colors.primaryDark.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}

/// L'accueil : d'un côté ce que le mode École fait, de l'autre la porte.
///
/// Sur un écran large, les deux se partagent la hauteur entière : rien
/// ne défile, chaque bouton est sous les yeux. Sur un téléphone, le
/// panneau se réduit à un titre et trois points, et la carte suit.
class _Welcome extends StatelessWidget {
  const _Welcome({required this.l10n, required this.panel});

  final AppLocalizations l10n;
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 880;
        if (wide) {
          return Row(
            children: [
              Expanded(flex: 11, child: _Pitch(l10n: l10n)),
              Expanded(
                flex: 9,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _Panel(child: panel),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return FitOrScroll(
          padding: pagePadding(context, top: 16, bottom: 20),
          child: ContentWidth(
            maxWidth: 520,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PitchCompact(l10n: l10n),
                const SizedBox(height: 16),
                _Panel(child: panel),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Le panneau de gauche : ce que la classe va vivre, en trois points.
class _Pitch extends StatelessWidget {
  const _Pitch({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    const ivory = Color(0xFFFFF9ED);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryDark, colors.primary],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(48, 40, 40, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.schoolMode.toUpperCase(),
            style: text.labelLarge?.copyWith(
              color: colors.goldAccent,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.teacherPitchTitle,
            key: const Key('teacher-pitch'),
            style: text.displaySmall?.copyWith(
              color: ivory,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              l10n.teacherPitchBody,
              style: text.bodyLarge?.copyWith(
                color: ivory.withValues(alpha: 0.86),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 32),
          for (final point in _pitchPoints(l10n)) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ivory.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(point.$1, color: colors.goldAccent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    point.$2,
                    style: text.titleMedium?.copyWith(color: ivory),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 10),
          Text(
            l10n.teacherBackToSite,
            style: text.bodySmall?.copyWith(
              color: colors.goldAccent,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Le même panneau, replié pour un téléphone : le titre, et les trois
/// points en pastilles.
class _PitchCompact extends StatelessWidget {
  const _PitchCompact({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.teacherPitchTitle,
          key: const Key('teacher-pitch'),
          style: text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final point in _pitchPoints(l10n))
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(point.$1, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(point.$2, style: text.bodySmall),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

List<(IconData, String)> _pitchPoints(AppLocalizations l10n) => [
  (Icons.card_giftcard_outlined, l10n.teacherPitchFree),
  (Icons.devices_outlined, l10n.teacherPitchDevices),
  (Icons.grade_outlined, l10n.teacherPitchMarks),
];
