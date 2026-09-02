"""Bake the IqraQuest launcher icon from the owner-supplied artwork to
every PNG size Android, iOS and the web target need, plus a review sheet.

The source (tool/art/source/app_icon_source.webp) is a painted emblem
chosen by the project owner: three horses racing across the coloured
tiles of the petits-chevaux board, an open book with a glowing question
mark, a crescent and star, painted inside a gold frame on black corners.
A launcher icon is masked by the platform (a squircle on iOS, a circle
or squircle on Android), and that mask *is* the frame: a second, painted
frame inside it wastes a tenth of the icon and gets clipped at every
corner, where the painted radius does not match the platform's. So the
painted frame is cropped away — the horses and the question mark come
out a fifth larger at every size — and the black corners are blended to
the ground before the crop as a safety net. Sizes at or below 120 px get
a light unsharp mask so the white horse and the "?" stay crisp on the
home screen. Nothing else in the artwork is altered.

Run:  python3 tool/art/bake_app_icon.py [--preview]
Writes ios/…/AppIcon.appiconset, android/…/mipmap-*/ic_launcher.png,
web/icons/*.png, web/favicon.png and build/screenshots/app_icon_*.png.
The iOS files are written without an alpha channel, as App Store
validation requires.
"""

from __future__ import annotations

import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SOURCE = os.path.join(ROOT, "tool", "art", "source", "app_icon_source.webp")
S = 1024  # master size

# The ground the corners are blended to: the deep green just inside the
# frame, so the blend reads as the frame sitting on the app's own colour.
GROUND = (8, 46, 34)
# The painted gold frame occupies the outer ~6% of the source; cropping
# 7.5% removes it entirely (and the black corners with it) so the
# platform mask becomes the only frame.
CROP = 0.075
# Below this size the icon gets a light unsharp mask after resampling.
SHARPEN_BELOW = 121


def _corner_mask(rgb: np.ndarray, threshold: int = 42) -> np.ndarray:
    """A [0,1] mask of the near-black region reachable from the four
    corners — the outside of the gold frame — found by flood fill, so the
    dark greens inside the frame are left untouched."""
    h, w, _ = rgb.shape
    dark = rgb.max(axis=2) < threshold
    seen = np.zeros((h, w), dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    for y, x in ((0, 0), (0, w - 1), (h - 1, 0), (h - 1, w - 1)):
        if dark[y, x]:
            seen[y, x] = True
            queue.append((y, x))
    while queue:
        y, x = queue.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < h and 0 <= nx < w and dark[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True
                queue.append((ny, nx))
    return seen.astype(np.float32)


def master() -> Image.Image:
    """The artwork prepared at master size: corners blended to the
    ground, edge cropped, resampled to 1024."""
    src = Image.open(SOURCE).convert("RGB")
    rgb = np.asarray(src, dtype=np.float32)
    mask = _corner_mask(rgb.astype(np.uint8))
    # Feather the blend by about a pixel so the frame's anti-aliased edge
    # does not pick up a hard seam.
    feather = Image.fromarray((mask * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))
    m = (np.asarray(feather, dtype=np.float32) / 255.0)[..., None]
    ground = np.asarray(GROUND, dtype=np.float32)[None, None, :]
    out = rgb * (1 - m) + ground * m
    img = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB")
    w, h = img.size
    c = int(min(w, h) * CROP)
    img = img.crop((c, c, w - c, h - c))
    return img.resize((S, S), Image.LANCZOS)


def maskable(full: Image.Image, inset: float = 0.10) -> Image.Image:
    """The web maskable variant: the artwork shrunk inside the ground so
    a circular mask keeps the whole frame."""
    out = Image.new("RGB", (S, S), GROUND)
    inner = int(S * (1 - 2 * inset))
    out.paste(full.resize((inner, inner), Image.LANCZOS), (int(S * inset), int(S * inset)))
    return out


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


def _resize(img, size):
    out = img.resize((size, size), Image.LANCZOS)
    if size < SHARPEN_BELOW:
        out = out.filter(ImageFilter.UnsharpMask(radius=1.2, percent=60, threshold=2))
    return out


def _save(img, rel, size, mode="RGBA"):
    path = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    _resize(img, size).convert(mode).save(path, optimize=True)


def review_sheet(full, mask_variant):
    """The icon at the sizes a home screen actually shows, plus the
    maskable variant, in build/screenshots/."""
    shots = os.path.join(ROOT, "build", "screenshots")
    os.makedirs(shots, exist_ok=True)
    full.save(os.path.join(shots, "app_icon_1024.png"))
    sheet = Image.new("RGB", (1024, 300), (18, 18, 22))
    x = 24
    for size in (180, 120, 87, 60, 40):
        thumb = _resize(full, size)
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * 0.22), fill=255)
        sheet.paste(thumb, (x, 150 - size // 2), mask)
        x += size + 40
    sheet.paste(mask_variant.resize((200, 200), Image.LANCZOS), (800, 50))
    sheet.save(os.path.join(shots, "app_icon_sheet.png"))


def main():
    full = master()
    mask_variant = maskable(full)
    for name, size in IOS:
        _save(full, os.path.join(IOS_DIR, name), size, mode="RGB")
    for density, size in ANDROID:
        _save(full, f"android/app/src/main/res/mipmap-{density}/ic_launcher.png", size)
    _save(full, "web/icons/Icon-192.png", 192)
    _save(full, "web/icons/Icon-512.png", 512)
    _save(mask_variant, "web/icons/Icon-maskable-192.png", 192)
    _save(mask_variant, "web/icons/Icon-maskable-512.png", 512)
    _save(full, "web/favicon.png", 32)
    review_sheet(full, mask_variant)
    print("icon baked:", len(IOS), "iOS +", len(ANDROID), "Android + 5 web; sheet in build/screenshots/")


if __name__ == "__main__":
    if "--preview" in sys.argv:
        full = master()
        review_sheet(full, maskable(full))
    else:
        main()
