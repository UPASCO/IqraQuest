"""Build the playable scene from the owner's 'oval board' reference
(82600b60): surgically remove its baked UI and loose pieces, extract
those pieces as the live horse sprites, extend sky and foreground, and
emit engine anchors measured on ITS tiles.

Run:  python3 tool/art/board_from_ref.py [--preview]
"""

from __future__ import annotations

import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage

SRC = "/root/.claude/uploads/f3e87935-e32a-50ba-a184-1ba4d8227229/82600b60-image.png"
W, H = 941, 1672  # the scene keeps the reference frame — the phone
# screen has the same portrait shape, so BoxFit.cover shows the board
# exactly as the mockup composes it.

TEAM_ORDER = ["emerald", "saphir", "grenat", "safran"]




# ---------------------------------------------------------------------------
# Live pieces: the knight figurines standing on the reference track.
# ---------------------------------------------------------------------------

PIECES = {
    "emerald": (378, 512, 452, 618),
    "saphir": (793, 722, 872, 818),
    "safran": (226, 915, 308, 1008),
}


def key_piece(crop: Image.Image, tol=46) -> Image.Image:
    arr = np.asarray(crop.convert("RGB"), dtype=np.float32)
    h, w = arr.shape[:2]
    border = np.concatenate([arr[0, :], arr[-1, :], arr[:, 0], arr[:, -1]])
    bg = np.median(border, axis=0)
    dist = np.sqrt(((arr - bg[None, None, :]) ** 2).sum(axis=2))
    near = dist < tol
    lab, n = ndimage.label(near)
    border_labels = set(np.unique(np.concatenate([lab[0, :], lab[-1, :], lab[:, 0], lab[:, -1]])))
    border_labels.discard(0)
    alpha = np.where(np.isin(lab, list(border_labels)), 0, 255).astype(np.uint8)
    # Keep the biggest blob only.
    lab2, n2 = ndimage.label(alpha > 0)
    if n2 > 1:
        sizes = ndimage.sum(np.ones_like(lab2), lab2, index=range(1, n2 + 1))
        alpha = np.where(lab2 == int(np.argmax(sizes)) + 1, alpha, 0).astype(np.uint8)
    a = Image.fromarray(alpha).filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
    out = crop.convert("RGBA")
    out.putalpha(a)
    bbox = out.getchannel("A").getbbox()
    return out.crop(bbox) if bbox else out


def hue_rotate(im: Image.Image, deg: float) -> Image.Image:
    hsv = im.convert("RGBA")
    arr = np.asarray(hsv).astype(np.float32)
    r, g, b = arr[..., 0] / 255, arr[..., 1] / 255, arr[..., 2] / 255
    mx = np.max(arr[..., :3] / 255, axis=2)
    mn = np.min(arr[..., :3] / 255, axis=2)
    delta = mx - mn + 1e-6
    hue = np.zeros_like(mx)
    m_r = mx == r
    m_g = (mx == g) & ~m_r
    m_b = ~(m_r | m_g)
    hue[m_r] = (60 * ((g - b) / delta) % 360)[m_r]
    hue[m_g] = (60 * ((b - r) / delta) + 120)[m_g]
    hue[m_b] = (60 * ((r - g) / delta) + 240)[m_b]
    sat = delta / (mx + 1e-6)
    saturated = (sat > 0.25) & (hue > 175) & (hue < 292)
    hue = np.where(saturated, (hue + deg) % 360, hue)
    hh = hue / 60.0
    i = np.floor(hh).astype(int) % 6
    f = hh - np.floor(hh)
    p = mx * (1 - sat)
    q = mx * (1 - sat * f)
    t = mx * (1 - sat * (1 - f))
    rr = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [mx, q, p, p, t, mx])
    gg = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [t, mx, mx, q, p, p])
    bb = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [p, p, t, mx, mx, q])
    out = arr.copy()
    out[..., 0] = np.where(saturated, rr * 255, arr[..., 0])
    out[..., 1] = np.where(saturated, gg * 255, arr[..., 1])
    out[..., 2] = np.where(saturated, bb * 255, arr[..., 2])
    return Image.fromarray(out.astype(np.uint8), "RGBA")


# ---------------------------------------------------------------------------
# Scene assembly: the reference frame, cleaned in place.
# ---------------------------------------------------------------------------

# Grafts over the baked loose pieces (clean texture from neighbours).
PATCHES = [
    ((378, 548, 452, 618), (455, 548)),
    ((378, 500, 452, 548), (560, 500)),
    ((793, 722, 872, 818), (793, 826)),
    ((226, 915, 308, 1008), (278, 883)),
    ((438, 1012, 535, 1068), (438, 956)),
    ((438, 1068, 535, 1132), (438, 1138)),
]

SKY_BOTTOM = 338      # everything above is repainted sky (kills title/avatars/chip)
PANEL_TOP = 1272      # everything below is repainted foreground sand (kills gait bar/nav)


def feather_paste(dst, patch, xy, feather=7):
    mask = Image.new("L", patch.size, 255)
    md = ImageDraw.Draw(mask)
    for k in range(feather):
        md.rectangle([k, k, patch.width - 1 - k, patch.height - 1 - k],
                     outline=int(255 * (k + 1) / feather))
    mask = mask.filter(ImageFilter.GaussianBlur(2))
    dst.paste(patch, xy, mask)


def build_scene(src_im: Image.Image) -> Image.Image:
    board = src_im.copy()
    for (l, t, r, b), (ox, oy) in PATCHES:
        feather_paste(board, src_im.crop((ox, oy, ox + (r - l), oy + (b - t))), (l, t))

    arr = np.asarray(board, dtype=np.float32)

    # --- Sky: rebuild each row from its own clean side columns, so the
    # gradient, haze and colour are EXACTLY the reference's. ---
    side = np.concatenate([arr[:SKY_BOTTOM, 2:34, :], arr[:SKY_BOTTOM, 907:939, :]], axis=1)
    rows = np.median(side, axis=1)
    sky = np.repeat(rows[:, None, :], W, axis=1)
    arr[:SKY_BOTTOM] = sky
    board = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    # A real dune band, mirrored across the width, hides the seam and
    # restores the painted horizon texture over the repaint.
    band = src_like = board.crop((652, 286, 940, 372))
    strip = Image.new("RGBA", (W, 86), (0, 0, 0, 0))
    x = 0
    flip = False
    while x < W:
        b = band.transpose(Image.FLIP_LEFT_RIGHT) if flip else band
        strip.paste(b.convert("RGBA"), (x, 0))
        x += band.width - 24
        flip = not flip
    fmask = Image.new("L", (W, 86), 255)
    fmd = ImageDraw.Draw(fmask)
    for k in range(30):
        fmd.line([(0, k), (W, k)], fill=int(255 * k / 30))
    strip.putalpha(Image.composite(strip.getchannel("A"), Image.new("L", (W, 86), 0), fmask))
    board.paste(strip, (0, 286), strip)
    hz_top, hz_bot = 226, 368
    zone = board.crop((0, hz_top, W, hz_bot))
    blurred = zone.filter(ImageFilter.GaussianBlur(7))
    hmask = Image.new("L", (W, hz_bot - hz_top), 0)
    hd = ImageDraw.Draw(hmask)
    n_ = hz_bot - hz_top
    for k in range(n_):
        f = math.sin(math.pi * k / n_)
        hd.line([(0, k), (W, k)], fill=int(215 * f))
    board.paste(blurred, (0, hz_top), hmask)
    d = ImageDraw.Draw(board, "RGBA")
    rng = np.random.default_rng(5)
    for _ in range(60):
        x, y = rng.uniform(0, W), rng.uniform(0, 250)
        a = int(rng.uniform(60, 180) * (1 - y / 260))
        r = rng.uniform(0.7, 1.7)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(255, 246, 220, max(a, 0)))
    d.ellipse((W * 0.85 - 24, 56, W * 0.85 + 24, 104), fill=(250, 234, 175, 235))
    px = np.asarray(board.crop((int(W * 0.85) - 60, 40, int(W * 0.85) - 40, 60)))[:, :, :3].mean(axis=(0, 1))
    d.ellipse((W * 0.85 - 33, 49, W * 0.85 + 13, 97), fill=(int(px[0]), int(px[1]), int(px[2]), 255))

    # --- Foreground: continue each column of sand downward, darkening
    # toward the camera; the HUD sits on top of this band. ---
    arr = np.asarray(board, dtype=np.float32)
    base = arr[1225:1266, 340:600].reshape(-1, 3).mean(axis=0)
    ah = H - PANEL_TOP
    t = np.linspace(0, 1, ah)[:, None, None]
    fore = np.repeat(np.repeat(base[None, None, :], ah, axis=0), W, axis=1) * (1.0 - 0.34 * t)
    gn = np.asarray(Image.effect_noise((W, ah), 20), dtype=np.float32)[..., None] / 255.0
    fore = fore * (0.95 + 0.10 * gn)
    blend = np.linspace(0, 1, 34)[:, None, None]
    fore[:34] = arr[PANEL_TOP:PANEL_TOP + 34] * (1 - blend) + fore[:34] * blend
    arr[PANEL_TOP:] = fore
    board = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))

    return board


# ---------------------------------------------------------------------------
# Anchors, in source coordinates.
# ---------------------------------------------------------------------------

# Side columns pulled to the tiles' inner edge so pieces on them stay
# fully inside the phone frame after BoxFit.cover.
OCTAGON = [
    (310, 585), (630, 585),
    (808, 730), (808, 1000),
    (650, 1160), (290, 1160),
    (132, 1000), (132, 730),
]

LANES = {
    "emerald": [(348, 668), (383, 703), (418, 738), (452, 772)],
    "saphir": [(636, 662), (601, 697), (566, 732), (531, 766)],
    "grenat": [(470, 1082), (470, 1032), (470, 982), (470, 936)],
    "safran": [(288, 920), (322, 897), (356, 875), (390, 852)],
}

# One gate per stable: where a horse ready to ride out stands, on the
# camp platform's front edge. All four slots share it (only the
# selectable exit piece is ever drawn there).
GATES = {
    "emerald": (196, 648),
    "saphir": (746, 648),
    "safran": (232, 1168),
    "grenat": (712, 1168),
}

CENTER = (470, 872)


def track_anchors():
    pts = OCTAGON + [OCTAGON[0]]
    segs = []
    total = 0.0
    for a, b in zip(pts, pts[1:]):
        ln = math.hypot(b[0] - a[0], b[1] - a[1])
        segs.append((a, b, ln))
        total += ln
    out = []
    for i in range(24):
        target = (total * i / 24 - 93) % total
        acc = 0.0
        for a, b, ln in segs:
            if acc + ln >= target:
                f = (target - acc) / ln
                out.append((a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f))
                break
            acc += ln
    return out


def emit_dart():
    def fmt(p, scale):
        return f"SceneAnchor({p[0] / W:.4f}, {p[1] / H:.4f}, {scale:.3f})"

    def depth(p):
        return 0.82 + 0.42 * (p[1] / H)

    track = ",\n  ".join(fmt(p, depth(p)) for p in track_anchors())
    lanes = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p, depth(p)) for p in LANES[team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    camps = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt((GATES[team][0] + 6 * k, GATES[team][1] + 4 * k), depth(GATES[team])) for k in range(4))}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    out = f"""// GENERATED by tool/art/board_from_ref.py — do not edit by hand.
// Anchors are normalized to the scene image built from the owner's
// board reference; scale is the perspective factor at that anchor.

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

const SceneAnchor sceneCenterAnchor = {fmt(CENTER, 1.0)};
"""
    with open("lib/widgets/board/scene_anchors.g.dart", "w") as f:
        f.write(out)
    print("wrote lib/widgets/board/scene_anchors.g.dart")


def main():
    src_im = Image.open(SRC).convert("RGB")
    out_dir = "assets/board/horses"
    os.makedirs(out_dir, exist_ok=True)
    pieces = {}
    for team, box in PIECES.items():
        pieces[team] = key_piece(src_im.crop(box))
        if team == "safran":
            pieces[team] = pieces[team].transpose(Image.FLIP_LEFT_RIGHT)
        pieces[team].save(f"{out_dir}/horse_{team}.webp", "WEBP", quality=95, method=6)
    grenat = hue_rotate(pieces["saphir"], 118)
    grenat.save(f"{out_dir}/horse_grenat.webp", "WEBP", quality=95, method=6)
    print("pieces:", {t: (pieces.get(t) or grenat).size for t in TEAM_ORDER})

    scene = build_scene(src_im)
    os.makedirs("assets/board", exist_ok=True)
    scene.save("assets/board/scene_oasis.webp", "WEBP", quality=92, method=6)
    emit_dart()
    print("assets/board/scene_oasis.webp", scene.size)
    if "--preview" in sys.argv:
        os.makedirs("build/art_preview", exist_ok=True)
        scene.save("build/art_preview/scene_ref.png")
        print("preview: build/art_preview/scene_ref.png")


if __name__ == "__main__":
    main()
