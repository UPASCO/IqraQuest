# IqraQuest — Content Source Policy ("Source First")

This document is binding for every question in `assets/data/questions/`.
No external religious-authority sign-off is required to ship a question —
instead, every question must independently pass every rule below. **When
in doubt about any single rule, the question is rejected and another is
chosen.** There is no partial credit and no exception process.

## 1. Acceptance rules

A question is accepted into the production bank only if **all** of the
following hold:

1. The fact is clearly established.
2. The exact source is known (work + precise reference), **or** the
   fact qualifies for the "established fact" reference class defined
   in §2bis below.
3. The source directly supports the stated answer — no leap of
   interpretation is required.
4. The fact is non-controversial among Muslims generally.
5. No particular school of jurisprudence (madhhab) is needed to determine
   the correct answer.
6. No weak (daʿīf) hadith is used.
7. No uncertain or disputed narration is used.
8. No contested doctrinal interpretation is required to answer.

## 2bis. The "established fact" reference class

A small class of facts is transmitted by tawātur (mass transmission) or
is basic descriptive terminology, verifiable identically in **any**
standard reference work: the Qurʾān has 114 sūrahs, al-Baqarah is its
longest sūrah, the Hijra went from Makkah to Madīnah, Fāṭima (رضي الله
عنها) married ʿAlī (رضي الله عنه), and the like. Demanding one specific
page citation for such facts would be false precision — no single work
is *the* source of a mass-transmitted fact — and **inventing** a precise
citation to satisfy rule §1.2 is exactly what this policy forbids.

Such a question is admitted only when ALL of these hold:

1. The fact is agreed identically across standard references — any
   standard sīra work, Qurʾānic-sciences primer, or introductory text
   states it the same way.
2. It is descriptive (a count, a name, a place, a sequence), never a
   doctrinal or interpretive claim.
3. Its `sourceReference` is prefixed `well-established` and says what
   kind of fact it is, so the class is auditable at a glance.

At the slightest doubt about whether a fact qualifies, the standing rule
applies unchanged: **do not use the question.**

## 2. Source priority

1. **Qurʾān** — facts explicitly stated in the text. Every such question
   stores the exact sūrah and āyah range (`sourceType: "quran"`).
2. **Authenticated hadith** — overwhelmingly drawn from **Ṣaḥīḥ
   al-Bukhārī** and **Ṣaḥīḥ Muslim** (`sourceType: "hadithBukhari"` /
   `"hadithMuslim"`), the two collections with the broadest scholarly
   consensus on authenticity. No other hadith collection is used in the
   v1 bank.
3. **Sīra** — only events that are established, widely known,
   non-controversial, and cross-referenced across standard biographical
   sources (`sourceType: "sira"`). Disputed ages, disputed head-counts,
   and disputed chronological details are excluded even when they are
   commonly repeated.

## 3. What is explicitly excluded

- Madhhab-dependent fiqh (e.g., hand position in prayer, secondary wuḍūʾ
  variants).
- Disputed or narrator-contested Sīra details (exact ages, disputed
  battle casualty counts, disputed chronologies).
- Anything that would need to be phrased as "according to one opinion…",
  "it is narrated that…", "some say…" — a source-first question has one
  precise, citable answer, not a survey of opinions (spec §62).
- Any claim of unanimous scholarly consensus (`ijmāʿ`). The schema field
  `consensusStatus` never claims religious consensus; its only value,
  `nonControversial`, means *"clear enough that no doctrinal arbitration
  is needed to answer this quiz question"* — see §5.

## 4. Canonical schema

Each question's **language-independent** facts live once, in
`assets/data/questions/master/questions.json`:

```json
{
  "id": "prophets_001",
  "category": "prophets",
  "difficulty": "easy",
  "ageLevel": "7+",
  "sourceType": "quran",
  "sourceWork": "Quran",
  "sourceReference": "11:37-38",
  "sourceVerificationStatus": "verified",
  "consensusStatus": "nonControversial",
  "isFree": true
}
```

`sourceVerificationStatus` has exactly two possible values in the
pipeline: `verified` and `rejected`. **There is no `pending_human_review`
state** (spec §61) — a question that has not cleared every rule in §1 is
simply not written to the production files at all; it never ships in an
intermediate state.

Per-language text for the same `id` lives in
`assets/data/questions/<lang>/questions.json`:

```json
{
  "id": "prophets_001",
  "question": "Quel prophète a construit l'arche sur l'ordre d'Allah ?",
  "answers": ["Nûh", "Ibrâhîm", "Mûsâ", "Yûsuf"],
  "correctAnswerIndex": 0,
  "explanation": "Allah ordonna à Nûh de construire l'arche.",
  "sourceDisplay": "Coran — Sourate Hûd, 11:37-38"
}
```

`QuestionRepository` (`lib/services/question_repository.dart`) joins the
two by `id` at load time and refuses to surface a question whose
`sourceVerificationStatus != verified` or `consensusStatus !=
nonControversial`.

## 5. `nonControversial`, defined precisely

Marking a question `nonControversial` is **not** a claim that a topic has
never been discussed among scholars. It means: *this specific quiz
question* can be answered correctly without needing to pick a side in any
live disagreement — because the fact is either explicit in the Qurʾān
text, or in an authenticated hadith whose plain meaning is not itself the
subject of sectarian or juristic dispute. If arriving at "the" correct
answer requires favoring one school, one narrator-chain judgment, or one
historical estimate over another, the question does not qualify — see §3.

## 6. Distractors (wrong answers)

Incorrect answer options must be:

- plausible (not absurd throwaway options — a real quiz, not a joke), and
- religiously neutral: naming another real prophet, place, or number as a
  wrong answer is fine (it is clearly marked wrong in that context); a
  distractor must never itself assert a new, uncited religious claim.

## 7. Traceability

- `content_quality/source_registry.json` — every unique `(sourceWork,
  sourceReference)` pair used in the bank, with the list of question ids
  that cite it. Generated automatically; never hand-edited (see §9).
- `content_quality/question_sources.csv` — one row per question:
  `question_id, category, source_type, source_work, source_reference,
  verification_status, consensus_status`.

## 8. Duplicate / near-duplicate detection

Before a new question is added, `tool/pre_release_check.dart` checks for:

- exact `id` collisions,
- exact duplicate `(category, sourceWork, sourceReference)` triples that
  would test the same fact twice under different ids.

Full semantic near-duplicate detection (e.g. two differently-worded
questions testing the identical fact) is a manual review step during
content authoring, not yet automated — flagged as a known gap in
`README.md`.

## 9. How the bank is generated

The v1 bank is generated from a single Python source of truth,
`tool/content/gen_questions.py`, which defines every question once (all
three shipped languages inline, side by side, so a translator/reviewer
can see them together) and then:

1. asserts every question against the schema (4 answers, valid index,
   non-empty every language field, non-empty source reference);
2. writes `assets/data/questions/master/questions.json` and
   `assets/data/questions/{fr,en,ar}/questions.json`;
3. writes `content_quality/source_registry.json` and
   `content_quality/question_sources.csv`.

Re-run it after any content edit — never hand-edit the generated JSON/CSV
files directly, or the registry and the shipped content will drift apart.

## 10. Honest scope of the v1 bank

The product brief targets 500 canonical questions × 12 languages. This
v1 ships **60 canonical questions**, fully written and reviewed against
every rule above in **3 languages (French, English, Arabic)** — see
`README.md` §Content scope for the full rationale. Scaling to 500
requires the same one-by-one sourcing discipline applied here; it is
deliberately not something to batch-generate, because rule §1 above
("at the slightest doubt, reject the question") cannot be verified in
bulk. The pipeline (schema, validators, registry, CSV, `dart` loader,
tests) is built to the full target scale and adding question #61 does not
require touching any app code.
