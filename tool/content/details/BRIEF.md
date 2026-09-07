# The "learn more" detail — writers' brief

Every question in the bank carries, in every language, a **detail**: the
paragraph the player reads when they tap "Learn more" after answering.
The card already showed a one-line explanation and the source; the
detail exists to add what those could not. It is the lesson behind the
card.

## What a detail is

Three to five sentences, roughly 45 to 90 words (English), that do
three things, in this order:

1. **Quote the source itself.** The verse, with its number; or the
   hadith, with its narrator and its number as given in the reference;
   or, for a "well-established" fact, the plain statement of the fact
   and where a reader finds it (the Qur'an, the sira, the practice of
   every Muslim). The number in `sourceReference` must appear in the
   text — the checker looks for it.
2. **Set it in its context**, only from the same source or the Qur'an:
   which story the verse belongs to, what came just before or after,
   who is speaking to whom, what occasion the hadith records.
3. **Say what is taken from it** — what a Muslim learns or does because
   of it — in one sentence, without turning it into a ruling.

## What a detail is not

- **Nothing the cited source, or the Qur'an, does not state.** No
  second hadith the reference does not cover, no date or figure that
  differs between biographies, no name of a place or person the source
  leaves unnamed.
- **Nothing contested.** No positions of schools of law, no matters
  scholars differ on, no sectarian points, no opinions of commentators
  presented as fact. If a sentence needs "some scholars", "it is said",
  "probably", "scholars differ", delete the sentence: the checker
  rejects those wordings.
- **No repetition of the explanation.** The player has read it. Build
  on it.
- **No moralising and no exclamation.** A calm, warm, precise voice a
  child of nine can follow and an adult respects.

## Form

- Plain prose, one paragraph, no bullet points, no headings, no
  markdown.
- Honorifics as in the bank: `ﷺ` after the Prophet's name (Muhammad ﷺ,
  the Prophet ﷺ); "peace be upon him" for other prophets only where the
  bank's language does so.
- Names as the bank spells them in that language (English: Nuh, Ibrahim,
  Musa, 'Isa, Yusuf; French: Nûh, Ibrâhîm, Mûsâ, 'Îsâ, Yûsuf; Arabic in
  Arabic).
- Qur'an quotations in the language of the detail, faithful to the
  meaning, marked with quotation marks and the verse number in
  parentheses: "…" (14:39).
- Hadith numbers as in the reference: "Sahih al-Bukhari 8", "Sahih
  Muslim 2564".

## Two examples

**prophets_252** — source Quran 14:39. Explanation: "Praise be to Allah
who granted me, despite old age, Isma'il and Ishaq" (14:39).

> Ibrahim says these words in a long prayer at the end of Surah Ibrahim,
> after settling his family in the barren valley of Makkah: "Praise be to
> Allah, who has granted me in old age Isma'il and Ishaq. Indeed, my Lord
> is the Hearer of supplication" (14:39). In the same prayer he asks that
> he and his descendants keep up the prayer (14:40). The verse names his
> two sons together and shows the way he received them: not as his own
> achievement, but as a gift he thanked Allah for after long waiting.

**faith_001** — source Sahih al-Bukhari 8. Explanation: The Prophet ﷺ
said: "Islam is built on five."

> The hadith is narrated by Ibn 'Umar and recorded in Sahih al-Bukhari
> 8: "Islam is built on five: the testimony that there is no god but
> Allah and that Muhammad is the Messenger of Allah, establishing the
> prayer, giving the zakat, the pilgrimage, and fasting Ramadan." The
> image is a house standing on five supports: each pillar carries the
> whole, and the testimony of faith comes first because the other four
> rest on it. A Muslim learns the five by name as the frame of the whole
> religion.

## File format

One Python file per chunk, `tool/content/details/<lang>/<chunk>.py`:

```python
"""English — details, prophets_a (58 questions)."""

D = {
"prophets_001": "…",
"prophets_002": "…",
}
```

Every id of the chunk, once; strings only; no other code. The generator
(`tool/content/gen_questions.py`, `check_details`) rejects a detail
that is missing, shorter than 220 characters (160 for Arabic and Urdu),
longer than 900, that repeats the explanation, that does not cite the
reference number, or that hedges.
