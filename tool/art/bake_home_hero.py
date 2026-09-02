"""Bake the home screen's hero image from the game's own art.

The home screen used to be painted at runtime — a vector horse on a
vector dune — which looked like a different product from the board it
led to. This composes ONE image out of the assets the game actually
plays with, so the first screen and the board are the same world:

  * the painted plate (assets/board/cross_board.webp), laid down in
    perspective on its cloth, with a gold rim light and a cast shadow;
  * the four painted knights (assets/board/pack/horse_*.webp) standing
    along its near edge, each on its own contact shadow;
  * palms and a lantern from the board pack as dark foreground framing;
  * the night, the stars and the crescent of the app icon above it.

Everything here is compositing and lighting of existing artwork — no
new subject is drawn. Output: assets/images/home_hero.webp (portrait,
full-bleed: the screen's UI sits straight on top of it).

Run:  python3 tool/art/bake_home_hero.py [--preview]
"""

from __future__ import annotations

import math
import os
import random
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "assets", "images", "home_hero.webp")

# A phone's own aspect (iPhone 6.5", 1242x2688): the screen then shows
# the picture whole instead of cropping its sides, which is what a
# squarer canvas costs under BoxFit.cover.
W, H = 1242, 2688

# The board's own cloth and gold, so the image and the plate agree.
SKY_TOP = (4, 20, 26)
CLOTH_LIGHT = (17, 80, 67)
CLOTH_DARK = (6, 31, 26)
GOLD = (243, 214, 138)
GOLD_DEEP = (198, 158, 74)
FOOT = (6, 35, 26)  # the calm ground the CTA sits on

rng = random.Random(7)


def asset(*parts: str) -> Image.Image:
    return Image.open(os.path.join(ROOT, *parts))


# ---- helpers ----------------------------------------------------------


def vertical_gradient(size, stops):
    """stops: [(t, (r,g,b)), ...] with t in 0..1, ascending."""
    w, h = size
    ys = np.linspace(0, 1, h)[:, None]
    ts = np.array([s[0] for s in stops])
    cols = np.array([s[1] for s in stops], dtype=np.float32)
    out = np.zeros((h, 3), dtype=np.float32)
    for c in range(3):
        out[:, c] = np.interp(ys[:, 0], ts, cols[:, c])
    return Image.fromarray(
        np.repeat(out[:, None, :], w, axis=1).astype(np.uint8), "RGB"
    )


def radial(size, centre, radius, colour, strength):
    """A soft radial wash as an L mask multiplied into a flat colour."""
    w, h = size
    yy, xx = np.mgrid[0:h, 0:w]
    d = np.sqrt((xx - centre[0]) ** 2 + (yy - centre[1]) ** 2) / radius
    a = np.clip(1 - d, 0, 1) ** 2 * strength
    layer = Image.new("RGB", size, colour)
    return layer, Image.fromarray((a * 255).astype(np.uint8), "L")


def perspective_coeffs(target, source):
    """Coefficients mapping the output quad back into the source quad."""
    matrix = []
    for (tx, ty), (sx, sy) in zip(target, source):
        matrix.append([sx, sy, 1, 0, 0, 0, -tx * sx, -tx * sy])
        matrix.append([0, 0, 0, sx, sy, 1, -ty * sx, -ty * sy])
    a = np.array(matrix, dtype=float)
    b = np.array(target, dtype=float).reshape(8)
    res = np.linalg.solve(a.T @ a, a.T @ b)
    return np.array(res).reshape(8)


def lay_flat(img, quad, canvas_size):
    """Puts a square image onto `quad` (tl, tr, br, bl) of the canvas."""
    src = img.convert("RGBA")
    w, h = src.size
    coeffs = perspective_coeffs(
        [(0, 0), (w, 0), (w, h), (0, h)],
        quad,
    )
    return src.transform(canvas_size, Image.PERSPECTIVE, coeffs, Image.BICUBIC)


def contact_shadow(size, centre, rx, ry, alpha, blur):
    """The dark pool that puts an object ON the table instead of over it."""
    layer = Image.new("L", size, 0)
    ImageDraw.Draw(layer).ellipse(
        [centre[0] - rx, centre[1] - ry, centre[0] + rx, centre[1] + ry],
        fill=int(alpha * 255),
    )
    return layer.filter(ImageFilter.GaussianBlur(blur))


def glow_from(alpha: Image.Image, spread: int, colour, strength: float):
    """A coloured halo bled out of an object's own silhouette."""
    halo = alpha.filter(ImageFilter.GaussianBlur(spread))
    arr = np.asarray(halo, dtype=np.float32) / 255.0
    arr = np.clip(arr * strength, 0, 1)
    return Image.new("RGB", alpha.size, colour), Image.fromarray(
        (arr * 255).astype(np.uint8), "L"
    )


# ---- the composition --------------------------------------------------


def build() -> Image.Image:
    canvas = vertical_gradient(
        (W, H),
        [
            (0.00, SKY_TOP),
            (0.30, (9, 46, 44)),
            (0.58, CLOTH_LIGHT),
            (0.84, CLOTH_DARK),
            (1.00, FOOT),
        ],
    )

    # --- the icon's own three horses, as the backdrop -------------------
    # The artwork the app is known by, cropped to the horses and bled
    # into the table: the first screen and the home-screen icon are the
    # same picture.
    art = asset("tool", "art", "source", "app_icon_source.webp").convert("RGB")
    aw, ah = art.size
    horses = art.crop(
        (int(aw * 0.055), int(ah * 0.10), int(aw * 0.945), int(ah * 0.74))
    )
    scale = (W * 1.04) / horses.width
    horses = horses.resize(
        (int(horses.width * scale), int(horses.height * scale)), Image.LANCZOS
    )
    hx = (W - horses.width) // 2
    hy = int(H * 0.070)

    # Feathered: hard edges would read as a photo pasted on a background.
    fade = np.ones((horses.height, horses.width), dtype=np.float32)
    ramp = np.clip(np.linspace(0, 1, horses.height), 0, 1)
    fade *= np.clip((1 - ramp) / 0.34, 0, 1)[:, None] ** 1.15  # bottom
    side = np.clip(np.minimum(
        np.linspace(0, 1, horses.width), 1 - np.linspace(0, 1, horses.width)
    ) / 0.10, 0, 1)
    fade *= side[None, :]
    top = np.clip(np.linspace(0, 1, horses.height) / 0.06, 0, 1)
    fade *= top[:, None]
    layer = Image.new("RGB", (W, H), (0, 0, 0))
    layer.paste(horses, (hx, hy))
    mask = Image.new("L", (W, H), 0)
    mask.paste(
        Image.fromarray((fade * 255).astype(np.uint8), "L"), (hx, hy)
    )
    canvas.paste(layer, (0, 0), mask)

    # Pushed back a little, so the board in front of it reads as nearer.
    depth = np.clip((np.linspace(0, 1, H) - 0.34) / 0.22, 0, 1) ** 1.2 * 0.62
    canvas.paste(
        Image.new("RGB", (W, H), (5, 26, 26)),
        (0, 0),
        Image.fromarray((depth[:, None] * np.ones((1, W)) * 255).astype(np.uint8), "L"),
    )

    # --- a few stars over the night above them --------------------------
    stars = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(stars)
    for _ in range(70):
        x = rng.uniform(0, W)
        y = rng.uniform(0, H * 0.10)
        fade_s = 1 - y / (H * 0.10)
        r = rng.choice([1.0, 1.0, 1.5])
        sd.ellipse(
            [x - r, y - r, x + r, y + r],
            fill=(244, 236, 220, int(255 * (0.06 + 0.40 * fade_s))),
        )
    canvas = Image.alpha_composite(canvas.convert("RGBA"), stars).convert("RGB")

    # --- the board, laid on the table in front of them ------------------
    plate_centre = (W * 0.5, H * 0.645)
    wash, mask = radial((W, H), plate_centre, W * 0.95, (255, 214, 140), 0.30)
    canvas.paste(wash, (0, 0), mask)

    plate = asset("assets", "board", "cross_board.webp")
    top_y, bot_y = H * 0.485, H * 0.800
    quad = [
        (W * 0.5 - W * 0.335, top_y),
        (W * 0.5 + W * 0.335, top_y),
        (W * 0.5 + W * 0.545, bot_y),
        (W * 0.5 - W * 0.545, bot_y),
    ]
    laid = lay_flat(plate, quad, (W, H))
    alpha = laid.getchannel("A")

    shadow = alpha.filter(ImageFilter.GaussianBlur(40))
    shadow = shadow.point(lambda v: int(v * 0.80))
    canvas.paste(Image.new("RGB", (W, H), (2, 12, 10)), (0, int(H * 0.018)), shadow)
    rim_c, rim_m = glow_from(alpha, 52, GOLD_DEEP, 0.95)
    canvas.paste(rim_c, (0, 0), rim_m)
    canvas = Image.alpha_composite(canvas.convert("RGBA"), laid).convert("RGB")

    bloom_c, bloom_m = glow_from(alpha, 150, (255, 206, 120), 0.34)
    canvas.paste(bloom_c, (0, 0), bloom_m)

    # --- gold motes in the warm air between them ------------------------
    motes = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    md = ImageDraw.Draw(motes)
    for _ in range(110):
        a = rng.uniform(0, math.tau)
        d = rng.uniform(0.05, 1.0) ** 0.6 * W * 0.58
        x = W * 0.5 + math.cos(a) * d
        y = H * 0.52 + math.sin(a) * d * 0.42
        if not (0 < x < W and 0 < y < H):
            continue
        r = rng.uniform(1.0, 3.4)
        md.ellipse(
            [x - r, y - r, x + r, y + r],
            fill=(255, 232, 170, int(rng.uniform(35, 170))),
        )
    canvas = Image.alpha_composite(
        canvas.convert("RGBA"), motes.filter(ImageFilter.GaussianBlur(0.7))
    ).convert("RGB")

    # --- the calm foot the buttons sit on, and the vignette -------------
    band = np.clip((np.linspace(0, 1, H) - 0.845) / 0.155, 0, 1) ** 1.3
    canvas.paste(
        Image.new("RGB", (W, H), FOOT),
        (0, 0),
        Image.fromarray((band[:, None] * np.ones((1, W)) * 235).astype(np.uint8), "L"),
    )

    yy, xx = np.mgrid[0:H, 0:W]
    d = np.sqrt(((xx - W / 2) / (W * 0.80)) ** 2 + ((yy - H * 0.52) / (H * 0.60)) ** 2)
    vig = np.clip((d - 0.44) / 0.72, 0, 1) ** 1.4 * 0.90
    canvas.paste(
        Image.new("RGB", (W, H), (2, 10, 12)),
        (0, 0),
        Image.fromarray((vig * 255).astype(np.uint8), "L"),
    )
    return canvas


def main():
    hero = build()
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    hero.save(OUT, "WEBP", quality=88, method=6)
    print("home hero baked:", OUT, hero.size, f"{os.path.getsize(OUT) // 1024} KB")
    if "--preview" in sys.argv:
        shots = os.path.join(ROOT, "build", "screenshots")
        os.makedirs(shots, exist_ok=True)
        hero.resize((W // 3, H // 3), Image.LANCZOS).save(
            os.path.join(shots, "home_hero_preview.png")
        )
        print("preview in build/screenshots/home_hero_preview.png")


if __name__ == "__main__":
    main()
