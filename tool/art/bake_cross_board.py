"""Bakes the classic cross board — the *jeu des petits chevaux* plate.

The board is set among four holy places, with Mecca at the centre as the
shared destination every horse rides to:

    Medina (green)   top-left        Arafat (blue)    top-right
    Mina (gold)      bottom-left     Al-Aqsa (red)    bottom-right

Geometry is the standard 15x15 cross: a 52-square circuit and a 5-step
escalier per team. The plate and the anchor table below come from the
SAME grid, so a horse can never be drawn on a square the art does not
have — the failure of the previous plate, which indexed 52 logical
squares into 24 painted tiles.

Everything is drawn at 2x and downsampled, which is what keeps the gold
hairlines and the arabesques clean at phone size.

Outputs:
    assets/board/cross_board.webp
    lib/widgets/board/cross_anchors.g.dart
"""

from __future__ import annotations

import math
import os

from PIL import Image, ImageDraw, ImageFilter

ROOT = "/home/user/IqraQuest"
OUT_IMAGE = f"{ROOT}/assets/board/cross_board.webp"
OUT_ANCHORS = f"{ROOT}/lib/widgets/board/cross_anchors.g.dart"

N = 15                  # the board is a 15x15 grid of cells
SIZE = 1536             # final plate resolution, square
SS = 2                  # supersample while drawing, then downsample
MARGIN = 0.058 * SIZE
CELL = (SIZE - 2 * MARGIN) / N

# ---- palette ---------------------------------------------------------
FRAME_DEEP = (16, 58, 62)
FRAME_DARK = (9, 36, 40)
GOLD = (198, 158, 74)
GOLD_LIGHT = (238, 210, 140)
CREAM = (246, 240, 223)
CREAM_HI = (255, 252, 243)
CREAM_LO = (219, 208, 180)

# Matches AppSemanticColors.player1..4 so a piece and its corner always
# read as the same team.
TEAM_COLORS = {
    "medina": (14, 107, 82),      # emerald — player1
    "arafat": (30, 91, 140),      # saphir  — player2
    "alaqsa": (140, 42, 61),      # grenat  — player3
    "mina": (193, 122, 31),       # safran  — player4
}

# Which corner a team occupies follows from the circuit: a team enters at
# index t * 13 and climbs the escalier reached just before it, so its
# corner is the one its start square touches.
#   t0 start (6, 0)   upper row of the left arm    -> top-left
#   t1 start (0, 8)   right side of the top arm    -> top-right
#   t2 start (8, 14)  lower row of the right arm   -> bottom-right
#   t3 start (14, 6)  left side of the bottom arm  -> bottom-left
CORNERS = {
    "medina": ((0, 6), (0, 6)),
    "arafat": ((0, 6), (9, 15)),
    "alaqsa": ((9, 15), (9, 15)),
    "mina": ((9, 15), (0, 6)),
}

LANES = {
    "medina": [(7, c) for c in range(1, 6)],          # in from the left
    "arafat": [(r, 7) for r in range(1, 6)],          # down from the top
    "alaqsa": [(7, c) for c in range(13, 8, -1)],     # in from the right
    "mina": [(r, 7) for r in range(13, 8, -1)],       # up from the bottom
}

# Index in this list IS the engine's team index (AppTeam order).
TEAM_ORDER = ["medina", "arafat", "alaqsa", "mina"]

CENTER = (7, 7)


def track_cells():
    """The 52 circuit cells, in riding order."""
    cells = []
    cells += [(6, c) for c in range(0, 6)]
    cells += [(r, 6) for r in range(5, -1, -1)]
    cells += [(0, 7)]
    cells += [(r, 8) for r in range(0, 6)]
    cells += [(6, c) for c in range(9, 15)]
    cells += [(7, 14)]
    cells += [(8, c) for c in range(14, 8, -1)]
    cells += [(r, 8) for r in range(9, 15)]
    cells += [(14, 7)]
    cells += [(r, 6) for r in range(14, 8, -1)]
    cells += [(8, c) for c in range(5, -1, -1)]
    cells += [(7, 0)]
    assert len(cells) == 52, len(cells)
    return cells


# ---- geometry helpers (final-resolution coordinates) -----------------

def cell_box(row, col, inset=0.0):
    x0 = MARGIN + col * CELL + inset
    y0 = MARGIN + row * CELL + inset
    return (x0, y0, x0 + CELL - 2 * inset, y0 + CELL - 2 * inset)


def cell_center(row, col):
    x0, y0, x1, y1 = cell_box(row, col)
    return ((x0 + x1) / 2, (y0 + y1) / 2)


def corner_rect(name):
    (r0, r1), (c0, c1) = CORNERS[name]
    x0, y0, _, _ = cell_box(r0, c0)
    _, _, x1, y1 = cell_box(r1 - 1, c1 - 1)
    return (x0, y0, x1, y1)


def corner_medallion(name):
    """The illustration disc, pushed away from the board's centre so the
    stables never sit on top of the place they depict."""
    x0, y0, x1, y1 = corner_rect(name)
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    dx, dy = _inward(name)
    r = (x1 - x0) * 0.305
    return (cx - dx * (x1 - x0) * 0.085, cy - dy * (y1 - y0) * 0.085, r)


def _inward(name):
    """Unit direction from this corner toward the middle of the board."""
    x0, y0, x1, y1 = corner_rect(name)
    mid = SIZE / 2
    return (1 if (x0 + x1) / 2 < mid else -1, 1 if (y0 + y1) / 2 < mid else -1)


def stable_slots(name):
    """Four waiting slots, clustered in the corner nearest the centre —
    beside the medallion, never over it."""
    x0, y0, x1, y1 = corner_rect(name)
    w, h = x1 - x0, y1 - y0
    dx, dy = _inward(name)
    cx = (x0 + x1) / 2 + dx * w * 0.315
    cy = (y0 + y1) / 2 + dy * h * 0.315
    g = CELL * 0.42
    return [(cx + ox * g, cy + oy * g)
            for ox, oy in [(-1, -1), (1, -1), (-1, 1), (1, 1)]]


# ---- drawing helpers (supersampled canvas) ---------------------------

def S(v):
    """Scale a final-resolution length onto the supersampled canvas."""
    return v * SS


def sbox(box):
    return tuple(v * SS for v in box)


def vgrad(size, top, bottom):
    """A vertical gradient tile, used for depth without any texture."""
    w, h = size
    g = Image.new("RGB", (1, max(1, h)))
    px = g.load()
    for y in range(max(1, h)):
        t = y / max(1, h - 1)
        px[0, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    return g.resize((max(1, w), max(1, h)))


def star8(d, cx, cy, r, fill, rot=0.0, inner=0.42):
    pts = []
    for i in range(16):
        a = rot + i * math.pi / 8
        rad = r if i % 2 == 0 else r * inner
        pts.append((cx + rad * math.cos(a), cy + rad * math.sin(a)))
    d.polygon(pts, fill=fill)


def arabesque(d, box, color, width, lobes=16):
    """A scalloped gold line — the ornament running inside each frame."""
    x0, y0, x1, y1 = box
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    rx, ry = (x1 - x0) / 2, (y1 - y0) / 2
    pts = []
    steps = 480
    for i in range(steps + 1):
        a = 2 * math.pi * i / steps
        k = 1 + 0.035 * math.sin(lobes * a)
        pts.append((cx + rx * k * math.cos(a), cy + ry * k * math.sin(a)))
    d.line(pts, fill=color, width=max(1, int(width)), joint="curve")


def bevel_tile(d, row, col, fill, rim=GOLD, rim_w=2.2):
    """A square with a lit top edge and a shadow under it."""
    box = sbox(cell_box(row, col, inset=CELL * 0.055))
    r = S(CELL * 0.17)
    x0, y0, x1, y1 = box
    d.rounded_rectangle((x0, y0 + S(1.6), x1, y1 + S(2.0)), radius=r,
                        fill=(0, 0, 0, 55))
    d.rounded_rectangle(box, radius=r, fill=fill, outline=rim,
                        width=max(1, int(S(rim_w))))
    d.arc((x0 + S(2), y0 + S(2), x1 - S(2), y1 - S(2)), 190, 350,
          fill=(*CREAM_HI, 150), width=max(1, int(S(1.6))))


# ---- the four medallion scenes ---------------------------------------
# Simplified, reverent illustrations: architecture and landscape only,
# never a figure.

def _sky(im, top, bottom):
    im.paste(vgrad(im.size, top, bottom), (0, 0))


def scene_medina(size):
    """Al-Masjid an-Nabawi: the green dome under a night sky."""
    im = Image.new("RGB", size)
    _sky(im, (28, 52, 74), (196, 178, 140))
    d = ImageDraw.Draw(im, "RGBA")
    w, h = size
    d.ellipse((w * 0.74, h * 0.10, w * 0.87, h * 0.23), fill=(246, 240, 210))
    d.ellipse((w * 0.78, h * 0.09, w * 0.92, h * 0.23), fill=(28, 52, 74))
    d.rectangle((0, h * 0.62, w, h), fill=(214, 196, 158))
    for x in (0.16, 0.30, 0.70, 0.84):
        d.rectangle((w * x - w * 0.018, h * 0.24, w * x + w * 0.018, h * 0.66),
                    fill=(238, 232, 214))
        d.polygon([(w * x - w * 0.026, h * 0.24), (w * x + w * 0.026, h * 0.24),
                   (w * x, h * 0.15)], fill=(226, 214, 188))
    d.rectangle((w * 0.34, h * 0.44, w * 0.66, h * 0.68), fill=(236, 228, 208))
    d.pieslice((w * 0.36, h * 0.24, w * 0.64, h * 0.54), 180, 360,
               fill=(24, 96, 68))
    d.arc((w * 0.36, h * 0.24, w * 0.64, h * 0.54), 180, 360,
          fill=(240, 226, 180), width=max(1, int(w * 0.008)))
    return im


def scene_alaqsa(size):
    """Al-Masjid al-Aqsa: the golden dome over the old stone walls."""
    im = Image.new("RGB", size)
    _sky(im, (86, 78, 120), (232, 176, 128))
    d = ImageDraw.Draw(im, "RGBA")
    w, h = size
    d.rectangle((0, h * 0.66, w, h), fill=(198, 176, 140))
    for i in range(9):
        x = w * (0.03 + i * 0.11)
        d.rectangle((x, h * 0.60, x + w * 0.095, h * 0.70),
                    fill=(214, 194, 158), outline=(184, 162, 126))
    d.rectangle((w * 0.30, h * 0.46, w * 0.70, h * 0.68), fill=(226, 210, 176))
    d.rectangle((w * 0.34, h * 0.42, w * 0.66, h * 0.48), fill=(206, 186, 150))
    d.pieslice((w * 0.36, h * 0.20, w * 0.64, h * 0.50), 180, 360,
               fill=(214, 166, 44))
    d.pieslice((w * 0.40, h * 0.23, w * 0.60, h * 0.47), 180, 360,
               fill=(238, 198, 84))
    d.rectangle((w * 0.492, h * 0.12, w * 0.508, h * 0.22), fill=(214, 166, 44))
    d.rectangle((w * 0.10, h * 0.30, w * 0.145, h * 0.66), fill=(224, 206, 172))
    return im


def scene_arafat(size):
    """Mount Arafat: the rocky hill at dusk."""
    im = Image.new("RGB", size)
    _sky(im, (60, 74, 118), (236, 186, 128))
    d = ImageDraw.Draw(im, "RGBA")
    w, h = size
    d.polygon([(0, h), (w * 0.30, h * 0.52), (w * 0.58, h * 0.74),
               (w, h * 0.44), (w, h)], fill=(150, 126, 96))
    d.polygon([(w * 0.16, h), (w * 0.50, h * 0.34), (w * 0.86, h)],
              fill=(176, 150, 116))
    d.polygon([(w * 0.34, h), (w * 0.50, h * 0.34), (w * 0.50, h)],
              fill=(190, 166, 132))
    d.rectangle((w * 0.485, h * 0.21, w * 0.515, h * 0.36), fill=(240, 234, 216))
    for i in range(26):
        a = 0.20 + (i % 13) * 0.048
        b = 0.52 + (i // 13) * 0.10 + (i % 3) * 0.02
        d.ellipse((w * a, h * b, w * a + w * 0.018, h * b + h * 0.018),
                  fill=(246, 242, 232))
    return im


def scene_mina(size):
    """Mina: the rows of white tents under the ridges."""
    im = Image.new("RGB", size)
    _sky(im, (74, 92, 126), (226, 198, 156))
    d = ImageDraw.Draw(im, "RGBA")
    w, h = size
    d.polygon([(0, h * 0.56), (w * 0.26, h * 0.32), (w * 0.52, h * 0.54),
               (w * 0.76, h * 0.30), (w, h * 0.52), (w, h), (0, h)],
              fill=(148, 124, 96))
    d.rectangle((0, h * 0.58, w, h), fill=(198, 172, 134))
    for row in range(4):
        y = h * (0.60 + row * 0.098)
        s = w * (0.070 + row * 0.016)
        for i in range(7):
            x = w * (0.02 + i * 0.148) + (row % 2) * w * 0.055
            d.polygon([(x, y + s * 0.62), (x + s, y + s * 0.62), (x + s / 2, y)],
                      fill=(248, 246, 240))
            d.line([(x + s / 2, y), (x + s / 2, y + s * 0.62)],
                   fill=(214, 208, 196), width=max(1, int(w * 0.004)))
    return im


SCENES = {
    "medina": scene_medina,
    "alaqsa": scene_alaqsa,
    "arafat": scene_arafat,
    "mina": scene_mina,
}


def circular(im, diameter):
    """Crop an illustration into a soft-edged disc."""
    im = im.resize((diameter, diameter), Image.LANCZOS)
    mask = Image.new("L", (diameter, diameter), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, diameter - 1, diameter - 1), fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(max(1, diameter * 0.006)))
    out = Image.new("RGBA", (diameter, diameter))
    out.paste(im, (0, 0), mask)
    return out


# ---- the plate -------------------------------------------------------

def bake():
    W = SIZE * SS
    im = Image.new("RGB", (W, W), FRAME_DEEP)
    im.paste(vgrad((W, W), FRAME_DEEP, FRAME_DARK), (0, 0))
    d = ImageDraw.Draw(im, "RGBA")

    i1 = S(MARGIN * 0.36)
    d.rounded_rectangle((i1, i1, W - i1, W - i1), radius=S(SIZE * 0.022),
                        outline=GOLD, width=max(1, int(S(5))))
    i2 = S(MARGIN * 0.58)
    d.rounded_rectangle((i2, i2, W - i2, W - i2), radius=S(SIZE * 0.018),
                        outline=GOLD_LIGHT, width=max(1, int(S(1.8))))
    arabesque(d, (i2 * 1.08, i2 * 1.08, W - i2 * 1.08, W - i2 * 1.08),
              (*GOLD, 90), S(1.4), lobes=48)
    for cx, cy in [(i2, i2), (W - i2, i2), (i2, W - i2), (W - i2, W - i2)]:
        star8(d, cx, cy, S(SIZE * 0.020), GOLD)
        star8(d, cx, cy, S(SIZE * 0.010), GOLD_LIGHT)

    d.rounded_rectangle(sbox((MARGIN, MARGIN, SIZE - MARGIN, SIZE - MARGIN)),
                        radius=S(CELL * 0.42), fill=CREAM_LO)

    # --- corners -----------------------------------------------------
    for name, color in TEAM_COLORS.items():
        box = sbox(corner_rect(name))
        pw, ph = int(box[2] - box[0]), int(box[3] - box[1])
        panel = vgrad((pw, ph),
                      tuple(min(255, int(c * 1.32)) for c in color),
                      tuple(int(c * 0.70) for c in color))
        pmask = Image.new("L", (pw, ph), 0)
        ImageDraw.Draw(pmask).rounded_rectangle(
            (0, 0, pw - 1, ph - 1), radius=S(CELL * 0.55), fill=255)
        im.paste(panel, (int(box[0]), int(box[1])), pmask)
        d.rounded_rectangle(box, radius=S(CELL * 0.55), outline=GOLD,
                            width=max(1, int(S(4))))
        inner = (box[0] + S(CELL * 0.30), box[1] + S(CELL * 0.30),
                 box[2] - S(CELL * 0.30), box[3] - S(CELL * 0.30))
        arabesque(d, inner, (*GOLD_LIGHT, 120), S(1.6), lobes=28)

        mx, my, rr = corner_medallion(name)
        diam = int(S(rr * 2))
        art = circular(SCENES[name]((diam, diam)), diam)
        im.paste(art, (int(S(mx) - diam / 2), int(S(my) - diam / 2)), art)
        d.ellipse((S(mx - rr), S(my - rr), S(mx + rr), S(my + rr)),
                  outline=GOLD, width=max(1, int(S(5))))
        d.ellipse((S(mx - rr * 0.94), S(my - rr * 0.94),
                   S(mx + rr * 0.94), S(my + rr * 0.94)),
                  outline=(*GOLD_LIGHT, 150), width=max(1, int(S(1.6))))

        # A single plinth under the four slots, so the stables read as
        # one place rather than four loose discs.
        slots = stable_slots(name)
        pad = CELL * 0.34
        px0 = min(p[0] for p in slots) - pad
        py0 = min(p[1] for p in slots) - pad
        px1 = max(p[0] for p in slots) + pad
        py1 = max(p[1] for p in slots) + pad
        d.rounded_rectangle(sbox((px0, py0, px1, py1)), radius=S(CELL * 0.34),
                            fill=(*CREAM, 60), outline=(*GOLD, 190),
                            width=max(1, int(S(2.4))))
        for sx, sy in slots:
            sr = CELL * 0.30
            d.ellipse((S(sx - sr), S(sy - sr), S(sx + sr), S(sy + sr)),
                      fill=(*CREAM, 235), outline=GOLD, width=max(1, int(S(2.4))))

    # --- circuit ------------------------------------------------------
    for (r, c) in track_cells():
        bevel_tile(d, r, c, CREAM)

    cells = track_cells()
    for t, name in enumerate(TEAM_ORDER):
        r, c = cells[t * 13]
        bevel_tile(d, r, c, TEAM_COLORS[name])
        cx, cy = cell_center(r, c)
        star8(d, S(cx), S(cy), S(CELL * 0.20), (*CREAM, 235))

    # --- escaliers ----------------------------------------------------
    for name, lane in LANES.items():
        for i, (r, c) in enumerate(lane):
            shade = tuple(min(255, int(v * (0.88 + 0.05 * i)))
                          for v in TEAM_COLORS[name])
            bevel_tile(d, r, c, shade)

    # --- Mecca, at the centre ----------------------------------------
    cx, cy = cell_center(*CENTER)
    R = CELL * 1.62
    star8(d, S(cx), S(cy), S(R * 1.16), (*GOLD, 60), rot=math.pi / 8, inner=0.72)
    d.ellipse((S(cx - R), S(cy - R), S(cx + R), S(cy + R)),
              fill=CREAM, outline=GOLD, width=max(1, int(S(6))))
    arabesque(d, (S(cx - R * 0.90), S(cy - R * 0.90),
                  S(cx + R * 0.90), S(cy + R * 0.90)),
              (*GOLD, 130), S(1.8), lobes=24)
    for i in range(12):
        a = i * math.pi / 6
        lx, ly = cx + R * 0.80 * math.cos(a), cy + R * 0.80 * math.sin(a)
        d.ellipse((S(lx - CELL * 0.05), S(ly - CELL * 0.05),
                   S(lx + CELL * 0.05), S(ly + CELL * 0.05)),
                  fill=(*GOLD_LIGHT, 200))
    # The Kaaba: a plain cube under its gold band. No figure, no ornament
    # beyond the band.
    cw, ch = R * 0.66, R * 0.78
    x0, y0 = cx - cw / 2, cy - ch * 0.46
    d.polygon([(S(x0), S(y0)), (S(x0 + cw), S(y0)),
               (S(x0 + cw * 0.88), S(y0 - ch * 0.15)),
               (S(x0 - cw * 0.12), S(y0 - ch * 0.15))], fill=(46, 43, 42))
    d.rectangle((S(x0), S(y0), S(x0 + cw), S(y0 + ch)), fill=(24, 22, 22))
    d.rectangle((S(x0), S(y0 + ch * 0.30), S(x0 + cw), S(y0 + ch * 0.41)),
                fill=GOLD)

    im = im.resize((SIZE, SIZE), Image.LANCZOS)
    os.makedirs(os.path.dirname(OUT_IMAGE), exist_ok=True)
    im.save(OUT_IMAGE, "WEBP", quality=93, method=6)
    print("wrote", OUT_IMAGE, im.size)


def write_anchors():
    def fmt(pt):
        x, y = pt
        return f"SceneAnchor({x / SIZE:.4f}, {y / SIZE:.4f})"

    cells = track_cells()
    track = ",\n  ".join(fmt(cell_center(r, c)) for (r, c) in cells)

    lanes, camps, corners = [], [], []
    for t, name in enumerate(TEAM_ORDER):
        pts = ", ".join(fmt(cell_center(r, c)) for (r, c) in LANES[name])
        lanes.append(f"  {t}: [{pts}],")
        camps.append(f"  {t}: [{', '.join(fmt(p) for p in stable_slots(name))}],")
        mx, my, _ = corner_medallion(name)
        corners.append(f"  {t}: {fmt((mx, my))},")

    body = f"""// GENERATED by tool/art/bake_cross_board.py — do not edit by hand.
//
// The plate and this table come from one grid, so an index can never
// address a square the art does not have.

class SceneAnchor {{
  const SceneAnchor(this.x, this.y);

  final double x;
  final double y;
}}

/// The 52 circuit squares, in riding order.
const List<SceneAnchor> crossTrackAnchors = [
  {track},
];

/// Each team's five-step escalier, outermost first.
const Map<int, List<SceneAnchor>> crossLaneAnchors = {{
{chr(10).join(lanes)}
}};

/// The four stable slots in each team's corner.
const Map<int, List<SceneAnchor>> crossCampAnchors = {{
{chr(10).join(camps)}
}};

/// Mecca, at the centre.
const SceneAnchor crossCenterAnchor = {fmt(cell_center(*CENTER))};

/// The middle of each team's corner medallion. The place names are drawn
/// by Flutter from the localisations rather than baked into the plate, so
/// all twelve languages read their own.
const Map<int, SceneAnchor> crossCornerAnchors = {{
{chr(10).join(corners)}
}};
"""
    with open(OUT_ANCHORS, "w", encoding="utf-8") as f:
        f.write(body)
    print("wrote", OUT_ANCHORS, f"({len(cells)} track anchors)")


if __name__ == "__main__":
    bake()
    write_anchors()
