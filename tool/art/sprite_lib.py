"""Shared pseudo-3D sprite shading for the IqraQuest asset baker.

The technique: rasterize a silhouette, inflate it with a distance
transform into a height field, derive normals, then light it like a
glossy figurine (lambert + blinn specular + rim + AO). It produces
pre-rendered game sprites with real volume — no Flutter primitives.
"""

from __future__ import annotations

import math

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage

SS = 4  # supersample factor for silhouette rasterization


def chaikin(points, iterations=3, closed=True):
    """Corner-cutting smoothing: hand-set polygons become organic curves."""
    pts = [tuple(p) for p in points]
    for _ in range(iterations):
        out = []
        n = len(pts)
        rng = range(n) if closed else range(n - 1)
        for i in rng:
            p, q = pts[i], pts[(i + 1) % n]
            out.append((0.75 * p[0] + 0.25 * q[0], 0.75 * p[1] + 0.25 * q[1]))
            out.append((0.25 * p[0] + 0.75 * q[0], 0.25 * p[1] + 0.75 * q[1]))
        if not closed:
            out = [pts[0]] + out + [pts[-1]]
        pts = out
    return pts


def poly_mask(size, polys, smooth=3):
    """Rasterize smoothed polygons into a float [0,1] mask (anti-aliased)."""
    w, h = size
    im = Image.new("L", (w * SS, h * SS), 0)
    d = ImageDraw.Draw(im)
    for poly in polys:
        pts = chaikin(poly, smooth) if smooth else [tuple(p) for p in poly]
        d.polygon([(x * SS, y * SS) for x, y in pts], fill=255)
    im = im.resize((w, h), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def ellipse_mask(size, box):
    w, h = size
    im = Image.new("L", (w * SS, h * SS), 0)
    d = ImageDraw.Draw(im)
    d.ellipse([box[0] * SS, box[1] * SS, box[2] * SS, box[3] * SS], fill=255)
    im = im.resize((w, h), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def rounded_rect_mask(size, box, radius):
    w, h = size
    im = Image.new("L", (w * SS, h * SS), 0)
    d = ImageDraw.Draw(im)
    d.rounded_rectangle(
        [box[0] * SS, box[1] * SS, box[2] * SS, box[3] * SS], radius=radius * SS, fill=255
    )
    im = im.resize((w, h), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def fbm(shape, octaves=4, seed=7, base=8):
    """Cheap fractal noise for material texture."""
    rng = np.random.default_rng(seed)
    h, w = shape
    out = np.zeros(shape, dtype=np.float32)
    amp, total = 1.0, 0.0
    for o in range(octaves):
        gh, gw = base * (2**o), base * (2**o)
        g = rng.random((gh, gw)).astype(np.float32)
        layer = np.asarray(
            Image.fromarray((g * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC),
            dtype=np.float32,
        ) / 255.0
        out += amp * layer
        total += amp
        amp *= 0.5
    return out / total


def _normals(height, z_scale):
    gy, gx = np.gradient(height)
    nx, ny = -gx * z_scale, -gy * z_scale
    nz = np.ones_like(height)
    norm = np.sqrt(nx * nx + ny * ny + nz * nz)
    return nx / norm, ny / norm, nz / norm


def shade(
    mask,
    base_rgb,
    *,
    inflate=0.55,
    z_scale=6.0,
    light=(-0.45, -0.75, 0.6),
    shade_rgb=None,
    spec=0.55,
    spec_power=26,
    rim=0.35,
    rim_rgb=(255, 232, 180),
    ao=0.35,
    texture=None,
    texture_amp=0.0,
):
    """Light a silhouette mask into a glossy pre-rendered sprite (RGBA)."""
    m = mask
    inside = m > 0.5
    dt = ndimage.distance_transform_edt(inside).astype(np.float32)
    if dt.max() > 0:
        h = (dt / dt.max()) ** inflate
    else:
        h = dt
    h = ndimage.gaussian_filter(h, 1.2)
    if texture is not None and texture_amp > 0:
        h = h + (texture - 0.5) * texture_amp

    nx, ny, nz = _normals(h, z_scale)
    lx, ly, lz = light
    ln = math.sqrt(lx * lx + ly * ly + lz * lz)
    lx, ly, lz = lx / ln, ly / ln, lz / ln

    diff = np.clip(nx * lx + ny * ly + nz * lz, 0, 1)
    # Blinn half-vector with the viewer straight on.
    hx, hy, hz = lx, ly, lz + 1.0
    hn = math.sqrt(hx * hx + hy * hy + hz * hz)
    hx, hy, hz = hx / hn, hy / hn, hz / hn
    sp = np.clip(nx * hx + ny * hy + nz * hz, 0, 1) ** spec_power

    # Rim: silhouette edges away from the light pick up warm bounce.
    edge = np.clip(1.0 - nz, 0, 1) ** 1.6
    rim_dir = np.clip(-(nx * lx + ny * ly), 0, 1)
    rim_l = edge * (0.35 + 0.65 * rim_dir)

    # Cheap AO: crevices = low height relative to local blur.
    ao_map = np.clip(ndimage.gaussian_filter(h, 6) - h, 0, 1)

    base = np.array(base_rgb, dtype=np.float32)
    if shade_rgb is None:
        dark = base * 0.32 + np.array([8, 4, 26], dtype=np.float32)
    else:
        dark = np.array(shade_rgb, dtype=np.float32)

    lit = dark[None, None, :] + (base - dark)[None, None, :] * (0.22 + 0.78 * diff)[..., None]
    lit += spec * 255 * sp[..., None] * np.array([1.0, 0.97, 0.9])[None, None, :]
    lit += rim * rim_l[..., None] * np.array(rim_rgb, dtype=np.float32)[None, None, :] * 0.55
    lit -= ao * ao_map[..., None] * 140
    if texture is not None and texture_amp > 0:
        lit *= (0.92 + 0.16 * texture)[..., None]

    rgba = np.zeros((*m.shape, 4), dtype=np.uint8)
    rgba[..., :3] = np.clip(lit, 0, 255).astype(np.uint8)
    rgba[..., 3] = np.clip(m * 255, 0, 255).astype(np.uint8)
    return rgba


def to_image(rgba):
    return Image.fromarray(rgba, "RGBA")


def soft_shadow(mask, blur=6, opacity=0.45, squash=0.32, dy=0.0):
    """Contact shadow: the silhouette squashed to the ground and blurred."""
    h, w = mask.shape
    im = Image.fromarray((mask * 255).astype(np.uint8))
    sh = max(1, int(h * squash))
    im = im.resize((w, sh), Image.LANCZOS)
    canvas = Image.new("L", (w, h), 0)
    canvas.paste(im, (0, int(h - sh + dy)))
    canvas = canvas.filter(ImageFilter.GaussianBlur(blur))
    arr = np.asarray(canvas, dtype=np.float32) / 255.0
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[..., 3] = (arr * opacity * 255).astype(np.uint8)
    return rgba


def alpha_paste(dst: Image.Image, src: Image.Image, xy):
    dst.alpha_composite(src, dest=(int(xy[0]), int(xy[1])))
