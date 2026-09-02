"""Bake the IqraQuest launcher icon — an original flat emblem — to every
PNG size Android, iOS and the web target need, plus a review sheet.

The mark is the game in one glance: a golden horse at full gallop
racing up a petits-chevaux track — square tiles in the four stable
colours — toward a radiant fan of question cards, a crescent in the sky
above: the race for Islamic knowledge, won by answering. No person, no
Kaaba-as-object, no text (the question mark is a glyph, not a word):
the rules of ASSET_LICENSES / spec §23.

Run:  python3 tool/art/bake_app_icon.py [--preview]
Writes ios/…/AppIcon.appiconset, android/…/mipmap-*/ic_launcher.png,
web/icons/*.png, web/favicon.png and build/screenshots/app_icon_*.png.
The iOS files are written without an alpha channel, as App Store
validation requires.
"""

from __future__ import annotations

import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, os.path.dirname(__file__))
from sprite_lib import chaikin  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FONT_PATH = os.path.join(ROOT, "assets", "fonts", "NotoSans-Regular.ttf")
S = 1024  # master size
SS = 4  # supersampling for anti-aliased masks

# ---- Palette -----------------------------------------------------------
EMERALD_LIGHT = (30, 150, 104)
EMERALD = (14, 96, 68)
EMERALD_DEEP = (6, 44, 33)
GOLD_LIGHT = (250, 214, 126)
GOLD = (232, 180, 80)
GOLD_DEEP = (170, 112, 34)
IVORY = (250, 243, 226)
IVORY_SHADE = (222, 206, 172)
NIGHT = (6, 28, 22)
LIGHT = (255, 238, 190)
STABLES = [(46, 158, 96), (58, 108, 202), (224, 168, 62), (186, 82, 168)]  # emerald, sapphire, saffron, garnet


# ---- Raster helpers ----------------------------------------------------
def poly_mask(polys, smooth=0):
    """Anti-aliased [0,1] mask of one or more polygons in 0..1 coordinates."""
    im = Image.new("L", (S * SS, S * SS), 0)
    d = ImageDraw.Draw(im)
    for poly in polys:
        pts = chaikin(poly, smooth) if smooth else [tuple(p) for p in poly]
        d.polygon([(x * S * SS, y * S * SS) for x, y in pts], fill=255)
    im = im.resize((S, S), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def ellipse_mask(cx, cy, rx, ry):
    im = Image.new("L", (S * SS, S * SS), 0)
    d = ImageDraw.Draw(im)
    k = S * SS
    d.ellipse([(cx - rx) * k, (cy - ry) * k, (cx + rx) * k, (cy + ry) * k], fill=255)
    im = im.resize((S, S), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def stroke_mask(points, width, smooth=2):
    """A ribbon of constant width along a polyline (0..1 coordinates)."""
    pts = chaikin(points, smooth, closed=False) if smooth else list(points)
    im = Image.new("L", (S * SS, S * SS), 0)
    d = ImageDraw.Draw(im)
    k = S * SS
    d.line([(x * k, y * k) for x, y in pts], fill=255, width=int(width * k), joint="curve")
    r = width * k / 2
    for x, y in (pts[0], pts[-1]):
        d.ellipse([x * k - r, y * k - r, x * k + r, y * k + r], fill=255)
    im = im.resize((S, S), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def blur(mask, radius):
    im = Image.fromarray((np.clip(mask, 0, 1) * 255).astype(np.uint8))
    return np.asarray(im.filter(ImageFilter.GaussianBlur(radius)), dtype=np.float32) / 255.0


def vgrad(top, bottom, y0=0.0, y1=1.0):
    """Vertical gradient image between two colours over the y0..y1 span."""
    t = np.clip((np.linspace(0, 1, S) - y0) / max(1e-6, y1 - y0), 0, 1)
    col = np.asarray(top, np.float32)[None, :] * (1 - t)[:, None] + np.asarray(bottom, np.float32)[None, :] * t[:, None]
    return np.repeat(col[:, None, :], S, axis=1)


def dgrad(c0, c1, x0, y0, x1, y1):
    """Gradient along the segment (x0,y0)→(x1,y1)."""
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float32) / S
    dx, dy = x1 - x0, y1 - y0
    t = np.clip(((xx - x0) * dx + (yy - y0) * dy) / max(1e-6, dx * dx + dy * dy), 0, 1)
    return np.asarray(c0, np.float32)[None, None, :] * (1 - t)[..., None] + np.asarray(c1, np.float32)[None, None, :] * t[..., None]


def rgrad_alpha(cx, cy, r, power=1.6):
    """Radial falloff [1 at centre → 0 at r] as an SxS alpha."""
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float32) / S
    d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / r
    return np.clip(1 - d, 0, 1) ** power


def fill(img, mask, colour):
    m = mask[..., None]
    if isinstance(colour, np.ndarray) and colour.ndim == 3:
        return img * (1 - m) + colour * m
    return img * (1 - m) + np.asarray(colour, np.float32)[None, None, :] * m


def rotated(points, cx, cy, deg):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [(cx + (x - cx) * c - (y - cy) * s, cy + (x - cx) * s + (y - cy) * c) for x, y in points]


# ---- The horse ---------------------------------------------------------
# A racing silhouette in the flying gallop, facing right, built from
# articulated primitives in a unit box (x right, y down): a barrel, a
# neck raised into the wind, a wedge of a head, four legs in two tapered
# segments each — forelegs reaching, hind legs driving — and streaming
# mane and tail. Joints are authored, so the pose is easy to tune.
def _taper(p0, p1, w0, w1):
    (x0, y0), (x1, y1) = p0, p1
    dx, dy = x1 - x0, y1 - y0
    n = math.hypot(dx, dy) or 1.0
    nx, ny = -dy / n, dx / n
    return [
        (x0 + nx * w0 / 2, y0 + ny * w0 / 2), (x1 + nx * w1 / 2, y1 + ny * w1 / 2),
        (x1 - nx * w1 / 2, y1 - ny * w1 / 2), (x0 - nx * w0 / 2, y0 - ny * w0 / 2),
    ]


def _ellipse_poly(cx, cy, rx, ry, deg=0.0, n=48):
    pts = [(cx + math.cos(2 * math.pi * i / n) * rx, cy + math.sin(2 * math.pi * i / n) * ry) for i in range(n)]
    return rotated(pts, cx, cy, deg)


HEAD = [
    (0.79, 0.10), (0.88, 0.08), (0.97, 0.16), (1.04, 0.26), (1.03, 0.33),
    (0.97, 0.37), (0.88, 0.35), (0.81, 0.28),
]
EARS = [[(0.815, 0.13), (0.825, -0.01), (0.865, 0.11)], [(0.865, 0.11), (0.895, 0.00), (0.92, 0.125)]]
LEGS = [  # (joint chain, widths) — order: shoulder/hip, knee/hock, fetlock, hoof
    ([(0.63, 0.43), (0.78, 0.50), (0.90, 0.53), (0.97, 0.55)], (0.16, 0.085, 0.06, 0.065)),   # fore, reaching
    ([(0.59, 0.45), (0.64, 0.61), (0.67, 0.72), (0.69, 0.79)], (0.15, 0.08, 0.06, 0.065)),    # fore, under
    ([(0.35, 0.42), (0.18, 0.53), (0.07, 0.60), (0.01, 0.64)], (0.20, 0.095, 0.065, 0.07)),   # hind, driving
    ([(0.38, 0.45), (0.27, 0.62), (0.22, 0.73), (0.19, 0.80)], (0.18, 0.09, 0.062, 0.068)),   # hind, under
]
# Mane: a band along the crest streaming back, with a scalloped tail edge.
MANE = [
    (0.67, 0.31), (0.73, 0.22), (0.79, 0.14), (0.77, 0.08), (0.72, 0.10),
    (0.69, 0.06), (0.65, 0.12), (0.61, 0.13), (0.59, 0.20), (0.60, 0.28),
]
# Tail: a long lock streaming back, thinning to a split tip.
TAIL = [(0.30, 0.33), (0.21, 0.27), (0.11, 0.23), (0.01, 0.22)]
TAIL_WIDTHS = (0.10, 0.08, 0.055, 0.02)


def horse_masks(box, tilt):
    """Body and hair masks for the horse laid in `box` (x, y, w, h) and
    rotated by `tilt` degrees about the box centre (negative = climbing)."""
    x, y, w, h = box
    cx, cy = x + w / 2, y + h / 2

    def m(poly):
        return rotated([(x + px * w, y + py * h) for px, py in poly], cx, cy, tilt)

    parts = [
        _ellipse_poly(0.49, 0.41, 0.24, 0.115, -6),           # barrel
        _ellipse_poly(0.33, 0.41, 0.12, 0.13, 0),             # hindquarters
        _ellipse_poly(0.64, 0.41, 0.11, 0.12, 0),             # shoulder
        _taper((0.66, 0.38), (0.86, 0.18), 0.22, 0.15),       # neck
    ]
    for chain, widths in LEGS:
        for i in range(3):
            parts.append(_taper(chain[i], chain[i + 1], widths[i], widths[i + 1]))
    body = poly_mask([m(p) for p in parts])
    body = np.maximum(body, poly_mask([m(HEAD)], smooth=1))
    body = np.maximum(body, poly_mask([m(e) for e in EARS]))
    # Round the joints so the legs read as one limb, not four sticks.
    for chain, widths in LEGS:
        for i in (1, 2, 3):
            jx, jy = chain[i]
            body = np.maximum(body, poly_mask([m(_ellipse_poly(jx, jy, widths[i] / 2, widths[i] / 2))]))

    tail_parts = [_taper(TAIL[i], TAIL[i + 1], TAIL_WIDTHS[i], TAIL_WIDTHS[i + 1]) for i in range(3)]
    tail_parts.append(_taper((0.11, 0.23), (0.02, 0.29), 0.045, 0.015))
    hair = np.maximum(poly_mask([m(MANE)], smooth=1), poly_mask([m(p) for p in tail_parts]))
    for i in (1, 2):
        jx, jy = TAIL[i]
        hair = np.maximum(hair, poly_mask([m(_ellipse_poly(jx, jy, TAIL_WIDTHS[i] / 2, TAIL_WIDTHS[i] / 2))]))
    return body, hair


# ---- The icon ----------------------------------------------------------
def render(fg_scale=1.0):
    """The icon at master size. `fg_scale` shrinks the scene about the
    centre while the ground still bleeds full-frame (maskable targets)."""

    def tx(x, y):
        return (0.5 + (x - 0.5) * fg_scale, 0.5 + (y - 0.5) * fg_scale)

    def txs(poly):
        return [tx(*p) for p in poly]

    # Sky: emerald, deepest at the bottom-left where the race starts,
    # brightest around the Book at the top-right, where it ends.
    img = dgrad(EMERALD_DEEP, EMERALD, 0.1, 0.95, 0.75, 0.25)
    book_c = tx(0.745, 0.245)
    img = fill(img, rgrad_alpha(book_c[0], book_c[1], 0.62 * fg_scale, 1.2) * 0.85, EMERALD_LIGHT)

    # Rays of the Book's light, soft and few.
    rays = np.zeros((S, S), np.float32)
    for i in range(12):
        a = math.radians(i * 30 + 15)
        half = math.radians(5.5)
        p0 = book_c
        p1 = (p0[0] + math.cos(a - half) * 1.2, p0[1] + math.sin(a - half) * 1.2)
        p2 = (p0[0] + math.cos(a + half) * 1.2, p0[1] + math.sin(a + half) * 1.2)
        rays = np.maximum(rays, poly_mask([[p0, p1, p2]]))
    rays = blur(rays, 6) * rgrad_alpha(book_c[0], book_c[1], 0.7 * fg_scale, 1.0)
    img = fill(img, rays * 0.22, LIGHT)
    img = fill(img, rgrad_alpha(book_c[0], book_c[1], 0.30 * fg_scale, 1.0) * 0.55, LIGHT)

    # The track: the petits-chevaux path itself, a curve of square tiles
    # in the four stable colours with ivory squares between, climbing
    # from the corner to the cards. The board is the game's first symbol.
    track_pts = [(0.00, 0.99), (0.14, 0.86), (0.30, 0.72), (0.48, 0.60), (0.60, 0.50), (0.69, 0.42)]
    track = stroke_mask(txs(track_pts), 0.085 * fg_scale)
    img = fill(img, blur(track, 12) * 0.45, NIGHT)
    img = fill(img, track, dgrad(GOLD_DEEP, GOLD, *tx(0.05, 0.95), *tx(0.66, 0.44)))
    curve = chaikin(track_pts, 3, closed=False)
    lengths = [0.0]
    for (x0, y0), (x1, y1) in zip(curve, curve[1:]):
        lengths.append(lengths[-1] + math.hypot(x1 - x0, y1 - y0))
    total = lengths[-1]
    n_tiles = 9
    for k in range(n_tiles):
        d = total * (0.06 + 0.88 * k / (n_tiles - 1))
        i = max(1, next(j for j, L in enumerate(lengths) if L >= d))
        f = (d - lengths[i - 1]) / max(1e-6, lengths[i] - lengths[i - 1])
        (ax, ay), (bx_, by_) = curve[i - 1], curve[i]
        px, py = ax + (bx_ - ax) * f, ay + (by_ - ay) * f
        ang = math.degrees(math.atan2(by_ - ay, bx_ - ax))
        r = 0.027
        sq = [(px - r, py - r), (px + r, py - r), (px + r, py + r), (px - r, py + r)]
        sq = txs(rotated(sq, px, py, ang))
        colour = STABLES[(k // 2) % 4] if k % 2 == 0 else IVORY
        img = fill(img, poly_mask([sq]), GOLD_DEEP)
        inner = [(px - r * 0.8, py - r * 0.8), (px + r * 0.8, py - r * 0.8), (px + r * 0.8, py + r * 0.8), (px - r * 0.8, py + r * 0.8)]
        img = fill(img, poly_mask([txs(rotated(inner, px, py, ang))]), colour)

    # The destination: a fan of question cards, the front one carrying a
    # bold question mark — the quiz that decides every move.
    cx_, cy_ = 0.745, 0.245
    cw, ch = 0.19, 0.25

    def card(dx, dy, deg, shrink=0.0):
        # A rounded rectangle, corners sampled so no smoothing is needed.
        w, h, r = cw / 2 - shrink, ch / 2 - shrink, 0.022
        pts = []
        for (sx, sy) in ((1, -1), (1, 1), (-1, 1), (-1, -1)):
            ccx, ccy = cx_ + dx + sx * (w - r), cy_ + dy + sy * (h - r)
            base = {(1, -1): -90, (1, 1): 0, (-1, 1): 90, (-1, -1): 180}[(sx, sy)]
            for i in range(7):
                a = math.radians(base + i * 15)
                pts.append((ccx + math.cos(a) * r, ccy + math.sin(a) * r))
        return txs(rotated(pts, cx_ + dx, cy_ + dy, deg))

    for dx, dy, deg, face in ((-0.075, 0.015, -16, STABLES[1]), (0.075, 0.015, 16, STABLES[0])):
        img = fill(img, blur(poly_mask([card(dx, dy, deg)]), 12) * 0.4, NIGHT)
        img = fill(img, poly_mask([card(dx, dy, deg)]), GOLD)
        img = fill(img, poly_mask([card(dx, dy, deg, shrink=0.009)]), face)
    img = fill(img, blur(poly_mask([card(0, 0, 0)]), 14) * 0.5, NIGHT)
    img = fill(img, poly_mask([card(0, 0, 0)]), GOLD)
    img = fill(img, poly_mask([card(0, 0, 0, shrink=0.008)]), vgrad(IVORY, IVORY_SHADE, cy_ - ch / 2, cy_ + ch / 2))
    # The question mark, set in the app's own display face.
    glyph = Image.new("L", (S * SS, S * SS), 0)
    font = ImageFont.truetype(FONT_PATH, int(0.24 * fg_scale * S * SS))
    d = ImageDraw.Draw(glyph)
    gx, gy = tx(cx_, cy_ + 0.005)
    d.text((gx * S * SS, gy * S * SS), "?", fill=255, font=font, anchor="mm", stroke_width=int(0.006 * fg_scale * S * SS), stroke_fill=255)
    qmask = np.asarray(glyph.resize((S, S), Image.LANCZOS), dtype=np.float32) / 255.0
    img = fill(img, blur(qmask, 6) * 0.35, GOLD_DEEP)
    img = fill(img, qmask, dgrad(GOLD_DEEP, GOLD, *tx(cx_, cy_ - 0.12), *tx(cx_, cy_ + 0.12)))

    # The crescent above the cards.
    mx, my, mr = 0.905, 0.075, 0.046
    crescent = np.clip(ellipse_mask(*tx(mx, my), mr * fg_scale, mr * fg_scale) - ellipse_mask(*tx(mx + 0.022, my - 0.014), mr * 0.88 * fg_scale, mr * 0.88 * fg_scale), 0, 1)
    img = fill(img, blur(crescent, 10) * 0.5, GOLD_LIGHT)
    img = fill(img, crescent, GOLD_LIGHT)

    # The horse, mid-stride on the track, climbing toward the light.
    box = (0.00, 0.36, 0.73, 0.48)
    box = tuple(v * fg_scale + (0.5 - 0.5 * fg_scale) * (1 if i < 2 else 0) for i, v in enumerate(box))
    body, hair = horse_masks(box, -15)
    silhouette = np.maximum(body, hair)
    # Speed: three streaks fading out behind the horse.
    for k, (y0, ln) in enumerate(((0.52, 0.16), (0.58, 0.22), (0.64, 0.14))):
        x0 = 0.02
        streak = stroke_mask([tx(x0, y0 + 0.02 * k), tx(x0 + ln, y0 - ln * 0.28 + 0.02 * k)], 0.018 * fg_scale, smooth=0)
        img = fill(img, blur(streak, 3) * 0.45 * (1 - silhouette), GOLD)
    img = fill(img, blur(silhouette, 16) * 0.55 * (1 - silhouette), NIGHT)
    body_grad = dgrad(GOLD_LIGHT, GOLD, box[0], box[1], box[0] + box[2] * 0.4, box[1] + box[3])
    img = fill(img, body, body_grad)
    img = fill(img, hair, dgrad(GOLD, GOLD_DEEP, box[0] + box[2], box[1], box[0], box[1] + box[3]))
    # Eye.
    ex, ey = rotated([(box[0] + 0.905 * box[2], box[1] + 0.17 * box[3])], box[0] + box[2] / 2, box[1] + box[3] / 2, -14)[0]
    img = fill(img, ellipse_mask(ex, ey, 0.011 * fg_scale, 0.011 * fg_scale), NIGHT)
    # Dust kicked up at the hind hooves.
    for (dx, dy, r) in ((0.07, 0.83, 0.035), (0.13, 0.86, 0.025), (0.03, 0.88, 0.02)):
        puff = ellipse_mask(*tx(dx, dy), r * fg_scale, r * 0.75 * fg_scale)
        img = fill(img, blur(puff, 6) * 0.35, IVORY)

    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGB")


# ---- Targets -----------------------------------------------------------
IOS_DIR = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
IOS = [
    ("Icon-App-20x20@1x.png", 20), ("Icon-App-20x20@2x.png", 40), ("Icon-App-20x20@3x.png", 60),
    ("Icon-App-29x29@1x.png", 29), ("Icon-App-29x29@2x.png", 58), ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@1x.png", 40), ("Icon-App-40x40@2x.png", 80), ("Icon-App-40x40@3x.png", 120),
    ("Icon-App-60x60@2x.png", 120), ("Icon-App-60x60@3x.png", 180),
    ("Icon-App-76x76@1x.png", 76), ("Icon-App-76x76@2x.png", 152),
    ("Icon-App-83.5x83.5@2x.png", 167), ("Icon-App-1024x1024@1x.png", 1024),
]
ANDROID = [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)]


def _save(img, rel, size, mode="RGBA"):
    path = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS).convert(mode)
    out.save(path, optimize=True)


def review_sheet(full, maskable):
    """The icon at the sizes a home screen actually shows, plus the
    maskable variant, in build/screenshots/."""
    shots = os.path.join(ROOT, "build", "screenshots")
    os.makedirs(shots, exist_ok=True)
    full.save(os.path.join(shots, "app_icon_1024.png"))
    sheet = Image.new("RGB", (1024, 300), (18, 18, 22))
    x = 24
    for size in (180, 120, 87, 60, 40):
        thumb = full.resize((size, size), Image.LANCZOS)
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * 0.22), fill=255)
        sheet.paste(thumb, (x, 150 - size // 2), mask)
        x += size + 40
    sheet.paste(maskable.resize((200, 200), Image.LANCZOS), (800, 50))
    sheet.save(os.path.join(shots, "app_icon_sheet.png"))


def main():
    full = render(1.0)
    maskable = render(0.8)
    for name, size in IOS:
        _save(full, os.path.join(IOS_DIR, name), size, mode="RGB")
    for density, size in ANDROID:
        _save(full, f"android/app/src/main/res/mipmap-{density}/ic_launcher.png", size)
    _save(full, "web/icons/Icon-192.png", 192)
    _save(full, "web/icons/Icon-512.png", 512)
    _save(maskable, "web/icons/Icon-maskable-192.png", 192)
    _save(maskable, "web/icons/Icon-maskable-512.png", 512)
    _save(full, "web/favicon.png", 32)
    review_sheet(full, maskable)
    print("icon baked:", len(IOS), "iOS +", len(ANDROID), "Android + 5 web; sheet in build/screenshots/")


if __name__ == "__main__":
    if "--preview" in sys.argv:
        review_sheet(render(1.0), render(0.8))
    else:
        main()
