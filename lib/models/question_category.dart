/// The five canonical content categories (spec §50). Order matters for
/// category chip iteration and content-quality reports.
enum QuestionCategory { prophets, sira, quran, faith, virtues }

/// Difficulty tier. Distinct from [QuestionCategory]; every question has
/// exactly one of each.
enum QuestionDifficulty { easy, medium, hard }

/// Where a fact is anchored. Ordered by source priority (spec §53):
/// Qur'an first, then the two most rigorously authenticated hadith
/// collections, then well-established, non-controversial Sīra events.
enum SourceType { quran, hadithBukhari, hadithMuslim, sira }

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
