"""Bake the full-screen 2.5D board diorama for the oasis route.

Composes modular baked sprites (slabs, tents, palms, props, the center
oasis landmark) into one pre-rendered scene with y-sorted depth, cast
shadows and a golden-hour grade — then emits the cell/camp anchors as
generated Dart so the Flutter layer can place live horses precisely.

Run:  python3 tool/art/bake_scene.py [--preview]
"""

from __future__ import annotations

import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(__file__))
from sprite_lib import (  # noqa: E402
    alpha_paste,
    chaikin,
    ellipse_mask,
    fbm,
    poly_mask,
    rounded_rect_mask,
    shade,
    soft_shadow,
    to_image,
)

W, H = 1170, 2340  # 390x780 logical @3x
CX, CY = 585, 1236  # board centre on canvas
RX, RY = 438, 560  # loop radii before perspective squash
SQUASH = 0.78  # vertical perspective squash around CY
TRACK_N = 24
HORIZON = 385

TEAM_ORDER = ["emerald", "saphir", "grenat", "safran"]
TEAM_RGB = {
    "emerald": (46, 158, 96),
    "saphir": (58, 108, 202),
    "grenat": (186, 82, 168),
    "safran": (224, 168, 62),
}
TEAM_DEEP = {
    "emerald": (14, 66, 40),
    "saphir": (18, 40, 96),
    "grenat": (86, 26, 80),
    "safran": (118, 72, 16),
}
GOLD = (240, 198, 110)
GOLD_DEEP = (150, 102, 34)
STONE = (216, 186, 138)
STONE_SIDE = (128, 96, 62)
SAND = (222, 172, 108)


# ---------------------------------------------------------------------------
# Geometry: superellipse loop, equal arc length, perspective applied last.
# ---------------------------------------------------------------------------


def _superellipse(theta, n=3.2):
    c, s = math.cos(theta), math.sin(theta)
    x = math.copysign(abs(c) ** (2.0 / n), c)
    y = math.copysign(abs(s) ** (2.0 / n), s)
    return x, y


def _loop_points_dense(m=1600):
    pts = []
    for k in range(m):
        th = 2 * math.pi * k / m
        x, y = _superellipse(th)
        pts.append((CX + RX * x, CY + RY * y))
    return pts


def track_positions():
    """24 cell centres, equal arc length, cell 0 at the top-left corner,
    clockwise. Returns list of (x, y, tangent_deg, depth_scale)."""
    dense = _loop_points_dense()
    # Arc lengths.
    lens = [0.0]
    for i in range(1, len(dense) + 1):
        a, b = dense[i - 1], dense[i % len(dense)]
        lens.append(lens[-1] + math.hypot(b[0] - a[0], b[1] - a[1]))
    total = lens[-1]
    # Start point: top-left corner = superellipse angle 225 deg.
    start_th = math.pi * 1.25
    start_k = int((start_th / (2 * math.pi)) * len(dense)) % len(dense)
    start_len = lens[start_k]

    out = []
    for i in range(TRACK_N):
        target = (start_len + total * i / TRACK_N) % total
        # Find dense index at that arc length.
        k = int(np.searchsorted(np.array(lens[:-1]), target)) % len(dense)
        x, y = dense[k]
        nxt = dense[(k + 8) % len(dense)]
        prv = dense[(k - 8) % len(dense)]
        tangent = math.degrees(math.atan2(nxt[1] - prv[1], nxt[0] - prv[0]))
        out.append(persp(x, y) + (tangent,))
    return out


def depth_of(ys):
    return 0.74 + 0.52 * (ys / H)


def persp(x, y):
    """Perspective: squash toward centre + depth scale by screen y."""
    ys = CY + (y - CY) * SQUASH
    depth = depth_of(ys)
    xs = CX + (x - CX) * (0.94 + 0.10 * (ys / H))
    return (xs, ys, depth)


# ---------------------------------------------------------------------------
# Prop bakers (all cached by args where useful).
# ---------------------------------------------------------------------------


def bake_slab(w=132, h=104, top=STONE, side=STONE_SIDE, seed=3):
    """One chunky stone paver: beveled top face + extruded front edge."""
    sw, sh = w + 16, h + 34
    canvas = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    side_m = rounded_rect_mask((sw, sh), (8, 26, 8 + w, 26 + h), 26)
    alpha_paste(canvas, to_image(shade(side_m, side, shade_rgb=tuple(int(c*0.45) for c in side), z_scale=2.2, spec=0.12, rim=0.08)), (0, 0))
    top_m = rounded_rect_mask((sw, sh), (8, 8, 8 + w, 8 + h), 26)
    tex = fbm((sh, sw), octaves=4, seed=seed, base=6)
    alpha_paste(
        canvas,
        to_image(
            shade(
                top_m, top, inflate=0.85, z_scale=2.6, spec=0.28, spec_power=18,
                rim=0.22, texture=tex, texture_amp=0.05,
            )
        ),
        (0, 0),
    )
    return canvas


def bake_colored_slab(team, chevron=True):
    """A final-lane slab in team colour with a lighter chevron inlay."""
    base = bake_slab(top=TEAM_RGB[team], side=TEAM_DEEP[team], seed=11)
    if chevron:
        sw, sh = base.size
        ch = poly_mask(
            (sw, sh),
            [[(46, 66), (74, 40), (102, 66), (102, 82), (74, 58), (46, 82)]],
            smooth=1,
        )
        light = tuple(min(255, int(c * 1.45 + 40)) for c in TEAM_RGB[team])
        alpha_paste(base, to_image(shade(ch, light, z_scale=1.6, spec=0.5)), (0, 0))
    return base


def bake_star_slab():
    base = bake_slab(top=(226, 198, 148), seed=5)
    sw, sh = base.size
    cx, cy, r = sw / 2, 60, 30
    pts = []
    for k in range(16):
        ang = math.pi * k / 8 - math.pi / 2
        rad = r if k % 2 == 0 else r * 0.45
        pts.append((cx + rad * math.cos(ang), cy + rad * math.sin(ang) * 0.8))
    star = poly_mask((sw, sh), [pts], smooth=1)
    alpha_paste(base, to_image(shade(star, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.2, spec=0.7, spec_power=30)), (0, 0))
    return base


def bake_pool_slab():
    """Oasis cell: slab with a small turquoise pool sunk into it."""
    base = bake_slab(top=(206, 188, 150), seed=9)
    sw, sh = base.size
    rim = ellipse_mask((sw, sh), (30, 34, sw - 30, 96))
    alpha_paste(base, to_image(shade(rim, (168, 148, 108), z_scale=1.6, spec=0.2)), (0, 0))
    pool = ellipse_mask((sw, sh), (38, 40, sw - 38, 90))
    water = shade(pool, (52, 176, 186), shade_rgb=(10, 66, 96), inflate=1.2, z_scale=1.2, spec=0.9, spec_power=10)
    alpha_paste(base, to_image(water), (0, 0))
    gl = ellipse_mask((sw, sh), (52, 48, 96, 64))
    alpha_paste(base, to_image(shade(gl, (210, 245, 240), z_scale=0.8, spec=0.0, rim=0.0)), (0, 0))
    return base


def bake_palm(height=260, seed=1):
    """A palm with a curved trunk and drooping fronds."""
    w = int(height * 0.95)
    canvas = Image.new("RGBA", (w, height), (0, 0, 0, 0))
    rng = np.random.default_rng(seed)
    # Trunk: tapered curve.
    bx, by = w * 0.5, height * 0.98
    tx, ty = w * 0.5 + height * 0.10, height * 0.30
    trunk = []
    n = 9
    for i in range(n + 1):
        t = i / n
        x = bx + (tx - bx) * t + math.sin(t * 2.2) * height * 0.03
        y = by + (ty - by) * t
        r = height * (0.035 - 0.020 * t)
        trunk.append((x - r, y))
    for i in range(n, -1, -1):
        t = i / n
        x = bx + (tx - bx) * t + math.sin(t * 2.2) * height * 0.03
        y = by + (ty - by) * t
        r = height * (0.035 - 0.020 * t)
        trunk.append((x + r, y))
    tm = poly_mask((w, height), [trunk], smooth=2)
    alpha_paste(canvas, to_image(shade(tm, (146, 104, 62), z_scale=4.0, spec=0.2, rim=0.2)), (0, 0))
    # Fronds.
    for k in range(7):
        ang = -math.pi * 0.95 + math.pi * 0.9 * k / 6 + rng.normal(0, 0.05)
        ln = height * (0.42 + 0.08 * rng.random())
        fx, fy = tx, ty
        ex = fx + math.cos(ang) * ln
        ey = fy + math.sin(ang) * ln * 0.6 + ln * 0.22  # droop
        mx = (fx + ex) / 2 + math.cos(ang + math.pi / 2) * ln * 0.10
        my = (fy + ey) / 2 - ln * 0.16
        frond = [
            (fx, fy),
            (mx, my - ln * 0.055),
            (ex, ey),
            (mx, my + ln * 0.075),
        ]
        fm = poly_mask((w, height), [frond], smooth=2)
        g = 120 + int(40 * rng.random())
        alpha_paste(canvas, to_image(shade(fm, (44, g, 74), z_scale=3.0, spec=0.3, rim=0.25)), (0, 0))
    return canvas


def bake_rock(size=90, seed=2):
    rng = np.random.default_rng(seed)
    pts = []
    for k in range(9):
        ang = 2 * math.pi * k / 9
        r = size * (0.32 + 0.13 * rng.random())
        pts.append((size / 2 + r * math.cos(ang), size * 0.55 + r * math.sin(ang) * 0.7))
    m = poly_mask((size, size), [pts], smooth=2)
    tex = fbm((size, size), octaves=3, seed=seed, base=5)
    return to_image(
        shade(m, (172, 142, 112), z_scale=4.5, spec=0.18, rim=0.2, texture=tex, texture_amp=0.10)
    )


def bake_bush(size=84, seed=4):
    rng = np.random.default_rng(seed)
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    for _ in range(4):
        x0 = rng.uniform(0, size * 0.4)
        y0 = rng.uniform(size * 0.3, size * 0.55)
        r = size * rng.uniform(0.22, 0.34)
        m = ellipse_mask((size, size), (x0, y0, x0 + 2 * r, y0 + 1.5 * r))
        g = int(rng.uniform(110, 150))
        alpha_paste(im, to_image(shade(m, (48, g, 78), z_scale=4.0, spec=0.25, rim=0.2)), (0, 0))
    return im


def bake_lantern(h=96):
    w = 48
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    pole = rounded_rect_mask((w, h), (20, 26, 28, h - 4), 4)
    alpha_paste(im, to_image(shade(pole, (74, 54, 40), z_scale=2.4, spec=0.2)), (0, 0))
    glow = ellipse_mask((w, h), (4, 2, 44, 44))
    ga = (glow * 130).astype(np.uint8)
    gi = np.zeros((h, w, 4), dtype=np.uint8)
    gi[..., 0], gi[..., 1], gi[..., 2] = 255, 200, 90
    gi[..., 3] = ga
    gi_im = Image.fromarray(gi).filter(ImageFilter.GaussianBlur(7))
    alpha_paste(im, gi_im, (0, 0))
    body = poly_mask((w, h), [[(16, 12), (32, 12), (36, 34), (24, 44), (12, 34)]], smooth=2)
    alpha_paste(im, to_image(shade(body, (255, 196, 84), shade_rgb=(140, 74, 20), z_scale=3.0, spec=0.7)), (0, 0))
    return im


def bake_chest_mini(w=120):
    h = int(w * 1.0)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    glow = ellipse_mask((w, h), (2, h * 0.18, w - 2, h * 0.9))
    gi = np.zeros((h, w, 4), dtype=np.uint8)
    gi[..., 0], gi[..., 1], gi[..., 2] = 255, 214, 120
    gi[..., 3] = (glow * 110).astype(np.uint8)
    alpha_paste(im, Image.fromarray(gi).filter(ImageFilter.GaussianBlur(9)), (0, 0))
    body = rounded_rect_mask((w, h), (w * 0.16, h * 0.46, w * 0.84, h * 0.86), 10)
    alpha_paste(im, to_image(shade(body, (146, 88, 48), z_scale=3.4, spec=0.3, rim=0.25)), (0, 0))
    lid = ellipse_mask((w, h), (w * 0.13, h * 0.26, w * 0.87, h * 0.62))
    alpha_paste(im, to_image(shade(lid, (168, 104, 56), z_scale=3.6, spec=0.35, rim=0.3)), (0, 0))
    band = rounded_rect_mask((w, h), (w * 0.44, h * 0.28, w * 0.56, h * 0.86), 5)
    alpha_paste(im, to_image(shade(band, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.4, spec=0.8, spec_power=30)), (0, 0))
    seam = rounded_rect_mask((w, h), (w * 0.16, h * 0.52, w * 0.84, h * 0.60), 4)
    alpha_paste(im, to_image(shade(seam, (255, 226, 150), z_scale=1.2, spec=0.6)), (0, 0))
    return im


def bake_tent(team, width=430):
    """A grand striped pavilion tent for one stable."""
    w = width
    h = int(width * 0.92)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    base_rgb = TEAM_RGB[team]
    deep = TEAM_DEEP[team]

    # Platform the tent stands on.
    plat = ellipse_mask((w, h), (w * 0.03, h * 0.68, w * 0.97, h * 0.99))
    alpha_paste(im, to_image(shade(plat, (200, 166, 120), shade_rgb=(122, 90, 54), z_scale=1.8, spec=0.15)), (0, 0))

    # Canopy: swooping cone with scalloped hem.
    apex = (w * 0.5, h * 0.06)
    hem_y = h * 0.72
    hem_pts = []
    scallops = 6
    for k in range(scallops + 1):
        x = w * 0.06 + (w * 0.88) * k / scallops
        hem_pts.append((x, hem_y + (h * 0.075 if k % 2 == 1 else 0)))
    canopy = [ (w * 0.06, hem_y) ] + hem_pts + [ (w * 0.94, hem_y), (w * 0.64, h * 0.14), apex, (w * 0.36, h * 0.14) ]
    cm = poly_mask((w, h), [canopy], smooth=2)
    tex = fbm((h, w), octaves=3, seed=8, base=5)
    canopy_rgba = shade(cm, base_rgb, shade_rgb=deep, inflate=0.62, z_scale=4.2, spec=0.5, spec_power=22, rim=0.4, texture=tex, texture_amp=0.03)
    # Stripes: alternate darker wedges from apex.
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    ang = np.arctan2(yy - apex[1], xx - apex[0])
    stripes = (np.sin(ang * 13.0) > 0.1).astype(np.float32)
    xxn = (xx - apex[0]) / (w * 0.5)
    cone = np.clip(0.82 + 0.28 * (-xxn), 0.58, 1.14)
    stripe_dark = (canopy_rgba[..., :3].astype(np.float32) * (1 - 0.20 * stripes[..., None]) * cone[..., None])
    canopy_rgba[..., :3] = np.clip(stripe_dark, 0, 255).astype(np.uint8)
    alpha_paste(im, to_image(canopy_rgba), (0, 0))

    # Door: dark arch with warm light inside.
    door = poly_mask((w, h), [[(w * 0.42, h * 0.78), (w * 0.44, h * 0.52), (w * 0.5, h * 0.44), (w * 0.56, h * 0.52), (w * 0.58, h * 0.78)]], smooth=2)
    da = np.zeros((h, w, 4), dtype=np.uint8)
    da[..., 0], da[..., 1], da[..., 2] = 30, 16, 12
    da[..., 3] = (door * 235).astype(np.uint8)
    alpha_paste(im, Image.fromarray(da), (0, 0))
    dglow = ellipse_mask((w, h), (w * 0.45, h * 0.58, w * 0.55, h * 0.76))
    dg = np.zeros((h, w, 4), dtype=np.uint8)
    dg[..., 0], dg[..., 1], dg[..., 2] = 255, 176, 80
    dg[..., 3] = (dglow * 120).astype(np.uint8)
    alpha_paste(im, Image.fromarray(dg).filter(ImageFilter.GaussianBlur(6)), (0, 0))

    # Finial + pennant.
    pole = rounded_rect_mask((w, h), (w * 0.492, h * 0.0, w * 0.508, h * 0.10), 3)
    alpha_paste(im, to_image(shade(pole, (90, 66, 44), z_scale=2.0, spec=0.2)), (0, 0))
    ball = ellipse_mask((w, h), (w * 0.475, -h * 0.005, w * 0.525, h * 0.035))
    alpha_paste(im, to_image(shade(ball, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.6, spec=0.85, spec_power=30)), (0, 0))
    pennant = poly_mask((w, h), [[(w * 0.51, h * 0.005), (w * 0.70, h * 0.03), (w * 0.51, h * 0.06)]], smooth=1)
    alpha_paste(im, to_image(shade(pennant, base_rgb, shade_rgb=deep, z_scale=2.2, spec=0.4)), (0, 0))

    # Gold hem trim.
    hem = poly_mask((w, h), [[(w * 0.06, hem_y - 5), (w * 0.94, hem_y - 5), (w * 0.94, hem_y + 9), (w * 0.06, hem_y + 9)]], smooth=1)
    hem_arr = shade(hem, GOLD, shade_rgb=GOLD_DEEP, z_scale=1.6, spec=0.6)
    hem_arr[..., 3] = (hem_arr[..., 3].astype(np.float32) * cm).astype(np.uint8)
    alpha_paste(im, to_image(hem_arr), (0, 0))
    return im


def bake_horse_slot(d=120):
    """An empty gold-ringed pedestal in the écurie, waiting for a horse."""
    im = Image.new("RGBA", (d, d), (0, 0, 0, 0))
    ring = ellipse_mask((d, d), (4, d * 0.30, d - 4, d * 0.92))
    alpha_paste(im, to_image(shade(ring, GOLD, shade_rgb=GOLD_DEEP, z_scale=1.8, spec=0.6, spec_power=26)), (0, 0))
    inner = ellipse_mask((d, d), (12, d * 0.36, d - 12, d * 0.86))
    alpha_paste(im, to_image(shade(inner, (196, 160, 114), shade_rgb=(126, 94, 58), z_scale=1.2, spec=0.25)), (0, 0))
    return im


def bake_center(width=520):
    """The hero landmark: raised paving, turquoise pool, gold fountain
    pavilion, palms — where all four final lanes converge."""
    w = width
    h = int(width * 0.94)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    # Raised paving disc.
    pav_side = ellipse_mask((w, h), (w * 0.02, h * 0.56, w * 0.98, h * 0.99))
    alpha_paste(im, to_image(shade(pav_side, STONE_SIDE, shade_rgb=(72, 52, 34), z_scale=2.0, spec=0.1)), (0, 0))
    pav = ellipse_mask((w, h), (w * 0.02, h * 0.48, w * 0.98, h * 0.94))
    tex = fbm((h, w), octaves=4, seed=13, base=7)
    alpha_paste(im, to_image(shade(pav, (224, 194, 144), shade_rgb=(136, 100, 60), inflate=0.9, z_scale=1.8, spec=0.25, texture=tex, texture_amp=0.05)), (0, 0))

    # Pool ring + water.
    rim = ellipse_mask((w, h), (w * 0.10, h * 0.54, w * 0.90, h * 0.90))
    alpha_paste(im, to_image(shade(rim, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.0, spec=0.6, spec_power=26)), (0, 0))
    pool = ellipse_mask((w, h), (w * 0.13, h * 0.57, w * 0.87, h * 0.87))
    water = shade(pool, (48, 182, 190), shade_rgb=(8, 70, 104), inflate=1.4, z_scale=1.0, spec=0.8, spec_power=8)
    alpha_paste(im, to_image(water), (0, 0))
    # Shimmer streaks.
    shimmer = np.zeros((h, w, 4), dtype=np.uint8)
    yy, xx = np.mgrid[0:h, 0:w]
    band = ((np.sin(xx * 0.10 + yy * 0.32) > 0.86) & (pool > 0.5)).astype(np.uint8)
    shimmer[..., 0], shimmer[..., 1], shimmer[..., 2] = 220, 250, 245
    shimmer[..., 3] = band * 110
    alpha_paste(im, Image.fromarray(shimmer).filter(ImageFilter.GaussianBlur(1.2)), (0, 0))

    # Island platform inside the pool.
    isle = ellipse_mask((w, h), (w * 0.32, h * 0.62, w * 0.68, h * 0.80))
    alpha_paste(im, to_image(shade(isle, (226, 198, 150), shade_rgb=(140, 104, 62), z_scale=2.0, spec=0.3)), (0, 0))

    # Domed golden pavilion: body with arched openings, cornice, dome,
    # and two small corner turrets so it reads as architecture.
    body = rounded_rect_mask((w, h), (w * 0.34, h * 0.40, w * 0.66, h * 0.68), 16)
    alpha_paste(im, to_image(shade(body, (238, 202, 132), shade_rgb=(146, 96, 40), z_scale=3.2, spec=0.5, spec_power=24)), (0, 0))
    for tx0 in (0.295, 0.655):
        turret = rounded_rect_mask((w, h), (w * tx0, h * 0.34, w * (tx0 + 0.05), h * 0.66), 10)
        alpha_paste(im, to_image(shade(turret, (226, 188, 120), shade_rgb=(140, 92, 38), z_scale=3.0, spec=0.5)), (0, 0))
        cap = ellipse_mask((w, h), (w * (tx0 - 0.008), h * 0.305, w * (tx0 + 0.058), h * 0.365))
        alpha_paste(im, to_image(shade(cap, (250, 214, 128), shade_rgb=GOLD_DEEP, z_scale=3.6, spec=0.85, spec_power=30)), (0, 0))
    for ax0 in (0.415, 0.535):
        arch = poly_mask(
            (w, h),
            [[(w * ax0, h * 0.66), (w * ax0, h * 0.52), (w * (ax0 + 0.025), h * 0.47),
              (w * (ax0 + 0.05), h * 0.52), (w * (ax0 + 0.05), h * 0.66)]],
            smooth=2,
        )
        aa = np.zeros((h, w, 4), dtype=np.uint8)
        aa[..., 0], aa[..., 1], aa[..., 2] = 66, 34, 22
        aa[..., 3] = (arch * 230).astype(np.uint8)
        alpha_paste(im, Image.fromarray(aa), (0, 0))
        aglow = ellipse_mask((w, h), (w * (ax0 + 0.008), h * 0.55, w * (ax0 + 0.042), h * 0.65))
        ag = np.zeros((h, w, 4), dtype=np.uint8)
        ag[..., 0], ag[..., 1], ag[..., 2] = 255, 186, 92
        ag[..., 3] = (aglow * 110).astype(np.uint8)
        alpha_paste(im, Image.fromarray(ag).filter(ImageFilter.GaussianBlur(4)), (0, 0))
    cornice = rounded_rect_mask((w, h), (w * 0.355, h * 0.375, w * 0.645, h * 0.425), 10)
    alpha_paste(im, to_image(shade(cornice, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.2, spec=0.7, spec_power=28)), (0, 0))
    dome = ellipse_mask((w, h), (w * 0.395, h * 0.19, w * 0.605, h * 0.42))
    alpha_paste(im, to_image(shade(dome, (252, 218, 132), shade_rgb=GOLD_DEEP, inflate=0.55, z_scale=4.5, spec=0.9, spec_power=34)), (0, 0))
    finial = ellipse_mask((w, h), (w * 0.487, h * 0.135, w * 0.513, h * 0.185))
    alpha_paste(im, to_image(shade(finial, (255, 232, 160), z_scale=2.6, spec=0.9)), (0, 0))

    # Palms flanking the pavilion give the centre its oasis silhouette.
    palm_l = bake_palm(int(h * 0.52), seed=17)
    alpha_paste(im, palm_l.transpose(Image.FLIP_LEFT_RIGHT), (int(w * 0.10), int(h * 0.18)))
    palm_r = bake_palm(int(h * 0.46), seed=23)
    alpha_paste(im, palm_r, (int(w * 0.60), int(h * 0.24)))
    return im


# ---------------------------------------------------------------------------
# Backdrop: sky, mountains, distant oasis city, sand.
# ---------------------------------------------------------------------------


def paint_backdrop():
    ys = np.arange(H, dtype=np.float32)

    def vgrad(stops, t):
        """Per-row vertical gradient from (pos, rgb) stops; t in [0,1]."""
        xs = np.array([s[0] for s in stops], dtype=np.float32)
        cols = np.array([s[1] for s in stops], dtype=np.float32)
        return np.stack([np.interp(t, xs, cols[:, c]) for c in range(3)], axis=-1)

    sky_t = np.clip(ys / HORIZON, 0, 1)
    sky_rows = vgrad(
        [(0.00, (38, 34, 76)), (0.45, (94, 56, 92)), (0.75, (196, 102, 84)), (1.00, (252, 178, 106))],
        sky_t,
    )
    ground_t = np.clip((ys - HORIZON) / (H - HORIZON), 0, 1)
    ground_rows = vgrad(
        [(0.0, (238, 188, 122)), (0.45, (216, 158, 96)), (1.0, (150, 96, 58))], ground_t
    )
    below = (ys > HORIZON).astype(np.float32)[:, None]
    rows = sky_rows * (1 - below) + ground_rows * below
    arr = np.repeat(rows[:, None, :], W, axis=1)

    im = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB").convert("RGBA")
    d = ImageDraw.Draw(im, "RGBA")

    # Sun glow at the horizon centre.
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((W * 0.5 - 330, HORIZON - 200, W * 0.5 + 330, HORIZON + 160), fill=(255, 214, 130, 110))
    gd.ellipse((W * 0.5 - 160, HORIZON - 95, W * 0.5 + 160, HORIZON + 75), fill=(255, 236, 170, 130))
    glow = glow.filter(ImageFilter.GaussianBlur(60))
    im.alpha_composite(glow)

    # Stars high up.
    rng = np.random.default_rng(3)
    for _ in range(70):
        x = rng.uniform(0, W)
        y = rng.uniform(0, HORIZON * 0.55)
        a = int(rng.uniform(40, 150) * (1 - y / (HORIZON * 0.6)))
        r = rng.uniform(0.8, 2.0)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(255, 244, 220, max(a, 0)))
    # Crescent.
    d.ellipse((W * 0.80 - 34, 96, W * 0.80 + 34, 164), fill=(250, 226, 150, 235))
    d.ellipse((W * 0.80 - 44, 88, W * 0.80 + 24, 156), fill=(0, 0, 0, 0))
    # Punch the crescent by re-overlaying sky color circle.
    d.ellipse((W * 0.80 - 46, 86, W * 0.80 + 22, 154), fill=(52, 40, 82, 255))

    # Mountain ridges with haze.
    for ridge, col, amp, yb in [
        (0, (122, 74, 88, 255), 60, HORIZON - 28),
        (1, (86, 52, 74, 255), 88, HORIZON + 6),
    ]:
        pts = [(0, yb)]
        rngr = np.random.default_rng(10 + ridge)
        x = 0
        while x < W:
            x += rngr.uniform(80, 190)
            pts.append((x, yb - rngr.uniform(20, amp)))
        pts += [(W, yb), (W, yb + 60), (0, yb + 60)]
        d.polygon([tuple(p) for p in chaikin(pts, 2, closed=True)], fill=col)

    # Distant skyline on the horizon: a cluster of domes and slender
    # minarets, silhouetted against the sunset with pinprick lights.
    city = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    cd = ImageDraw.Draw(city)
    cxs = W * 0.5
    base_y = HORIZON + 8
    sil = (94, 52, 58, 255)
    sil_far = (124, 70, 72, 255)
    # Far small domes.
    for dx, dw, dh in [(-210, 60, 34), (170, 74, 40), (250, 46, 26), (-150, 44, 24)]:
        cd.ellipse((cxs + dx - dw / 2, base_y - dh - 14, cxs + dx + dw / 2, base_y - 6), fill=sil_far)
        cd.rectangle((cxs + dx - dw / 2, base_y - 16, cxs + dx + dw / 2, base_y), fill=sil_far)
    # Main dome complex.
    cd.rectangle((cxs - 120, base_y - 40, cxs + 120, base_y), fill=sil)
    cd.ellipse((cxs - 74, base_y - 118, cxs + 74, base_y - 18), fill=sil)
    cd.ellipse((cxs - 16, base_y - 132, cxs + 16, base_y - 104), fill=sil)
    for mx in (-160, 160):
        cd.rectangle((cxs + mx - 6, base_y - 116, cxs + mx + 6, base_y), fill=sil)
        cd.ellipse((cxs + mx - 11, base_y - 132, cxs + mx + 11, base_y - 108), fill=sil)
        cd.line((cxs + mx, base_y - 144, cxs + mx, base_y - 128), fill=sil, width=3)
    # Warm rim light on dome tops (sun behind).
    cd.arc((cxs - 74, base_y - 118, cxs + 74, base_y - 18), 200, 340, fill=(255, 190, 120, 200), width=4)
    # Pinprick windows.
    rngc = np.random.default_rng(9)
    for _ in range(16):
        lx = cxs + rngc.uniform(-115, 115)
        ly = base_y - rngc.uniform(6, 34)
        cd.ellipse((lx - 2, ly - 2, lx + 2, ly + 2), fill=(255, 224, 150, 230))
    im.alpha_composite(city)

    # An oasis lake between the city and the board: an irregular pool
    # with a dark wet rim, catching a streak of sky light.
    lake = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ld = ImageDraw.Draw(lake)
    rngl = np.random.default_rng(41)
    lcx, lcy = W * 0.52, HORIZON + 150
    shore, water = [], []
    for k in range(14):
        ang = 2 * math.pi * k / 14
        rx = W * 0.215 * (1 + 0.18 * rngl.uniform(-1, 1))
        ry = 58 * (1 + 0.22 * rngl.uniform(-1, 1))
        shore.append((lcx + rx * math.cos(ang), lcy + ry * math.sin(ang)))
        water.append((lcx + (rx - 14) * math.cos(ang), lcy + (ry - 8) * math.sin(ang)))
    ld.polygon([tuple(p) for p in chaikin(shore, 3)], fill=(118, 88, 58, 255))
    ld.polygon([tuple(p) for p in chaikin(water, 3)], fill=(58, 142, 162, 255))
    inner = [(lcx + (p[0] - lcx) * 0.62, lcy + (p[1] - lcy) * 0.55 - 6) for p in water]
    ld.polygon([tuple(p) for p in chaikin(inner, 3)], fill=(132, 208, 212, 255))
    ld.ellipse((lcx - 55, lcy - 10, lcx + 65, lcy + 2), fill=(236, 232, 196, 90))
    lake = lake.filter(ImageFilter.GaussianBlur(1.6))
    im.alpha_composite(lake)

    # Broad tonal patches first: big, soft variation across the sand.
    mot = Image.new("L", (W, H), 0)
    md = ImageDraw.Draw(mot)
    rngm = np.random.default_rng(51)
    for _ in range(26):
        mx = rngm.uniform(-100, W + 100)
        my = rngm.uniform(HORIZON + 80, H + 100)
        mw = rngm.uniform(180, 520)
        mh = mw * rngm.uniform(0.28, 0.5)
        md.ellipse((mx - mw / 2, my - mh / 2, mx + mw / 2, my + mh / 2), fill=int(rngm.uniform(70, 150)))
    mot = mot.filter(ImageFilter.GaussianBlur(80))
    mot_a = np.asarray(mot, dtype=np.float32) / 255.0
    arrm = np.asarray(im, dtype=np.float32)
    gm = (np.arange(H)[:, None] > HORIZON).astype(np.float32)
    arrm[..., :3] *= (1.0 - 0.16 * mot_a * gm)[..., None]
    im = Image.fromarray(np.clip(arrm, 0, 255).astype(np.uint8), "RGBA")

    # Sand dune contour bands + texture noise on the ground.
    tex = fbm((H, W), octaves=5, seed=21, base=6)
    arr2 = np.asarray(im, dtype=np.float32)
    gmask = (np.arange(H)[:, None] > HORIZON).astype(np.float32)
    mod = (0.94 + 0.12 * tex) * gmask + (1 - gmask)
    arr2[..., :3] *= mod[..., None]
    im = Image.fromarray(np.clip(arr2, 0, 255).astype(np.uint8), "RGBA")
    d = ImageDraw.Draw(im, "RGBA")
    rngd = np.random.default_rng(31)
    for k in range(10):
        yb = HORIZON + 60 + (H - HORIZON - 120) * (k / 10) ** 1.3
        pts = [(0, yb)]
        x = 0
        while x < W:
            x += rngd.uniform(120, 260)
            pts.append((x, yb + rngd.uniform(-26, 26)))
        pts.append((W, yb))
        sm = chaikin(pts, 2, closed=False)
        d.line([tuple(p) for p in sm], fill=(255, 226, 170, 13), width=3)
        d.line([(p[0], p[1] + 3) for p in sm], fill=(90, 50, 30, 11), width=3)
    return im


# ---------------------------------------------------------------------------
# Compose.
# ---------------------------------------------------------------------------


def rotate_sprite(im, deg):
    return im.rotate(-deg, resample=Image.BICUBIC, expand=True)


def compose():
    scene = paint_backdrop()
    draws = []  # (sort_y, image, (x, y)) — y-sorted painter's algorithm

    def add(im, cx, cy, sort_y=None, scale=1.0):
        if scale != 1.0:
            im = im.resize((max(1, int(im.width * scale)), max(1, int(im.height * scale))), Image.LANCZOS)
        draws.append((sort_y if sort_y is not None else cy, im, (cx - im.width / 2, cy - im.height)))

    cells = track_positions()
    cxp, cyp, _ = persp(CX, CY)

    palms = [bake_palm(h, seed=s) for h, s in [(300, 1), (240, 5), (200, 9)]]
    rocks = [bake_rock(seed=s) for s in (2, 6, 12)]
    bushes = [bake_bush(seed=s) for s in (4, 8)]
    lantern = bake_lantern()

    # --- Causeway: a continuous raised roadbed the slabs sit on, so the
    # track reads as one built road through the desert, not loose stones.
    def stamp_causeway(points, width_fn):
        edge = Image.new("L", (W, H), 0)
        fill = Image.new("L", (W, H), 0)
        ed, fd = ImageDraw.Draw(edge), ImageDraw.Draw(fill)
        for (x, y) in points:
            r = width_fn(y)
            ed.ellipse((x - r - 7, y - r * 0.62 - 4, x + r + 7, y + r * 0.62 + 14), fill=255)
            fd.ellipse((x - r, y - r * 0.62, x + r, y + r * 0.62), fill=255)
        edge_a = np.asarray(edge.filter(ImageFilter.GaussianBlur(2)), dtype=np.float32) / 255
        fill_a = np.asarray(fill.filter(ImageFilter.GaussianBlur(2)), dtype=np.float32) / 255
        out = np.zeros((H, W, 4), dtype=np.uint8)
        # Dark earthen edge...
        out[..., 0], out[..., 1], out[..., 2] = 126, 84, 48
        out[..., 3] = (edge_a * 255).astype(np.uint8)
        scene.alpha_composite(Image.fromarray(out))
        # ...then the packed-sand roadbed with a little noise.
        tex = fbm((H, W), octaves=3, seed=61, base=10)
        road = np.zeros((H, W, 4), dtype=np.uint8)
        shade_mod = (206 + 24 * tex).astype(np.uint8)
        road[..., 0] = shade_mod
        road[..., 1] = (shade_mod * 0.82).astype(np.uint8)
        road[..., 2] = (shade_mod * 0.58).astype(np.uint8)
        road[..., 3] = (fill_a * 255).astype(np.uint8)
        scene.alpha_composite(Image.fromarray(road))

    dense = [persp(x, y) for (x, y) in _loop_points_dense(360)]
    stamp_causeway([(p[0], p[1]) for p in dense], lambda y: 84 * depth_of(y))
    for t_i in range(4):
        exit_i = (t_i * 6 - 1) % TRACK_N
        bx, by = cells[exit_i][0], cells[exit_i][1]
        lane_pts = []
        for k in range(40):
            t = 0.20 + (0.62 - 0.20) * k / 39
            lane_pts.append((bx + (cxp - bx) * t, by + (cyp - by) * t))
        stamp_causeway(lane_pts, lambda y: 62 * depth_of(y))

    # --- Track slabs (drawn as ground: sorted far below everything) ---
    slab_plain = [bake_slab(seed=s) for s in (3, 7, 15)]
    slab_star = bake_star_slab()
    slab_pool = bake_pool_slab()
    entry_slabs = {t: bake_colored_slab(t, chevron=False) for t in TEAM_ORDER}
    lane_slabs = {t: bake_colored_slab(t) for t in TEAM_ORDER}

    anchors_track = []
    rng_rot = np.random.default_rng(55)
    for i, (x, y, depth, tang) in enumerate(cells):
        off = i % 6
        if off == 0:
            team = TEAM_ORDER[i // 6]
            spr = entry_slabs[team]
        elif off == 2:
            spr = slab_star
        elif off == 4:
            spr = slab_pool
        else:
            spr = slab_plain[i % 3]
        # Axis-aligned paving with just a hand-laid wobble: rotated cells
        # read as chaos, straight ones read as a road.
        rot = rotate_sprite(spr, float(rng_rot.uniform(-4, 4)))
        s = 1.07 * depth
        rot = rot.resize((int(rot.width * s), int(rot.height * s)), Image.LANCZOS)
        # Slabs paste as ground plane immediately (before props), with a
        # soft drop shadow so the paving sits IN the sand, not on it.
        m = np.asarray(rot.split()[-1], dtype=np.float32) / 255.0
        shd = soft_shadow(m, blur=7, opacity=0.35, squash=0.9, dy=10)
        scene.alpha_composite(
            Image.fromarray(shd), (int(x - rot.width / 2) + 6, int(y - rot.height / 2) + 10)
        )
        scene.alpha_composite(rot, (int(x - rot.width / 2), int(y - rot.height / 2)))
        anchors_track.append((x, y - 8 * depth, depth))

    # --- Final lanes: 4 colored arms into the centre ---
    anchors_lane = {t: [] for t in TEAM_ORDER}
    for t_i, team in enumerate(TEAM_ORDER):
        exit_i = (t_i * 6 - 1) % TRACK_N
        bx, by, bd, _ = cells[exit_i]
        for step in range(1, 5):
            # Stop well short of the pool: the last lane slab meets the
            # centre paving edge, not the water.
            t = 0.26 + 0.38 * (step - 1) / 3
            x = bx + (cxp - bx) * t
            y = by + (cyp - by) * t
            depth = depth_of(y)
            ang = math.degrees(math.atan2(cyp - by, cxp - bx))
            spr = rotate_sprite(lane_slabs[team], ang + 90)
            s = 0.74 * depth
            spr = spr.resize((int(spr.width * s), int(spr.height * s)), Image.LANCZOS)
            m = np.asarray(spr.split()[-1], dtype=np.float32) / 255.0
            shd = soft_shadow(m, blur=6, opacity=0.32, squash=0.9, dy=8)
            scene.alpha_composite(
                Image.fromarray(shd), (int(x - spr.width / 2) + 5, int(y - spr.height / 2) + 8)
            )
            scene.alpha_composite(spr, (int(x - spr.width / 2), int(y - spr.height / 2)))
            anchors_lane[team].append((x, y - 6 * depth, depth))

    # --- Centre landmark, ringed by greenery so the oasis reads lush ---
    center_im = bake_center(470)
    add(center_im, cxp, cyp + 170, sort_y=cyp + 20)
    anchor_center = (cxp, cyp + 30, 1.0)
    ring_rng = np.random.default_rng(83)
    for k in range(9):
        ang = 2 * math.pi * k / 9 + 0.3
        gx = cxp + 262 * math.cos(ang)
        gy = cyp + 92 + 150 * math.sin(ang)
        d_ = depth_of(gy)
        pick = ring_rng.random()
        if pick < 0.5:
            add(bushes[k % 2], gx, gy, sort_y=gy + 40, scale=0.62 * d_)
        elif pick < 0.8:
            add(rocks[k % 3], gx, gy, sort_y=gy + 40, scale=0.6 * d_)
        else:
            add(lantern, gx, gy, sort_y=gy + 40, scale=0.9 * d_)

    # --- Camps: big pavilions + 4 horse slots each ---
    camp_pos = {
        "emerald": (150, 622),
        "saphir": (1020, 622),
        "grenat": (980, 1952),
        "safran": (190, 1952),
    }
    slot_im = bake_horse_slot(100)
    anchors_camp = {t: [] for t in TEAM_ORDER}
    for team, (cx, cy) in camp_pos.items():
        depth = depth_of(cy)
        tent = bake_tent(team)
        ts = (0.86 if cy < H / 2 else 0.68) * depth
        # Tent sits behind its horse slots.
        add(tent, cx, cy + 40, sort_y=cy - 130, scale=ts)
        # A paddock apron in front of the tent for the 2x2 stable slots.
        apron = ellipse_mask((360, 200), (6, 30, 354, 194))
        apron_im = to_image(shade(apron, (208, 172, 122), shade_rgb=(124, 92, 56), z_scale=1.6, spec=0.15))
        if cy < H / 2:
            add(apron_im, cx, cy + 220 * depth, sort_y=cy - 60, scale=depth)
        else:
            add(apron_im, cx, cy + 190 * depth, sort_y=cy - 60, scale=1.25 * depth)
        top_half = cy < H / 2
        for k in range(4):
            if top_half:
                # Slots in front of (below) the tent, two by two.
                sign = 1 if cx < W / 2 else -1
                sx = cx + sign * (-52 + 116 * (k % 2)) * depth
                sy = cy + (92 + 76 * (k // 2)) * depth
            else:
                # Bottom camps: one visible row of four in front of the
                # tent, above the HUD band.
                sx = cx + (-126 + 84 * k) * depth
                sy = cy + (64 + (12 if k % 2 == 1 else 0)) * depth
            sd = depth_of(sy)
            add(slot_im, sx, sy + 22, sort_y=sy - 30, scale=0.85 * sd)
            anchors_camp[team].append((sx, sy + 2, sd))

    # --- Props: palms, rocks, bushes, lanterns scattered with depth ---
    chest = bake_chest_mini()

    def on_track(x, y, margin):
        best = min(math.hypot(x - c[0], y - c[1]) for c in cells)
        return best < margin

    rng = np.random.default_rng(77)
    # Between horizon and board: a distant palm grove band.
    for _ in range(10):
        x = rng.uniform(40, W - 40)
        y = rng.uniform(HORIZON + 60, HORIZON + 240)
        s = rng.uniform(0.28, 0.45)
        add(palms[rng.integers(0, 3)], x, y, scale=s)
    # Around the lake and in the top band between the camps.
    for lx, ly, ls in [(255, 585, 0.62), (352, 610, 0.5), (868, 592, 0.6), (782, 618, 0.48), (568, 560, 0.42)]:
        add(palms[0] if ls > 0.55 else palms[1], lx, ly, scale=ls)
        if ls > 0.5:
            add(bushes[0], lx + 40, ly + 8, scale=0.55)
    for rx_, ry_, rs in [(455, 620, 0.8), (700, 640, 0.9)]:
        add(rocks[1], rx_, ry_, scale=rs)

    # Inside + around the loop.
    for _ in range(96):
        x = rng.uniform(30, W - 30)
        y = rng.uniform(HORIZON + 260, H - 240)
        if on_track(x, y, 112):
            continue
        r = math.hypot(x - cxp, y - cyp)
        if r < 300:  # keep the centre stage clear
            continue
        # Keep the camp aprons clear too.
        if any(math.hypot(x - px, y - py - 120) < 260 for px, py in camp_pos.values()):
            continue
        depth = depth_of(y)
        pick = rng.random()
        if pick < 0.38:
            add(palms[rng.integers(0, 3)], x, y, scale=rng.uniform(0.5, 0.85) * depth)
        elif pick < 0.62:
            add(rocks[rng.integers(0, 3)], x, y, scale=rng.uniform(0.7, 1.2) * depth)
        elif pick < 0.86:
            add(bushes[rng.integers(0, 2)], x, y, scale=rng.uniform(0.7, 1.1) * depth)
        else:
            add(lantern, x, y, scale=rng.uniform(0.8, 1.0) * depth)
    # Inner wedges between the lanes.
    for wx, wy, kind, ws in [
        (585, 830, "palm", 0.55), (500, 880, "bush", 0.7), (680, 872, "rock", 0.8),
        (250, 1236, "bush", 0.8), (330, 1160, "rock", 0.7),
        (920, 1236, "palm", 0.5), (870, 1320, "bush", 0.7),
        (585, 1640, "palm", 0.62), (500, 1700, "rock", 0.9), (688, 1690, "bush", 0.8),
    ]:
        d_ = depth_of(wy)
        if kind == "palm":
            add(palms[2], wx, wy, scale=ws * d_)
        elif kind == "rock":
            add(rocks[2], wx, wy, scale=ws * d_)
        else:
            add(bushes[1], wx, wy, scale=ws * d_)

    # Lanterns punctuating the track corners.
    for i in (2, 8, 14, 20):
        x, y, depth, _ = cells[i]
        add(lantern, x + 74 * depth, y - 30, scale=1.25 * depth)
    # Occluders: palms leaning over the causeway so the road passes
    # THROUGH the grove, not beside it.
    add(palms[0], 96, 1568, scale=0.9)
    add(palms[1], 1078, 1020, scale=0.78)
    add(palms[2], 942, 1668, scale=0.85)
    add(palms[1], 214, 792, scale=0.62)
    # A chest resting beside a star cell for flavour.
    x, y, depth, _ = cells[9]
    add(chest, min(x + 128 * depth, W - 70), y + 20, scale=0.8 * depth)

    # Foreground occluders at the very bottom.
    add(palms[0], 30, H + 130, sort_y=H + 100, scale=1.45)
    add(palms[1], W - 20, H + 110, sort_y=H + 100, scale=1.35)
    add(rocks[0], 585, H + 40, sort_y=H + 90, scale=1.7)

    # Paint the y-sorted props with contact shadows.
    draws.sort(key=lambda d: d[0])
    for _, im, (x, y) in draws:
        sh_h = im.height
        m = np.asarray(im.split()[-1], dtype=np.float32) / 255.0
        if m.max() > 0:
            shd = soft_shadow(m, blur=8, opacity=0.30, squash=0.18, dy=0)
            scene.alpha_composite(Image.fromarray(shd), (int(x), int(y - sh_h * 0.06)))
        scene.alpha_composite(im, (int(x), int(y)))

    # ------------------------------------------------------------------
    # Grade: warm highlights, teal-shadow lift, vignette, bloom.
    # ------------------------------------------------------------------
    arr = np.asarray(scene.convert("RGB"), dtype=np.float32) / 255.0
    luma = arr.mean(axis=2, keepdims=True)
    warm = np.array([1.06, 0.99, 0.90])[None, None, :]
    cool = np.array([0.92, 0.99, 1.10])[None, None, :]
    arr = arr * (cool + (warm - cool) * luma)
    # Vignette.
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    vr = np.sqrt(((xx - W / 2) / (W * 0.75)) ** 2 + ((yy - H / 2) / (H * 0.68)) ** 2)
    arr *= (1 - 0.30 * np.clip(vr - 0.55, 0, 1))[..., None]
    # Bloom from bright pixels.
    bright = np.clip(arr - 0.78, 0, 1)
    bloom = np.asarray(
        Image.fromarray((bright * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(14)),
        dtype=np.float32,
    ) / 255.0
    arr = np.clip(arr + bloom * 0.5, 0, 1)
    # Gentle S-curve.
    arr = np.clip(arr * 1.06 - 0.02, 0, 1)
    arr = arr ** 0.96
    scene = Image.fromarray((arr * 255).astype(np.uint8), "RGB")

    anchors = {
        "track": anchors_track,
        "lane": anchors_lane,
        "camp": anchors_camp,
        "center": anchor_center,
    }
    return scene, anchors


def emit_dart(anchors, path="lib/widgets/board/scene_anchors.g.dart"):
    def fmt(p):
        return f"SceneAnchor({p[0] / W:.4f}, {p[1] / H:.4f}, {p[2]:.3f})"

    lanes = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p) for p in anchors['lane'][team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    camps = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p) for p in anchors['camp'][team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    track = ",\n  ".join(fmt(p) for p in anchors["track"])
    src = f"""// GENERATED by tool/art/bake_scene.py — do not edit by hand.
// Anchor positions are normalized to the baked scene image
// (assets/board/scene_oasis.webp); scale is the perspective depth
// factor for sprites standing at that anchor.

class SceneAnchor {{
  const SceneAnchor(this.x, this.y, this.scale);

  final double x;
  final double y;
  final double scale;
}}

const List<SceneAnchor> sceneTrackAnchors = [
  {track},
];

const Map<int, List<SceneAnchor>> sceneLaneAnchors = {{
  {lanes},
}};

const Map<int, List<SceneAnchor>> sceneCampAnchors = {{
  {camps},
}};

const SceneAnchor sceneCenterAnchor = {fmt(anchors["center"])};
"""
    with open(path, "w") as f:
        f.write(src)
    print("wrote", path)


def main():
    scene, anchors = compose()
    os.makedirs("assets/board", exist_ok=True)
    scene.save("assets/board/scene_oasis.webp", "WEBP", quality=88, method=6)
    print("assets/board/scene_oasis.webp", scene.size)
    emit_dart(anchors)
    if "--preview" in sys.argv:
        os.makedirs("build/art_preview", exist_ok=True)
        scene.save("build/art_preview/scene.png")
        print("preview: build/art_preview/scene.png")


if __name__ == "__main__":
    main()
