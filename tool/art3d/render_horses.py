"""The master horse: a stylized 3D Arabian built with a skin-modifier
skeleton, subdivision-smoothed, with saddle and team-colored textile.
Natural coat per stable, team identity in the tack — no pedestal.

Renders each team's idle sprite on transparency with the SAME camera
angle and golden-hour light as the board scene.

Run:  python3 tool/art3d/render_horses.py [--fast] [--one]
"""

from __future__ import annotations

import math
import os
import sys

import bpy
import bmesh

sys.path.insert(0, os.path.dirname(__file__))
from common import (  # noqa: E402
    mesh_object,
    new_material,
    render,
    reset_scene,
    setup_camera,
    setup_light_and_sky,
    smooth,
)

# Natural coats; the team lives in the saddle blanket.
COATS = {
    "emerald": ((0.68, 0.63, 0.57), (0.24, 0.22, 0.20)),  # grey-white, dark mane
    "saphir": ((0.32, 0.16, 0.07), (0.06, 0.03, 0.02)),  # bay
    "grenat": ((0.45, 0.20, 0.08), (0.25, 0.10, 0.04)),  # chestnut
    "safran": ((0.06, 0.05, 0.05), (0.02, 0.02, 0.02)),  # black
}
TEAM_CLOTH = {
    "emerald": (0.02, 0.30, 0.09),
    "saphir": (0.05, 0.11, 0.48),
    "grenat": (0.38, 0.05, 0.30),
    "safran": (0.66, 0.32, 0.04),
}


def skin_mesh(name, chains, mat, connect=None):
    """Build a skin-modifier body: chains = list of [(x,y,z,r), ...].
    connect = [(chain_idx, vert_idx_in_chain, other_chain_idx)] edges that
    weld extra chains onto the first one so Skin sees one skeleton."""
    mesh = bpy.data.meshes.new(name)
    verts = []
    edges = []
    radii = []
    bases = []
    for chain in chains:
        base = len(verts)
        bases.append(base)
        for i, (x, y, z, r) in enumerate(chain):
            verts.append((x, y, z))
            radii.append(r)
            if i > 0:
                edges.append((base + i - 1, base + i))
    if connect:
        for c0, v0, c1 in connect:
            edges.append((bases[c0] + v0, bases[c1]))
    mesh.from_pydata(verts, edges, [])
    obj = mesh_object(name, mesh, mat)
    mod = obj.modifiers.new("Skin", "SKIN")
    mod.use_smooth_shade = True
    for i, r in enumerate(radii):
        sv = obj.data.skin_vertices[0].data[i]
        sv.radius = (r, r)
    obj.data.skin_vertices[0].data[0].use_root = True
    sub = obj.modifiers.new("Subsurf", "SUBSURF")
    sub.levels = 2
    sub.render_levels = 3
    return obj


def build_horse(team):
    coat_rgb, mane_rgb = COATS[team]
    m_coat = new_material(f"coat_{team}", coat_rgb, rough=0.68, coat=0.06,
                          color2=tuple(c * 0.8 for c in coat_rgb), noise_bump=0.06, noise_scale=18)
    m_mane = new_material(f"mane_{team}", mane_rgb, rough=0.8)
    m_cloth = new_material(f"cloth_{team}", TEAM_CLOTH[team], rough=0.7, noise_bump=0.25)
    m_gold = new_material(f"gold_{team}", (0.68, 0.42, 0.09), rough=0.35, metal=1.0)
    m_leather = new_material(f"leather_{team}", (0.24, 0.12, 0.05), rough=0.6, coat=0.3)
    m_dark = new_material(f"dark_{team}", (0.04, 0.03, 0.03), rough=0.5)
    m_hoof = new_material(f"hoof_{team}", (0.10, 0.07, 0.05), rough=0.5)

    # ---- Body: spine + neck + head as one skin chain, legs as chains ----
    spine = [
        (-0.60, 0, 1.02, 0.13),  # croup
        (-0.36, 0, 1.06, 0.175),  # hindquarters
        (-0.02, 0, 1.00, 0.19),  # barrel
        (0.26, 0, 1.04, 0.175),  # girth
        (0.44, 0, 1.14, 0.135),  # withers
        (0.56, 0, 1.26, 0.110),  # neck base
        (0.68, 0, 1.44, 0.088),  # mid neck (arched)
        (0.75, 0, 1.58, 0.072),  # upper neck
        (0.80, 0, 1.67, 0.060),  # poll
        (0.91, 0, 1.63, 0.058),  # skull
        (1.05, 0, 1.50, 0.036),  # muzzle (head down-forward)
        (1.09, 0, 1.45, 0.027),  # nose
    ]
    legs = []
    for sx, sy, hip in [(0.42, 0.10, False), (0.42, -0.10, False), (-0.42, 0.11, True), (-0.42, -0.11, True)]:
        if hip:
            legs.append([
                (sx, sy, 0.85, 0.105),
                (sx - 0.03, sy, 0.62, 0.062),
                (sx + 0.02, sy, 0.42, 0.042),  # hock
                (sx - 0.01, sy, 0.22, 0.035),
                (sx - 0.01, sy, 0.07, 0.040),  # fetlock
            ])
        else:
            legs.append([
                (sx, sy, 0.85, 0.090),
                (sx + 0.01, sy, 0.60, 0.052),
                (sx, sy, 0.40, 0.038),  # knee
                (sx, sy, 0.20, 0.033),
                (sx, sy, 0.07, 0.038),
            ])
    body = skin_mesh(
        f"horse_{team}", [spine] + legs, m_coat,
        connect=[(0, 4, 1), (0, 4, 2), (0, 1, 3), (0, 1, 4)],
    )
    smooth(body)

    # ---- Hooves ----
    for sx, sy, _ in [(0.42, 0.10, 0), (0.42, -0.10, 0), (-0.43, 0.11, 0), (-0.43, -0.11, 0)]:
        mesh = bpy.data.meshes.new("hoof")
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, cap_ends=True, segments=12, radius1=0.052, radius2=0.042, depth=0.09)
        bm.to_mesh(mesh)
        bm.free()
        o = mesh_object("hoof", mesh, m_hoof)
        o.location = (sx, sy, 0.045)
        smooth(o)

    # ---- Ears ----
    for sy in (0.055, -0.055):
        mesh = bpy.data.meshes.new("ear")
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=0.030, radius2=0.004, depth=0.14)
        bm.to_mesh(mesh)
        bm.free()
        o = mesh_object("ear", mesh, m_coat)
        o.location = (0.76, sy, 1.78)
        o.rotation_euler = (math.radians(-12 if sy > 0 else 12), math.radians(-15), 0)
        smooth(o)

    # ---- Mane: one smooth crest hugging the back of the neck ----
    mane = skin_mesh(f"mane_{team}", [[
        (0.44, 0, 1.22, 0.075),
        (0.52, 0, 1.38, 0.070),
        (0.60, 0, 1.52, 0.062),
        (0.67, 0, 1.64, 0.052),
        (0.73, 0, 1.74, 0.040),
    ]], m_mane)
    mane.scale = (1.0, 0.55, 1.0)
    smooth(mane)
    # Tail: skin chain, flowing.
    tail = skin_mesh(f"tail_{team}", [[
        (-0.68, 0, 1.02, 0.045),
        (-0.80, 0, 0.86, 0.055),
        (-0.86, 0, 0.62, 0.050),
        (-0.86, 0, 0.38, 0.038),
        (-0.82, 0, 0.20, 0.022),
    ]], m_mane)
    smooth(tail)

    # ---- Tack: team blanket, leather saddle, gold accents, bridle ----
    mesh = bpy.data.meshes.new("blanket")
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1)
    bmesh.ops.scale(bm, vec=(0.46, 0.42, 0.30), verts=bm.verts)
    bm.to_mesh(mesh)
    bm.free()
    blanket = mesh_object("blanket", mesh, m_cloth)
    blanket.location = (0.10, 0, 1.12)
    bmod = blanket.modifiers.new("Bevel", "BEVEL")
    bmod.width = 0.05
    bmod.segments = 3
    sub = blanket.modifiers.new("Sub", "SUBSURF")
    sub.levels = 2
    sub.render_levels = 2
    smooth(blanket)

    mesh = bpy.data.meshes.new("saddle")
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=0.19)
    bm.to_mesh(mesh)
    bm.free()
    saddle = mesh_object("saddle", mesh, m_leather)
    saddle.location = (0.10, 0, 1.21)
    saddle.scale = (1.15, 0.72, 0.55)
    smooth(saddle)
    # Pommel + cantle.
    for dx, r in [(0.26, 0.05), (-0.20, 0.06)]:
        mesh = bpy.data.meshes.new("pom")
        bm = bmesh.new()
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=r)
        bm.to_mesh(mesh)
        bm.free()
        o = mesh_object("pom", mesh, m_gold)
        o.location = (0.10 + dx, 0, 1.29)
        smooth(o)
    # Girth strap.
    mesh = bpy.data.meshes.new("girth")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=False, segments=24, radius1=0.205, radius2=0.205, depth=0.09)
    bm.to_mesh(mesh)
    bm.free()
    girth = mesh_object("girth", mesh, m_leather)
    girth.location = (0.14, 0, 1.02)
    girth.rotation_euler = (0, math.radians(90), 0)
    smooth(girth)
    # Bridle: thin bands around the head + rein hint.
    mesh = bpy.data.meshes.new("brow")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=False, segments=16, radius1=0.062, radius2=0.062, depth=0.02)
    bm.to_mesh(mesh)
    bm.free()
    brow = mesh_object("brow", mesh, m_leather)
    brow.location = (0.86, 0, 1.65)
    brow.rotation_euler = (0, math.radians(75), 0)
    mesh = bpy.data.meshes.new("nose")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=False, segments=16, radius1=0.045, radius2=0.045, depth=0.018)
    bm.to_mesh(mesh)
    bm.free()
    nb = mesh_object("noseband", mesh, m_leather)
    nb.location = (1.00, 0, 1.53)
    nb.rotation_euler = (0, math.radians(70), 0)

    # ---- Eyes ----
    for sy in (0.052, -0.052):
        mesh = bpy.data.meshes.new("eye")
        bm = bmesh.new()
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.020)
        bm.to_mesh(mesh)
        bm.free()
        o = mesh_object("eye", mesh, m_dark)
        o.location = (0.905, sy, 1.645)
        smooth(o)


def main():
    fast = "--fast" in sys.argv
    teams = ["emerald"] if "--one" in sys.argv else list(COATS)
    os.makedirs("assets/board/horses", exist_ok=True)
    os.makedirs("build/art_preview", exist_ok=True)
    for team in teams:
        scene = reset_scene()
        build_horse(team)
        setup_light_and_sky(scene, sun_elev=12, sun_azim=210, sun_power=2.7)
        # Same 40-degree three-quarter view as the board camera, from the
        # front-left so the horse reads as riding toward the player.
        setup_camera(scene, loc=(0.9, -3.6, 2.6), look_at=(0.10, 0, 1.02), lens=52)
        out = f"build/art_preview/horse3d_{team}.png"
        render(scene, os.path.abspath(out), res=(512, 512) if fast else (1024, 1024),
               samples=48 if fast else 128, transparent=True)
        print("rendered", out)


if __name__ == "__main__":
    main()
