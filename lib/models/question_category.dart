/// The five canonical content categories (spec §50). Order matters for
/// category chip iteration and content-quality reports.
enum QuestionCategory { prophets, sira, quran, faith, virtues }

/// Difficulty tier. Distinct from [QuestionCategory]; every question has
/// exactly one of each.
/// The four levels a question is graded on, easiest first. [beginner]
/// sits below [easy]: the facts every Muslim household already knows —
/// the Prophet's ﷺ name, the book, the direction of prayer — so a very
/// young or brand-new player can join the same table and still answer.
enum QuestionDifficulty { beginner, easy, medium, hard }

extension QuestionDifficultyX on QuestionDifficulty {
  /// What a correct answer at this level is worth: harder question,
  /// more knowledge. The single source of truth for the three values —
  /// a rider on a fixed level always scores their own level, a rider on
  /// the mixed level scores the level the card actually asked.
  int get knowledgePoints => switch (this) {
    // The beginner level scores like the easy one on purpose: a child
    // answering at their level sits on the same scoreboard as everyone
    // else rather than playing for nothing.
    QuestionDifficulty.beginner => 1,
    QuestionDifficulty.easy => 1,
    QuestionDifficulty.medium => 2,
    QuestionDifficulty.hard => 3,
  };
}

/// Where a fact is anchored. Ordered by source priority (spec §53):
/// Qur'an first, then the two most rigorously authenticated hadith
/// collections, then well-established, non-controversial Sīra events.
/// `creed` covers descriptive articles-of-faith facts admitted under the
/// "established fact" reference class (CONTENT_SOURCE_POLICY.md §2bis).
enum SourceType { quran, hadithBukhari, hadithMuslim, sira, creed }

/// A question may only ship in the production bank when its
/// verification pipeline status is [verified] — see
/// CONTENT_SOURCE_POLICY.md. No `pending_human_review` state exists in the
/// shipped schema by design (spec §61).
enum SourceVerificationStatus { verified, rejected }

/// `nonControversial` means: clear enough that no doctrinal arbitrage
/// (madhhab, disputed narration, disputed chronology) is needed to answer
/// the quiz question. It is deliberately *not* a claim of religious
/// "ijmā'" (spec §55).
enum ConsensusStatus { nonControversial }
