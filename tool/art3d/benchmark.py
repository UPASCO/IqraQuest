"""ART QUALITY BENCHMARK — one tiny scene at target quality.

One horse, one stable, three carved slabs, one palm, one chest, one
basin, on a dune patch — full procedural PBR materials, golden-hour key
+ cool sky fill, close beauty-shot camera, teal-shadow/gold-highlight
grade. This scene answers one question: can this pipeline look like a
premium mobile game?

Run:  python3 tool/art3d/benchmark.py [--fast]
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
    smooth,
)
import render_horses  # noqa: E402


# ---------------------------------------------------------------------------
# Node-graph PBR materials: this is where the material credibility lives.
# ---------------------------------------------------------------------------


def _nodes(mat):
    mat.use_nodes = True
    nt = mat.node_tree
    return nt, nt.nodes["Principled BSDF"]


def mat_sand():
    mat = bpy.data.materials.new("bm_sand")
    nt, b = _nodes(mat)
    b.inputs["Roughness"].default_value = 0.95
    try:
        b.inputs["Specular IOR Level"].default_value = 0.12
    except KeyError:
        pass
    big = nt.nodes.new("ShaderNodeTexNoise")
    big.inputs["Scale"].default_value = 0.8
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (0.44, 0.24, 0.095, 1)
    ramp.color_ramp.elements[1].color = (0.60, 0.36, 0.16, 1)
    nt.links.new(big.outputs["Fac"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], b.inputs["Base Color"])
    # Grain bump: fine noise + ripple waves.
    grain = nt.nodes.new("ShaderNodeTexNoise")
    grain.inputs["Scale"].default_value = 220.0
    grain.inputs["Detail"].default_value = 4.0
    wave = nt.nodes.new("ShaderNodeTexWave")
    wave.inputs["Scale"].default_value = 1.6
    wave.inputs["Distortion"].default_value = 6.0
    mixn = nt.nodes.new("ShaderNodeMix")
    mixn.data_type = "FLOAT"
    mixn.inputs["Factor"].default_value = 0.35
    nt.links.new(grain.outputs["Fac"], mixn.inputs["A"])
    nt.links.new(wave.outputs["Fac"], mixn.inputs["B"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.45
    nt.links.new(mixn.outputs["Result"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    return mat


def mat_stone(base=(0.46, 0.35, 0.22), crack_scale=3.2):
    mat = bpy.data.materials.new("bm_stone")
    nt, b = _nodes(mat)
    b.inputs["Roughness"].default_value = 0.82
    try:
        b.inputs["Specular IOR Level"].default_value = 0.16
    except KeyError:
        pass
    # Tone variation.
    var = nt.nodes.new("ShaderNodeTexNoise")
    var.inputs["Scale"].default_value = 2.4
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (*[c * 0.72 for c in base], 1)
    ramp.color_ramp.elements[1].color = (*[min(1, c * 1.18) for c in base], 1)
    nt.links.new(var.outputs["Fac"], ramp.inputs["Fac"])
    # Cracks darken the color: voronoi cell edges.
    vor = nt.nodes.new("ShaderNodeTexVoronoi")
    vor.feature = "DISTANCE_TO_EDGE"
    vor.inputs["Scale"].default_value = crack_scale
    crack_ramp = nt.nodes.new("ShaderNodeValToRGB")
    crack_ramp.color_ramp.elements[0].position = 0.0
    crack_ramp.color_ramp.elements[0].color = (0.35, 0.35, 0.35, 1)
    crack_ramp.color_ramp.elements[1].position = 0.045
    crack_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
    nt.links.new(vor.outputs["Distance"], crack_ramp.inputs["Fac"])
    mixc = nt.nodes.new("ShaderNodeMix")
    mixc.data_type = "RGBA"
    mixc.blend_type = "MULTIPLY"
    mixc.inputs["Factor"].default_value = 1.0
    nt.links.new(ramp.outputs["Color"], mixc.inputs["A"])
    nt.links.new(crack_ramp.outputs["Color"], mixc.inputs["B"])
    nt.links.new(mixc.outputs["Result"], b.inputs["Base Color"])
    # Bump: cracks + surface noise.
    surf = nt.nodes.new("ShaderNodeTexNoise")
    surf.inputs["Scale"].default_value = 26.0
    surf.inputs["Detail"].default_value = 8.0
    mixb = nt.nodes.new("ShaderNodeMix")
    mixb.data_type = "FLOAT"
    mixb.inputs["Factor"].default_value = 0.5
    nt.links.new(surf.outputs["Fac"], mixb.inputs["A"])
    nt.links.new(crack_ramp.outputs["Color"], mixb.inputs["B"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.55
    nt.links.new(mixb.outputs["Result"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    return mat


def mat_wood():
    mat = bpy.data.materials.new("bm_wood")
    nt, b = _nodes(mat)
    b.inputs["Roughness"].default_value = 0.65
    wave = nt.nodes.new("ShaderNodeTexWave")
    wave.inputs["Scale"].default_value = 3.0
    wave.inputs["Distortion"].default_value = 4.5
    wave.inputs["Detail"].default_value = 3.0
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (0.16, 0.085, 0.04, 1)
    ramp.color_ramp.elements[1].color = (0.30, 0.16, 0.075, 1)
    nt.links.new(wave.outputs["Fac"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], b.inputs["Base Color"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.3
    nt.links.new(wave.outputs["Fac"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    return mat


def mat_fabric(color, folds_scale=9.0):
    mat = bpy.data.materials.new("bm_fabric")
    nt, b = _nodes(mat)
    b.inputs["Roughness"].default_value = 0.85
    try:
        b.inputs["Sheen Weight"].default_value = 0.6
    except KeyError:
        pass
    var = nt.nodes.new("ShaderNodeTexNoise")
    var.inputs["Scale"].default_value = 3.0
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.elements[0].color = (*[c * 0.7 for c in color], 1)
    ramp.color_ramp.elements[1].color = (*[min(1, c * 1.25) for c in color], 1)
    nt.links.new(var.outputs["Fac"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], b.inputs["Base Color"])
    # Weave bump.
    weave = nt.nodes.new("ShaderNodeTexWave")
    weave.inputs["Scale"].default_value = 90.0
    folds = nt.nodes.new("ShaderNodeTexWave")
    folds.inputs["Scale"].default_value = folds_scale
    folds.inputs["Distortion"].default_value = 3.0
    folds.bands_direction = "Y"
    mixb = nt.nodes.new("ShaderNodeMix")
    mixb.data_type = "FLOAT"
    mixb.inputs["Factor"].default_value = 0.6
    nt.links.new(weave.outputs["Fac"], mixb.inputs["A"])
    nt.links.new(folds.outputs["Fac"], mixb.inputs["B"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.45
    nt.links.new(mixb.outputs["Result"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    return mat


def mat_water():
    mat = bpy.data.materials.new("bm_water")
    nt, b = _nodes(mat)
    b.inputs["Base Color"].default_value = (0.03, 0.42, 0.45, 1)
    b.inputs["Roughness"].default_value = 0.04
    try:
        b.inputs["Transmission Weight"].default_value = 0.75
    except KeyError:
        pass
    rip = nt.nodes.new("ShaderNodeTexNoise")
    rip.inputs["Scale"].default_value = 14.0
    rip.inputs["Detail"].default_value = 6.0
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.18
    nt.links.new(rip.outputs["Fac"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    return mat


def mat_gold():
    return new_material("bm_gold", (0.66, 0.40, 0.09), rough=0.32, metal=1.0)




TEX_DIR = os.path.join(os.getcwd(), "assets_3d", "textures")
HDRI = os.path.join(os.getcwd(), "assets_3d", "hdri", "venice_sunset_1k.hdr")


def _img(nt, fname, non_color=False):
    path = os.path.join(TEX_DIR, fname)
    if not os.path.exists(path):
        return None
    img = bpy.data.images.load(path, check_existing=True)
    if non_color:
        img.colorspace_settings.name = "Non-Color"
    node = nt.nodes.new("ShaderNodeTexImage")
    node.image = img
    return node


def _tiled(nt, tex_node, scale):
    coord = nt.nodes.new("ShaderNodeTexCoord")
    mapping = nt.nodes.new("ShaderNodeMapping")
    mapping.inputs["Scale"].default_value = (scale, scale, scale)
    nt.links.new(coord.outputs["Object"], mapping.inputs["Vector"])
    nt.links.new(mapping.outputs["Vector"], tex_node.inputs["Vector"])
    return mapping


def mat_sand_tex():
    """Photo sand, warmed, with ripple bump."""
    mat = bpy.data.materials.new("bmt_sand")
    nt, b = _nodes(mat)
    b.inputs["Roughness"].default_value = 0.95
    try:
        b.inputs["Specular IOR Level"].default_value = 0.1
    except KeyError:
        pass
    tex = _img(nt, "sand.jpg")
    if tex is None:
        return mat_sand()
    tex.projection = "BOX"
    tex.projection_blend = 0.3
    _tiled(nt, tex, 0.5)
    hsv = nt.nodes.new("ShaderNodeHueSaturation")
    hsv.inputs["Saturation"].default_value = 0.95
    hsv.inputs["Value"].default_value = 1.22
    mixw = nt.nodes.new("ShaderNodeMix")
    mixw.data_type = "RGBA"
    mixw.blend_type = "MULTIPLY"
    mixw.inputs["Factor"].default_value = 0.4
    mixw.inputs["B"].default_value = (1.0, 0.78, 0.5, 1)
    nt.links.new(tex.outputs["Color"], hsv.inputs["Color"])
    nt.links.new(hsv.outputs["Color"], mixw.inputs["A"])
    nt.links.new(mixw.outputs["Result"], b.inputs["Base Color"])
    bump_src = nt.nodes.new("ShaderNodeTexWave")
    bump_src.inputs["Scale"].default_value = 1.4
    bump_src.inputs["Distortion"].default_value = 7.0
    fine = nt.nodes.new("ShaderNodeTexNoise")
    fine.inputs["Scale"].default_value = 180.0
    mixb = nt.nodes.new("ShaderNodeMix")
    mixb.data_type = "FLOAT"
    mixb.inputs["Factor"].default_value = 0.22
    nt.links.new(bump_src.outputs["Fac"], mixb.inputs["A"])
    nt.links.new(fine.outputs["Fac"], mixb.inputs["B"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.25
    nt.links.new(mixb.outputs["Result"], bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    return mat


def mat_stone_tex(warm=(1.0, 0.80, 0.55), scale=0.45):
    """Photo rock + its normal map, graded to warm sandstone."""
    mat = bpy.data.materials.new("bmt_stone")
    nt, b = _nodes(mat)
    b.inputs["Roughness"].default_value = 0.85
    try:
        b.inputs["Specular IOR Level"].default_value = 0.14
    except KeyError:
        pass
    tex = _img(nt, "sand.jpg")
    if tex is None:
        return mat_stone()
    tex.projection = "BOX"
    tex.projection_blend = 0.3
    m = _tiled(nt, tex, scale)
    hsv = nt.nodes.new("ShaderNodeHueSaturation")
    hsv.inputs["Saturation"].default_value = 0.85
    hsv.inputs["Value"].default_value = 1.15
    mixw = nt.nodes.new("ShaderNodeMix")
    mixw.data_type = "RGBA"
    mixw.blend_type = "MULTIPLY"
    mixw.inputs["Factor"].default_value = 0.45
    mixw.inputs["B"].default_value = (*warm, 1)
    nt.links.new(tex.outputs["Color"], hsv.inputs["Color"])
    nt.links.new(hsv.outputs["Color"], mixw.inputs["A"])
    nt.links.new(mixw.outputs["Result"], b.inputs["Base Color"])
    nrm_tex = _img(nt, "rock_normal.png", non_color=True)
    if nrm_tex is not None:
        nt.links.new(m.outputs["Vector"], nrm_tex.inputs["Vector"])
        nrm = nt.nodes.new("ShaderNodeNormalMap")
        nrm.inputs["Strength"].default_value = 0.8
        nt.links.new(nrm_tex.outputs["Color"], nrm.inputs["Color"])
        nt.links.new(nrm.outputs["Normal"], b.inputs["Normal"])
    return mat


def mat_wood_tex():
    mat = bpy.data.materials.new("bmt_wood")
    nt, b = _nodes(mat)
    tex = _img(nt, "wood_diffuse.jpg")
    if tex is None:
        return mat_wood()
    m = _tiled(nt, tex, 1.1)
    dark = nt.nodes.new("ShaderNodeHueSaturation")
    dark.inputs["Value"].default_value = 0.7
    dark.inputs["Saturation"].default_value = 1.1
    nt.links.new(tex.outputs["Color"], dark.inputs["Color"])
    nt.links.new(dark.outputs["Color"], b.inputs["Base Color"])
    rough = _img(nt, "wood_roughness.jpg", non_color=True)
    if rough is not None:
        nt.links.new(m.outputs["Vector"], rough.inputs["Vector"])
        nt.links.new(rough.outputs["Color"], b.inputs["Roughness"])
    bmp = _img(nt, "wood_bump.jpg", non_color=True)
    if bmp is not None:
        nt.links.new(m.outputs["Vector"], bmp.inputs["Vector"])
        bump = nt.nodes.new("ShaderNodeBump")
        bump.inputs["Strength"].default_value = 0.35
        nt.links.new(bmp.outputs["Color"], bump.inputs["Height"])
        nt.links.new(bump.outputs["Normal"], b.inputs["Normal"])
    return mat


def mat_water_tex():
    mat = bpy.data.materials.new("bmt_water")
    nt, b = _nodes(mat)
    b.inputs["Base Color"].default_value = (0.05, 0.45, 0.50, 1)
    b.inputs["Roughness"].default_value = 0.06
    try:
        b.inputs["Coat Weight"].default_value = 1.0
    except KeyError:
        pass
    nrm_tex = _img(nt, "waternormals.jpg", non_color=True)
    if nrm_tex is not None:
        _tiled(nt, nrm_tex, 1.5)
        nrm = nt.nodes.new("ShaderNodeNormalMap")
        nrm.inputs["Strength"].default_value = 0.55
        nt.links.new(nrm_tex.outputs["Color"], nrm.inputs["Color"])
        nt.links.new(nrm.outputs["Normal"], b.inputs["Normal"])
    return mat


def setup_hdri_world(scene, *, strength=1.15, rot_z=195.0):
    world = bpy.data.worlds.new("hdri_world")
    scene.world = world
    world.use_nodes = True
    nt = world.node_tree
    bg = nt.nodes["Background"]
    if os.path.exists(HDRI):
        env = nt.nodes.new("ShaderNodeTexEnvironment")
        env.image = bpy.data.images.load(HDRI, check_existing=True)
        coord = nt.nodes.new("ShaderNodeTexCoord")
        mapping = nt.nodes.new("ShaderNodeMapping")
        mapping.inputs["Rotation"].default_value = (0, 0, math.radians(rot_z))
        nt.links.new(coord.outputs["Generated"], mapping.inputs["Vector"])
        nt.links.new(mapping.outputs["Vector"], env.inputs["Vector"])
        nt.links.new(env.outputs["Color"], bg.inputs["Color"])
    else:
        bg.inputs["Color"].default_value = (0.30, 0.16, 0.12, 1)
    bg.inputs["Strength"].default_value = strength


# ---------------------------------------------------------------------------
# Builders.
# ---------------------------------------------------------------------------


def grid(name, mat, segments=140, size=1.0):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=segments, y_segments=segments, size=size)
    bm.to_mesh(mesh)
    bm.free()
    return mesh_object(name, mesh, mat)


def box(name, size, mat, *, loc=(0, 0, 0), rot=(0, 0, 0), bevel=0.04, sub=0):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1)
    bmesh.ops.scale(bm, vec=size, verts=bm.verts)
    bm.to_mesh(mesh)
    bm.free()
    obj = mesh_object(name, mesh, mat)
    obj.location = loc
    obj.rotation_euler = rot
    if bevel:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 4
    if sub:
        s = obj.modifiers.new("Sub", "SUBSURF")
        s.levels = sub
        s.render_levels = sub
        for p in obj.data.polygons:
            p.use_smooth = True
    return obj


def cyl(name, r1, r2, depth, mat, *, loc=(0, 0, 0), rot=(0, 0, 0), verts=24, scale=(1, 1, 1)):
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=verts, radius1=r1, radius2=r2, depth=depth)
    bm.to_mesh(mesh)
    bm.free()
    obj = mesh_object(name, mesh, mat)
    obj.location = loc
    obj.rotation_euler = rot
    obj.scale = scale
    smooth(obj)
    return obj


def carved_slab(name, mat, mat_inlay, *, loc, rot_z=0.0, star=False):
    """A premium paver: beveled slab + noise-displaced top + optional
    engraved gold star inlay sunk into the surface."""
    obj = box(name, (1.24, 1.0, 0.24), mat, loc=loc, rot=(0, 0, rot_z), bevel=0.055)
    # Surface imperfection.
    mod = obj.modifiers.new("Sub", "SUBSURF")
    mod.subdivision_type = "SIMPLE"
    mod.levels = 3
    mod.render_levels = 4
    tex = bpy.data.textures.new(f"{name}_worn", "CLOUDS")
    tex.noise_scale = 0.35
    disp = obj.modifiers.new("Worn", "DISPLACE")
    disp.texture = tex
    disp.strength = 0.014
    for p in obj.data.polygons:
        p.use_smooth = True
    if star:
        pts_out, pts_in = 8, 0.5
        mesh = bpy.data.meshes.new(f"{name}_star")
        bm = bmesh.new()
        vs = []
        for k in range(pts_out * 2):
            ang = math.pi * k / pts_out
            rr = 0.30 if k % 2 == 0 else 0.30 * pts_in
            vs.append(bm.verts.new((rr * math.cos(ang), rr * math.sin(ang), 0)))
        f = bm.faces.new(vs)
        res = bmesh.ops.extrude_face_region(bm, geom=[f])
        up = [v for v in res["geom"] if isinstance(v, bmesh.types.BMVert)]
        bmesh.ops.translate(bm, verts=up, vec=(0, 0, 0.02))
        bm.to_mesh(mesh)
        bm.free()
        star_o = mesh_object(f"{name}_star", mesh, mat_inlay)
        star_o.location = (loc[0], loc[1], loc[2] + 0.115)
        star_o.rotation_euler = (0, 0, rot_z)
    return obj


def build_palm_v2(loc, h, mats, seed=1):
    """Palm with ringed trunk and ribbed, serrated fronds."""
    import random as _r

    r = _r.Random(seed)
    trunk_mat, leaf_mat = mats
    lean = r.uniform(0.06, 0.16)
    lean_dir = r.uniform(0, 2 * math.pi)
    # Trunk rings.
    n = 10
    top = (loc[0], loc[1], 0)
    for i in range(n):
        t = i / (n - 1)
        seg_r = 0.062 * h * (1 - 0.4 * t)
        cx = loc[0] + math.cos(lean_dir) * lean * h * t * t
        cy = loc[1] + math.sin(lean_dir) * lean * h * t * t
        cz = 0.03 + h * 0.66 * t
        cyl(f"pt_{seed}_{i}", seg_r * (1.12 if i % 2 else 1.0), seg_r * 0.92, h * 0.085,
            trunk_mat, loc=(cx, cy, cz), verts=14)
        top = (cx, cy, cz + h * 0.05)
    # Fronds: rib + leaflets.
    for k in range(10):
        ang = 2 * math.pi * k / 10 + r.uniform(-0.14, 0.14)
        ln = h * r.uniform(0.5, 0.66)
        pitch = r.uniform(0.35, 0.95)
        mesh = bpy.data.meshes.new(f"fr_{seed}_{k}")
        bm = bmesh.new()
        segs = 9
        prev_rib = None
        for i in range(segs + 1):
            t = i / segs
            fx = ln * t
            fz = 0.30 * ln * math.sin(min(1.0, t * 1.4) * math.pi * 0.5) - (0.9 * pitch) * ln * t * t
            rib = bm.verts.new((fx, 0, fz))
            if prev_rib is not None and i > 0:
                # Leaflet pair as thin quads angled downward.
                ll = ln * 0.11 * math.sin(math.pi * min(1, t * 1.1) + 0.001)
                if ll > 0.01:
                    for sgn in (-1, 1):
                        a = bm.verts.new(prev_rib.co)
                        bpt = bm.verts.new(rib.co)
                        c = bm.verts.new((rib.co.x, sgn * ll, rib.co.z - ll * 0.7))
                        d = bm.verts.new((prev_rib.co.x, sgn * ll, prev_rib.co.z - ll * 0.7))
                        bm.faces.new((a, bpt, c, d))
            prev_rib = rib
        bm.to_mesh(mesh)
        bm.free()
        obj = mesh_object(f"fr_{seed}_{k}", mesh, leaf_mat)
        obj.location = top
        obj.rotation_euler = (r.uniform(-0.1, 0.1), r.uniform(-0.35, 0.35), ang)
        smooth(obj)


def build_stable(loc, cloth_mat, mats):
    """The emerald écurie: carved platform with steps, wooden posts, a
    draped canopy with folds, ropes, lanterns, four horse stalls."""
    m_stone_, m_wood_, m_gold_, m_lant = mats
    cx, cy = loc
    # Platform + steps.
    box("st_plat", (4.4, 3.0, 0.35), m_stone_, loc=(cx, cy, 0.17), bevel=0.06)
    box("st_step1", (2.2, 0.55, 0.22), m_stone_, loc=(cx, cy - 1.7, 0.11), bevel=0.05)
    box("st_step2", (1.7, 0.4, 0.11), m_stone_, loc=(cx, cy - 2.1, 0.055), bevel=0.04)
    # Back wall.
    box("st_wall", (4.2, 0.28, 1.5), m_stone_, loc=(cx, cy + 1.25, 1.05), bevel=0.05)
    # Posts (6, carved: slight taper + base + capital).
    posts_x = [-1.9, -0.65, 0.65, 1.9]
    for i, px in enumerate(posts_x):
        cyl(f"st_post_{i}", 0.10, 0.085, 2.1, m_wood_, loc=(cx + px, cy - 1.25, 1.35), verts=12)
        box(f"st_postbase_{i}", (0.26, 0.26, 0.14), m_stone_, loc=(cx + px, cy - 1.25, 0.42), bevel=0.03)
        box(f"st_postcap_{i}", (0.22, 0.22, 0.08), m_gold_, loc=(cx + px, cy - 1.25, 2.22), bevel=0.02)
    # Canopy: subdivided sloped sheet with cloth displacement + scallops.
    mesh = bpy.data.meshes.new("st_canopy")
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=48, y_segments=24, size=1)
    bm.to_mesh(mesh)
    bm.free()
    can = mesh_object("st_canopy", mesh, cloth_mat)
    can.scale = (2.45, 1.75, 1)
    can.location = (cx, cy + 0.05, 2.68)
    can.rotation_euler = (math.radians(14), 0, 0)
    tex = bpy.data.textures.new("st_cloth", "CLOUDS")
    tex.noise_scale = 0.5
    disp = can.modifiers.new("Folds", "DISPLACE")
    disp.texture = tex
    disp.strength = 0.16
    for p in can.data.polygons:
        p.use_smooth = True
    solid = can.modifiers.new("Solid", "SOLIDIFY")
    solid.thickness = 0.05
    # Scalloped front hem: hanging strip.
    for i in range(9):
        hx = cx - 2.1 + 0.52 * i
        cyl(f"st_hem_{i}", 0.13, 0.13, 0.03, cloth_mat,
            loc=(hx, cy - 1.60, 2.30), rot=(math.radians(90), 0, 0), verts=12, scale=(1, 0.5, 1))
    # Ropes to pegs.
    for sgn in (-1, 1):
        curve = bpy.data.curves.new(f"rope_{sgn}", "CURVE")
        curve.dimensions = "3D"
        sp = curve.splines.new("NURBS")
        sp.points.add(2)
        sp.points[0].co = (cx + sgn * 2.35, cy - 1.3, 2.35, 1)
        sp.points[1].co = (cx + sgn * 3.1, cy - 1.7, 1.0, 1)
        sp.points[2].co = (cx + sgn * 3.5, cy - 1.9, 0.05, 1)
        curve.bevel_depth = 0.022
        rope = bpy.data.objects.new(f"rope_{sgn}", curve)
        bpy.context.scene.collection.objects.link(rope)
        rope.data.materials.append(m_wood_)
    # Stalls: 4 wooden dividers + gold floor rings.
    for i in range(5):
        sx = cx - 1.8 + 0.9 * i
        box(f"st_div_{i}", (0.07, 1.4, 0.7), m_wood_, loc=(sx, cy + 0.45, 0.9), bevel=0.02)
    for i in range(4):
        sx = cx - 1.35 + 0.9 * i
        curve = bpy.data.curves.new(f"ring_{i}", "CURVE")
        curve.dimensions = "3D"
        sp = curve.splines.new("NURBS")
        n = 16
        sp.points.add(n - 1)
        for k in range(n):
            a = 2 * math.pi * k / n
            sp.points[k].co = (sx + 0.3 * math.cos(a), cy + 0.45 + 0.3 * math.sin(a), 0.36, 1)
        sp.use_cyclic_u = True
        curve.bevel_depth = 0.03
        ring = bpy.data.objects.new(f"ring_{i}", curve)
        bpy.context.scene.collection.objects.link(ring)
        ring.data.materials.append(m_gold_)
    # Lanterns on the front posts.
    for px in (-1.9, 1.9):
        cyl(f"st_lchain_{px}", 0.012, 0.012, 0.25, m_wood_, loc=(cx + px, cy - 1.45, 2.2))
        o = cyl(f"st_lamp_{px}", 0.09, 0.055, 0.22, m_lant, loc=(cx + px, cy - 1.45, 2.0), verts=8)
    # Banner.
    box("st_banner", (0.05, 0.5, 0.9), cloth_mat, loc=(cx + 2.35, cy - 0.4, 2.6), bevel=0.01)
    cyl("st_bpole", 0.035, 0.03, 3.4, m_wood_, loc=(cx + 2.35, cy - 0.4, 1.7), verts=10)


def build_chest(loc, mats):
    m_wood_, m_gold_ = mats
    cx, cy = loc
    body = box("chest_body", (0.62, 0.42, 0.34), m_wood_, loc=(cx, cy, 0.20), bevel=0.035)
    # Curved lid: cylinder half.
    lid = cyl("chest_lid", 0.21, 0.21, 0.60, m_wood_,
              loc=(cx, cy, 0.38), rot=(0, math.radians(90), 0), verts=20)
    # Bands + lock.
    for dx in (-0.18, 0.18):
        box(f"chest_band_{dx}", (0.07, 0.46, 0.40), m_gold_, loc=(cx + dx, cy, 0.24), bevel=0.012)
        cyl(f"chest_bandtop_{dx}", 0.225, 0.225, 0.07, m_gold_,
            loc=(cx + dx, cy, 0.38), rot=(0, math.radians(90), 0), verts=20)
    box("chest_lock", (0.10, 0.05, 0.13), m_gold_, loc=(cx, cy - 0.235, 0.30), bevel=0.015)


def build_basin(loc, mats):
    m_stone_, m_gold_, m_water_ = mats
    cx, cy = loc
    cyl("basin_rim", 1.08, 1.02, 0.34, m_stone_, loc=(cx, cy, 0.17), verts=36)
    curve = bpy.data.curves.new("basin_goldring", "CURVE")
    curve.dimensions = "3D"
    sp = curve.splines.new("NURBS")
    n = 24
    sp.points.add(n - 1)
    for k in range(n):
        a = 2 * math.pi * k / n
        sp.points[k].co = (cx + 0.99 * math.cos(a), cy + 0.99 * math.sin(a), 0.375, 1)
    sp.use_cyclic_u = True
    curve.bevel_depth = 0.045
    ring = bpy.data.objects.new("basin_goldring", curve)
    bpy.context.scene.collection.objects.link(ring)
    ring.data.materials.append(m_gold_)
    floor_mat = bpy.data.materials.get("bmt_stone") or m_stone_
    cyl("basin_floor", 0.98, 0.98, 0.04, floor_mat, loc=(cx, cy, 0.24), verts=36)
    cyl("basin_water", 0.92, 0.92, 0.04, m_water_, loc=(cx, cy, 0.362), verts=36)
    import random as _rr
    _rb = _rr.Random(9)
    for i in range(7):
        a = 2 * math.pi * i / 7 + _rb.uniform(-0.3, 0.3)
        rr = 1.28 + _rb.uniform(0, 0.2)
        s = _rb.uniform(0.08, 0.16)
        o = cyl(f"basin_stone_{i}", s, s * 0.8, s * 1.2, m_stone_,
                loc=(cx + rr * math.cos(a), cy + rr * math.sin(a), s * 0.4), verts=8)
        o.rotation_euler = (_rb.uniform(0, 0.5), _rb.uniform(0, 0.5), _rb.uniform(0, 3))


def main():
    fast = "--fast" in sys.argv
    scene = reset_scene()
    scene.cycles.samples = 48 if fast else 160

    m_sand = mat_sand_tex()
    m_stone = mat_stone_tex()
    m_wood = mat_wood_tex()
    m_gold = mat_gold()
    m_water = mat_water_tex()
    m_cloth = mat_fabric((0.02, 0.30, 0.10))
    m_leaf = new_material("bm_leaf", (0.02, 0.135, 0.04), rough=0.62,
                          color2=(0.045, 0.22, 0.06), noise_bump=0.2, noise_scale=30)
    m_trunk = mat_stone(base=(0.24, 0.14, 0.07), crack_scale=8.0)
    m_lant = new_material("bm_lant", (0.25, 0.12, 0.03), rough=0.4,
                          emission=(1.0, 0.40, 0.08), emission_strength=18.0)

    # Terrain patch with soft dunes.
    terr = grid("bm_terrain", m_sand, segments=180)
    terr.scale = (9, 9, 1)
    tex = bpy.data.textures.new("bm_dunes", "CLOUDS")
    tex.noise_scale = 0.9
    disp = terr.modifiers.new("D", "DISPLACE")
    disp.texture = tex
    disp.strength = 0.9
    tex2 = bpy.data.textures.new("bm_rip", "CLOUDS")
    tex2.noise_scale = 0.10
    disp2 = terr.modifiers.new("R", "DISPLACE")
    disp2.texture = tex2
    disp2.strength = 0.05
    terr.location = (0, 2, -0.52)
    smooth(terr)

    # Distant dunes close the horizon (the HDRI keeps lighting the sky).
    import random as _rd
    _dr = _rd.Random(3)
    for i in range(6):
        dx = -12 + 5 * i + _dr.uniform(-1, 1)
        dy = 11 + _dr.uniform(0, 5)
        dr_ = _dr.uniform(4, 7)
        o = cyl(f"bgdune_{i}", dr_, dr_ * 0.6, dr_ * 0.8, m_sand, loc=(dx, dy, -0.3), verts=24, scale=(1.6, 1.0, 0.6))

    # The six benchmark objects.
    build_stable((-1.1, 3.1), m_cloth, (m_stone, m_wood, m_gold, m_lant))
    for i, (sx, sy, star) in enumerate([(-1.1, -1.6, False), (0.2, -1.75, True), (1.5, -1.55, False)]):
        carved_slab(f"bm_slab_{i}", m_stone, m_gold, loc=(sx, sy, 0.12),
                    rot_z=math.radians(-8 + 7 * i), star=star)
    build_palm_v2((2.9, 1.4, 0), 3.0, (m_trunk, m_leaf), seed=5)
    build_chest((2.35, -0.4), (m_wood, m_gold))
    build_basin((-2.75, 0.3), (m_stone, m_gold, m_water))

    # The horse, on the middle slab area.
    render_horses.build_horse("emerald")
    for obj in scene.objects:
        if obj.name.startswith(("horse_", "tail_")) or obj.name in (
            "blanket", "saddle", "girth", "brow", "noseband",
        ) or obj.name.startswith(("hoof", "ear", "mane_", "pom", "eye")):
            obj.location = (obj.location.x + 0.15, obj.location.y - 0.3, obj.location.z + 0.02)
            obj.rotation_euler = (obj.rotation_euler.x, obj.rotation_euler.y, obj.rotation_euler.z + math.radians(-24))

    # Lighting: warm key, cool fill, lantern accents already emissive.
    key = bpy.data.lights.new("Key", "SUN")
    key.energy = 2.2
    key.color = (1.0, 0.62, 0.32)
    key.angle = math.radians(3)
    ko = bpy.data.objects.new("Key", key)
    scene.collection.objects.link(ko)
    ko.rotation_euler = (math.radians(90 - 16), 0, math.radians(215))
    fill = bpy.data.lights.new("FillSky", "SUN")
    fill.energy = 0.25
    fill.color = (0.45, 0.62, 0.95)
    fill.angle = math.radians(60)
    fo = bpy.data.objects.new("FillSky", fill)
    scene.collection.objects.link(fo)
    fo.rotation_euler = (math.radians(30), 0, math.radians(20))
    rim = bpy.data.lights.new("Rim", "SUN")
    rim.energy = 0.8
    rim.color = (1.0, 0.80, 0.55)
    rim.angle = math.radians(8)
    ro = bpy.data.objects.new("Rim", rim)
    scene.collection.objects.link(ro)
    ro.rotation_euler = (math.radians(70), 0, math.radians(160))

    # Golden-hour HDRI world: real sky light and reflections.
    setup_hdri_world(scene, strength=1.15, rot_z=195.0)

    setup_camera(scene, loc=(1.4, -7.2, 4.6), look_at=(0, 0.4, 0.9), lens=44)
    out = os.path.abspath("build/art_preview/benchmark.png")
    os.makedirs("build/art_preview", exist_ok=True)
    render(scene, out, res=(720, 900) if fast else (1440, 1800))

    # Grade: teal shadows, gold highlights, vignette.
    from PIL import Image, ImageFilter
    import numpy as np

    im = Image.open(out).convert("RGB")
    arr = np.asarray(im, dtype=np.float32) / 255.0
    luma = arr.mean(axis=2, keepdims=True)
    shadow_tint = np.array([0.90, 1.02, 1.12])[None, None, :]
    high_tint = np.array([1.08, 1.00, 0.88])[None, None, :]
    arr = arr * (shadow_tint + (high_tint - shadow_tint) * luma)
    arr = np.clip(arr * 1.05 - 0.015, 0, 1) ** 0.97
    h, w = arr.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    vr = np.sqrt(((xx - w / 2) / (w * 0.72)) ** 2 + ((yy - h / 2) / (h * 0.72)) ** 2)
    arr *= (1 - 0.32 * np.clip(vr - 0.5, 0, 1))[..., None]
    bright = np.clip(arr - 0.80, 0, 1)
    bloom = np.asarray(
        Image.fromarray((bright * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(10)),
        dtype=np.float32,
    ) / 255.0
    arr = np.clip(arr + bloom * 0.45, 0, 1)
    Image.fromarray((arr * 255).astype(np.uint8)).save(out)
    print("benchmark:", out)


if __name__ == "__main__":
    main()
