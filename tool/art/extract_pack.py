"""Extract production sprites from the owner-supplied IqraQuest asset
pack sheets (uploaded ZIP), with edge-flood background removal.

The sheets place bright painterly assets on a near-uniform dark ground:
for each crop we flood from the border across pixels close to the local
background colour — that connected region becomes transparent, interior
darks stay opaque — then feather the edge.

Run:  python3 tool/art/extract_pack.py <pack_dir> [--sheet]
Outputs assets/board/pack/*.webp and a contact sheet preview.
"""

from __future__ import annotations

import os
import sys

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

MASTER = "reference_master_asset_pack.png"
CATALOG = "reference_catalog_asset_pack.png"

# Sheet leftovers to force-erase per sprite, in crop-local pixels.
ERASE = {
    "horse_emerald": [(0, 0, 175, 14), (0, 0, 46, 40), (0, 206, 175, 228), (150, 50, 175, 200)],
    "horse_saphir": [(0, 0, 152, 12), (0, 0, 58, 72), (85, 0, 152, 34), (0, 200, 152, 221)],
    "horse_safran": [(0, 0, 166, 12), (102, 0, 166, 52), (158, 52, 166, 140), (0, 200, 166, 212)],
    "horse_grenat": [(0, 0, 144, 10), (0, 0, 40, 50), (104, 0, 144, 40), (0, 196, 144, 210)],
    "palm_tall_3": [(46, 148, 66, 200)],
}

# name: (sheet, box, bg_tolerance)
CROPS = {
    # --- Horses: the big caparisoned walk poses (hero pieces) ---
    "horse_emerald": (MASTER, (325, 5, 500, 233), 60),
    "horse_saphir": (MASTER, (498, 12, 650, 233), 60),
    "horse_safran": (MASTER, (608, 22, 774, 234), 60),
    "horse_grenat": (MASTER, (756, 28, 900, 238), 30),
    # --- Camps (per team, with their painted stable dressing) ---
    "camp_emerald": (CATALOG, (448, 36, 574, 193), 32),
    "camp_saphir": (CATALOG, (575, 34, 704, 193), 32),
    "camp_safran": (CATALOG, (704, 32, 834, 193), 48),
    "camp_grenat": (CATALOG, (835, 32, 962, 193), 48),
    # --- Central landmark ---
    "landmark_center": (MASTER, (556, 262, 896, 508), 55),
    # --- Tiles (catalog set: crisper, more variants) ---
    "tile_straight": (CATALOG, (988, 38, 1058, 100), 50),
    "tile_corner_left": (CATALOG, (1066, 33, 1142, 100), 50),
    "tile_corner_right": (CATALOG, (1146, 33, 1222, 100), 50),
    "tile_start": (CATALOG, (1226, 33, 1302, 100), 50),
    "tile_question": (CATALOG, (988, 118, 1058, 184), 50),
    "tile_treasure": (CATALOG, (1066, 116, 1142, 184), 50),
    "tile_bonus": (CATALOG, (1146, 116, 1222, 184), 50),
    "tile_checkpoint": (CATALOG, (1226, 116, 1302, 184), 50),
    "tile_final_emerald": (CATALOG, (988, 203, 1058, 274), 50),
    "tile_final_saphir": (CATALOG, (1066, 203, 1142, 274), 50),
    "tile_final_safran": (CATALOG, (1146, 199, 1222, 274), 50),
    "tile_final_grenat": (CATALOG, (1226, 199, 1302, 274), 50),
    "tile_goal_center": (CATALOG, (1148, 288, 1290, 360), 50),
    # --- Chests ---
    "chest_closed": (MASTER, (1398, 266, 1478, 346), 55),
    "chest_open": (CATALOG, (418, 638, 532, 742), 28),
    # --- Props (master) ---
    "palm_tall_1": (MASTER, (8, 505, 86, 706), 50),
    "palm_tall_2": (MASTER, (88, 508, 166, 706), 50),
    "palm_tall_3": (MASTER, (168, 512, 234, 706), 50),
    "rock_large": (MASTER, (300, 512, 432, 602), 50),
    "rock_pair": (MASTER, (432, 518, 502, 592), 50),
    "amphora": (MASTER, (352, 638, 398, 702), 50),
    "campfire": (MASTER, (416, 646, 472, 702), 50),
    "lantern_stand": (CATALOG, (644, 408, 702, 522), 40),
    # --- Water ---
    "pool_upper": (MASTER, (504, 516, 646, 610), 50),
    "bridge_stone": (MASTER, (728, 504, 856, 600), 50),
    "pond_round": (MASTER, (504, 610, 642, 702), 50),
    "waterfall_twin": (MASTER, (614, 584, 768, 662), 50),
    # --- Banners (catalog large flags) ---
    "banner_emerald": (CATALOG, (524, 842, 598, 960), 38),
    "banner_saphir": (CATALOG, (598, 842, 670, 960), 50),
    "banner_safran": (CATALOG, (670, 842, 742, 960), 50),
    "banner_grenat": (CATALOG, (738, 842, 802, 960), 50),
    # --- Vegetation / foreground ---
    "bush_flower": (CATALOG, (10, 714, 106, 786), 22),
    "bush_round": (CATALOG, (106, 714, 202, 786), 22),
    "fg_fern": (CATALOG, (794, 850, 898, 950), 22),
    "fg_grass": (CATALOG, (906, 852, 998, 946), 22),
    "fg_rock": (CATALOG, (1002, 844, 1106, 952), 40),
    "fg_bush": (CATALOG, (1106, 848, 1206, 952), 22),
    # --- FX (for the Flutter live layer) ---
    "fx_selection_glow": (CATALOG, (984, 522, 1066, 602), 45),
    "fx_move_path": (CATALOG, (1066, 528, 1142, 602), 45),
    "fx_arrival": (CATALOG, (1216, 430, 1296, 508), 45),
    "fx_reward_burst": (CATALOG, (1140, 428, 1212, 506), 45),
    "fx_dust": (CATALOG, (984, 428, 1056, 506), 45),
    # --- Hero backdrop band + foreground of the master sheet ---
    "backdrop_band": (MASTER, (512, 736, 980, 898), 0),
}


def key_out(im: Image.Image, tol: float) -> Image.Image:
    """Remove the connected dark background (flood from crop borders)."""
    arr = np.asarray(im.convert("RGB"), dtype=np.float32)
    h, w = arr.shape[:2]
    # Several background seeds: the sheet ground varies (vignettes, panel
    # edges), so flood against the median AND each corner's local colour.
    border = np.concatenate([arr[0, :], arr[-1, :], arr[:, 0], arr[:, -1]])
    bg = np.median(border, axis=0)
    dist = np.sqrt(((arr - bg[None, None, :]) ** 2).sum(axis=2))
    near_bg = dist < tol
    # Connected components of near-bg; keep only those touching border.
    lab, n = ndimage.label(near_bg)
    border_labels = set(np.unique(np.concatenate([lab[0, :], lab[-1, :], lab[:, 0], lab[:, -1]])))
    border_labels.discard(0)
    bg_mask = np.isin(lab, list(border_labels))
    alpha = np.where(bg_mask, 0, 255).astype(np.uint8)
    # Feather: slight erode then blur for a soft 1-2px edge.
    alpha_im = Image.fromarray(alpha)
    alpha_im = alpha_im.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.0))
    out = im.convert("RGBA")
    out.putalpha(alpha_im)
    return out


def trim(im: Image.Image, pad=2) -> Image.Image:
    bbox = im.getchannel("A").getbbox()
    if bbox is None:
        return im
    l, t, r, b = bbox
    return im.crop((max(0, l - pad), max(0, t - pad), min(im.width, r + pad), min(im.height, b + pad)))


def main():
    pack_dir = sys.argv[1]
    art = os.path.join(pack_dir, "01_REFERENCE_ART")
    sheets = {
        MASTER: Image.open(os.path.join(art, MASTER)).convert("RGB"),
        CATALOG: Image.open(os.path.join(art, CATALOG)).convert("RGB"),
    }
    out_dir = "assets/board/pack"
    os.makedirs(out_dir, exist_ok=True)
    results = {}
    for name, (sheet, box, tol) in CROPS.items():
        crop = sheets[sheet].crop(box)
        if name.startswith("fx_"):
            rgb = np.asarray(crop.convert("RGB"), dtype=np.float32)
            luma = rgb.max(axis=2)
            alpha = np.clip((luma - 26) * 1.9, 0, 255).astype(np.uint8)
            sprite = crop.convert("RGBA")
            sprite.putalpha(Image.fromarray(alpha))
            sprite = trim(sprite)
        elif tol > 0:
            sprite = key_out(crop, tol)
            if name in ERASE:
                a = np.asarray(sprite.getchannel("A")).copy()
                for (l, t, r, bo) in ERASE[name]:
                    a[t:bo, l:r] = 0
                sprite.putalpha(Image.fromarray(a))
            # Universal crumb filter: drop stray blobs < 3% of the main
            # body so no sheet fragment ever floats into the scene.
            a = np.asarray(sprite.getchannel("A"))
            lab, n = ndimage.label(a > 40)
            if n > 1:
                sizes = ndimage.sum(np.ones_like(lab), lab, index=range(1, n + 1))
                main_sz = sizes.max()
                keep = np.isin(lab, [j + 1 for j, sz in enumerate(sizes) if sz > 0.03 * main_sz])
                sprite.putalpha(Image.fromarray(np.where(keep, a, 0).astype(np.uint8)))
            if name.startswith("horse_"):
                # Neighbours on the sheet overlap each crop: keep only the
                # sprite's main connected body, drop stray fragments.
                a = np.asarray(sprite.getchannel("A"))
                lab, n = ndimage.label(a > 40)
                if n > 1:
                    sizes = ndimage.sum(np.ones_like(lab), lab, index=range(1, n + 1))
                    main = int(np.argmax(sizes)) + 1
                    keep = lab == main
                    a2 = np.where(keep, a, 0).astype(np.uint8)
                    sprite.putalpha(Image.fromarray(a2))
            sprite = trim(sprite)
        else:
            sprite = crop.convert("RGBA")
        sprite.save(f"{out_dir}/{name}.webp", "WEBP", quality=95, method=6)
        results[name] = sprite

    # The sheet occludes the blue horse's hindquarters behind its
    # neighbour, so the saphir piece is derived from the complete white
    # emerald horse with its textile recolored green -> blue (the pack's
    # own rule: same horse, only the tack changes per team).
    em = results["horse_emerald"].convert("RGBA")
    arr = np.asarray(em).astype(np.float32)
    import colorsys
    r, g, b = arr[..., 0] / 255, arr[..., 1] / 255, arr[..., 2] / 255
    mx, mn = np.max(arr[..., :3] / 255, axis=2), np.min(arr[..., :3] / 255, axis=2)
    delta = mx - mn + 1e-6
    hue = np.zeros_like(mx)
    m_r = mx == r
    m_g = (mx == g) & ~m_r
    m_b = ~(m_r | m_g)
    hue[m_r] = (60 * ((g - b) / delta) % 360)[m_r]
    hue[m_g] = (60 * ((b - r) / delta) + 120)[m_g]
    hue[m_b] = (60 * ((r - g) / delta) + 240)[m_b]
    sat = delta / (mx + 1e-6)
    greens = (hue > 60) & (hue < 175) & (sat > 0.22)
    hsv = np.stack([hue, sat, mx], axis=-1)
    hsv[..., 0][greens] = (hsv[..., 0][greens] + 100) % 360
    hh = hsv[..., 0] / 60.0
    i = np.floor(hh).astype(int) % 6
    f = hh - np.floor(hh)
    v = hsv[..., 2]
    s = hsv[..., 1]
    p = v * (1 - s)
    q = v * (1 - s * f)
    t = v * (1 - s * (1 - f))
    rr = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [v, q, p, p, t, v])
    gg = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [t, v, v, q, p, p])
    bb = np.select([i == 0, i == 1, i == 2, i == 3, i == 4, i == 5], [p, p, t, v, v, q])
    out = np.stack([rr, gg, bb], axis=-1)
    arr[..., :3] = np.where(greens[..., None], out * 255, arr[..., :3])
    saphir = Image.fromarray(arr.astype(np.uint8), "RGBA")
    saphir.save(f"{out_dir}/horse_saphir.webp", "WEBP", quality=95, method=6)
    results["horse_saphir"] = saphir

    if "--sheet" in sys.argv:
        cols = 8
        cell = 170
        rows = (len(results) + cols - 1) // cols
        sheet_im = Image.new("RGBA", (cols * cell, rows * cell), (40, 44, 60, 255))
        from PIL import ImageDraw

        d = ImageDraw.Draw(sheet_im)
        for i, (name, im) in enumerate(results.items()):
            x, y = (i % cols) * cell, (i // cols) * cell
            th = im.copy()
            th.thumbnail((cell - 12, cell - 26))
            sheet_im.alpha_composite(th, (x + (cell - th.width) // 2, y + (cell - 22 - th.height) // 2))
            d.text((x + 4, y + cell - 16), name[:24], fill=(255, 220, 160))
        os.makedirs("build/art_preview", exist_ok=True)
        sheet_im.save("build/art_preview/pack_contact_sheet.png")
        print("contact sheet: build/art_preview/pack_contact_sheet.png")
    print(f"extracted {len(results)} sprites to {out_dir}")


if __name__ == "__main__":
    main()
