import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/teacher_gateway.dart';
import '../domain/lesson.dart';

/// Where the console is in a teacher's afternoon.
enum ConsoleStage {
  /// Still working out whether this browser is signed in.
  loading,

  /// Nobody is signed in: the address field.
  signedOut,

  /// The link has been sent and is waiting in an inbox.
  linkSent,

  /// Signed in, but nothing was bought on this address.
  noLicence,

  /// Signed in with a licence: pick a lesson and open a room.
  ready,

  /// A room is open, and this console sets its pace.
  running,
}

@immutable
class ConsoleState {
  const ConsoleState({
    this.stage = ConsoleStage.loading,
    this.email,
    this.licence,
    this.sessionId,
    this.code,
    this.error,
    this.errorLimit,
    this.busy = false,
  });

  final ConsoleStage stage;
  final String? email;
  final Licence? licence;

  /// The open room, once there is one.
  final String? sessionId;
  final String? code;

  final TeacherError? error;

  /// How many rooms the licence may run at once, when that is the error.
  final int? errorLimit;

  /// A call is in flight: the buttons wait rather than firing twice.
  final bool busy;

  ConsoleState copyWith({
    ConsoleStage? stage,
    Object? email = _unset,
    Object? licence = _unset,
    Object? sessionId = _unset,
    Object? code = _unset,
    Object? error = _unset,
    Object? errorLimit = _unset,
    bool? busy,
  }) => ConsoleState(
    stage: stage ?? this.stage,
    email: identical(email, _unset) ? this.email : email as String?,
    licence: identical(licence, _unset) ? this.licence : licence as Licence?,
    sessionId: identical(sessionId, _unset)
        ? this.sessionId
        : sessionId as String?,
    code: identical(code, _unset) ? this.code : code as String?,
    error: identical(error, _unset) ? this.error : error as TeacherError?,
    errorLimit: identical(errorLimit, _unset)
        ? this.errorLimit
        : errorLimit as int?,
    busy: busy ?? this.busy,
  );
}

const Object _unset = Object();

/// The teacher's half of a classroom session: sign in, open a room, and
/// set the pace of the lesson.
///
/// Everything here is one gesture at a time, and every one of them can
/// fail on a school network — so each says what happened rather than
/// leaving a teacher pressing a button in front of a class.
class TeacherConsoleController extends StateNotifier<ConsoleState> {
  TeacherConsoleController(this.gateway) : super(const ConsoleState());

  final TeacherGateway gateway;

  /// Picks up the tokens a magic link just delivered, or the ones this
  /// browser kept, and asks what licence they carry.
  Future<void> start({String? fragment}) async {
    try {
      final signedIn = await gateway.restore(fragment: fragment);
      if (!signedIn) {
        state = state.copyWith(stage: ConsoleStage.signedOut);
        return;
      }
      state = state.copyWith(email: gateway.email);
      await refreshLicence();
    } on TeacherException catch (e) {
      state = state.copyWith(
        stage: ConsoleStage.signedOut,
        error: e.error,
      );
    } catch (_) {
      state = state.copyWith(
        stage: ConsoleStage.signedOut,
        error: TeacherError.unreachable,
      );
    }
  }

  Future<void> sendLink(String email) async {
    state = state.copyWith(busy: true, error: null);
    try {
      await gateway.sendMagicLink(email);
      state = state.copyWith(
        stage: ConsoleStage.linkSent,
        email: email.trim(),
        busy: false,
      );
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  /// Asks again what this address is entitled to — the button a teacher
  /// presses on coming back from the payment page.
  Future<void> refreshLicence() async {
    state = state.copyWith(busy: true, error: null);
    try {
      final licence = await gateway.licence();
      state = state.copyWith(
        stage: licence == null || !licence.isValid
            ? ConsoleStage.noLicence
            : ConsoleStage.ready,
        licence: licence,
        email: gateway.email ?? state.email,
        busy: false,
      );
    } on TeacherException catch (e) {
      state = state.copyWith(
        stage: e.error == TeacherError.notSignedIn
            ? ConsoleStage.signedOut
            : state.stage,
        error: e.error,
        busy: false,
      );
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  Future<void> openSession({
    required Lesson lesson,
    int teamCount = 3,
    String boardLanguage = 'fr',
    int secondsPerQuestion = 0,
    bool keepIndividualScores = false,
  }) async {
    state = state.copyWith(busy: true, error: null);
    try {
      final opened = await gateway.openSession(
        lessonId: lesson.id,
        questionIds: lesson.questionIds,
        teamCount: teamCount,
        boardLanguage: boardLanguage,
        secondsPerQuestion: secondsPerQuestion,
        keepIndividualScores: keepIndividualScores,
      );
      state = state.copyWith(
        stage: ConsoleStage.running,
        sessionId: opened.sessionId,
        code: opened.code,
        busy: false,
      );
    } on TeacherException catch (e) {
      state = state.copyWith(
        error: e.error,
        errorLimit: e.limit,
        busy: false,
      );
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  Future<void> ask() => _advance(TeacherAction.ask);

  Future<void> reveal() => _advance(TeacherAction.reveal);

  /// Ends the lesson: the report is written and the children's names go
  /// with the session. The console lands back on the lesson list.
  Future<void> endSession() async {
    await _advance(TeacherAction.close);
    if (state.error != null) return;
    state = state.copyWith(
      stage: ConsoleStage.ready,
      sessionId: null,
      code: null,
    );
  }

  Future<void> _advance(TeacherAction action) async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;
    state = state.copyWith(busy: true, error: null);
    try {
      await gateway.advance(sessionId, action);
      state = state.copyWith(busy: false);
    } on TeacherException catch (e) {
      state = state.copyWith(error: e.error, busy: false);
    } catch (_) {
      state = state.copyWith(error: TeacherError.unreachable, busy: false);
    }
  }

  Future<void> signOut() async {
    await gateway.signOut();
    state = const ConsoleState(stage: ConsoleStage.signedOut);
  }

  void clearError() => state = state.copyWith(error: null, errorLimit: null);
}

/// The console's line to the server. Overridden in `main()`; left as the
/// in-memory fake when no Supabase project is configured, so the console
/// can be walked end to end without one.
final teacherGatewayProvider = Provider<TeacherGateway>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final teacherConsoleProvider =
    StateNotifierProvider<TeacherConsoleController, ConsoleState>(
      (ref) => TeacherConsoleController(ref.watch(teacherGatewayProvider)),
    );
