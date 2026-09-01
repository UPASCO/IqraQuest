"""Bakes the classic cross board — the *jeu des petits chevaux* plate.

The board is set among four holy places, with Mecca at the centre as the
shared destination every horse rides to:

    Medina (green)      top-left        Jerusalem / al-Aqsa (red)  top-right
    Arafat (blue)       bottom-left     Mina (gold)                bottom-right

Geometry is the standard 15x15 cross: a 52-square circuit and a 5-step
escalier per team. Both the plate and the anchor table below are derived
from the SAME grid, so a horse can never be drawn on a square the art
does not have — the failure the previous baked plate had, where 56
logical squares were indexed into 24 painted tiles.

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

N = 15                      # the board is a 15x15 grid of cells
SIZE = 1536                 # plate resolution, square
MARGIN = 0.055 * SIZE       # frame inset before the grid starts
CELL = (SIZE - 2 * MARGIN) / N

# ---- palette, read off the reference board ---------------------------
FRAME_DEEP = (18, 62, 66)
FRAME_EDGE = (10, 40, 44)
GOLD = (198, 158, 74)
GOLD_LIGHT = (231, 199, 122)
CREAM = (245, 238, 220)
CREAM_SHADE = (228, 217, 191)
INK = (58, 47, 30)

# Matches AppSemanticColors.player1..4 so a piece and its corner are
# always the same colour.
TEAM_COLORS = {
    "medina": (14, 107, 82),      # emerald  — player1
    "arafat": (30, 91, 140),      # saphir   — player2
    "jerusalem": (140, 42, 61),   # grenat   — player3
    "mina": (193, 122, 31),       # safran   — player4
}

# Which corner each team occupies is NOT a free choice: it follows from
# the circuit. Team t enters the track at index t * 13 and climbs the
# escalier reached just before that, so its corner is the one its start
# square touches. Deriving it here keeps art and rules from ever drifting
# apart — the bug that put horses outside their stables.
#
#   t0 start (6, 0)  upper row of the left arm    -> top-left
#   t1 start (0, 8)  right side of the top arm    -> top-right
#   t2 start (8, 14) lower row of the right arm   -> bottom-right
#   t3 start (14, 6) left side of the bottom arm  -> bottom-left
#
# Places then follow the team colours, which are fixed in AppTeam and
# written into every save: emerald green, saphir blue, grenat red,
# safran gold.
CORNERS = {
    "medina": ((0, 6), (0, 6)),        # emerald, green
    "arafat": ((0, 6), (9, 15)),       # saphir, blue
    "jerusalem": ((9, 15), (9, 15)),   # grenat, red
    "mina": ((9, 15), (0, 6)),         # safran, gold
}


def track_cells():
    """The 52 circuit cells, in riding order.

    One lap of the cross: along an arm, up one side of the next arm,
    across its tip, and back down — repeated four times.
    """
    cells = []
    cells += [(6, c) for c in range(0, 6)]          # 6  left arm, upper row
    cells += [(r, 6) for r in range(5, -1, -1)]     # 6  up the top arm's left side
    cells += [(0, 7)]                               # 1  across the tip
    cells += [(r, 8) for r in range(0, 6)]          # 6  down its right side
    cells += [(6, c) for c in range(9, 15)]         # 6  right arm, upper row
    cells += [(7, 14)]                              # 1
    cells += [(8, c) for c in range(14, 8, -1)]     # 6  right arm, lower row
    cells += [(r, 8) for r in range(9, 15)]         # 6  down the bottom arm
    cells += [(14, 7)]                              # 1
    cells += [(r, 6) for r in range(14, 8, -1)]     # 6  back up its left side
    cells += [(8, c) for c in range(5, -1, -1)]     # 6  left arm, lower row
    cells += [(7, 0)]                               # 1
    assert len(cells) == 52, len(cells)
    return cells


# Each team's escalier: five cells running inward to the centre.
LANES = {
    "medina": [(7, c) for c in range(1, 6)],            # in from the left
    "arafat": [(r, 7) for r in range(1, 6)],            # down from the top
    "jerusalem": [(7, c) for c in range(13, 8, -1)],    # in from the right
    "mina": [(r, 7) for r in range(13, 8, -1)],         # up from the bottom
}

# Index in this list IS the engine's team index (AppTeam order):
# emerald, saphir, grenat, safran.
TEAM_ORDER = ["medina", "arafat", "jerusalem", "mina"]

CENTER = (7, 7)


# ---- drawing helpers -------------------------------------------------

def cell_box(row, col, inset=0.0):
    x0 = MARGIN + col * CELL + inset
    y0 = MARGIN + row * CELL + inset
    return (x0, y0, x0 + CELL - 2 * inset, y0 + CELL - 2 * inset)


def cell_center(row, col):
    x0, y0, x1, y1 = cell_box(row, col)
    return ((x0 + x1) / 2, (y0 + y1) / 2)


def star8(draw, cx, cy, r, fill, rot=0.0):
    """The eight-point khatam star used across the app."""
    pts = []
    for i in range(16):
        a = rot + i * math.pi / 8
        rad = r if i % 2 == 0 else r * 0.42
        pts.append((cx + rad * math.cos(a), cy + rad * math.sin(a)))
    draw.polygon(pts, fill=fill)


def tile(draw, row, col, fill, rim=GOLD, rim_w=3):
    box = cell_box(row, col, inset=CELL * 0.055)
    draw.rounded_rectangle(box, radius=CELL * 0.16, fill=fill, outline=rim, width=rim_w)


def bake():
    im = Image.new("RGB", (SIZE, SIZE), FRAME_DEEP)
    d = ImageDraw.Draw(im, "RGBA")

    # --- outer frame -------------------------------------------------
    d.rectangle((0, 0, SIZE, SIZE), fill=FRAME_DEEP)
    inset = MARGIN * 0.42
    d.rounded_rectangle(
        (inset, inset, SIZE - inset, SIZE - inset),
        radius=SIZE * 0.02, outline=GOLD, width=int(SIZE * 0.004),
    )
    inset2 = MARGIN * 0.62
    d.rounded_rectangle(
        (inset2, inset2, SIZE - inset2, SIZE - inset2),
        radius=SIZE * 0.016, outline=GOLD_LIGHT, width=max(1, int(SIZE * 0.0015)),
    )
    # corner filigree
    for cx, cy in [(inset2, inset2), (SIZE - inset2, inset2),
                   (inset2, SIZE - inset2), (SIZE - inset2, SIZE - inset2)]:
        star8(d, cx, cy, SIZE * 0.018, GOLD)

    # --- the playfield ground ---------------------------------------
    d.rounded_rectangle(
        (MARGIN, MARGIN, SIZE - MARGIN, SIZE - MARGIN),
        radius=CELL * 0.4, fill=CREAM_SHADE,
    )

    # --- the four corner zones ---------------------------------------
    for name, ((r0, r1), (c0, c1)) in CORNERS.items():
        color = TEAM_COLORS[name]
        x0, y0, _, _ = cell_box(r0, c0)
        _, _, x1, y1 = cell_box(r1 - 1, c1 - 1)
        d.rounded_rectangle((x0, y0, x1, y1), radius=CELL * 0.55,
                            fill=color, outline=GOLD, width=5)
        # A quiet medallion where each place's illustration is inset.
        mx, my = (x0 + x1) / 2, (y0 + y1) / 2
        rr = (x1 - x0) * 0.34
        d.ellipse((mx - rr, my - rr, mx + rr, my + rr),
                  fill=(*CREAM, 235), outline=GOLD, width=5)
        star8(d, mx, my, rr * 0.30, (*color, 90))
        # the four stable slots, where the horses wait
        for i, (ox, oy) in enumerate([(-1, -1), (1, -1), (-1, 1), (1, 1)]):
            sx = mx + ox * rr * 0.62
            sy = my + oy * rr * 0.62
            sr = CELL * 0.36
            d.ellipse((sx - sr, sy - sr, sx + sr, sy + sr),
                      fill=(*CREAM, 210), outline=GOLD, width=3)

    # --- the circuit --------------------------------------------------
    for (r, c) in track_cells():
        tile(d, r, c, CREAM)

    # every team's first square carries its colour
    cells = track_cells()
    for i, name in enumerate(TEAM_ORDER):
        r, c = cells[i * 13]
        tile(d, r, c, (*TEAM_COLORS[name], 235))
        cx, cy = cell_center(r, c)
        star8(d, cx, cy, CELL * 0.20, (*CREAM, 220))

    # --- the four escaliers ------------------------------------------
    for name, lane in LANES.items():
        for (r, c) in lane:
            tile(d, r, c, TEAM_COLORS[name])

    # --- the centre: Mecca -------------------------------------------
    cx, cy = cell_center(*CENTER)
    R = CELL * 1.62
    star8(d, cx, cy, R * 1.02, (*GOLD, 70), rot=math.pi / 8)
    d.ellipse((cx - R, cy - R, cx + R, cy + R), fill=CREAM, outline=GOLD, width=6)
    d.ellipse((cx - R * 0.86, cy - R * 0.86, cx + R * 0.86, cy + R * 0.86),
              outline=GOLD_LIGHT, width=2)
    # The Kaaba, drawn as it is always shown: a plain cube under its
    # gold band. No figure, no ornament beyond the band.
    cw, ch = R * 0.66, R * 0.76
    x0, y0 = cx - cw / 2, cy - ch * 0.52
    d.rectangle((x0, y0, x0 + cw, y0 + ch), fill=(22, 20, 20))
    d.polygon([(x0, y0), (x0 + cw, y0), (x0 + cw * 0.86, y0 - ch * 0.16),
               (x0 - cw * 0.14, y0 - ch * 0.16)], fill=(40, 37, 36))
    band = y0 + ch * 0.30
    d.rectangle((x0, band, x0 + cw, band + ch * 0.11), fill=GOLD)

    im = im.filter(ImageFilter.SMOOTH)
    os.makedirs(os.path.dirname(OUT_IMAGE), exist_ok=True)
    im.save(OUT_IMAGE, "WEBP", quality=92, method=6)
    print("wrote", OUT_IMAGE, im.size)


def write_anchors():
    """Anchor table derived from the same grid the plate was drawn on."""
    def fmt(pt):
        x, y = pt
        return f"SceneAnchor({x / SIZE:.4f}, {y / SIZE:.4f})"

    cells = track_cells()
    track = ",\n  ".join(fmt(cell_center(r, c)) for (r, c) in cells)

    lanes = []
    for t, name in enumerate(TEAM_ORDER):
        pts = ", ".join(fmt(cell_center(r, c)) for (r, c) in LANES[name])
        lanes.append(f"  {t}: [{pts}],")

    camps = []
    corner_lines = []
    for t, name in enumerate(TEAM_ORDER):
        (r0, r1), (c0, c1) = CORNERS[name]
        x0, y0, _, _ = cell_box(r0, c0)
        _, _, x1, y1 = cell_box(r1 - 1, c1 - 1)
        mx, my = (x0 + x1) / 2, (y0 + y1) / 2
        rr = (x1 - x0) * 0.34
        slots = [(mx + ox * rr * 0.62, my + oy * rr * 0.62)
                 for ox, oy in [(-1, -1), (1, -1), (-1, 1), (1, 1)]]
        camps.append(f"  {t}: [{', '.join(fmt(p) for p in slots)}],")
        corner_lines.append(f"  {t}: {fmt((mx, my))},")

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

/// The middle of each team's corner medallion, where its place is named.
/// The names are drawn by Flutter from the localisations rather than
/// baked into the plate, so all twelve languages read their own.
const Map<int, SceneAnchor> crossCornerAnchors = {{
{chr(10).join(corner_lines)}
}};
"""
    with open(OUT_ANCHORS, "w", encoding="utf-8") as f:
        f.write(body)
    print("wrote", OUT_ANCHORS, f"({len(cells)} track anchors)")


if __name__ == "__main__":
    bake()
    write_anchors()
