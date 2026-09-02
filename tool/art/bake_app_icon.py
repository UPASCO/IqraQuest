"""Bake the IqraQuest launcher icon — an original flat emblem — to every
PNG size Android, iOS and the web target need, plus a review sheet.

The mark: a gold eight-point star (the khatam of Islamic geometry, the
badge shape that survives any launcher mask) holding an emerald field
where a golden knight — the very figurine that rides the board — rises
out of an open book. Read (Iqra), then ride (Quest). No person, no
Kaaba-as-object, no text: the rules of ASSET_LICENSES / spec §23.

Run:  python3 tool/art/bake_app_icon.py [--preview]
Writes ios/…/AppIcon.appiconset, android/…/mipmap-*/ic_launcher.png,
web/icons/*.png, web/favicon.png and build/screenshots/app_icon_*.png.
The iOS files are written without an alpha channel, as App Store
validation requires.
"""

from __future__ import annotations

import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(__file__))
from sprite_lib import chaikin  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
S = 1024  # master size
SS = 4  # supersampling for anti-aliased masks

# ---- Palette -----------------------------------------------------------
EMERALD_TOP = (26, 138, 96)
EMERALD_BOTTOM = (8, 62, 46)
EMERALD_FIELD_TOP = (12, 78, 58)
EMERALD_FIELD_BOTTOM = (6, 42, 32)
GOLD_LIGHT = (247, 210, 120)
GOLD = (230, 178, 78)
GOLD_DEEP = (176, 118, 36)
IVORY = (248, 240, 222)
IVORY_SHADE = (224, 208, 176)
NIGHT = (8, 30, 24)


# ---- Raster helpers ----------------------------------------------------
def _canvas():
    return np.zeros((S, S, 3), dtype=np.float32)


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


def blur(mask, radius):
    im = Image.fromarray((np.clip(mask, 0, 1) * 255).astype(np.uint8))
    return np.asarray(im.filter(ImageFilter.GaussianBlur(radius)), dtype=np.float32) / 255.0


def vgrad(top, bottom, y0=0.0, y1=1.0):
    """Vertical gradient image between two colours over the y0..y1 span."""
    t = np.clip((np.linspace(0, 1, S) - y0) / max(1e-6, y1 - y0), 0, 1)
    col = np.asarray(top, np.float32)[None, :] * (1 - t)[:, None] + np.asarray(bottom, np.float32)[None, :] * t[:, None]
    return np.repeat(col[:, None, :], S, axis=1)


def rgrad_alpha(cx, cy, r):
    """Radial falloff [1 at centre → 0 at r] as an SxS alpha."""
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float32) / S
    d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / r
    return np.clip(1 - d, 0, 1) ** 1.6


def fill(img, mask, colour):
    m = mask[..., None]
    if isinstance(colour, np.ndarray) and colour.ndim == 3:
        return img * (1 - m) + colour * m
    return img * (1 - m) + np.asarray(colour, np.float32)[None, None, :] * m


def star(cx, cy, r_out, r_in, n=8, rot=-np.pi / 2):
    pts = []
    for i in range(2 * n):
        r = r_out if i % 2 == 0 else r_in
        a = rot + i * np.pi / n
        pts.append((cx + np.cos(a) * r, cy + np.sin(a) * r))
    return pts


# ---- The emblem --------------------------------------------------------
def _horse(tx, scale):
    """The knight, facing right, in a unit box mapped through tx: a long
    wedge of a head on an arched neck, the two edges converging on the
    muzzle — the one proportion that makes a silhouette read 'horse'."""
    head = [
        (0.14, 1.00), (0.08, 0.84), (0.10, 0.66), (0.18, 0.50),
        (0.28, 0.36), (0.38, 0.24), (0.46, 0.16), (0.56, 0.14),
        (0.66, 0.17), (0.76, 0.25), (0.86, 0.35), (0.94, 0.44),
        (1.00, 0.52), (0.98, 0.61), (0.92, 0.68), (0.84, 0.70),
        (0.76, 0.70), (0.68, 0.71), (0.60, 0.68), (0.55, 0.66),
        (0.52, 0.78), (0.54, 0.90), (0.58, 1.00),
    ]
    ear_back = [(0.40, 0.22), (0.43, 0.00), (0.51, 0.17)]
    ear_front = [(0.53, 0.17), (0.58, -0.02), (0.66, 0.19)]
    mane = [
        (0.08, 0.84), (0.02, 0.66), (0.06, 0.48), (0.16, 0.33),
        (0.28, 0.21), (0.40, 0.13), (0.48, 0.10), (0.44, 0.22),
        (0.36, 0.31), (0.26, 0.43), (0.19, 0.57), (0.17, 0.71),
        (0.19, 0.86),
    ]
    forelock = [(0.50, 0.15), (0.60, 0.12), (0.72, 0.20), (0.70, 0.27), (0.60, 0.23)]

    def m(poly):
        return [tx(x, y) for x, y in poly]

    body = poly_mask([m(head)], smooth=1)
    body = np.maximum(body, poly_mask([m(ear_back), m(ear_front)]))
    mane_m = np.maximum(poly_mask([m(mane)], smooth=2), poly_mask([m(forelock)], smooth=1))
    return body, mane_m


def render(fg_scale=1.0):
    """The icon at master size. `fg_scale` shrinks the emblem about the
    centre while the ground still bleeds full-frame (maskable targets)."""

    def tx(x, y):
        return (0.5 + (x - 0.5) * fg_scale, 0.5 + (y - 0.5) * fg_scale)

    img = _canvas()

    # Ground: a living emerald, lit from the upper left.
    img = vgrad(EMERALD_TOP, EMERALD_BOTTOM)
    img = fill(img, rgrad_alpha(0.32, 0.18, 0.9) * 0.35, (48, 170, 118))

    # Star shadow, then the gold star and its emerald field.
    cx, cy = tx(0.5, 0.5)
    r_out = 0.445 * fg_scale
    r_in = r_out * 0.72
    star_m = poly_mask([star(cx, cy, r_out, r_in)])
    shadow = blur(poly_mask([star(cx, cy + 0.02 * fg_scale, r_out, r_in)]), 22)
    img = fill(img, shadow * 0.5, NIGHT)
    img = fill(img, star_m, vgrad(GOLD_LIGHT, GOLD_DEEP, cy - r_out, cy + r_out))
    # A crisp lighter rim on the upper facets.
    rim = np.clip(star_m - poly_mask([star(cx, cy + 0.012 * fg_scale, r_out, r_in)]), 0, 1)
    img = fill(img, rim, (255, 232, 170))

    field_out = r_out * 0.86
    field_m = poly_mask([star(cx, cy, field_out, field_out * 0.72)])
    img = fill(img, field_m, vgrad(EMERALD_FIELD_TOP, EMERALD_FIELD_BOTTOM, cy - field_out, cy + field_out))
    # Dawn glow rising behind the book.
    img = fill(img, field_m * rgrad_alpha(cx, cy + 0.20 * fg_scale, 0.42 * fg_scale) * 0.55, (214, 160, 66))

    # The open book, seen from the front, its pages bowing up and out;
    # the knight is painted between cover and pages so it rises out of
    # the book rather than standing on it.
    bx, by, bw = 0.5, 0.745, 0.54  # centre x, baseline y, width
    cover = [
        (bx - bw / 2 - 0.02, by - 0.06), (bx, by - 0.01), (bx + bw / 2 + 0.02, by - 0.06),
        (bx + bw / 2 + 0.02, by + 0.03), (bx, by + 0.08), (bx - bw / 2 - 0.02, by + 0.03),
    ]
    def page_edge(t):
        # The page's top edge from spine (t=0) to outer corner (t=1):
        # bowed upward in the middle, the corner a touch above the gutter.
        return by - 0.128 - 0.055 * 4 * t * (1 - t) - 0.012 * t

    def page_x(t):
        return bx - 0.006 - t * (bw / 2 - 0.006)

    left_page = (
        [(page_x(t), page_edge(t)) for t in (1.0, 0.8, 0.6, 0.4, 0.2, 0.0)]
        + [(page_x(0.0), by + 0.030), (page_x(1.0), by - 0.015)]
    )
    right_page = [(2 * bx - x, y) for x, y in left_page]
    img = fill(img, poly_mask([[tx(*p) for p in cover]], smooth=1), vgrad(GOLD, GOLD_DEEP, by - 0.08, by + 0.09))

    # The knight rising out of the book.
    hx, hy, hw, hh = 0.30, 0.215, 0.42, 0.47  # box: left, top, width, height

    def htx(x, y):
        return tx(hx + x * hw, hy + y * hh)

    body, mane = _horse(htx, fg_scale)
    silhouette = np.maximum(body, mane)
    img = fill(img, blur(silhouette, 14) * 0.5 * (1 - silhouette), NIGHT)
    img = fill(img, body, vgrad(GOLD_LIGHT, GOLD, hy, hy + hh))
    img = fill(img, mane, vgrad(GOLD, GOLD_DEEP, hy, hy + hh))
    # Eye and nostril: the two marks that make a silhouette a face.
    ex, ey = htx(0.70, 0.33)
    img = fill(img, ellipse_mask(ex, ey, 0.019 * fg_scale, 0.019 * fg_scale), NIGHT)
    img = fill(img, ellipse_mask(ex + 0.005 * fg_scale, ey - 0.006 * fg_scale, 0.006 * fg_scale, 0.006 * fg_scale), IVORY)
    nx, ny = htx(0.94, 0.55)
    img = fill(img, ellipse_mask(nx, ny, 0.011 * fg_scale, 0.008 * fg_scale) * 0.7, GOLD_DEEP)

    pages = poly_mask([[tx(*p) for p in left_page], [tx(*p) for p in right_page]])
    img = fill(img, blur(pages, 10) * 0.35 * (1 - pages), NIGHT)
    img = fill(img, pages, vgrad(IVORY, IVORY_SHADE, by - 0.19, by + 0.04))
    # Gutter: the pages curve down into the spine.
    gutter = pages * blur(poly_mask([[tx(bx - 0.05, by - 0.25), tx(bx + 0.05, by - 0.25), tx(bx + 0.05, by + 0.1), tx(bx - 0.05, by + 0.1)]]), 12)
    img = fill(img, gutter * 0.6, IVORY_SHADE)
    # Three ruled lines a page, following the bowed edge: read, not blank.
    for side in (-1, 1):
        for dy in (0.040, 0.068, 0.096):
            ts = (0.12, 0.3, 0.5, 0.7, 0.86)
            top = [(bx + side * (bx - page_x(t)), page_edge(t) + dy - 0.005) for t in ts]
            bottom = [(bx + side * (bx - page_x(t)), page_edge(t) + dy + 0.005) for t in reversed(ts)]
            img = fill(img, poly_mask([[tx(*q) for q in top + bottom]]) * 0.32, GOLD_DEEP)

    # One spark above the brow: the moment of knowing.
    sx, sy = tx(0.725, 0.245)
    spark = poly_mask([star(sx, sy, 0.055 * fg_scale, 0.016 * fg_scale, n=4)])
    img = fill(img, blur(spark, 8) * 0.6, GOLD_LIGHT)
    img = fill(img, spark, IVORY)

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


def main():
    full = render(1.0)
    maskable = render(0.78)

    for name, size in IOS:
        _save(full, os.path.join(IOS_DIR, name), size, mode="RGB")
    for density, size in ANDROID:
        _save(full, f"android/app/src/main/res/mipmap-{density}/ic_launcher.png", size)
    _save(full, "web/icons/Icon-192.png", 192)
    _save(full, "web/icons/Icon-512.png", 512)
    _save(maskable, "web/icons/Icon-maskable-192.png", 192)
    _save(maskable, "web/icons/Icon-maskable-512.png", 512)
    _save(full, "web/favicon.png", 32)

    # Review sheet: the icon at the sizes a home screen actually shows.
    shots = os.path.join(ROOT, "build", "screenshots")
    os.makedirs(shots, exist_ok=True)
    full.save(os.path.join(shots, "app_icon_1024.png"))
    sheet = Image.new("RGB", (1024, 300), (18, 18, 22))
    x = 24
    for size in (180, 120, 87, 60, 40):
        r = 40
        thumb = full.resize((size, size), Image.LANCZOS)
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * 0.22), fill=255)
        sheet.paste(thumb, (x, 150 - size // 2), mask)
        x += size + 40
    sheet.paste(maskable.resize((200, 200), Image.LANCZOS), (800, 50))
    sheet.save(os.path.join(shots, "app_icon_sheet.png"))
    print("icon baked:", len(IOS), "iOS +", len(ANDROID), "Android + 5 web; sheet in build/screenshots/")


if __name__ == "__main__":
    if "--preview" in sys.argv:
        render(1.0).save(os.path.join(ROOT, "build", "screenshots", "app_icon_1024.png"))
    else:
        main()
