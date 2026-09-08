import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../services/local_storage_service.dart';
import '../data/classroom_gateway.dart';
import '../domain/classroom_state.dart';

/// What the pupil's device is doing right now.
enum PupilStage {
  /// Not in a class: the join form.
  out,

  /// Talking to the room — joining, or recovering a seat after a drop.
  connecting,

  /// In the room, nothing open yet.
  waiting,

  /// A question is on the table and this pupil has not answered it.
  answering,

  /// Answered; waiting for the class.
  answered,

  /// The teacher revealed the card.
  revealed,

  /// The session ended.
  over,
}

/// The pupil's whole side of a classroom session.
@immutable
class PupilSession {
  const PupilSession({
    required this.stage,
    this.seat,
    this.state,
    this.question,
    this.answerOrder = const [],
    this.chosenIndex,
    this.wasCorrect,
    this.error,
  });

  final PupilStage stage;
  final ClassroomSeat? seat;
  final ClassroomState? state;

  /// The card on the table, in this pupil's own language, already
  /// shuffled for this device — two pupils see the same question with
  /// the answers in a different order, which is how it should be.
  final Question? question;

  /// Where each shown answer came from in the bank. The shuffle is what
  /// stops a child copying the neighbour's letter; this is how the tap
  /// is translated back before it travels.
  final List<int> answerOrder;

  /// Where the pupil tapped, in the shuffled order shown here.
  final int? chosenIndex;
  final bool? wasCorrect;

  final ClassroomError? error;

  PupilSession copyWith({
    PupilStage? stage,
    ClassroomSeat? seat,
    ClassroomState? state,
    Object? question = _unset,
    List<int>? answerOrder,
    Object? chosenIndex = _unset,
    Object? wasCorrect = _unset,
    Object? error = _unset,
  }) => PupilSession(
    stage: stage ?? this.stage,
    seat: seat ?? this.seat,
    state: state ?? this.state,
    question: identical(question, _unset) ? this.question : question as Question?,
    answerOrder: answerOrder ?? this.answerOrder,
    chosenIndex: identical(chosenIndex, _unset)
        ? this.chosenIndex
        : chosenIndex as int?,
    wasCorrect: identical(wasCorrect, _unset)
        ? this.wasCorrect
        : wasCorrect as bool?,
    error: identical(error, _unset) ? this.error : error as ClassroomError?,
  );
}

const Object _unset = Object();

/// Drives the pupil's screen: joins a room, follows the teacher's pace,
/// sends one answer per question, and gets the seat back when the school
/// wifi drops — which it will.
///
/// The pupil never chooses anything but their answer. Everything else —
/// which question, when, for how long — comes from the room. That is the
/// point of a class.
class ClassroomController extends StateNotifier<PupilSession> {
  ClassroomController({required this.gateway, required this.storage})
    : super(const PupilSession(stage: PupilStage.out));

  final ClassroomGateway gateway;
  final LocalStorageService storage;

  /// The bank, in this device's language. The room sends card ids; the
  /// text is already here.
  ///
  /// Pushed in rather than watched: the bank is read from the asset
  /// bundle and can land after a pupil has joined, and rebuilding the
  /// controller then would throw the child out of the room mid-lesson.
  List<Question> questions = const [];

  /// Takes the bank, and draws the open card if one was waiting for it.
  void useBank(List<Question> bank) {
    questions = bank;
    final room = state.state;
    if (state.question != null || room == null) return;
    if (room.phase != ClassroomPhase.asking &&
        room.phase != ClassroomPhase.revealing) {
      return;
    }
    final draw = _cardFor(room);
    if (draw != null) {
      state = state.copyWith(question: draw.card, answerOrder: draw.order);
    }
  }

  static const _seatKey = 'iqraquest.classroom.seat.v1';

  StreamSubscription<ClassroomState>? _watch;
  int _correctAnswers = 0;

  /// How many squares this pupil has brought their team.
  int get squaresBrought => _correctAnswers;

  /// A seat kept from a previous run, if the app was closed mid-class.
  ClassroomSeat? get storedSeat {
    final json = storage.getJson(_seatKey);
    if (json == null) return null;
    try {
      return ClassroomSeat.restore(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> join({required String code, required String nickname}) async {
    state = state.copyWith(stage: PupilStage.connecting, error: null);
    try {
      final seat = await gateway.join(code: code, nickname: nickname);
      await storage.setJson(_seatKey, seat.toJson());
      _correctAnswers = 0;
      _follow(seat);
    } on ClassroomException catch (e) {
      state = PupilSession(stage: PupilStage.out, error: e.error);
    } catch (_) {
      state = const PupilSession(
        stage: PupilStage.out,
        error: ClassroomError.unreachable,
      );
    }
  }

  /// Takes the kept seat back after a restart. If the room has moved on
  /// or closed, the pupil lands back on the join form rather than on a
  /// screen that pretends.
  Future<void> resume() async {
    final seat = storedSeat;
    if (seat == null) return;
    state = state.copyWith(stage: PupilStage.connecting, error: null);
    try {
      await gateway.boardState(seat.code);
      _follow(seat);
    } on ClassroomException catch (e) {
      await _forgetSeat();
      state = PupilSession(
        stage: PupilStage.out,
        error: e.error == ClassroomError.unknownCode ? null : e.error,
      );
    } catch (_) {
      state = const PupilSession(
        stage: PupilStage.out,
        error: ClassroomError.unreachable,
      );
    }
  }

  void _follow(ClassroomSeat seat) {
    _watch?.cancel();
    state = PupilSession(stage: PupilStage.waiting, seat: seat);
    _watch = gateway.watch(seat.code).listen(_onRoom, onError: (_) {
      state = state.copyWith(error: ClassroomError.unreachable);
    });
    // The stream carries changes; this fetch fills the first frame.
    unawaited(_refresh(seat.code));
  }

  Future<void> _refresh(String code) async {
    try {
      _onRoom(await gateway.boardState(code));
    } on ClassroomException catch (e) {
      state = state.copyWith(error: e.error);
    } catch (_) {
      state = state.copyWith(error: ClassroomError.unreachable);
    }
  }

  void _onRoom(ClassroomState room) {
    final previousIndex = state.state?.currentIndex;
    final movedOn =
        previousIndex != null && previousIndex != room.currentIndex;

    switch (room.phase) {
      case ClassroomPhase.lobby:
        state = state.copyWith(
          stage: PupilStage.waiting,
          state: room,
          question: null,
          chosenIndex: null,
          wasCorrect: null,
        );
      case ClassroomPhase.asking:
        // A new card: draw it in this pupil's language, shuffled for
        // this device so nobody copies the neighbour's letter.
        final alreadyAnswered =
            !movedOn && state.stage == PupilStage.answered;
        final draw = movedOn || state.question == null ? _cardFor(room) : null;
        state = state.copyWith(
          stage: alreadyAnswered ? PupilStage.answered : PupilStage.answering,
          state: room,
          question: draw?.card ?? state.question,
          answerOrder: draw?.order ?? state.answerOrder,
          chosenIndex: movedOn ? null : state.chosenIndex,
          wasCorrect: movedOn ? null : state.wasCorrect,
        );
      case ClassroomPhase.revealing:
        final shown = state.question == null ? _cardFor(room) : null;
        state = state.copyWith(
          stage: PupilStage.revealed,
          state: room,
          question: shown?.card ?? state.question,
          answerOrder: shown?.order ?? state.answerOrder,
        );
      case ClassroomPhase.over:
        unawaited(_forgetSeat());
        state = state.copyWith(stage: PupilStage.over, state: room);
    }
  }

  /// Draws the open card in this device's language, in an order of its
  /// own. The seed is the room, the seat and the question, so a device
  /// that reconnects mid-question finds the answers exactly where it
  /// left them — moving them under a child's finger would be cruel.
  ({Question card, List<int> order})? _cardFor(ClassroomState room) {
    final id = room.currentQuestionId;
    if (id == null) return null;
    for (final q in questions) {
      if (q.id != id) continue;
      final order = [0, 1, 2, 3]
        ..shuffle(
          Random(
            Object.hash(room.sessionId, state.seat?.token, room.currentIndex),
          ),
        );
      return (
        card: Question(
          id: q.id,
          category: q.category,
          difficulty: q.difficulty,
          value: q.value,
          ageLevel: q.ageLevel,
          question: q.question,
          answers: [for (final i in order) q.answers[i]],
          correctAnswerIndex: order.indexOf(q.correctAnswerIndex),
          explanation: q.explanation,
          detail: q.detail,
          sourceType: q.sourceType,
          sourceWork: q.sourceWork,
          sourceReference: q.sourceReference,
          sourceDisplay: q.sourceDisplay,
          sourceVerificationStatus: q.sourceVerificationStatus,
          consensusStatus: q.consensusStatus,
          isFree: q.isFree,
        ),
        order: order,
      );
    }
    return null;
  }

  /// Sends the tapped answer. [shownIndex] is where the pupil tapped in
  /// the shuffled order; what travels is where that answer sits in the
  /// bank, and the room decides whether it was right.
  Future<void> answer(int shownIndex) async {
    final seat = state.seat;
    final room = state.state;
    final question = state.question;
    if (seat == null || room == null || question == null) return;
    if (state.stage != PupilStage.answering) return;

    // Shown immediately: a child who tapped must see that the tap
    // landed, whatever the school wifi is doing.
    state = state.copyWith(stage: PupilStage.answered, chosenIndex: shownIndex);

    try {
      final outcome = await gateway.answer(
        code: seat.code,
        token: seat.token,
        questionIndex: room.currentIndex,
        // Back to the bank's own order — where the right answer is
        // always first, which is how the room judges it.
        choice: shownIndex < state.answerOrder.length
            ? state.answerOrder[shownIndex]
            : shownIndex,
      );
      if (outcome.correct) _correctAnswers += 1;
      state = state.copyWith(wasCorrect: outcome.correct, error: null);
    } on ClassroomException catch (e) {
      state = state.copyWith(error: e.error);
    } catch (_) {
      state = state.copyWith(error: ClassroomError.unreachable);
    }
  }

  /// Leaves the room at once. Nothing here waits on the network or on
  /// the disk: a child who says they are leaving must see the form the
  /// same frame, whatever the school wifi is doing. The seat is dropped
  /// and the stream closed behind them.
  void leave() {
    unawaited(_watch?.cancel());
    _watch = null;
    unawaited(_forgetSeat());
    _correctAnswers = 0;
    state = const PupilSession(stage: PupilStage.out);
  }

  void clearError() => state = state.copyWith(error: null);

  Future<void> _forgetSeat() => storage.remove(_seatKey);

  @override
  void dispose() {
    _watch?.cancel();
    super.dispose();
  }
}

/// The gateway the app talks to. Overridden in `main()` with the real
/// Supabase one when the project is configured, and left as the
/// in-memory fake otherwise — so a build without a server still opens
/// the screen and says, honestly, that no class can be reached.
final classroomGatewayProvider = Provider<ClassroomGateway>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final classroomControllerProvider =
    StateNotifierProvider<ClassroomController, PupilSession>((ref) {
      final controller = ClassroomController(
        gateway: ref.watch(classroomGatewayProvider),
        storage: ref.watch(localStorageProvider),
      );
      // Listened to, never watched: the bank arriving must hand the
      // controller its cards, not replace the controller and with it
      // the seat a child is sitting in.
      ref.listen(questionPoolProvider, (_, next) {
        final pool = next.valueOrNull;
        if (pool != null) controller.useBank(pool);
      }, fireImmediately: true);
      return controller;
    });
