#!/usr/bin/env python3
"""Checks one details file against the bank's rules, before it joins
the generator's run:

    python3 tool/content/check_details.py en tool/content/details/en/prophets_a.py

Prints every problem (missing id, length, missing citation, hedge,
repeated explanation) and exits 1 if there is any. Also reports ids in
the file that the bank does not know, and the chunk's average length.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ["IQ_DETAILS_OPTIONAL"] = "1"
import gen_questions as g  # noqa: E402

lang, path = sys.argv[1], sys.argv[2]
ns = {}
with open(path, encoding="utf-8") as f:
    exec(compile(f.read(), path, "exec"), ns)
D = ns["D"]

by_id = {q["id"]: q for q in g.Q}
unknown = [i for i in D if i not in by_id]
g.Q = [by_id[i] for i in D if i in by_id]

if lang in ("fr", "en", "ar"):
    explanation_of = lambda q: q[lang]["explanation"]
else:
    tr = g.load_translations(lang)
    explanation_of = lambda q: tr[q["id"]][2]

problems = g.check_details(lang, D, explanation_of)
for p in problems:
    print("PROBLEM", p)
for u in unknown:
    print("PROBLEM", f"{u}: not a question id in the bank")
lengths = [len(D[i].strip()) for i in D]
print(f"{path}: {len(D)} details, avg {sum(lengths)//max(1,len(lengths))} chars, "
      f"min {min(lengths) if lengths else 0}, max {max(lengths) if lengths else 0}")
print("OK" if not problems and not unknown else f"{len(problems) + len(unknown)} problem(s)")
sys.exit(1 if problems or unknown else 0)
