"""Compose the playable oasis board from the production asset pack.

Track tiles, camps, the central landmark, water, vegetation and
foreground all come from the owner-supplied pack (extracted by
extract_pack.py); the backdrop sky/desert and depth compositing
(y-sort, contact shadows, golden-hour grade) are ours. Emits the scene
image and the anchor table used by the Flutter live layer.

Run:  python3 tool/art/bake_scene_pack.py [--preview]
"""

from __future__ import annotations

import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(__file__))
from sprite_lib import chaikin, fbm, soft_shadow  # noqa: E402

W, H = 1170, 2340
CX, CY = 585, 1258
RX, RY = 438, 560
SQUASH = 0.72
TRACK_N = 24
HORIZON = 360
PACK = "assets/board/pack"

TEAM_ORDER = ["emerald", "saphir", "grenat", "safran"]


def depth_of(ys):
    return 0.66 + 0.62 * (ys / H)


def persp(x, y):
    ys = CY + (y - CY) * SQUASH
    return (CX + (x - CX) * (0.94 + 0.10 * (ys / H)), ys, depth_of(ys))


def _superellipse(theta, n=3.2):
    c, s = math.cos(theta), math.sin(theta)
    return (
        math.copysign(abs(c) ** (2.0 / n), c) * RX,
        math.copysign(abs(s) ** (2.0 / n), s) * RY,
    )


def _loop_dense(m=1600):
    return [
        (CX + p[0], CY + p[1])
        for p in (_superellipse(math.pi * 1.25 - 2 * math.pi * k / m) for k in range(m))
    ]


def track_positions():
    dense = _loop_dense()
    lens = [0.0]
    for i in range(1, len(dense) + 1):
        a, b = dense[i - 1], dense[i % len(dense)]
        lens.append(lens[-1] + math.hypot(b[0] - a[0], b[1] - a[1]))
    total = lens[-1]
    out = []
    arr = np.array(lens[:-1])
    for i in range(TRACK_N):
        k = int(np.searchsorted(arr, total * i / TRACK_N)) % len(dense)
        x, y = dense[k]
        nxt, prv = dense[(k + 8) % len(dense)], dense[(k - 8) % len(dense)]
        tang = math.degrees(math.atan2(nxt[1] - prv[1], nxt[0] - prv[0]))
        out.append(persp(x, y) + (tang,))
    return out


_sprites: dict[str, Image.Image] = {}


def spr(name):
    if name not in _sprites:
        _sprites[name] = Image.open(f"{PACK}/{name}.webp").convert("RGBA")
    return _sprites[name]


# ---------------------------------------------------------------------------
# Backdrop: procedural dusk sky blended into the pack's painted valley.
# ---------------------------------------------------------------------------


def paint_backdrop():
    ys = np.arange(H, dtype=np.float32)

    def vgrad(stops, t):
        xs = np.array([s[0] for s in stops], dtype=np.float32)
        cols = np.array([s[1] for s in stops], dtype=np.float32)
        return np.stack([np.interp(t, xs, cols[:, c]) for c in range(3)], axis=-1)

    sky_rows = vgrad(
        [(0.0, (30, 26, 62)), (0.5, (96, 52, 86)), (0.8, (205, 100, 74)), (1.0, (250, 172, 96))],
        np.clip(ys / HORIZON, 0, 1),
    )
    ground_rows = vgrad(
        [(0.0, (212, 150, 92)), (0.5, (188, 126, 74)), (1.0, (126, 76, 44))],
        np.clip((ys - HORIZON) / (H - HORIZON), 0, 1),
    )
    below = (ys > HORIZON).astype(np.float32)[:, None]
    rows = sky_rows * (1 - below) + ground_rows * below
    arr = np.repeat(rows[:, None, :], W, axis=1)
    im = Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGB").convert("RGBA")
    d = ImageDraw.Draw(im, "RGBA")

    # Stars + crescent.
    rng = np.random.default_rng(3)
    for _ in range(60):
        x, y = rng.uniform(0, W), rng.uniform(0, HORIZON * 0.5)
        a = int(rng.uniform(40, 150) * (1 - y / (HORIZON * 0.55)))
        r = rng.uniform(0.8, 1.8)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(255, 244, 220, max(a, 0)))
    d.ellipse((W * 0.82 - 30, 86, W * 0.82 + 30, 146), fill=(250, 226, 150, 235))
    d.ellipse((W * 0.82 - 40, 78, W * 0.82 + 18, 138), fill=(44, 36, 74, 255))

    # The pack's painted valley panorama closes the horizon.
    band = spr("backdrop_band").convert("RGBA")
    bw = W + 40
    bh = int(band.height * bw / band.width)
    band = band.resize((bw, bh), Image.LANCZOS).filter(ImageFilter.GaussianBlur(1.0))
    # Feather its top edge into the sky.
    fade = Image.new("L", (bw, bh), 255)
    fd = ImageDraw.Draw(fade)
    for k in range(70):
        fd.line([(0, k), (bw, k)], fill=int(255 * k / 70))
    band.putalpha(fade)
    im.alpha_composite(band, (-20, HORIZON - int(bh * 0.42)))
    band_bottom = HORIZON - int(bh * 0.42) + bh

    # Blend band bottom into our sand with a soft gradient strip.
    sh = 150
    strip = Image.new("RGBA", (W, sh), (0, 0, 0, 0))
    sarr = np.zeros((sh, W, 4), dtype=np.uint8)
    nmask = fbm((sh, W), octaves=3, seed=77, base=6)
    for k in range(sh):
        c = ground_rows[min(H - 1, band_bottom + k)]
        base_a = k / sh
        row_a = np.clip(base_a + (nmask[k] - 0.5) * 0.55, 0, 1)
        sarr[k, :, 0], sarr[k, :, 1], sarr[k, :, 2] = int(c[0]), int(c[1]), int(c[2])
        sarr[k, :, 3] = (row_a * 255).astype(np.uint8)
    strip = Image.fromarray(sarr).filter(ImageFilter.GaussianBlur(2))
    im.alpha_composite(strip, (0, band_bottom - sh))

    # Sand texture: mottling + dune contour lines.
    tex = fbm((H, W), octaves=5, seed=21, base=6)
    arr2 = np.asarray(im, dtype=np.float32)
    gmask = (np.arange(H)[:, None] > band_bottom - 40).astype(np.float32)
    arr2[..., :3] *= (1 - 0.10 * (tex - 0.5) * 2 * gmask)[..., None]
    mot = Image.new("L", (W, H), 0)
    md = ImageDraw.Draw(mot)
    rngm = np.random.default_rng(51)
    for _ in range(24):
        mx, my = rngm.uniform(-100, W + 100), rngm.uniform(band_bottom, H + 100)
        mw = rngm.uniform(180, 520)
        md.ellipse((mx - mw / 2, my - mw * 0.2, mx + mw / 2, my + mw * 0.2), fill=int(rngm.uniform(70, 150)))
    mot_a = np.asarray(mot.filter(ImageFilter.GaussianBlur(80)), dtype=np.float32) / 255
    arr2[..., :3] *= (1.0 - 0.14 * mot_a * gmask)[..., None]
    im = Image.fromarray(np.clip(arr2, 0, 255).astype(np.uint8), "RGBA")
    d = ImageDraw.Draw(im, "RGBA")
    return im


# ---------------------------------------------------------------------------
# Compose.
# ---------------------------------------------------------------------------


def compose():
    scene = paint_backdrop()
    draws = []

    def add(name_or_im, cx, cy, *, sort_y=None, scale=1.0, rot=0.0, flip=False, shadow=0.32):
        im = spr(name_or_im) if isinstance(name_or_im, str) else name_or_im
        if flip:
            im = im.transpose(Image.FLIP_LEFT_RIGHT)
        if rot:
            im = im.rotate(-rot, resample=Image.BICUBIC, expand=True)
        if scale != 1.0:
            im = im.resize((max(1, int(im.width * scale)), max(1, int(im.height * scale))), Image.LANCZOS)
        draws.append((sort_y if sort_y is not None else cy, im, cx, cy, shadow))

    cells = track_positions()
    cxp, cyp, _ = persp(CX, CY)

    # --- Ground integration layer: packed-earth roadbed, compacted
    # contact zones, worn side-trails — everything sits IN the world.
    ground = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(ground)

    def stamp_path(points, width_fn, step=1):
        for (px, py) in points[::step]:
            r = width_fn(py)
            gd.ellipse((px - r, py - r * 0.55, px + r, py + r * 0.55), fill=210)

    dense_pts = [persp(x, y)[:2] for (x, y) in _loop_dense(420)]
    stamp_path(dense_pts, lambda y: 108 * depth_of(y))
    camp_xy = {"emerald": (168, 590), "saphir": (1002, 590), "grenat": (990, 1980), "safran": (180, 1980)}
    for t_i, team in enumerate(TEAM_ORDER):
        exit_i = (t_i * 6 - 1) % TRACK_N
        bx, by = cells[exit_i][0], cells[exit_i][1]
        lane_pts = [(bx + (cxp - bx) * (0.18 + 0.5 * k / 30), by + (cyp - by) * (0.18 + 0.5 * k / 30)) for k in range(31)]
        stamp_path(lane_pts, lambda y: 78 * depth_of(y))
        # Worn trail from each camp to its entry tile.
        ex, ey = cells[t_i * 6][0], cells[t_i * 6][1]
        cxx, cyy = camp_xy[team]
        trail = [(cxx + (ex - cxx) * k / 24, cyy + 140 + (ey - (cyy + 140)) * k / 24) for k in range(25)]
        stamp_path(trail, lambda y: 34 * depth_of(y))
    # Compacted ground under camps and the landmark.
    for (cxx, cyy) in camp_xy.values():
        d_ = depth_of(cyy)
        gd.ellipse((cxx - 250 * d_, cyy - 60, cxx + 250 * d_, cyy + 190 * d_), fill=190)
    gd.ellipse((cxp - 330, cyp - 120, cxp + 330, cyp + 210), fill=190)
    ground = ground.filter(ImageFilter.GaussianBlur(9))
    g_a = np.asarray(ground, dtype=np.float32) / 255.0
    sc = np.asarray(scene, dtype=np.float32)
    packed = np.array([166, 116, 70], dtype=np.float32)
    sc[..., :3] = sc[..., :3] * (1 - 0.72 * g_a[..., None]) + packed[None, None, :] * (0.72 * g_a[..., None])
    # Subtle rim: light top edge / dark bottom edge of the roadbed.
    gy = np.gradient(g_a, axis=0)
    sc[..., :3] = np.clip(sc[..., :3] + (np.clip(-gy, 0, 1) * 90 - np.clip(gy, 0, 1) * 70)[..., None] * np.array([1.0, 0.85, 0.6])[None, None, :], 0, 255)
    scene = Image.fromarray(sc.astype(np.uint8), "RGBA")

    # --- Track tiles pasted directly (ground layer) ---
    anchors_track = []
    effect_tile = {0: None, 2: "tile_question", 4: "tile_bonus"}
    order = sorted(range(TRACK_N), key=lambda i: cells[i][1])
    for i in order:
        (x, y, depth, tang) = cells[i]
        off = i % 6
        if off == 0:
            name = "tile_start"
        else:
            name = effect_tile.get(off) or ("tile_straight" if i % 2 else "tile_treasure" if off == 3 and i == 9 else "tile_straight")
        # A couple of treasure tiles for flavour on plain squares.
        if i in (9, 21):
            name = "tile_treasure"
        im = spr(name)
        s = (2.8 if off == 0 else 2.55) * depth
        im2 = im.resize((int(im.width * s), int(im.height * s)), Image.LANCZOS)
        m = np.asarray(im2.split()[-1], dtype=np.float32) / 255.0
        shd = soft_shadow(m, blur=8, opacity=0.44, squash=0.9, dy=10)
        scene.alpha_composite(Image.fromarray(shd), (int(x - im2.width / 2) + 6, int(y - im2.height / 2) + 10))
        scene.alpha_composite(im2, (int(x - im2.width / 2), int(y - im2.height / 2)))
        anchors_track.append((i, x, y - 10 * depth, depth))

    anchors_track = [p[1:] for p in sorted(anchors_track)]

    # --- Final lanes ---
    anchors_lane = {t: [] for t in TEAM_ORDER}
    for t_i, team in enumerate(TEAM_ORDER):
        exit_i = (t_i * 6 - 1) % TRACK_N
        bx, by = cells[exit_i][0], cells[exit_i][1]
        steps = list(range(1, 5))
        steps.sort(key=lambda st: by + (cyp - by) * (0.26 + 0.38 * (st - 1) / 3))
        placed = {}
        for step in steps:
            t = 0.30 + 0.34 * (step - 1) / 3
            x, y = bx + (cxp - bx) * t, by + (cyp - by) * t
            depth = depth_of(y)
            im = spr(f"tile_final_{team}")
            s = 1.65 * depth
            im = im.resize((int(im.width * s), int(im.height * s)), Image.LANCZOS)
            m = np.asarray(im.split()[-1], dtype=np.float32) / 255.0
            shd = soft_shadow(m, blur=7, opacity=0.42, squash=0.9, dy=9)
            scene.alpha_composite(Image.fromarray(shd), (int(x - im.width / 2) + 5, int(y - im.height / 2) + 8))
            scene.alpha_composite(im, (int(x - im.width / 2), int(y - im.height / 2)))
            placed[step] = (x, y - 8 * depth, depth)
        anchors_lane[team] = [placed[s_] for s_ in range(1, 5)]

    # --- Central landmark ---
    add("landmark_center", cxp, cyp + 155, sort_y=cyp - 60, scale=1.52, shadow=0.45)
    anchor_center = (cxp, cyp + 40, 1.0)

    # --- Camps + banner + slots ---
    camp_pos = {
        "emerald": (168, 590),
        "saphir": (1002, 590),
        "grenat": (990, 1980),
        "safran": (180, 1980),
    }
    anchors_camp = {t: [] for t in TEAM_ORDER}
    ring_im = spr("fx_selection_glow")
    for team, (cx, cy) in camp_pos.items():
        depth = depth_of(cy)
        flip = cx > W / 2  # camps face inward
        add(f"camp_{team}", cx, cy + 165, sort_y=cy - 160, scale=3.3 * depth, flip=flip, shadow=0.5)
        for k in range(4):
            sx = cx + (-46 + 62 * (k % 2)) * depth * (1 if cx < W / 2 else -1)
            sy = cy + (112 + 52 * (k // 2)) * depth
            sd = depth_of(sy)
            add(ring_im, sx, sy + 12, sort_y=sy + 60, scale=0.62 * sd, shadow=0.0)
            add(ring_im, sx, sy + 12, sort_y=sy + 60, scale=0.62 * sd, shadow=0.0)
            anchors_camp[team].append((sx, sy + 2, sd))

    # --- Water: falls + pond at the top, pool inside the loop ---
    add("pool_upper", 300, 1120, sort_y=1015, scale=1.35, shadow=0.3)

    # --- Props ---
    prng = np.random.default_rng(7)
    palms = ["palm_tall_1", "palm_tall_2", "palm_tall_3"]
    spots = []

    def clear(x, y, d=120):
        for (px, py) in spots:
            if math.hypot(x - px, y - py) < d:
                return False
        for (px, py, _pd) in anchors_track:
            if math.hypot(x - px, y - py) < 158:
                return False
        for lane in anchors_lane.values():
            for (px, py, _pd) in lane:
                if math.hypot(x - px, y - py) < 100:
                    return False
        if math.hypot(x - cxp, y - cyp) < 390:
            return False
        for (px, py) in camp_pos.values():
            if math.hypot(x - px, y - py - 100) < 300:
                return False
        return True

    for _ in range(120):
        x = prng.uniform(40, W - 40)
        y = prng.uniform(700, H - 260)
        if not clear(x, y):
            continue
        spots.append((x, y))
        d = depth_of(y)
        pick = prng.random()
        if pick < 0.16:
            add("palm_tall_1", x, y, scale=prng.uniform(1.4, 1.9) * d, flip=bool(prng.integers(0, 2)))
        elif pick < 0.38:
            add("rock_large", x, y, scale=prng.uniform(0.62, 0.9) * d, flip=bool(prng.integers(0, 2)))
        else:
            add("bush_flower" if prng.random() < 0.5 else "bush_round", x, y, scale=prng.uniform(0.85, 1.25) * d)
    # Flavour: chest + campfire near the trail.
    x, y, d, _t = cells[9]
    add("chest_closed", x + 150 * d, y + 30, scale=1.0 * d)
    x, y, d, _t = cells[20]
    add("campfire", x - 150 * d, y + 20, scale=1.2 * d, shadow=0.2)

    # Vegetation hugging the structure bases (no floating buildings).
    for (bx, by, s_) in [(60, 760, 0.9), (300, 745, 0.75), (880, 755, 0.8), (1105, 740, 0.85),
                          (95, 2120, 1.15), (330, 2105, 0.95), (860, 2110, 1.0), (1090, 2120, 1.1),
                          (cxp - 265, cyp + 165, 0.9), (cxp + 255, cyp + 150, 0.85)]:
        add("bush_flower" if (bx + by) % 2 else "bush_round", bx, by, scale=s_, sort_y=by + 6, shadow=0.25)
    add("rock_large", 1015, 785, scale=0.6, shadow=0.3)
    add("rock_large", 150, 2155, scale=0.75, flip=True, shadow=0.3)

    # Palms leaning over the track and camps (occlusion sells the depth).
    add("palm_tall_1", 62, 1590, scale=2.3, sort_y=1680)
    add("palm_tall_1", 1108, 1620, scale=2.2, sort_y=1710, flip=True)

    # --- Foreground framing ---
    add("fg_fern", 95, H + 15, sort_y=H + 200, scale=3.1, shadow=0.0)
    add("fg_rock", 585, H + 30, sort_y=H + 190, scale=2.8, shadow=0.0)
    add("fg_grass", 1070, H + 15, sort_y=H + 200, scale=3.1, shadow=0.0)

    # --- Paint the y-sorted props ---
    draws.sort(key=lambda t: t[0])
    for _sy, im, cx, cy, shadow in draws:
        left, top = int(cx - im.width / 2), int(cy - im.height)
        if shadow > 0:
            m = np.asarray(im.split()[-1], dtype=np.float32) / 255.0
            if m.max() > 0:
                shd = soft_shadow(m, blur=9, opacity=shadow * 1.25, squash=0.20, dy=0)
                scene.alpha_composite(Image.fromarray(shd), (left, int(cy - im.height * 0.06)))
        scene.alpha_composite(im, (left, top))

    # --- Grade ---
    arr = np.asarray(scene.convert("RGB"), dtype=np.float32) / 255.0
    luma = arr.mean(axis=2, keepdims=True)
    warm = np.array([1.07, 0.99, 0.89])[None, None, :]
    cool = np.array([0.90, 0.985, 1.13])[None, None, :]
    arr = arr * (cool + (warm - cool) * luma)
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    vr = np.sqrt(((xx - W / 2) / (W * 0.75)) ** 2 + ((yy - H / 2) / (H * 0.68)) ** 2)
    arr *= (1 - 0.30 * np.clip(vr - 0.55, 0, 1))[..., None]
    bright = np.clip(arr - 0.78, 0, 1)
    bloom = np.asarray(
        Image.fromarray((bright * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(13)),
        dtype=np.float32,
    ) / 255.0
    arr = np.clip(arr + bloom * 0.45, 0, 1)
    arr = np.clip(arr * 1.05 - 0.015, 0, 1) ** 0.97
    scene = Image.fromarray((arr * 255).astype(np.uint8), "RGB")
    return scene, {
        "track": anchors_track,
        "lane": anchors_lane,
        "camp": anchors_camp,
        "center": anchor_center,
    }


def _slot_ring(d=110):
    im = Image.new("RGBA", (d, d), (0, 0, 0, 0))
    dr = ImageDraw.Draw(im)
    dr.ellipse((6, d * 0.34, d - 6, d * 0.86), outline=(238, 196, 108, 235), width=5)
    dr.ellipse((14, d * 0.40, d - 14, d * 0.80), outline=(238, 196, 108, 90), width=3)
    return im.filter(ImageFilter.GaussianBlur(0.6))


def emit_dart(anchors):
    def fmt(p):
        return f"SceneAnchor({p[0] / W:.4f}, {p[1] / H:.4f}, {p[2]:.3f})"

    track = ",\n  ".join(fmt(p) for p in anchors["track"])
    lanes = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p) for p in anchors['lane'][team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    camps = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p) for p in anchors['camp'][team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    src = f"""// GENERATED by tool/art/bake_scene_pack.py — do not edit by hand.
// Anchors are normalized to the composed scene image
// (assets/board/scene_oasis.webp); scale is the perspective factor for
// sprites standing at that anchor.

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
    with open("lib/widgets/board/scene_anchors.g.dart", "w") as f:
        f.write(src)
    print("wrote lib/widgets/board/scene_anchors.g.dart")


def main():
    scene, anchors = compose()
    os.makedirs("assets/board", exist_ok=True)
    scene.save("assets/board/scene_oasis.webp", "WEBP", quality=88, method=6)
    emit_dart(anchors)
    print("assets/board/scene_oasis.webp", scene.size)
    if "--preview" in sys.argv:
        os.makedirs("build/art_preview", exist_ok=True)
        scene.save("build/art_preview/scene_pack.png")
        print("preview: build/art_preview/scene_pack.png")


if __name__ == "__main__":
    main()
