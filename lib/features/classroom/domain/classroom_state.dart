import 'package:flutter/foundation.dart';

/// Where a classroom session is, right now.
///
/// The teacher holds the pace: a session waits in the lobby while pupils
/// join, opens one question at a time, shows the answer when the room is
/// ready, and ends when the last card is revealed. Nothing advances on
/// its own — a class is not a tournament, and two pupils still typing
/// are a reason to wait, not a reason to lose.
enum ClassroomPhase { lobby, asking, revealing, over }

/// How the room keeps score.
///
/// [teams] is the default and the one a large class wants: two to four
/// horses, and every child's right answer pushes one of them. [individual]
/// gives each pupil their own line on the wall — the teacher asks for it
/// deliberately, because a ranking that shows the first also shows the
/// last, in front of everyone.
enum ClassroomScoring { teams, individual }

/// One pupil's live score, sent only in [ClassroomScoring.individual].
@immutable
class ClassroomPupilScore {
  const ClassroomPupilScore({
    required this.nickname,
    required this.team,
    required this.correct,
  });

  final String nickname;
  final int team;
  final int correct;

  factory ClassroomPupilScore.fromJson(Map<String, dynamic> json) =>
      ClassroomPupilScore(
        nickname: json['nickname'] as String,
        team: (json['team'] as num?)?.toInt() ?? 0,
        correct: (json['correct'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'team': team,
    'correct': correct,
  };
}

/// One pupil, as the room sees them: a first name and a team. That is
/// the whole of it — there is no account behind this, and nothing here
/// outlives the session.
@immutable
class ClassroomParticipant {
  const ClassroomParticipant({required this.nickname, required this.team});

  final String nickname;
  final int team;

  factory ClassroomParticipant.fromJson(Map<String, dynamic> json) =>
      ClassroomParticipant(
        nickname: json['nickname'] as String,
        team: (json['team'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {'nickname': nickname, 'team': team};
}

/// Everything the board and the pupils' devices need to draw the room.
///
/// It carries no answer of any pupil and no name against a score: the
/// only numbers here are per team, plus how many have answered the
/// question on the table. A projector faces twenty-five children; it
/// must never be the thing that tells the class who got it wrong.
@immutable
class ClassroomState {
  const ClassroomState({
    required this.sessionId,
    required this.code,
    required this.lessonId,
    required this.boardLanguage,
    required this.teamCount,
    required this.questionIds,
    required this.phase,
    required this.currentIndex,
    required this.participants,
    required this.squaresByTeam,
    required this.answeredCurrent,
    this.scoring = ClassroomScoring.teams,
    this.pupilScores = const [],
    this.answersByQuestion = const {},
    this.correctByQuestion = const {},
    this.askedAt,
    this.secondsPerQuestion = 0,
  });

  final String sessionId;
  final String code;
  final String lessonId;

  /// The language the projected board is drawn in. A pupil's own device
  /// stays in the pupil's language: the same card is read in French on
  /// one desk and in Arabic on the next.
  final String boardLanguage;

  final int teamCount;

  /// Fixed when the session opens, so every device shows the same card
  /// at the same moment. Only the ids travel — the questions themselves
  /// are in every app already.
  final List<String> questionIds;

  final ClassroomPhase phase;
  final int currentIndex;
  final List<ClassroomParticipant> participants;

  /// One square per correct answer. A team of eight with six right
  /// answers moves six squares — which is what makes every child's
  /// answer visibly worth something on the wall, the weakest included.
  final Map<int, int> squaresByTeam;

  /// How many pupils have answered the open question. Never who, never
  /// what.
  final int answeredCurrent;

  /// How the room keeps score, chosen by the teacher when the session
  /// was opened.
  final ClassroomScoring scoring;

  /// Every pupil's running score, best first. Empty unless the teacher
  /// asked for [ClassroomScoring.individual] — in the team mode the wall
  /// carries no name against a score at all.
  final List<ClassroomPupilScore> pupilScores;

  /// How many answers each question of the lesson received, by index.
  /// Counts only: this is what lets the board close on the cards the
  /// class found hard, without ever naming a child.
  final Map<int, int> answersByQuestion;

  /// How many of those answers were right, by index.
  final Map<int, int> correctByQuestion;

  final DateTime? askedAt;

  /// Zero means the teacher reveals by hand, which is the default: a
  /// countdown is a good game and a poor lesson.
  final int secondsPerQuestion;

  int get questionCount => questionIds.length;

  /// The card on the table, or null in the lobby and at the end.
  String? get currentQuestionId =>
      phase == ClassroomPhase.lobby || phase == ClassroomPhase.over
      ? null
      : (currentIndex >= 0 && currentIndex < questionIds.length
            ? questionIds[currentIndex]
            : null);

  bool get isLast => currentIndex >= questionIds.length - 1;

  int squaresOf(int team) => squaresByTeam[team] ?? 0;

  /// Teams from the furthest along to the last, ties left in team order
  /// so the board does not reshuffle between two identical frames.
  List<int> get standings {
    final teams = [for (var t = 0; t < teamCount; t++) t];
    teams.sort((a, b) {
      final bySquares = squaresOf(b).compareTo(squaresOf(a));
      return bySquares != 0 ? bySquares : a.compareTo(b);
    });
    return teams;
  }

  int headCountOf(int team) =>
      participants.where((p) => p.team == team).length;

  /// The share of right answers on one card, or null if nobody answered
  /// it — a card the class never reached says nothing about the class.
  double? successOf(int questionIndex) {
    final answers = answersByQuestion[questionIndex] ?? 0;
    if (answers == 0) return null;
    return (correctByQuestion[questionIndex] ?? 0) / answers;
  }

  /// The cards worth going over again, hardest first: the ones the class
  /// got wrong most often. Ties keep lesson order, so the list on the
  /// wall does not reshuffle itself while the teacher reads it.
  List<int> hardestQuestions({int take = 3}) {
    final answered = [
      for (var i = 0; i < questionIds.length; i++)
        if ((answersByQuestion[i] ?? 0) > 0) i,
    ];
    answered.sort((a, b) {
      final byScore = successOf(a)!.compareTo(successOf(b)!);
      return byScore != 0 ? byScore : a.compareTo(b);
    });
    // A card everyone answered right is not a card to go over.
    return [for (final i in answered) if (successOf(i)! < 1) i].take(take).toList();
  }

  /// What is left of the timer, or null when there is none.
  ///
  /// Counted from the server's own stamp against the device's clock, so
  /// a few seconds of drift are possible — the server grants two seconds
  /// of grace on top, and a classroom timer that is a second out is a
  /// timer nobody notices.
  Duration? remaining({DateTime? now}) {
    if (secondsPerQuestion <= 0 || askedAt == null) return null;
    if (phase != ClassroomPhase.asking) return null;
    final elapsed = (now ?? DateTime.now()).difference(askedAt!);
    final left = Duration(seconds: secondsPerQuestion) - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  static Map<int, int> _intMap(Object? raw) {
    final out = <int, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        final k = int.tryParse('$key');
        if (k != null) out[k] = (value as num).toInt();
      });
    }
    return out;
  }

  factory ClassroomState.fromJson(Map<String, dynamic> json) {
    final squares = _intMap(json['squaresByTeam']);
    return ClassroomState(
      sessionId: json['sessionId'] as String,
      code: json['code'] as String,
      lessonId: json['lessonId'] as String,
      boardLanguage: json['boardLanguage'] as String? ?? 'fr',
      teamCount: (json['teamCount'] as num).toInt(),
      questionIds: [
        for (final id in json['questionIds'] as List? ?? const []) '$id',
      ],
      phase: ClassroomPhase.values.byName(json['phase'] as String),
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      participants: [
        for (final p in json['participants'] as List? ?? const [])
          ClassroomParticipant.fromJson(p as Map<String, dynamic>),
      ],
      squaresByTeam: squares,
      answeredCurrent: (json['answeredCurrent'] as num?)?.toInt() ?? 0,
      scoring: switch (json['scoring']) {
        'individual' => ClassroomScoring.individual,
        _ => ClassroomScoring.teams,
      },
      pupilScores: [
        for (final p in json['pupilScores'] as List? ?? const [])
          ClassroomPupilScore.fromJson(p as Map<String, dynamic>),
      ],
      answersByQuestion: _intMap(json['answersByQuestion']),
      correctByQuestion: _intMap(json['correctByQuestion']),
      askedAt: switch (json['askedAt']) {
        final String s => DateTime.tryParse(s)?.toLocal(),
        _ => null,
      },
      secondsPerQuestion: (json['secondsPerQuestion'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'code': code,
    'lessonId': lessonId,
    'boardLanguage': boardLanguage,
    'teamCount': teamCount,
    'questionIds': questionIds,
    'phase': phase.name,
    'currentIndex': currentIndex,
    'participants': [for (final p in participants) p.toJson()],
    'squaresByTeam': {
      for (final entry in squaresByTeam.entries) '${entry.key}': entry.value,
    },
    'answeredCurrent': answeredCurrent,
    'scoring': scoring.name,
    'pupilScores': [for (final p in pupilScores) p.toJson()],
    'answersByQuestion': {
      for (final entry in answersByQuestion.entries) '${entry.key}': entry.value,
    },
    'correctByQuestion': {
      for (final entry in correctByQuestion.entries) '${entry.key}': entry.value,
    },
    'askedAt': askedAt?.toUtc().toIso8601String(),
    'secondsPerQuestion': secondsPerQuestion,
  };

  ClassroomState copyWith({
    ClassroomPhase? phase,
    int? currentIndex,
    List<ClassroomParticipant>? participants,
    Map<int, int>? squaresByTeam,
    int? answeredCurrent,
    ClassroomScoring? scoring,
    List<ClassroomPupilScore>? pupilScores,
    Map<int, int>? answersByQuestion,
    Map<int, int>? correctByQuestion,
    Object? askedAt = _unset,
  }) => ClassroomState(
    sessionId: sessionId,
    code: code,
    lessonId: lessonId,
    boardLanguage: boardLanguage,
    teamCount: teamCount,
    questionIds: questionIds,
    phase: phase ?? this.phase,
    currentIndex: currentIndex ?? this.currentIndex,
    participants: participants ?? this.participants,
    squaresByTeam: squaresByTeam ?? this.squaresByTeam,
    answeredCurrent: answeredCurrent ?? this.answeredCurrent,
    scoring: scoring ?? this.scoring,
    pupilScores: pupilScores ?? this.pupilScores,
    answersByQuestion: answersByQuestion ?? this.answersByQuestion,
    correctByQuestion: correctByQuestion ?? this.correctByQuestion,
    askedAt: identical(askedAt, _unset) ? this.askedAt : askedAt as DateTime?,
    secondsPerQuestion: secondsPerQuestion,
  );
}

const Object _unset = Object();

/// What a pupil gets back for entering a code and a first name: which
/// team they ride for, and the token that lets them come back after the
/// school wifi drops — good for this session and nothing else.
@immutable
class ClassroomSeat {
  const ClassroomSeat({
    required this.sessionId,
    required this.code,
    required this.participantId,
    required this.token,
    required this.nickname,
    required this.team,
  });

  final String sessionId;
  final String code;
  final String participantId;
  final String token;
  final String nickname;
  final int team;

  factory ClassroomSeat.fromJson(Map<String, dynamic> json, {
    required String code,
    required String nickname,
  }) => ClassroomSeat(
    sessionId: json['sessionId'] as String,
    code: code,
    participantId: json['participantId'] as String,
    token: '${json['token']}',
    nickname: nickname,
    team: (json['team'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'code': code,
    'participantId': participantId,
    'token': token,
    'nickname': nickname,
    'team': team,
  };

  factory ClassroomSeat.restore(Map<String, dynamic> json) => ClassroomSeat(
    sessionId: json['sessionId'] as String,
    code: json['code'] as String,
    participantId: json['participantId'] as String,
    token: json['token'] as String,
    nickname: json['nickname'] as String,
    team: (json['team'] as num).toInt(),
  );
}
