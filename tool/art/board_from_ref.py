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
W, H = 1170, 2340
SCALE = 1310 / 941.0  # slight overscan: the board dominates
CROP_TOP, CROP_BOT = 335, 1262  # board world inside the source
TOPPAD = 215  # sky extension above the board world

TEAM_ORDER = ["emerald", "saphir", "grenat", "safran"]


def sx(v):
    return v * SCALE - (941 * SCALE - W) / 2


def sy(v):
    return (v - CROP_TOP) * SCALE + TOPPAD


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
# Scene assembly.
# ---------------------------------------------------------------------------

# Patches: (dst_box, src_origin) — clean texture grafted over baked pieces.
PATCHES = [
    ((378, 548, 452, 618), (455, 548)),   # green knight lower (track tiles)
    ((378, 500, 452, 548), (560, 500)),   # green knight upper (sand)
    ((793, 722, 872, 818), (793, 826)),   # blue knight (tiles below)
    ((226, 915, 308, 1008), (226, 1012)), # gold knight (tiles below)
    ((438, 1012, 535, 1068), (438, 956)), # pink knight upper (lane chevrons)
    ((438, 1068, 535, 1118), (438, 1124)),# pink knight base + ring (lane below)
]


def feather_paste(dst: Image.Image, patch: Image.Image, xy, feather=7):
    mask = Image.new("L", patch.size, 255)
    md = ImageDraw.Draw(mask)
    for k in range(feather):
        md.rectangle([k, k, patch.width - 1 - k, patch.height - 1 - k],
                     outline=int(255 * (k + 1) / feather))
    mask = mask.filter(ImageFilter.GaussianBlur(2))
    dst.paste(patch, xy, mask)


def build_scene(src: Image.Image) -> Image.Image:
    board = src.copy()
    for (l, t, r, b), (ox, oy) in PATCHES:
        patch = src.crop((ox, oy, ox + (r - l), oy + (b - t)))
        feather_paste(board, patch, (l, t))

    full = board.crop((0, CROP_TOP, 941, CROP_BOT)).resize(
        (int(941 * SCALE), int((CROP_BOT - CROP_TOP) * SCALE)), Image.LANCZOS
    )
    ox = (full.width - W) // 2
    world = full.crop((ox, 0, ox + W, full.height))
    board_h = world.height

    canvas = Image.new("RGB", (W, H), (18, 40, 34))

    # Sky extension, matched to the reference's green-gold dusk.
    ys = np.arange(TOPPAD + 80, dtype=np.float32)
    top = np.array([16, 44, 40], dtype=np.float32)
    bot = np.array([132, 148, 104], dtype=np.float32)
    t = (ys / ys[-1])[:, None]
    rows = top[None, :] * (1 - t) + bot[None, :] * t
    sky = np.repeat(rows[:, None, :], W, axis=1).astype(np.uint8)
    canvas.paste(Image.fromarray(sky, "RGB"), (0, 0))
    d = ImageDraw.Draw(canvas, "RGBA")
    rng = np.random.default_rng(5)
    for _ in range(70):
        x, y = rng.uniform(0, W), rng.uniform(0, TOPPAD * 0.9)
        a = int(rng.uniform(50, 170) * (1 - y / TOPPAD))
        r = rng.uniform(0.8, 2.0)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(255, 246, 220, max(a, 0)))
    d.ellipse((W * 0.85 - 30, 70, W * 0.85 + 30, 130), fill=(250, 232, 170, 235))
    d.ellipse((W * 0.85 - 41, 61, W * 0.85 + 17, 121), fill=(20, 48, 42, 255))

    board_bottom = TOPPAD + board_h

    # Foreground apron: clean sand gradient sampled from the board's own
    # ground, noised, darkening toward the camera (the HUD sits on it).
    ah = H - board_bottom + 8
    wl = np.asarray(world.crop((380, board_h - 260, 780, board_h - 200)), dtype=np.float32)
    base = wl.reshape(-1, 3).mean(axis=0)
    t = np.linspace(0, 1, ah)[:, None]
    rows = base[None, :] * (0.93 - 0.38 * t)
    arr = np.repeat(rows[:, None, :], W, axis=1)
    gn = np.asarray(Image.effect_noise((W, ah), 22), dtype=np.float32)[..., None] / 255.0
    arr = arr * (0.94 + 0.12 * gn)
    # Soft dune lobes so the apron isn't a flat wall.
    lob = Image.new("L", (W, ah), 0)
    ld = ImageDraw.Draw(lob)
    rngl = np.random.default_rng(9)
    for _ in range(8):
        lx, ly = rngl.uniform(-80, W + 80), rngl.uniform(0, ah)
        lw = rngl.uniform(240, 520)
        ld.ellipse((lx - lw / 2, ly - lw * 0.14, lx + lw / 2, ly + lw * 0.14), fill=int(rngl.uniform(60, 120)))
    lob_a = np.asarray(lob.filter(ImageFilter.GaussianBlur(60)), dtype=np.float32)[..., None] / 255.0
    arr = arr * (1.0 - 0.12 * lob_a) + np.array([255, 226, 170])[None, None, :] * 0.05 * lob_a
    apron = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8))
    canvas.paste(apron, (0, board_bottom - 8))

    # The board world on top, its own top edge feathered into the sky.
    fade = Image.new("L", (W, board_h), 255)
    fd = ImageDraw.Draw(fade)
    for k in range(90):
        fd.line([(0, k), (W, k)], fill=int(255 * k / 90))
    for k in range(110):
        fd.line([(0, board_h - 1 - k), (W, board_h - 1 - k)], fill=int(255 * k / 110))
    canvas.paste(world, (0, TOPPAD), fade)

    # Foreground props from the extracted pack (occlusion + depth).
    pack = "assets/board/pack"
    def fg(name, cx, cy, scale, flip=False):
        im = Image.open(f"{pack}/{name}.webp").convert("RGBA")
        if flip:
            im = im.transpose(Image.FLIP_LEFT_RIGHT)
        im = im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS)
        canvas.paste(im, (int(cx - im.width / 2), int(cy - im.height)), im)

    def small_shadow(cx, cy, wdt):
        sh = Image.new("RGBA", (int(wdt), max(2, int(wdt * 0.22))), (0, 0, 0, 0))
        ImageDraw.Draw(sh).ellipse((0, 0, wdt - 1, wdt * 0.22 - 1), fill=(22, 14, 8, 90))
        sh = sh.filter(ImageFilter.GaussianBlur(5))
        canvas.paste(sh, (int(cx - wdt / 2), int(cy - wdt * 0.11)), sh)

    for name, cx, cy, s_, fl in [
        ("bush_round", 205, board_bottom + 190, 1.25, False),
        ("bush_flower", 590, board_bottom + 250, 1.3, False),
        ("bush_round", 965, board_bottom + 200, 1.2, True),
    ]:
        small_shadow(cx, cy, 150 * s_)
        fg(name, cx, cy, s_, flip=fl)
    fg("fg_fern", 48, H - 560, 2.6)
    fg("fg_grass", 1118, H - 580, 2.5)

    # Gentle grade: cooler shadows, gold highlights, vignette.
    arr = np.asarray(canvas, dtype=np.float32) / 255.0
    luma = arr.mean(axis=2, keepdims=True)
    warm = np.array([1.05, 1.0, 0.92])[None, None, :]
    cool = np.array([0.94, 1.0, 1.06])[None, None, :]
    arr = arr * (cool + (warm - cool) * luma)
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    vr = np.sqrt(((xx - W / 2) / (W * 0.78)) ** 2 + ((yy - H / 2) / (H * 0.70)) ** 2)
    arr *= (1 - 0.26 * np.clip(vr - 0.55, 0, 1))[..., None]
    arr = np.clip(arr * 1.03 - 0.008, 0, 1) ** 0.985
    return Image.fromarray((arr * 255).astype(np.uint8), "RGB")


# ---------------------------------------------------------------------------
# Anchors: measured on the reference's own octagonal track.
# ---------------------------------------------------------------------------

OCTAGON = [
    (310, 585), (630, 585),   # top edge
    (835, 730), (835, 1000),  # right edge
    (650, 1165), (290, 1165), # bottom edge
    (105, 1000), (105, 730),  # left edge
]

LANES = {
    "emerald": [(348, 668), (383, 703), (418, 738), (452, 772)],
    "saphir": [(636, 662), (601, 697), (566, 732), (531, 766)],
    "grenat": [(470, 1082), (470, 1032), (470, 982), (470, 936)],
    "safran": [(288, 920), (322, 897), (356, 875), (390, 852)],
}

CAMPS = {
    "emerald": [(58, 636), (112, 652), (50, 684), (104, 700)],
    "saphir": [(742, 622), (780, 646), (736, 668), (774, 692)],
    "grenat": [(672, 1222), (720, 1236), (624, 1236), (672, 1250)],
    "safran": [(338, 1210), (386, 1224), (330, 1236), (378, 1250)],
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
    # Cell 0 sits on the green entry medallion (on the TL diagonal),
    # then clockwise — matching the tiles pieces actually ride.
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
        return f"SceneAnchor({sx(p[0]) / W:.4f}, {sy(p[1]) / H:.4f}, {scale:.3f})"

    def depth(p):
        return 0.80 + 0.45 * (sy(p[1]) / H)

    track = ",\n  ".join(fmt(p, depth(p)) for p in track_anchors())
    lanes = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p, depth(p)) for p in LANES[team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    camps = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p, depth(p) * 0.92) for p in CAMPS[team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    src = f"""// GENERATED by tool/art/board_from_ref.py — do not edit by hand.
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
        f.write(src)
    print("wrote lib/widgets/board/scene_anchors.g.dart")


def main():
    src = Image.open(SRC).convert("RGB")

    # Extract the knight pieces first (before they are erased).
    out_dir = "assets/board/horses"
    os.makedirs(out_dir, exist_ok=True)
    pieces = {}
    for team, box in PIECES.items():
        pieces[team] = key_piece(src.crop(box))
        if team == "safran":
            pieces[team] = pieces[team].transpose(Image.FLIP_LEFT_RIGHT)
        pieces[team].save(f"{out_dir}/horse_{team}.webp", "WEBP", quality=95, method=6)
    # Pink piece: hue-shift of the blue knight (same sculpt, team recolour).
    grenat = hue_rotate(pieces["saphir"], 118)
    grenat.save(f"{out_dir}/horse_grenat.webp", "WEBP", quality=95, method=6)
    print("pieces:", {t: pieces.get(t, grenat).size for t in TEAM_ORDER})

    scene = build_scene(src)
    os.makedirs("assets/board", exist_ok=True)
    scene.save("assets/board/scene_oasis.webp", "WEBP", quality=90, method=6)
    emit_dart()
    print("assets/board/scene_oasis.webp", scene.size)
    if "--preview" in sys.argv:
        os.makedirs("build/art_preview", exist_ok=True)
        scene.save("build/art_preview/scene_ref.png")
        print("preview: build/art_preview/scene_ref.png")


if __name__ == "__main__":
    main()
