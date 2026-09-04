/// The five canonical content categories (spec §50). Order matters for
/// category chip iteration and content-quality reports.
enum QuestionCategory { prophets, sira, quran, faith, virtues }

/// Difficulty tier. Distinct from [QuestionCategory]; every question has
/// exactly one of each.
enum QuestionDifficulty { easy, medium, hard }

extension QuestionDifficultyX on QuestionDifficulty {
  /// What a correct answer at this level is worth: harder question,
  /// more knowledge. The single source of truth for the three values —
  /// a rider on a fixed level always scores their own level, a rider on
  /// the mixed level scores the level the card actually asked.
  int get knowledgePoints => switch (this) {
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
