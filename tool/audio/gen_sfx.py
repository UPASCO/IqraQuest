"""Synthesize IqraQuest's sound effects from scratch.

Every file is generated procedurally (sine/noise synthesis) — original
audio, no third-party samples. Sound direction (spec §26–27): warm,
soft, short; a light Arabic-scale colour in the melodic cues (hijaz-like
intervals); explicitly NO Quranic recitation, NO adhan, NO casino-style
win jingles (no coin cascades, no slot bells).

Run:  python3 tool/audio/gen_sfx.py
Writes assets/audio/*.wav (mono, 22050 Hz, 16-bit).
"""

from __future__ import annotations

import os
import wave

import numpy as np

SR = 22050
OUT = "assets/audio"
rng = np.random.default_rng(7)


def t(dur):
    return np.linspace(0, dur, int(SR * dur), endpoint=False)


def env(n, a=0.005, r=0.2):
    """Attack/release envelope over n samples."""
    e = np.ones(n)
    na, nr = max(1, int(SR * a)), max(1, int(SR * r))
    na, nr = min(na, n), min(nr, n)
    e[:na] = np.linspace(0, 1, na)
    e[-nr:] *= np.linspace(1, 0, nr)
    return e


def tone(freq, dur, *, harmonics=((1, 1.0), (2, 0.35), (3, 0.12)), a=0.005, r=None, bend=0.0):
    """A warm plucked tone: few harmonics, exponential decay, slight bend."""
    x = t(dur)
    f = freq * (1 + bend * x / dur)
    phase = 2 * np.pi * np.cumsum(f) / SR
    y = sum(amp * np.sin(k * phase) for k, amp in harmonics)
    y *= np.exp(-x * (4.5 / dur))
    y *= env(len(x), a=a, r=r if r is not None else dur * 0.5)
    return y


def noise_burst(dur, *, lp=0.25, a=0.002, r=None, tremolo=0.0):
    """Filtered noise (one-pole low-pass), for taps, whooshes, water."""
    n = int(SR * dur)
    x = rng.standard_normal(n)
    y = np.empty(n)
    acc = 0.0
    for i in range(n):
        acc += lp * (x[i] - acc)
        y[i] = acc
    y /= np.abs(y).max() + 1e-9
    if tremolo > 0:
        y *= 1 - tremolo * 0.5 * (1 + np.sin(2 * np.pi * 9 * t(dur)))
    y *= env(n, a=a, r=r if r is not None else dur * 0.6)
    return y


def silence(dur):
    return np.zeros(int(SR * dur))


def mix(*parts):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def seq(*events):
    """events: (start_seconds, signal)"""
    n = max(int(SR * s) + len(sig) for s, sig in events)
    out = np.zeros(n)
    for s, sig in events:
        i = int(SR * s)
        out[i : i + len(sig)] += sig
    return out


def save(name, y, gain=0.8):
    y = y / (np.abs(y).max() + 1e-9) * gain
    data = (np.clip(y, -1, 1) * 32767).astype(np.int16)
    os.makedirs(OUT, exist_ok=True)
    with wave.open(f"{OUT}/{name}.wav", "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print(f"{name}.wav  {len(data) / SR:.2f}s")


# A hijaz-coloured base row on D: D, Eb, F#, G, A, Bb, C#.
D4 = 293.66
HIJAZ = [1.0, 16 / 15, 5 / 4, 4 / 3, 3 / 2, 8 / 5, 15 / 8, 2.0]


def note(step, octave=0):
    return D4 * HIJAZ[step % 8] * (2 ** (octave + step // 8))


# ---------------------------------------------------------------------------

# UI tap: tiny soft tick.
save("tap", mix(noise_burst(0.05, lp=0.5, r=0.04), 0.4 * tone(note(4, 1), 0.06, r=0.05)), gain=0.5)

# Gait armed: muted low pluck.
save("gait_select", tone(note(0), 0.16, r=0.12), gain=0.55)

# Gait confirmed: quick downward whoosh + pluck.
save(
    "gait_confirm",
    seq((0.0, noise_burst(0.22, lp=0.12, r=0.18)), (0.06, 0.7 * tone(note(4), 0.22, bend=-0.25))),
    gain=0.6,
)

# Horse moving: soft hoof patter (used once per move).
hoof = lambda p: mix(noise_burst(0.05, lp=0.35, r=0.045), 0.8 * tone(95 * p, 0.06, r=0.05))
save(
    "move_hoofs",
    seq(*[(i * 0.155 + rng.uniform(0, 0.012), hoof(1 + 0.06 * (i % 3))) for i in range(5)]),
    gain=0.55,
)

# Correct answer: warm two-note rise (oud-like pluck).
save(
    "correct",
    seq((0.0, tone(note(2), 0.35)), (0.16, tone(note(4), 0.5)), (0.16, 0.4 * tone(note(4), 0.5, harmonics=((2, 0.5), (4, 0.15))))),
    gain=0.65,
)

# Wrong answer: gentle low fall — kind, not punishing.
save(
    "wrong",
    seq((0.0, tone(note(1), 0.3, bend=-0.12)), (0.12, 0.7 * tone(note(0), 0.4, bend=-0.08))),
    gain=0.5,
)

# Chest offer: soft mystery shimmer.
save(
    "chest",
    seq(
        (0.0, 0.5 * noise_burst(0.5, lp=0.06, r=0.4, tremolo=0.5)),
        (0.05, 0.6 * tone(note(6), 0.3)),
        (0.22, 0.6 * tone(note(9), 0.4)),
    ),
    gain=0.55,
)

# Streak unlocked: rising three-note flourish + shimmer (no slot bells).
save(
    "streak",
    seq(
        (0.0, tone(note(0, 1), 0.25)),
        (0.12, tone(note(2, 1), 0.25)),
        (0.24, tone(note(4, 1), 0.55)),
        (0.24, 0.3 * noise_burst(0.5, lp=0.05, r=0.45)),
    ),
    gain=0.6,
)

# Oasis / arrival: water shimmer with droplets.
drop = lambda f: tone(f, 0.09, harmonics=((1, 1.0), (2, 0.2)), bend=0.35, r=0.08)
save(
    "water",
    seq(
        (0.0, 0.6 * noise_burst(0.8, lp=0.04, r=0.7, tremolo=0.4)),
        (0.10, 0.5 * drop(note(4, 1))),
        (0.32, 0.45 * drop(note(6, 1))),
        (0.55, 0.4 * drop(note(4, 1))),
    ),
    gain=0.5,
)

# Victory: short warm instrumental flourish (D hijaz arpeggio, held top).
save(
    "victory",
    seq(
        (0.00, tone(note(0), 0.5)),
        (0.16, tone(note(2), 0.5)),
        (0.32, tone(note(4), 0.6)),
        (0.48, tone(note(0, 1), 1.0)),
        (0.48, 0.5 * tone(note(4), 1.0)),
        (0.48, 0.25 * noise_burst(0.9, lp=0.04, r=0.85)),
    ),
    gain=0.7,
)

# Card drawn: a paper swish as the card leaves the deck, then a bright
# two-note turn as it lands face up. Short — it opens every turn.
save(
    "card_draw",
    seq(
        (0.00, 0.9 * noise_burst(0.16, lp=0.30, a=0.004, r=0.12)),
        (0.10, 0.5 * noise_burst(0.10, lp=0.55, r=0.08)),
        (0.18, 0.8 * tone(note(4), 0.22, r=0.16)),
        (0.30, tone(note(7), 0.40, r=0.30)),
        (0.30, 0.35 * tone(note(7), 0.40, harmonics=((2, 0.5), (3, 0.2)), r=0.30)),
    ),
    gain=0.6,
)

# End of the race: a fuller instrumental flourish for the results board.
# Same hijaz colour as the in-game victory cue, but with a frame-drum
# hit under it, the melody doubled an octave up and a long held chord —
# a "tada" that is still an instrument, not a slot machine.
drum = lambda: mix(
    tone(82, 0.32, harmonics=((1, 1.0), (2, 0.3)), bend=-0.4, r=0.28),
    0.5 * noise_burst(0.08, lp=0.22, r=0.06),
)
phrase = [(0.00, 0), (0.15, 2), (0.30, 4), (0.45, 7)]
save(
    "fanfare",
    seq(
        (0.00, 0.6 * drum()),
        *[(s, 0.8 * tone(note(n), 0.45)) for s, n in phrase],
        *[(s, 0.45 * tone(note(n, 1), 0.40, harmonics=((1, 1.0), (2, 0.2)))) for s, n in phrase],
        (0.60, 0.8 * drum()),
        (0.62, 1.3 * tone(note(0, 1), 1.6, r=1.2)),
        (0.62, 0.9 * tone(note(4), 1.6, r=1.2)),
        (0.62, 0.7 * tone(note(2, 1), 1.6, r=1.2)),
        (0.62, 0.35 * tone(note(0, 2), 1.4, harmonics=((1, 1.0), (2, 0.15)), r=1.1)),
        (0.62, 0.30 * noise_burst(1.3, lp=0.04, r=1.2, tremolo=0.3)),
        (0.95, 0.35 * tone(note(4, 1), 0.9, r=0.8)),
        (1.10, 0.30 * tone(note(7, 1), 0.9, r=0.8)),
    ),
    gain=0.78,
)

# The stable gate opens (a 5 or a 6 with a horse waiting): a latch click,
# a swing of air, then a rising three-note call — the horse is called out.
save(
    "stable_exit",
    seq(
        (0.00, 0.6 * noise_burst(0.06, lp=0.6, r=0.05)),
        (0.05, 0.5 * noise_burst(0.30, lp=0.10, r=0.26)),
        (0.12, 0.8 * tone(note(0), 0.30)),
        (0.26, 0.85 * tone(note(2), 0.32)),
        (0.40, tone(note(4), 0.65)),
        (0.40, 0.35 * tone(note(4, 1), 0.55, harmonics=((1, 1.0), (2, 0.2)))),
    ),
    gain=0.62,
)

# A six: the whole table looks up. Two bright plucks an octave apart with a
# shimmer of air behind — a lift, not a slot machine; nothing rings or
# cascades.
save(
    "six",
    seq(
        (0.00, 0.9 * tone(note(4), 0.35)),
        (0.13, tone(note(4, 1), 0.55)),
        (0.13, 0.45 * tone(note(0, 2), 0.50, harmonics=((1, 1.0), (2, 0.15)))),
        (0.15, 0.25 * noise_burst(0.55, lp=0.05, r=0.5, tremolo=0.35)),
        (0.36, 0.5 * tone(note(7, 1), 0.45, r=0.4)),
    ),
    gain=0.66,
)

# A capture: a swoop of air as the rider lands, a soft thud, then two
# falling notes as the caught horse trots home — decisive, never harsh.
save(
    "capture",
    seq(
        (0.00, 0.9 * noise_burst(0.22, lp=0.14, a=0.01, r=0.18)),
        (0.16, 0.8 * tone(70, 0.22, harmonics=((1, 1.0), (2, 0.25)), bend=-0.3, r=0.2)),
        (0.16, 0.4 * noise_burst(0.06, lp=0.3, r=0.05)),
        (0.30, 0.8 * tone(note(4), 0.28, bend=-0.08)),
        (0.46, 0.7 * tone(note(1), 0.45, bend=-0.1)),
    ),
    gain=0.6,
)
