"""Build and render the oasis-route board as a true 3D scene.

Real geometry, procedural PBR materials, one warm sun with global
illumination — rendered by Cycles into the full-screen board image, with
every gameplay anchor projected through the camera into generated Dart.

Run:  python3 tool/art3d/scene_oasis.py [--fast]
"""

from __future__ import annotations

import math
import os
import random
import sys

import bpy
import bmesh
from mathutils import Vector

sys.path.insert(0, os.path.dirname(__file__))
from common import (  # noqa: E402
    GOLD,
    IVORY,
    SAND,
    STONE,
    TEAM_COLORS,
    WATER,
    mesh_object,
    new_material,
    render,
    reset_scene,
    setup_camera,
    setup_light_and_sky,
    smooth,
)

TRACK_N = 24
RX, RY = 4.15, 4.85
TEAM_ORDER = ["emerald", "saphir", "grenat", "safran"]
rng = random.Random(7)

OUT_IMG = "assets/board/scene_oasis.webp"
OUT_PNG = "build/art_preview/scene3d.png"


# ---------------------------------------------------------------------------
# Track geometry: superellipse, equal arc length, cell 0 at top-left,
# clockwise as seen on screen (+Y is away from the camera).
# ---------------------------------------------------------------------------


def superellipse_point(theta, n=3.2):
    c, s = math.cos(theta), math.sin(theta)
    x = math.copysign(abs(c) ** (2.0 / n), c)
    y = math.copysign(abs(s) ** (2.0 / n), s)
    return RX * x, RY * y


def track_positions():
    m = 2000
    pts = []
    for k in range(m):
        # theta decreasing from 135deg -> screen-clockwise from top-left.
        th = math.radians(135) - 2 * math.pi * k / m
        pts.append(superellipse_point(th))
    lens = [0.0]
    for i in range(1, m + 1):
        a, b = pts[i - 1], pts[i % m]
        lens.append(lens[-1] + math.hypot(b[0] - a[0], b[1] - a[1]))
    total = lens[-1]
    out = []
    for i in range(TRACK_N):
        target = total * i / TRACK_N
        k = max(0, min(m - 1, _searchsorted(lens, target)))
        x, y = pts[k]
        nxt = pts[(k + 10) % m]
        prv = pts[(k - 10) % m]
        tang = math.atan2(nxt[1] - prv[1], nxt[0] - prv[0])
        out.append((x, y, tang))
    return out


def _searchsorted(arr, v):
    lo, hi = 0, len(arr) - 1
    while lo < hi:
        mid = (lo + hi) // 2
        if arr[mid] < v:
            lo = mid + 1
        else:
            hi = mid
    return lo


# ---------------------------------------------------------------------------
# Mesh builders.
# ---------------------------------------------------------------------------


def build_box(name, size, mat, *, bevel=0.05, loc=(0, 0, 0), rot_z=0.0):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1)
    bmesh.ops.scale(bm, vec=size, verts=bm.verts)
    bm.to_mesh(mesh)
    bm.free()
    obj = mesh_object(name, mesh, mat)
    obj.location = loc
    obj.rotation_euler = (0, 0, rot_z)
    if bevel:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 3
        for p in obj.data.polygons:
            p.use_smooth = False
    return obj


def build_cylinder(name, r, depth, mat, *, loc=(0, 0, 0), verts=32, scale=(1, 1, 1)):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=verts, radius1=r, radius2=r, depth=depth)
    bm.to_mesh(mesh)
    bm.free()
    obj = mesh_object(name, mesh, mat)
    obj.location = loc
    obj.scale = scale
    smooth(obj)
    return obj


def build_cone(name, r1, r2, depth, mat, *, loc=(0, 0, 0), verts=24):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=verts, radius1=r1, radius2=r2, depth=depth)
    bm.to_mesh(mesh)
    bm.free()
    obj = mesh_object(name, mesh, mat)
    obj.location = loc
    smooth(obj)
    return obj


def build_sphere(name, r, mat, *, loc=(0, 0, 0), scale=(1, 1, 1), subdiv=3):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subdiv, radius=r)
    bm.to_mesh(mesh)
    bm.free()
    obj = mesh_object(name, mesh, mat)
    obj.location = loc
    obj.scale = scale
    smooth(obj)
    return obj


def build_torus(name, r, minor, mat, *, loc=(0, 0, 0), scale=(1, 1, 1)):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, cap_ends=False, segments=28, radius=r)
    bm.to_mesh(mesh)
    bm.free()
    obj = mesh_object(name, mesh, mat)
    obj.location = loc
    obj.scale = scale
    # Give the circle thickness via skin-like bevel: convert with a
    # simple screw... simplest: use a curve instead.
    bpy.data.objects.remove(obj)
    curve = bpy.data.curves.new(name, "CURVE")
    curve.dimensions = "3D"
    sp = curve.splines.new("NURBS")
    n = 20
    sp.points.add(n - 1)
    for i in range(n):
        a = 2 * math.pi * i / n
        sp.points[i].co = (r * math.cos(a), r * math.sin(a), 0, 1)
    sp.use_cyclic_u = True
    curve.bevel_depth = minor
    curve.bevel_resolution = 3
    obj = bpy.data.objects.new(name, curve)
    bpy.context.scene.collection.objects.link(obj)
    obj.location = loc
    obj.scale = scale
    obj.data.materials.append(mat)
    return obj


def build_dome(name, r, mat, *, loc, squash=1.15):
    """Onion dome: sphere pulled upward at the pole."""
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=r)
    for v in bm.verts:
        z = v.co.z / r
        if z > 0:
            v.co.z *= 1.0 + 0.55 * (z**2.2)
            f = 1.0 - 0.35 * max(0.0, z - 0.35)
            v.co.x *= f
            v.co.y *= f
    bm.to_mesh(mesh)
    bm.free()
    obj = mesh_object(name, mesh, mat)
    obj.location = loc
    obj.scale = (1, 1, squash)
    smooth(obj)
    return obj


def build_palm(loc, h, mats, lean=0.18, seed=1):
    r = random.Random(seed)
    trunk_mat, leaf_mat = mats
    # Trunk: stacked, slightly offset segments.
    n = 7
    x, y = loc[0], loc[1]
    dx = lean * math.cos(seed)
    dy = lean * math.sin(seed)
    top = (x, y, 0)
    for i in range(n):
        t = i / (n - 1)
        seg_r = 0.075 * h * (1 - 0.45 * t)
        cz = h * t * 0.72 + 0.05
        cx = x + dx * h * t * t
        cy = y + dy * h * t * t
        build_cylinder(f"trunk_{seed}_{i}", seg_r, h * 0.16, trunk_mat, loc=(cx, cy, cz))
        top = (cx, cy, cz + h * 0.07)
    # Fronds: bent blades around the crown.
    for k in range(11):
        ang = 2 * math.pi * k / 11 + r.uniform(-0.15, 0.15)
        ln = h * r.uniform(0.40, 0.55)
        mesh = bpy.data.meshes.new(f"frond_{seed}_{k}")
        bm = bmesh.new()
        segs = 6
        verts = []
        for i in range(segs + 1):
            t = i / segs
            wl = 0.055 * h * math.sin(math.pi * min(1, t * 1.15)) + 0.006
            fx = ln * t
            fz = 0.18 * ln * math.sin(math.pi * t * 0.5) - 0.95 * ln * t * t
            verts.append(bm.verts.new((fx, -wl, fz)))
            verts.append(bm.verts.new((fx, wl, fz)))
        for i in range(segs):
            bm.faces.new((verts[2 * i], verts[2 * i + 1], verts[2 * i + 3], verts[2 * i + 2]))
        bm.to_mesh(mesh)
        bm.free()
        obj = mesh_object(f"frond_{seed}_{k}", mesh, leaf_mat)
        obj.location = top
        obj.rotation_euler = (r.uniform(-0.12, 0.12), r.uniform(-0.1, 0.1), ang)
        smooth(obj)


def build_rock(loc, r, mat, seed=1):
    obj = build_sphere(f"rock_{seed}", r, mat, loc=(loc[0], loc[1], r * 0.45), subdiv=2)
    obj.scale = (1.0 + 0.4 * math.sin(seed), 1.0, 0.62)
    tex = bpy.data.textures.new(f"rocktex_{seed}", "CLOUDS")
    tex.noise_scale = r * 1.5
    mod = obj.modifiers.new("Displace", "DISPLACE")
    mod.texture = tex
    mod.strength = r * 0.55


def build_lantern(loc, mats, h=0.55, seed=0):
    pole_mat, glass_mat = mats
    build_cylinder(f"lpole_{seed}", 0.022, h, pole_mat, loc=(loc[0], loc[1], h / 2))
    build_sphere(f"lglass_{seed}", 0.055, glass_mat, loc=(loc[0], loc[1], h + 0.045), subdiv=2)


# ---------------------------------------------------------------------------
# Scene assembly.
# ---------------------------------------------------------------------------


def build_scene(fast=False):
    scene = reset_scene()
    if fast:
        scene.cycles.samples = 48

    # Materials.
    m_sand = new_material("sand", (0.42, 0.225, 0.085), rough=0.95, noise_bump=0.35, noise_scale=3.0,
                          color2=(0.30, 0.15, 0.055))
    m_stone = new_material("stone", (0.38, 0.28, 0.16), rough=0.85, noise_bump=0.7,
                           noise_scale=14, color2=(0.36, 0.27, 0.16))
    m_stone_dark = new_material("stone_dark", (0.40, 0.30, 0.20), rough=0.85, noise_bump=0.4)
    m_gold = new_material("gold", (0.68, 0.42, 0.09), rough=0.36, metal=1.0)
    m_ivory = new_material("ivory", (0.62, 0.52, 0.36), rough=0.75, noise_bump=0.2)
    m_water = new_material("water", WATER, rough=0.08, coat=1.0, color2=(0.05, 0.55, 0.55))
    m_leaf = new_material("leaf", (0.02, 0.16, 0.045), rough=0.65, color2=(0.05, 0.28, 0.07))
    m_trunk = new_material("trunk", (0.19, 0.11, 0.055), rough=0.9, noise_bump=0.5)
    m_glass = new_material("lantern", (0.30, 0.14, 0.03), rough=0.4,
                           emission=(1.0, 0.32, 0.04), emission_strength=22.0)
    m_wall = new_material("wall", (0.66, 0.50, 0.30), rough=0.7, noise_bump=0.3)
    m_carpet = new_material("carpet", (0.45, 0.08, 0.07), rough=0.9)
    deep_team = {"emerald": (0.015, 0.24, 0.07), "saphir": (0.04, 0.10, 0.45),
                 "grenat": (0.36, 0.05, 0.28), "safran": (0.62, 0.30, 0.03)}
    team_mats = {t: new_material(f"team_{t}", deep_team[t], rough=0.5, coat=0.3)
                 for t, c in TEAM_COLORS.items()}
    team_cloth = {t: new_material(f"cloth_{t}", c, rough=0.75, noise_bump=0.2)
                  for t, c in TEAM_COLORS.items()}

    # ---- Terrain: dunes ----
    mesh = bpy.data.meshes.new("terrain")
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=160, y_segments=200, size=1)
    bm.to_mesh(mesh)
    bm.free()
    terrain = mesh_object("terrain", mesh, m_sand)
    terrain.scale = (20, 26, 1)
    sub = terrain.modifiers.new("Sub", "SUBSURF")
    sub.subdivision_type = "SIMPLE"
    sub.levels = 2
    sub.render_levels = 2
    tex = bpy.data.textures.new("dunes", "CLOUDS")
    tex.noise_scale = 0.55
    tex.noise_depth = 3
    mod = terrain.modifiers.new("Dunes", "DISPLACE")
    mod.texture = tex
    mod.strength = 1.5
    tex2 = bpy.data.textures.new("ripples", "CLOUDS")
    tex2.noise_scale = 0.05
    mod2 = terrain.modifiers.new("Ripples", "DISPLACE")
    mod2.texture = tex2
    mod2.strength = 0.06
    terrain.location = (0, 4, -1.15)
    smooth(terrain)

    # A flat apron under the playfield so slabs sit level.
    build_cylinder("apron", 6.0, 0.3, m_sand, loc=(0, 0, -0.15), verts=64, scale=(1, 1.1, 1))

    # ---- Oasis lake behind the board ----
    build_cylinder("lake", 3.6, 0.1, m_water, loc=(0.3, 9.2, 0.0), verts=48, scale=(1.5, 0.5, 1))

    # ---- Track ----
    cells = track_positions()
    anchors_track = []
    for i, (x, y, tang) in enumerate(cells):
        off = i % 6
        if off == 0:
            mat = team_mats[TEAM_ORDER[i // 6]]
        else:
            mat = m_stone
        build_box(
            f"slab_{i}", (1.28, 1.02, 0.26), mat,
            loc=(x, y, 0.11), rot_z=tang + rng.uniform(-0.05, 0.05), bevel=0.06,
        )
        if off == 2:  # star cell: gold marker
            build_sphere(f"star_{i}", 0.14, m_gold, loc=(x, y, 0.26), scale=(1.4, 1.4, 0.35))
        if off == 4:  # oasis cell: little pool inset
            build_cylinder(f"cellpool_{i}", 0.26, 0.06, m_water, loc=(x, y, 0.235), verts=24)
        anchors_track.append((x, y, 0.24))

    # ---- Final lanes ----
    anchors_lane = {t: [] for t in TEAM_ORDER}
    for t_i, team in enumerate(TEAM_ORDER):
        exit_i = (t_i * 6 - 1) % TRACK_N
        bx, by, _ = cells[exit_i]
        for step in range(1, 5):
            t = 0.22 + 0.50 * (step - 1) / 3
            x, y = bx * (1 - t), by * (1 - t)
            ang = math.atan2(-by, -bx)
            build_box(
                f"lane_{team}_{step}", (0.92, 0.74, 0.2), team_mats[team],
                loc=(x, y, 0.09), rot_z=ang, bevel=0.05,
            )
            anchors_lane[team].append((x, y, 0.20))

    # ---- Centre: oasis palace ----
    build_cylinder("plat2", 2.35, 0.22, m_stone_dark, loc=(0, 0, 0.11), verts=48)
    build_cylinder("plat1", 2.05, 0.3, m_stone, loc=(0, 0, 0.3), verts=48)
    # Pool ring in front.
    build_torus("pool_rim", 0.98, 0.07, m_gold, loc=(0, -1.05, 0.46), scale=(1, 0.55, 1))
    build_cylinder("pool", 0.95, 0.05, m_water, loc=(0, -1.05, 0.45), verts=36, scale=(1, 0.55, 1))
    # Main block + iwan (dark inset decal).
    build_box("block", (1.5, 1.0, 1.15), m_wall, loc=(0, 0.35, 1.0), bevel=0.04)
    build_box("iwan", (0.52, 0.06, 0.85), m_stone_dark, loc=(0, -0.16, 0.85), bevel=0.02)
    lamp = bpy.data.lights.new("iwan_glow", "POINT")
    lamp.energy = 60
    lamp.color = (1.0, 0.55, 0.2)
    lamp_o = bpy.data.objects.new("iwan_glow", lamp)
    scene.collection.objects.link(lamp_o)
    lamp_o.location = (0, -0.3, 0.9)
    # Side wings.
    for sx in (-1, 1):
        build_box("wing", (0.85, 0.8, 0.75), m_wall, loc=(sx * 1.55, 0.4, 0.8), bevel=0.04)
        build_dome(f"wingdome_{sx}", 0.28, m_gold, loc=(sx * 1.55, 0.4, 1.28))
    # Main dome on drum.
    build_cylinder("drum", 0.48, 0.5, m_ivory, loc=(0, 0.35, 1.78), verts=24)
    build_dome("dome", 0.44, m_gold, loc=(0, 0.35, 2.12))
    # Minarets.
    for sx in (-1, 1):
        build_cone(f"minaret_{sx}", 0.15, 0.08, 3.4, m_wall, loc=(sx * 2.25, 0.9, 1.7))
        build_torus(f"minbal_{sx}", 0.16, 0.03, m_gold, loc=(sx * 2.25, 0.9, 3.0))
        build_dome(f"minidome_{sx}", 0.17, m_gold, loc=(sx * 2.25, 0.9, 3.5))
    # Carpet from iwan to pool.
    build_box("carpet", (0.5, 0.9, 0.02), m_carpet, loc=(0, -0.72, 0.46), bevel=0.0)
    # Palace palms.
    build_palm((-1.15, -0.65, 0), 1.9, (m_trunk, m_leaf), seed=31)
    build_palm((1.25, -0.5, 0), 1.6, (m_trunk, m_leaf), seed=37)

    # ---- Camps ----
    camp_pos = {
        "emerald": (-3.7, 5.5),
        "saphir": (3.7, 5.5),
        "grenat": (3.35, -5.2),
        "safran": (-3.35, -5.2),
    }
    anchors_camp = {t: [] for t in TEAM_ORDER}
    for team, (cx, cy) in camp_pos.items():
        # Platform.
        build_cylinder(f"camp_plat_{team}", 1.75, 0.18, m_stone, loc=(cx, cy, 0.09), verts=40)
        # Pavilion: ivory wall drum, broad swooping canopy, upper tier,
        # gold finial, door with warm light.
        ty = cy + 0.35
        build_cylinder(f"tentwall_{team}", 0.92, 0.75, m_ivory, loc=(cx, ty, 0.42), verts=20)
        build_cone(f"tent_{team}", 1.45, 0.42, 0.85, team_cloth[team], loc=(cx, ty, 1.18), verts=20)
        build_cone(f"tenttop_{team}", 0.44, 0.03, 0.62, team_cloth[team], loc=(cx, ty, 1.95), verts=16)
        build_torus(f"tenthem_{team}", 1.42, 0.045, m_gold, loc=(cx, ty, 0.80))
        build_sphere(f"tentball_{team}", 0.09, m_gold, loc=(cx, ty, 2.32), subdiv=2)
        door_y = ty - 0.90 if cy > 0 else ty - 0.90
        build_box(f"tentdoor_{team}", (0.40, 0.08, 0.5), m_stone_dark,
                  loc=(cx, door_y, 0.30), bevel=0.02)
        dl = bpy.data.lights.new(f"doorglow_{team}", "POINT")
        dl.energy = 25
        dl.color = (1.0, 0.55, 0.2)
        dlo = bpy.data.objects.new(f"doorglow_{team}", dl)
        scene.collection.objects.link(dlo)
        dlo.location = (cx, door_y - 0.15, 0.45)
        # Carpet forecourt + 4 slots where the camera can see them:
        # in front for the top camps, on the inner flank for the bottom.
        if cy > 0:
            sy = cy - 1.3
            build_box(f"camp_carpet_{team}", (1.7, 0.8, 0.03), m_carpet, loc=(cx, sy, 0.2))
            for k in range(4):
                sxo = cx - 0.62 + 0.42 * k
                syo = sy + (0.24 if k % 2 else -0.24)
                build_torus(f"slot_{team}_{k}", 0.24, 0.035, m_gold, loc=(sxo, syo, 0.22))
                anchors_camp[team].append((sxo, syo, 0.24))
        else:
            sgn = 1 if cx < 0 else -1
            sx0 = cx + sgn * 1.9
            build_box(f"camp_carpet_{team}", (0.9, 1.7, 0.03), m_carpet, loc=(sx0, cy + 0.2, 0.2))
            for k in range(4):
                sxo = sx0 + (0.26 if k % 2 else -0.26) * sgn
                syo = cy - 0.5 + 0.48 * k
                build_torus(f"slot_{team}_{k}", 0.24, 0.035, m_gold, loc=(sxo, syo, 0.22))
                anchors_camp[team].append((sxo, syo, 0.24))
        # Banner pole.
        build_cylinder(f"bpole_{team}", 0.03, 1.9, m_trunk, loc=(cx + 1.3, cy, 0.95))
        build_box(f"banner_{team}", (0.5, 0.02, 0.3), team_cloth[team], loc=(cx + 1.55, cy, 1.65))

    # ---- Props ----
    prng = random.Random(4)
    placed = []
    def clear_of_everything(x, y, d=1.35):
        for (px, py) in placed:
            if math.hypot(x - px, y - py) < d:
                return False
        for (px, py, _) in anchors_track:
            if math.hypot(x - px, y - py) < 1.15:
                return False
        for lane in anchors_lane.values():
            for (px, py, _) in lane:
                if math.hypot(x - px, y - py) < 0.9:
                    return False
        if math.hypot(x, y) < 3.1:
            return False
        for (px, py) in camp_pos.values():
            if math.hypot(x - px, y - py) < 2.4:
                return False
        return True

    for i in range(60):
        x = prng.uniform(-6.6, 6.6)
        y = prng.uniform(-7.2, 8.4)
        if not clear_of_everything(x, y):
            continue
        placed.append((x, y))
        pick = prng.random()
        if pick < 0.45:
            build_palm((x, y, 0), prng.uniform(1.2, 2.2), (m_trunk, m_leaf), seed=100 + i)
        elif pick < 0.7:
            build_rock((x, y), prng.uniform(0.25, 0.6), m_stone, seed=200 + i)
        else:
            build_lantern((x, y), (m_trunk, m_glass), seed=i)
    # Lake-side palms.
    for k, (px, py) in enumerate([(-1.6, 7.6), (3.6, 7.9), (0.4, 8.0), (5.0, 7.2)]):
        build_palm((px, py, 0), 2.4, (m_trunk, m_leaf), seed=300 + k)

    # ---- Dusk backdrop + distant mountains ----
    bd_mat = bpy.data.materials.new("dusk")
    bd_mat.use_nodes = True
    nt = bd_mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    em = nt.nodes.new("ShaderNodeEmission")
    em.inputs["Strength"].default_value = 1.6
    grad = nt.nodes.new("ShaderNodeTexGradient")
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (1.0, 0.42, 0.10, 1)
    ramp.color_ramp.elements[1].color = (0.10, 0.06, 0.22, 1)
    e = ramp.color_ramp.elements.new(0.35)
    e.color = (0.85, 0.25, 0.16, 1)
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    mapr = nt.nodes.new("ShaderNodeMapRange")
    mapr.inputs["From Min"].default_value = 0.0
    mapr.inputs["From Max"].default_value = 14.0
    nt.links.new(geo.outputs["Position"], sep.inputs["Vector"])
    nt.links.new(sep.outputs["Z"], mapr.inputs["Value"])
    nt.links.new(mapr.outputs["Result"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], em.inputs["Color"])
    nt.links.new(em.outputs["Emission"], out.inputs["Surface"])
    mesh = bpy.data.meshes.new("backdrop")
    bmb = bmesh.new()
    bmesh.ops.create_grid(bmb, x_segments=2, y_segments=2, size=1)
    bmb.to_mesh(mesh)
    bmb.free()
    bdrop = mesh_object("backdrop", mesh, bd_mat)
    bdrop.scale = (60, 16, 1)
    bdrop.rotation_euler = (math.radians(90), 0, 0)
    bdrop.location = (0, 42, 8)

    m_mount = new_material("mountain", (0.075, 0.032, 0.045), rough=1.0, noise_bump=0.4, noise_scale=1.5)
    hrng = random.Random(11)
    for mi in range(9):
        mx = -20 + 5.2 * mi + hrng.uniform(-1.5, 1.5)
        my = 30 + hrng.uniform(0, 8)
        mr = hrng.uniform(4.0, 7.5)
        mh = hrng.uniform(0.28, 0.5)
        build_sphere(f"hill_{mi}", mr, m_mount, loc=(mx, my, -0.8), scale=(1.3, 0.8, mh), subdiv=3)

    # Foreground framing: rocks + palms at the bottom edge.
    build_rock((-2.6, -7.6), 0.85, m_stone, seed=901)
    build_rock((2.9, -7.8), 0.7, m_stone, seed=902)
    build_palm((-1.2, -8.0, 0), 2.6, (m_trunk, m_leaf), seed=903)
    build_palm((1.6, -8.2, 0), 2.2, (m_trunk, m_leaf), seed=904)

    # ---- Light + camera ----
    setup_light_and_sky(scene, sun_elev=12, sun_azim=210, sun_power=2.7)
    cam = setup_camera(scene, loc=(0, -15.5, 13.2), look_at=(0, 1.9, 0.35), lens=34)
    return scene, cam, anchors_track, anchors_lane, anchors_camp


def export_anchors(scene, cam, anchors_track, anchors_lane, anchors_camp):
    from bpy_extras.object_utils import world_to_camera_view

    def proj(p):
        v = world_to_camera_view(scene, cam, Vector(p))
        depth = v.z
        return (v.x, 1 - v.y, depth)

    # Depth -> sprite scale: nearer (smaller z distance) = bigger.
    depths = [proj(p)[2] for p in anchors_track]
    dmin, dmax = min(depths), max(depths)

    def scale_of(d):
        t = (d - dmin) / max(dmax - dmin, 1e-6)
        return 1.18 - 0.42 * t

    def fmt(p):
        x, y, d = proj(p)
        return f"SceneAnchor({x:.4f}, {y:.4f}, {scale_of(d):.3f})"

    track = ",\n  ".join(fmt(p) for p in anchors_track)
    lanes = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p) for p in anchors_lane[team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    camps = ",\n  ".join(
        f"{t_i}: [{', '.join(fmt(p) for p in anchors_camp[team])}]"
        for t_i, team in enumerate(TEAM_ORDER)
    )
    center = fmt((0, -1.05, 0.5))
    src = f"""// GENERATED by tool/art3d/scene_oasis.py — do not edit by hand.
// Anchors are normalized to the rendered scene image
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

const SceneAnchor sceneCenterAnchor = {center};
"""
    with open("lib/widgets/board/scene_anchors.g.dart", "w") as f:
        f.write(src)
    print("wrote lib/widgets/board/scene_anchors.g.dart")


def main():
    fast = "--fast" in sys.argv
    scene, cam, at, al, ac = build_scene(fast)
    os.makedirs("build/art_preview", exist_ok=True)
    res = (585, 1170) if fast else (1170, 2340)
    render(scene, os.path.abspath(OUT_PNG), res=res, samples=48 if fast else 128)
    if not fast:
        from PIL import Image

        Image.open(OUT_PNG).convert("RGB").save(OUT_IMG, "WEBP", quality=88, method=6)
        print("wrote", OUT_IMG)
        export_anchors(scene, cam, at, al, ac)
    print("preview:", OUT_PNG)


if __name__ == "__main__":
    main()
