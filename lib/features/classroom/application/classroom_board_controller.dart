import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/models.dart';
import '../../../services/question_repository.dart';
import '../data/classroom_gateway.dart';
import '../domain/classroom_state.dart';
import '../domain/shuffle_seed.dart';
import 'classroom_controller.dart';

/// What the projector is showing.
@immutable
class BoardView {
  const BoardView({
    this.room,
    this.question,
    this.bank = const [],
    this.error,
    this.loading = true,
  });

  final ClassroomState? room;

  /// The open card, in the board's own language and in the board's own
  /// order — never the bank's, where the right answer is always first.
  final Question? question;

  /// The lesson's cards, in the board's language, so the closing screen
  /// can name the ones the class found hard.
  final List<Question> bank;

  final ClassroomError? error;
  final bool loading;

  BoardView copyWith({
    ClassroomState? room,
    Object? question = _unset,
    List<Question>? bank,
    Object? error = _unset,
    bool? loading,
  }) => BoardView(
    room: room ?? this.room,
    question: identical(question, _unset)
        ? this.question
        : question as Question?,
    bank: bank ?? this.bank,
    error: identical(error, _unset) ? this.error : error as ClassroomError?,
    loading: loading ?? this.loading,
  );

  /// The card at [index] of the lesson, in the board's language.
  Question? cardAt(int index) {
    final ids = room?.questionIds ?? const [];
    if (index < 0 || index >= ids.length) return null;
    for (final q in bank) {
      if (q.id == ids[index]) return q;
    }
    return null;
  }
}

const Object _unset = Object();

/// Drives the projected board: follows the room, and draws the open card
/// in the language the session was opened in.
///
/// The board is a reader, never a writer. It cannot join, answer or
/// advance anything — the teacher's console does that, and the wall only
/// shows what the room already agreed on.
class ClassroomBoardController extends StateNotifier<BoardView> {
  ClassroomBoardController({
    required this.gateway,
    required this.repository,
    required this.code,
  }) : super(const BoardView());

  final ClassroomGateway gateway;
  final QuestionRepository repository;
  final String code;

  StreamSubscription<ClassroomState>? _watch;
  String? _loadedLanguage;

  Future<void> start() async {
    try {
      final room = await gateway.boardState(code);
      await _apply(room);
      _watch = gateway.watch(code).listen(
        (room) => unawaited(_apply(room)),
        onError: (_) =>
            state = state.copyWith(error: ClassroomError.unreachable),
      );
    } on ClassroomException catch (e) {
      state = state.copyWith(error: e.error, loading: false);
    } catch (_) {
      state = state.copyWith(
        error: ClassroomError.unreachable,
        loading: false,
      );
    }
  }

  Future<void> _apply(ClassroomState room) async {
    if (!mounted) return;
    if (_loadedLanguage != room.boardLanguage) {
      final bank = await repository.loadAll(room.boardLanguage);
      if (!mounted) return;
      _loadedLanguage = room.boardLanguage;
      state = state.copyWith(bank: bank);
    }
    state = state.copyWith(
      room: room,
      question: _cardFor(room),
      error: null,
      loading: false,
    );
  }

  /// The open card, with its answers in an order of the board's own.
  ///
  /// The wall must not be the one place in the room where the right
  /// answer is always the first line. The order is seeded on the session
  /// and the question, so a projector that reconnects mid-question puts
  /// the answers back exactly where the class last saw them.
  Question? _cardFor(ClassroomState room) {
    final id = room.currentQuestionId;
    if (id == null) return null;
    for (final q in state.bank) {
      if (q.id != id) continue;
      final order = [0, 1, 2, 3]
        ..shuffle(Random(stableSeed([room.sessionId, room.currentIndex])));
      return Question(
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
      );
    }
    return null;
  }

  @override
  void dispose() {
    _watch?.cancel();
    super.dispose();
  }
}

final classroomBoardProvider = StateNotifierProvider.autoDispose
    .family<ClassroomBoardController, BoardView, String>((ref, code) {
      final controller = ClassroomBoardController(
        gateway: ref.watch(classroomGatewayProvider),
        repository: ref.watch(questionRepositoryProvider),
        code: code,
      );
      unawaited(controller.start());
      return controller;
    });
