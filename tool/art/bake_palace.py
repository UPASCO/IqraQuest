"""The centre-of-board landmark: a golden oasis palace.

Rendered at high resolution as one composed sprite: raised platform,
arcaded facade with a grand iwan, onion domes on drums, four minarets,
tilework bands, glowing windows, forecourt pool with fountain jets.

Run solo:  python3 tool/art/bake_palace.py   (writes build/art_preview/palace.png)
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
    ellipse_mask,
    fbm,
    poly_mask,
    rounded_rect_mask,
    shade,
    star_band,
    to_image,
)

GOLD = (240, 198, 110)
GOLD_DEEP = (146, 98, 32)
WALL = (243, 214, 158)
WALL_DEEP = (150, 104, 52)
DOME = (252, 210, 118)
DOME_DEEP = (160, 100, 36)


def _dome(im, w, h, cx, cy, rw, rh, base=DOME, deep=DOME_DEEP):
    """Onion dome: bulb + tapered tip + gold finial."""
    bulb = ellipse_mask((w, h), (cx - rw, cy - rh, cx + rw, cy + rh * 0.72))
    tip = poly_mask(
        (w, h),
        [[(cx - rw * 0.30, cy - rh * 0.82), (cx, cy - rh * 1.28), (cx + rw * 0.30, cy - rh * 0.82)]],
        smooth=2,
    )
    m = np.clip(bulb + tip, 0, 1)
    alpha_paste(
        im,
        to_image(shade(m, base, shade_rgb=deep, inflate=0.5, z_scale=5.0, spec=0.85, spec_power=30)),
        (0, 0),
    )
    # Vertical ribs catch the light.
    for k in (-0.55, -0.18, 0.18, 0.55):
        rib = poly_mask(
            (w, h),
            [[(cx + rw * k - 1.5, cy - rh * 0.95), (cx + rw * k + 1.5, cy - rh * 0.95),
              (cx + rw * k * 1.35 + 1.5, cy + rh * 0.55), (cx + rw * k * 1.35 - 1.5, cy + rh * 0.55)]],
            smooth=1,
        )
        arr = shade(rib, (255, 236, 178), z_scale=1.0, spec=0.2, rim=0.0)
        arr[..., 3] = (arr[..., 3] * 0.5 * m).astype(np.uint8)
        alpha_paste(im, to_image(arr), (0, 0))
    # Finial.
    fin = ellipse_mask((w, h), (cx - 4, cy - rh * 1.42, cx + 4, cy - rh * 1.24))
    alpha_paste(im, to_image(shade(fin, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.4, spec=0.9)), (0, 0))


def _minaret(im, w, h, cx, base_y, top_y, rw):
    shaft = poly_mask(
        (w, h),
        [[(cx - rw, base_y), (cx - rw * 0.66, top_y), (cx + rw * 0.66, top_y), (cx + rw, base_y)]],
        smooth=1,
    )
    alpha_paste(
        im,
        to_image(shade(shaft, WALL, shade_rgb=WALL_DEEP, inflate=0.9, z_scale=5.0, spec=0.5, spec_power=22)),
        (0, 0),
    )
    # Balcony ring.
    bal_y = top_y + (base_y - top_y) * 0.18
    bal = ellipse_mask((w, h), (cx - rw * 1.22, bal_y - 4, cx + rw * 1.22, bal_y + 7))
    alpha_paste(im, to_image(shade(bal, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.6, spec=0.7)), (0, 0))
    # Cap dome.
    _dome(im, w, h, cx, top_y - 6, rw * 1.15, rw * 1.7)


def bake_palace(width=760):
    w = width
    h = int(width * 0.88)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    plat_y = h * 0.78

    # ---- Raised platform: two stone tiers with tilework ----
    t2 = ellipse_mask((w, h), (w * 0.015, plat_y - h * 0.055, w * 0.985, plat_y + h * 0.16))
    alpha_paste(im, to_image(shade(t2, (176, 138, 92), shade_rgb=(96, 68, 40), z_scale=2.2, spec=0.15)), (0, 0))
    t1 = ellipse_mask((w, h), (w * 0.05, plat_y - h * 0.10, w * 0.95, plat_y + h * 0.09))
    tex = fbm((h, w), octaves=4, seed=19, base=8)
    alpha_paste(
        im,
        to_image(shade(t1, (228, 196, 146), shade_rgb=(138, 100, 58), inflate=0.9, z_scale=2.0, spec=0.25, texture=tex, texture_amp=0.05)),
        (0, 0),
    )

    # ---- Back minarets (tall, behind the building) ----
    _minaret(im, w, h, w * 0.145, plat_y - h * 0.02, h * 0.135, w * 0.020)
    _minaret(im, w, h, w * 0.855, plat_y - h * 0.02, h * 0.135, w * 0.020)

    # ---- Side wings with arcades ----
    for x0, x1 in [(0.20, 0.40), (0.60, 0.80)]:
        _dome(im, w, h, w * (x0 + x1) / 2, h * 0.415, w * 0.058, h * 0.062)
        wing = rounded_rect_mask((w, h), (w * x0, h * 0.44, w * x1, plat_y), 10)
        alpha_paste(
            im,
            to_image(shade(wing, WALL, shade_rgb=WALL_DEEP, inflate=0.85, z_scale=3.2, spec=0.4, spec_power=20)),
            (0, 0),
        )
        # Arcade of three arches.
        for k in range(3):
            ax = w * (x0 + 0.035 + 0.065 * k)
            arch = poly_mask(
                (w, h),
                [[(ax, plat_y - 4), (ax, h * 0.56), (ax + w * 0.017, h * 0.515),
                  (ax + w * 0.034, h * 0.56), (ax + w * 0.034, plat_y - 4)]],
                smooth=2,
            )
            aa = np.zeros((h, w, 4), dtype=np.uint8)
            aa[..., 0], aa[..., 1], aa[..., 2] = 74, 40, 26
            aa[..., 3] = (arch * 235).astype(np.uint8)
            alpha_paste(im, Image.fromarray(aa), (0, 0))
            glow = ellipse_mask((w, h), (ax + 3, h * 0.60, ax + w * 0.030, plat_y - 8)) * arch
            gg = np.zeros((h, w, 4), dtype=np.uint8)
            gg[..., 0], gg[..., 1], gg[..., 2] = 255, 186, 92
            gg[..., 3] = (glow * 130).astype(np.uint8)
            alpha_paste(im, Image.fromarray(gg).filter(ImageFilter.GaussianBlur(2)), (0, 0))

    # ---- Central block with the grand iwan ----
    block = rounded_rect_mask((w, h), (w * 0.40, h * 0.335, w * 0.60, plat_y), 12)
    alpha_paste(
        im,
        to_image(shade(block, (248, 222, 168), shade_rgb=WALL_DEEP, inflate=0.8, z_scale=3.4, spec=0.45, spec_power=22)),
        (0, 0),
    )
    # Tilework band across the facade.
    alpha_paste(im, star_band((w, h), (w * 0.405, h * 0.36, w * 0.595, h * 0.395), cell=int(w * 0.024), color=(64, 130, 128), alpha=200), (0, 0))
    # Iwan: tall pointed arch, dark with warm glow.
    iwan = poly_mask(
        (w, h),
        [[(w * 0.445, plat_y - 4), (w * 0.445, h * 0.475), (w * 0.5, h * 0.415),
          (w * 0.555, h * 0.475), (w * 0.555, plat_y - 4)]],
        smooth=2,
    )
    ia = np.zeros((h, w, 4), dtype=np.uint8)
    ia[..., 0], ia[..., 1], ia[..., 2] = 66, 34, 22
    ia[..., 3] = (iwan * 240).astype(np.uint8)
    alpha_paste(im, Image.fromarray(ia), (0, 0))
    ig = ellipse_mask((w, h), (w * 0.457, h * 0.55, w * 0.543, plat_y - 8)) * iwan
    gg = np.zeros((h, w, 4), dtype=np.uint8)
    gg[..., 0], gg[..., 1], gg[..., 2] = 255, 192, 96
    gg[..., 3] = (ig * 165).astype(np.uint8)
    alpha_paste(im, Image.fromarray(gg).filter(ImageFilter.GaussianBlur(3)), (0, 0))
    # Red patterned carpet runner from the iwan down to the pool.
    carpet = poly_mask(
        (w, h),
        [[(w * 0.472, plat_y - 2), (w * 0.528, plat_y - 2),
          (w * 0.545, plat_y + h * 0.052), (w * 0.455, plat_y + h * 0.052)]],
        smooth=1,
    )
    alpha_paste(im, to_image(shade(carpet, (168, 52, 44), shade_rgb=(84, 20, 18), z_scale=1.4, spec=0.2)), (0, 0))
    cb = poly_mask(
        (w, h),
        [[(w * 0.479, plat_y + 2), (w * 0.521, plat_y + 2),
          (w * 0.534, plat_y + h * 0.045), (w * 0.466, plat_y + h * 0.045)]],
        smooth=1,
    )
    arrc = shade(cb, (222, 168, 96), z_scale=1.0, spec=0.2)
    arrc[..., 3] = (arrc[..., 3] * 0.55).astype(np.uint8)
    alpha_paste(im, to_image(arrc), (0, 0))
    # Gold arch frame.
    frame = poly_mask(
        (w, h),
        [[(w * 0.437, plat_y - 2), (w * 0.437, h * 0.468), (w * 0.5, h * 0.400),
          (w * 0.563, h * 0.468), (w * 0.563, plat_y - 2), (w * 0.548, plat_y - 2),
          (w * 0.548, h * 0.478), (w * 0.5, h * 0.425), (w * 0.452, h * 0.478),
          (w * 0.452, plat_y - 2)]],
        smooth=1,
    )
    alpha_paste(im, to_image(shade(frame, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.0, spec=0.7, spec_power=26)), (0, 0))

    # ---- Main dome on a drum + crown of the composition ----
    _dome(im, w, h, w * 0.5, h * 0.235, w * 0.098, h * 0.115)
    drum = rounded_rect_mask((w, h), (w * 0.435, h * 0.295, w * 0.565, h * 0.35), 8)
    alpha_paste(im, to_image(shade(drum, WALL, shade_rgb=WALL_DEEP, z_scale=3.0, spec=0.4)), (0, 0))
    alpha_paste(im, star_band((w, h), (w * 0.44, h * 0.305, w * 0.56, h * 0.335), cell=int(w * 0.02), color=(64, 130, 128), alpha=190), (0, 0))

    # ---- Front minarets (short, at platform edge) ----
    _minaret(im, w, h, w * 0.245, plat_y + h * 0.045, h * 0.30, w * 0.016)
    _minaret(im, w, h, w * 0.755, plat_y + h * 0.045, h * 0.30, w * 0.016)

    # ---- Forecourt pool with jets ----
    rim_m = ellipse_mask((w, h), (w * 0.30, plat_y + h * 0.035, w * 0.70, plat_y + h * 0.155))
    alpha_paste(im, to_image(shade(rim_m, GOLD, shade_rgb=GOLD_DEEP, z_scale=2.0, spec=0.6, spec_power=24)), (0, 0))
    pool = ellipse_mask((w, h), (w * 0.315, plat_y + h * 0.045, w * 0.685, plat_y + h * 0.145))
    alpha_paste(
        im,
        to_image(shade(pool, (52, 170, 186), shade_rgb=(10, 66, 100), inflate=1.3, z_scale=1.0, spec=0.8, spec_power=9)),
        (0, 0),
    )
    # Sky reflection streak + ripple rings.
    refl = ellipse_mask((w, h), (w * 0.40, plat_y + h * 0.06, w * 0.60, plat_y + h * 0.095))
    ra = shade(refl, (255, 216, 150), z_scale=0.6, spec=0.0, rim=0.0)
    ra[..., 3] = (ra[..., 3] * 0.45).astype(np.uint8)
    alpha_paste(im, to_image(ra), (0, 0))
    d = ImageDraw.Draw(im)
    for k in range(3):
        rr = w * (0.05 + 0.05 * k)
        d.ellipse(
            (w * 0.5 - rr, plat_y + h * 0.095 - rr * 0.28, w * 0.5 + rr, plat_y + h * 0.095 + rr * 0.28),
            outline=(220, 245, 240, 70),
            width=2,
        )
    # Fountain jets arcing into the pool.
    for sgn in (-1, 1):
        for js in (0.35, 0.55):
            arc = []
            for k in range(10):
                t = k / 9
                ax = w * 0.5 + sgn * w * js * 0.16 * t
                ay = plat_y + h * 0.02 + (t * t) * h * 0.075 - t * h * 0.035
                arc.append((ax, ay))
            arc += [(x, y + 3) for x, y in reversed(arc)]
            jm = poly_mask((w, h), [arc], smooth=1)
            ja = shade(jm, (210, 244, 246), z_scale=0.8, spec=0.3, rim=0.0)
            ja[..., 3] = (ja[..., 3] * 0.7).astype(np.uint8)
            alpha_paste(im, to_image(ja), (0, 0))

    # ---- Warm bloom around the whole palace ----
    lum = np.asarray(im, dtype=np.float32)
    bright = np.clip(lum[..., :3].mean(axis=2) - 200, 0, 55) / 55 * (lum[..., 3] / 255)
    ba = np.zeros((h, w, 4), dtype=np.uint8)
    ba[..., 0], ba[..., 1], ba[..., 2] = 255, 214, 130
    ba[..., 3] = (bright * 90).astype(np.uint8)
    alpha_paste(im, Image.fromarray(ba).filter(ImageFilter.GaussianBlur(10)), (0, 0))
    return im


if __name__ == "__main__":
    os.makedirs("build/art_preview", exist_ok=True)
    bg = Image.new("RGBA", (820, 740), (222, 172, 108, 255))
    p = bake_palace()
    bg.alpha_composite(p, (30, 40))
    bg.save("build/art_preview/palace.png")
    print("build/art_preview/palace.png")
