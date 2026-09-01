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
W, H = 941, 1672  # the reference frame
# Final canvas: taller than any phone aspect (941/2080 = 0.452), so
# BoxFit.cover NEVER crops the sides — the full painted width always
# shows; only the sky/sand buffers give and take vertically.
OUT_H = 2080
TOP_EXT = 300

TEAM_ORDER = ["emerald", "saphir", "grenat", "safran"]

PIECE_SIZE = (86, 108)  # set from the generated sprites in main()




# ---------------------------------------------------------------------------
# Live pieces: the knight figurines standing on the reference track.
# ---------------------------------------------------------------------------

# One clean sculpt, four liveries: the emerald knight is the only piece
# on the reference whose colour is unique against the sand (green), so
# it mattes cleanly by hue; the other teams are hue-derived from it and
# every piece gets a freshly drawn team-colour disc base (the painted
# bases are inseparable from the gold tiles beneath them).
KNIGHT_BOX = (374, 506, 454, 598)  # emerald body only, painted disc excluded


def _hsv(arr):
    r, g, b = arr[..., 0], arr[..., 1], arr[..., 2]
    mx = arr.max(axis=2)
    mn = arr.min(axis=2)
    delta = mx - mn + 1e-6
    hue = np.zeros_like(mx)
    m_r = mx == r
    m_g = (mx == g) & ~m_r
    m_b = ~(m_r | m_g)
    hue[m_r] = (60 * ((g - b) / delta) % 360)[m_r]
    hue[m_g] = (60 * ((b - r) / delta) + 120)[m_g]
    hue[m_b] = (60 * ((r - g) / delta) + 240)[m_b]
    sat = delta / (mx + 1e-6)
    return hue, sat, mx


def extract_knight(src_im: Image.Image) -> Image.Image:
    crop = src_im.crop(KNIGHT_BOX).convert("RGB")
    arr = np.asarray(crop, dtype=np.float32) / 255
    hue, sat, _ = _hsv(arr)
    body = (hue > 62) & (hue < 185) & (sat > 0.14)
    body = ndimage.binary_closing(body, iterations=3)
    body = ndimage.binary_fill_holes(body)
    lab, n = ndimage.label(body)
    if n > 1:
        sizes = ndimage.sum(np.ones_like(lab), lab, index=range(1, n + 1))
        body = lab == int(np.argmax(sizes)) + 1
    body = ndimage.binary_dilation(body, iterations=1)
    a = Image.fromarray((body * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))
    out = crop.convert("RGBA")
    out.putalpha(a)
    bbox = out.getchannel("A").getbbox()
    return out.crop(bbox) if bbox else out


def retint(body: Image.Image, color) -> Image.Image:
    """Re-dress the sculpt in a team colour from its own lighting: the
    glossy shading survives, the colour becomes clean and uniform."""
    arr = np.asarray(body).astype(np.float32)
    rgb = arr[..., :3] / 255
    lum = 0.30 * rgb[..., 0] + 0.55 * rgb[..., 1] + 0.15 * rgb[..., 2]
    lo, hi = np.percentile(lum[arr[..., 3] > 40], [3, 99]) if (arr[..., 3] > 40).any() else (0, 1)
    shade = np.clip((lum - lo) / (hi - lo + 1e-6), 0, 1) ** 0.72
    c = np.array(color, dtype=np.float32) / 255
    dark = c * 0.32
    light = c + (1 - c) * 0.50
    out = arr.copy()
    tinted = dark[None, None, :] + (light - dark)[None, None, :] * shade[..., None]
    # push colour: move away from the grey axis a touch
    grey = tinted.mean(axis=2, keepdims=True)
    tinted = np.clip(grey + (tinted - grey) * 1.35, 0, 1)
    out[..., :3] = tinted * 255
    return Image.fromarray(out.astype(np.uint8), "RGBA")


LIVERY = {
    # body colour, disc top face, disc side
    "emerald": ((52, 168, 96), (46, 158, 95), (24, 96, 55)),
    "saphir": ((64, 110, 220), (70, 105, 205), (34, 56, 128)),
    "grenat": ((216, 64, 140), (198, 72, 132), (120, 34, 76)),
    "safran": ((240, 180, 40), (232, 172, 48), (150, 100, 22)),
}


def with_base(body: Image.Image, top_rgb, rim_rgb) -> Image.Image:
    """Stand the sculpt on a clean team-colour disc with a soft shadow."""
    s = 4  # supersample
    bw = body.width
    disc_w, disc_h = int(bw * 1.12), max(12, int(bw * 0.40))
    pad = 6
    cw, ch = disc_w + 2 * pad, body.height + disc_h // 2 + pad + 6
    canvas = Image.new("RGBA", (cw * s, ch * s), (0, 0, 0, 0))
    d = ImageDraw.Draw(canvas)
    cx, base_y = cw * s // 2, (ch - pad - disc_h) * s
    box = [cx - disc_w * s // 2, base_y, cx + disc_w * s // 2, base_y + disc_h * s]
    # contact shadow
    sh = [box[0] - 3 * s, box[1] + disc_h * s // 3, box[2] + 3 * s, box[3] + 3 * s]
    d.ellipse(sh, fill=(30, 16, 8, 90))
    # disc side (darker), then top face (team colour), then gold rim line
    d.ellipse(box, fill=rim_rgb + (255,))
    top_box = [box[0] + 1 * s, box[1], box[2] - 1 * s, box[3] - int(disc_h * s * 0.35)]
    d.ellipse(top_box, fill=top_rgb + (255,))
    d.ellipse(box, outline=(214, 168, 66, 235), width=2 * s)
    canvas = canvas.resize((cw, ch), Image.LANCZOS)
    canvas = canvas.filter(ImageFilter.GaussianBlur(0.4))
    # feet planted on the disc's top face
    canvas.alpha_composite(body, ((cw - bw) // 2, ch - pad - disc_h + int(disc_h * 0.58) - body.height))
    return canvas


def _hsv_to_rgb(hue, sat, val):
    hh = hue / 60.0
    i = np.floor(hh).astype(int) % 6
    f = hh - np.floor(hh)
    p = val * (1 - sat)
    q = val * (1 - sat * f)
    t = val * (1 - sat * (1 - f))
    rr = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [val, q, p, p, t, val])
    gg = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [t, val, val, q, p, p])
    bb = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [p, p, t, val, val, q])
    return rr, gg, bb


def magenta_to_gold(im: Image.Image) -> Image.Image:
    """Recolour a crop's magenta lane pixels to saffron gold."""
    arr = np.asarray(im.convert("RGB")).astype(np.float32) / 255
    hue, sat, val = _hsv(arr)
    lane = (hue > 275) & (hue < 355) & (sat > 0.22)
    hue = np.where(lane, 46.0, hue)
    sat = np.where(lane, np.clip(sat * 0.95, 0, 1), sat)
    val = np.where(lane, np.clip(val * 1.10, 0, 1), val)
    rr, gg, bb = _hsv_to_rgb(hue, sat, val)
    out = np.stack([rr, gg, bb], axis=2) * 255
    return Image.fromarray(out.astype(np.uint8), "RGB")


# ---------------------------------------------------------------------------
# Scene assembly: the reference frame, cleaned in place.
# ---------------------------------------------------------------------------

# Grafts over the baked loose pieces (clean texture from neighbours).
PATCHES = [
    ((378, 548, 452, 618), (455, 548)),
    ((378, 500, 452, 548), (560, 500)),
    ((793, 722, 872, 818), (793, 826)),
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


def rebuild_yellow_lane(board: Image.Image, src_im: Image.Image) -> None:
    """The baked yellow knight stands beside the yellow lane at
    (233..300 x 918..1010): bury it (and its little pedestal) in clean
    sand; the strip itself (292..397 x 882..990) is left untouched."""
    sand = src_im.crop((376, 958, 440, 1024))
    for x, y in ((234, 914), (240, 975), (280, 970)):
        tile = sand if (x + y) % 4 else sand.transpose(Image.FLIP_LEFT_RIGHT)
        feather_paste(board, tile, (x, y), feather=12)


def build_scene(src_im: Image.Image) -> Image.Image:
    board = src_im.copy()
    for (l, t, r, b), (ox, oy) in PATCHES:
        feather_paste(board, src_im.crop((ox, oy, ox + (r - l), oy + (b - t))), (l, t))
    rebuild_yellow_lane(board, src_im)

    arr = np.asarray(board, dtype=np.float32)

    # --- Sky: rebuild each row from its own clean side columns, so the
    # gradient, haze and colour are EXACTLY the reference's. ---
    side = arr[:SKY_BOTTOM, 2:40, :]  # left columns only: the source moon lives on the right
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

    # ---- Tall canvas: sky buffer above, sand buffer below ----
    final = Image.new("RGB", (W, OUT_H))
    top_c = np.asarray(board.crop((0, 0, W, 2)), dtype=np.float32).mean(axis=(0, 1))
    t = np.linspace(0, 1, TOP_EXT)[:, None]
    ext_rows = (top_c[None, :] * (0.55 + 0.45 * t))
    final.paste(Image.fromarray(
        np.repeat(ext_rows[:, None, :], W, axis=1).astype(np.uint8)), (0, 0))
    final.paste(board, (0, TOP_EXT))
    bot_c = np.asarray(board.crop((0, H - 4, W, H)), dtype=np.float32).mean(axis=(0, 1))
    bh = OUT_H - TOP_EXT - H
    t = np.linspace(0, 1, max(bh, 1))[:, None]
    bot_rows = bot_c[None, :] * (1.0 - 0.22 * t)
    bot = np.repeat(bot_rows[:, None, :], W, axis=1)
    gn = np.asarray(Image.effect_noise((W, max(bh, 1)), 16), dtype=np.float32)[..., None] / 255.0
    bot = bot * (0.96 + 0.08 * gn)
    final.paste(Image.fromarray(np.clip(bot, 0, 255).astype(np.uint8)), (0, TOP_EXT + H))

    d = ImageDraw.Draw(final, "RGBA")
    rng = np.random.default_rng(5)
    for _ in range(110):
        x, y = rng.uniform(0, W), rng.uniform(0, TOP_EXT + 240)
        a = int(rng.uniform(60, 185) * (1 - y / (TOP_EXT + 260)))
        r = rng.uniform(0.7, 1.8)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(255, 246, 220, max(a, 0)))
    d.ellipse((W * 0.84 - 26, 128, W * 0.84 + 26, 180), fill=(250, 234, 175, 235))
    px = np.asarray(final.crop((int(W * 0.84) - 70, 110, int(W * 0.84) - 50, 130)), dtype=np.float32).mean(axis=(0, 1))
    d.ellipse((W * 0.84 - 36, 120, W * 0.84 + 14, 172), fill=(int(px[0]), int(px[1]), int(px[2]), 255))
    return final


# ---------------------------------------------------------------------------
# Anchors, in source coordinates.
# ---------------------------------------------------------------------------

# The 24 track cells, hand-measured on the CENTRES of the painted tiles
# (the illustration has ~30 tiles for 24 logical cells, so a few painted
# tiles are stepped over; every anchor sits ON a tile face). Clockwise
# from the green entry medallion; entries at 0 / 6 / 12 / 18 sit on the
# tile adjacent to each camp, and cells 23 / 5 / 11 / 17 are the tiles
# the painted final-lane strips branch from.
TRACK = [
    (332, 580),   # 0  green entry medallion (horse icon)
    (406, 562),   # 1  wide silver plaque
    (485, 561),   # 2  wide silver plaque (knowledge)
    (558, 566),
    (625, 578),   # 4  blue star medallion (wisdom)
    (678, 622),   # 5  blue lane branches here
    (738, 652),   # 6  saphir entry (below blue camp)
    (808, 678),   # 7  gold horse medallion
    (838, 795),
    (840, 902),
    (815, 947),   # 10 red star medallion (wisdom)
    (800, 1010),  # 11 magenta lane branches here
    (770, 1060),  # 12 grenat entry (beside pink camp)
    (622, 1118),  # 13 red horse medallion
    (505, 1132),
    (340, 1120),  # 15 gold star medallion
    (210, 1065),
    (165, 1025),  # 17 yellow lane branches here
    (140, 940),   # 18 safran entry (white star medallion)
    (120, 880),
    (122, 825),
    (152, 728),
    (217, 683),   # 22 green star medallion (wisdom)
    (277, 645),   # 23 green lane branches here
]

# Final lanes: four anchors each, ring -> centre, measured on the
# painted chevron strips (grenat uses the magenta diagonal by the pink
# camp corner; the short vertical strip at bottom-centre is decor).
LANES = {
    "emerald": [(312, 664), (344, 681), (376, 697), (406, 712)],
    "saphir": [(676, 660), (644, 677), (612, 694), (582, 711)],
    "grenat": [(692, 974), (656, 954), (620, 933), (586, 914)],
    "safran": [(306, 962), (332, 940), (358, 918), (384, 896)],
}

# One gate per stable: where a horse ready to ride out stands, on open
# sand between its camp and its entry cell. All four slots share it
# (only the selectable exit piece is ever drawn there).
GATES = {
    "emerald": (352, 630),
    "saphir": (722, 708),
    "grenat": (690, 1020),
    "safran": (255, 1035),
}

CENTER = (470, 895)


def track_anchors():
    return TRACK


def emit_dart():
    def fmt(p, scale):
        return f"SceneAnchor({p[0] / W:.4f}, {(p[1] + TOP_EXT) / OUT_H:.4f}, {scale:.3f})"

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

/// width / height of the generated knight sprites (all four share one canvas).
const double scenePieceAspect = {PIECE_SIZE[0] / PIECE_SIZE[1]:.4f};
"""
    with open("lib/widgets/board/scene_anchors.g.dart", "w") as f:
        f.write(out)
    print("wrote lib/widgets/board/scene_anchors.g.dart")


def main():
    src_im = Image.open(SRC).convert("RGB")
    out_dir = "assets/board/horses"
    os.makedirs(out_dir, exist_ok=True)
    body = extract_knight(src_im)
    size = None
    for team, (body_c, top, rim) in LIVERY.items():
        sprite = with_base(retint(body, body_c), top, rim)
        sprite.save(f"{out_dir}/horse_{team}.webp", "WEBP", quality=95, method=6)
        size = sprite.size
    global PIECE_SIZE
    PIECE_SIZE = size
    print("pieces:", size)

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
