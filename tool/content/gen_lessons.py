#!/usr/bin/env python3
"""Cuts the shipped question bank into classroom lessons.

A lesson is what a teacher opens for one period: a single theme, a
single level, and enough cards to fill twenty minutes with a class
answering together — never so many that the bell rings mid-question.

The cut is deterministic: same bank in, same lessons out, so a code
handed to a class today and a code handed to the same class next week
draw the same cards in the same order. It reads the master bank (the
canonical ids, categories and levels) and writes one manifest the app,
the projected board and the teacher's console all read.

    python3 tool/content/gen_lessons.py
"""
import json
import math
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MASTER = os.path.join(ROOT, "assets/data/questions/master/questions.json")
OUT_DIR = os.path.join(ROOT, "assets/data/lessons")
OUT = os.path.join(OUT_DIR, "lessons.json")

# The order the app shows them in: the enum order in
# lib/models/question_category.dart, easiest level first.
CATEGORIES = ["prophets", "sira", "quran", "faith", "virtues"]
DIFFICULTIES = ["beginner", "easy", "medium", "hard"]

# A period, not a marathon. Eleven cards is the ceiling because a class
# answering together spends about a minute and a half on each.
MAX_CARDS = 11


def sizes(n):
    """Splits n cards into as few lessons as the ceiling allows, then
    balances them — so a theme never ends on a two-question lesson."""
    count = max(1, math.ceil(n / MAX_CARDS))
    base, rest = divmod(n, count)
    return [base + (1 if i < rest else 0) for i in range(count)]


def build(bank):
    lessons = []
    for category in CATEGORIES:
        for difficulty in DIFFICULTIES:
            ids = [
                q["id"]
                for q in bank
                if q["category"] == category and q["difficulty"] == difficulty
            ]
            if not ids:
                continue
            start = 0
            for index, size in enumerate(sizes(len(ids)), start=1):
                lessons.append(
                    {
                        "id": f"lesson_{category}_{difficulty}_{index:02d}",
                        "category": category,
                        "difficulty": difficulty,
                        "index": index,
                        "questionIds": ids[start : start + size],
                    }
                )
                start += size
    return lessons


def main():
    with open(MASTER, encoding="utf-8") as f:
        bank = json.load(f)

    lessons = build(bank)

    # What the app is entitled to assume, checked here rather than
    # discovered by a class of twenty-five.
    seen = set()
    for lesson in lessons:
        assert 5 <= len(lesson["questionIds"]) <= MAX_CARDS, lesson["id"]
        for qid in lesson["questionIds"]:
            assert qid not in seen, f"{qid} is in two lessons"
            seen.add(qid)
    assert len(seen) == len(bank), f"{len(bank) - len(seen)} cards in no lesson"

    os.makedirs(OUT_DIR, exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(
            {"version": 1, "lessons": lessons}, f, ensure_ascii=False, indent=2
        )
        f.write("\n")

    print(f"{len(lessons)} lessons, {len(seen)} cards -> {os.path.relpath(OUT, ROOT)}")
    for category in CATEGORIES:
        n = len([x for x in lessons if x["category"] == category])
        print(f"  {category:9} {n:3} lessons")


if __name__ == "__main__":
    main()
