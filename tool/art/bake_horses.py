"""Bake the team figurine horses: glossy game-piece sprites with real
volume, one per stable color, standing on a round pedestal.

Run:  python3 tool/art/bake_horses.py [--preview]
Outputs assets/board/horses/horse_<team>.webp (+ a preview grid).
"""

from __future__ import annotations

import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
from sprite_lib import (  # noqa: E402
    alpha_paste,
    ellipse_mask,
    poly_mask,
    shade,
    soft_shadow,
    to_image,
)

W, H = 440, 540
GROUND = 470  # where hooves rest

# Stable palettes: (coat, deep shade, mane) — richly saturated figurines.
TEAMS = {
    "emerald": ((46, 158, 96), (10, 54, 34), (16, 84, 52)),
    "saphir": ((58, 108, 202), (14, 34, 88), (24, 56, 128)),
    "safran": ((224, 168, 62), (110, 66, 14), (160, 108, 30)),
    "grenat": ((186, 82, 168), (78, 22, 74), (120, 44, 110)),
}
GOLD = (238, 196, 108)
GOLD_DEEP = (140, 96, 30)


def _horse_body_polys(dx=0.0, dy=0.0):
    """Union of simple shapes that the distance-field shading fuses
    into one chunky proud figurine, facing right. Toy-like proportions:
    big barrel, thick arched neck, big head, short sturdy legs."""

    def sh(poly):
        return [(x + dx, y + dy) for x, y in poly]

    body = [
        (86, 250), (120, 218), (185, 206), (250, 214), (284, 240),
        (294, 280), (284, 322), (240, 346), (170, 350), (110, 342),
        (76, 310), (70, 278),
    ]
    chest = [(250, 226), (292, 246), (304, 288), (292, 326), (256, 342), (238, 290)]
    rump = [(70, 240), (116, 214), (142, 240), (136, 316), (104, 342), (66, 312), (58, 274)]
    neck = [
        (198, 254), (204, 204), (220, 160), (246, 126), (276, 108),
        (300, 112), (300, 142), (282, 172), (268, 212), (262, 266), (222, 286),
    ]
    head = [
        (250, 100), (276, 82), (304, 84), (330, 98), (358, 126),
        (372, 146), (368, 160), (346, 160), (316, 146), (282, 128), (258, 116),
    ]
    jaw = [(266, 116), (304, 126), (330, 146), (322, 164), (294, 164), (262, 142)]
    ear1 = [(258, 54), (276, 86), (248, 92)]
    ear2 = [(288, 56), (300, 88), (270, 90)]
    front_leg = [
        (244, 320), (286, 318), (280, 366), (274, 400), (278, 444),
        (292, 452), (292, 468), (250, 468), (254, 410), (246, 366),
    ]
    hind_leg = [
        (84, 316), (132, 322), (122, 368), (106, 392), (102, 436),
        (110, 452), (118, 466), (74, 466), (82, 408), (84, 366),
    ]
    return [sh(p) for p in [body, chest, rump, neck, head, jaw, ear1, ear2, front_leg, hind_leg]]


def _far_leg_polys():
    front = [
        (192, 330), (228, 330), (218, 376), (214, 404), (218, 442),
        (230, 458), (188, 458), (196, 404), (190, 372),
    ]
    hind = [
        (128, 326), (166, 330), (156, 372), (148, 396), (146, 434),
        (152, 458), (114, 458), (126, 402), (128, 368),
    ]
    return [front, hind]


def _mane_polys():
    # Scalloped crest flowing down the back of the neck onto the withers.
    return [
        [
            (222, 146), (238, 112), (254, 86), (272, 66), (290, 60),
            (296, 78), (280, 92), (290, 104), (268, 120), (274, 138),
            (248, 152), (252, 172), (230, 186), (232, 208), (212, 222),
            (212, 248), (192, 256), (188, 220), (198, 182),
        ]
    ]


def _tail_polys():
    return [
        [
            (78, 238), (54, 252), (36, 286), (30, 330), (38, 374),
            (56, 400), (72, 372), (60, 330), (64, 292), (80, 264), (94, 250),
        ]
    ]


def bake_horse(coat, deep, mane_rgb):
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))

    # Ground contact shadow first.
    all_mask = np.clip(
        poly_mask((W, H), _horse_body_polys()) + poly_mask((W, H), _far_leg_polys()), 0, 1
    )
    alpha_paste(canvas, to_image(soft_shadow(all_mask, blur=10, opacity=0.5, squash=0.16, dy=-46)), (0, 0))

    # Pedestal: a solid gold puck with a domed team-color top.
    ped_side = ellipse_mask((W, H), (84, GROUND + 6, 356, GROUND + 62))
    alpha_paste(
        canvas,
        to_image(shade(ped_side, GOLD_DEEP, z_scale=2.6, spec=0.35, rim=0.15)),
        (0, 0),
    )
    ped_top = ellipse_mask((W, H), (80, GROUND - 24, 360, GROUND + 40))
    alpha_paste(
        canvas,
        to_image(shade(ped_top, GOLD, shade_rgb=GOLD_DEEP, inflate=0.7, z_scale=2.6, spec=0.75, spec_power=34)),
        (0, 0),
    )
    ped_inner = ellipse_mask((W, H), (102, GROUND - 14, 338, GROUND + 26))
    alpha_paste(
        canvas,
        to_image(shade(ped_inner, tuple(int(c * 0.8) for c in coat), shade_rgb=deep, inflate=0.8, z_scale=1.8, spec=0.45)),
        (0, 0),
    )

    # Far legs: darker, behind the body.
    far = poly_mask((W, H), _far_leg_polys())
    far_rgb = tuple(int(c * 0.55) for c in coat)
    alpha_paste(canvas, to_image(shade(far, far_rgb, z_scale=5.0, spec=0.25, rim=0.12)), (0, 0))

    # Tail behind the body.
    tail = poly_mask((W, H), _tail_polys())
    alpha_paste(canvas, to_image(shade(tail, mane_rgb, z_scale=5.5, spec=0.4, rim=0.2)), (0, 0))

    # The body itself: glossy team-color figurine.
    body = poly_mask((W, H), _horse_body_polys())
    alpha_paste(
        canvas,
        to_image(shade(body, coat, shade_rgb=deep, inflate=0.5, z_scale=7.0, spec=0.6, spec_power=30, rim=0.4)),
        (0, 0),
    )

    # Mane on top of the neck.
    mane = poly_mask((W, H), _mane_polys())
    alpha_paste(canvas, to_image(shade(mane, mane_rgb, z_scale=6.0, spec=0.45, rim=0.25)), (0, 0))

    # Gold saddle pad + girth: the premium trim.
    saddle = ellipse_mask((W, H), (142, 214, 240, 284))
    alpha_paste(
        canvas,
        to_image(shade(saddle, GOLD, shade_rgb=GOLD_DEEP, z_scale=3.2, spec=0.8, spec_power=36)),
        (0, 0),
    )

    # Eye + nostril give the head its character.
    eye = ellipse_mask((W, H), (292, 100, 308, 116))
    alpha_paste(canvas, to_image(shade(eye, (26, 20, 18), z_scale=2.0, spec=0.9, spec_power=12)), (0, 0))
    nostril = ellipse_mask((W, H), (352, 140, 362, 150))
    alpha_paste(canvas, to_image(shade(nostril, tuple(int(c * 0.5) for c in coat), z_scale=1.6, spec=0.2)), (0, 0))

    return canvas


def main():
    out_dir = "assets/board/horses"
    os.makedirs(out_dir, exist_ok=True)
    sprites = {}
    for team, (coat, deep, mane_rgb) in TEAMS.items():
        im = bake_horse(coat, deep, mane_rgb)
        sprites[team] = im
        im.save(f"{out_dir}/horse_{team}.webp", "WEBP", quality=92, method=6)
        print(f"horse_{team}.webp")

    if "--preview" in sys.argv:
        grid = Image.new("RGBA", (W * 4, H), (24, 34, 48, 255))
        for i, im in enumerate(sprites.values()):
            grid.alpha_composite(im, (i * W, 0))
        os.makedirs("build/art_preview", exist_ok=True)
        grid.save("build/art_preview/horses.png")
        print("preview: build/art_preview/horses.png")


if __name__ == "__main__":
    main()
