"""Shared Blender helpers for the IqraQuest 3D asset pipeline.

Everything renders with Cycles, one warm low sun + dusk sky, and a fixed
high three-quarter camera so every asset shares the same perspective and
light — the consistency rule of the style guide.
"""

from __future__ import annotations

import math

import bpy

# ---------------------------------------------------------------------------
# Palette (style guide): emerald, night blue, warm sand, stone brown,
# controlled gold, oasis turquoise, purple accent, golden ochre.
# ---------------------------------------------------------------------------
TEAM_COLORS = {
    "emerald": (0.05, 0.38, 0.16),
    "saphir": (0.06, 0.14, 0.52),
    "grenat": (0.42, 0.07, 0.34),
    "safran": (0.72, 0.38, 0.05),
}
GOLD = (0.85, 0.55, 0.14)
SAND = (0.75, 0.52, 0.28)
STONE = (0.62, 0.48, 0.32)
IVORY = (0.82, 0.72, 0.55)
WATER = (0.02, 0.35, 0.42)


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 96
    scene.cycles.use_denoising = True
    try:
        scene.cycles.denoiser = "OPENIMAGEDENOISE"
    except Exception:
        pass
    scene.view_settings.view_transform = "Filmic"
    scene.view_settings.look = "High Contrast"
    scene.view_settings.exposure = -0.45
    return scene


def new_material(name, color, *, rough=0.5, metal=0.0, coat=0.0, emission=None,
                 emission_strength=0.0, noise_bump=0.0, noise_scale=8.0,
                 color2=None):
    """A Principled material; optional procedural noise bump and a second
    color blended by large noise for organic variation."""
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = nt.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    try:
        bsdf.inputs["Specular IOR Level"].default_value = 0.18
    except KeyError:
        pass
    try:
        bsdf.inputs["Coat Weight"].default_value = coat
    except KeyError:
        pass
    if emission is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1)
        bsdf.inputs["Emission Strength"].default_value = emission_strength

    if color2 is not None:
        noise = nt.nodes.new("ShaderNodeTexNoise")
        noise.inputs["Scale"].default_value = 2.2
        ramp = nt.nodes.new("ShaderNodeValToRGB")
        ramp.color_ramp.elements[0].color = (*color, 1)
        ramp.color_ramp.elements[1].color = (*color2, 1)
        nt.links.new(noise.outputs["Fac"], ramp.inputs["Fac"])
        nt.links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])

    if noise_bump > 0:
        noise = nt.nodes.new("ShaderNodeTexNoise")
        noise.inputs["Scale"].default_value = noise_scale
        noise.inputs["Detail"].default_value = 6.0
        bump = nt.nodes.new("ShaderNodeBump")
        bump.inputs["Strength"].default_value = noise_bump
        nt.links.new(noise.outputs["Fac"], bump.inputs["Height"])
        nt.links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    return mat


def setup_light_and_sky(scene, *, sun_elev=14.0, sun_azim=200.0, sun_power=3.2):
    """Golden-hour: one warm sun + Nishita dusk sky for ambience."""
    world = bpy.data.worlds.new("World")
    scene.world = world
    world.use_nodes = True
    nt = world.node_tree
    bg = nt.nodes["Background"]
    sky = nt.nodes.new("ShaderNodeTexSky")
    try:
        sky.sky_type = "NISHITA"
    except Exception:
        pass
    try:
        sky.sun_elevation = math.radians(3.5)
        sky.sun_rotation = math.radians(sun_azim)
        sky.sun_intensity = 0.3
        sky.dust_density = 9.0
    except Exception:
        pass
    nt.links.new(sky.outputs["Color"], bg.inputs["Color"])
    bg.inputs["Strength"].default_value = 1.1

    sun = bpy.data.lights.new("Sun", "SUN")
    sun.energy = sun_power
    sun.color = (1.0, 0.72, 0.45)
    sun.angle = math.radians(4)
    sun_obj = bpy.data.objects.new("Sun", sun)
    scene.collection.objects.link(sun_obj)
    # Point the sun: low elevation, from behind-left of the board.
    sun_obj.rotation_euler = (
        math.radians(90 - sun_elev),
        0,
        math.radians(sun_azim),
    )
    # A soft warm fill from the camera side so shadows stay readable.
    fill = bpy.data.lights.new("Fill", "SUN")
    fill.energy = 0.32
    fill.color = (0.75, 0.82, 1.0)
    fill.angle = math.radians(40)
    fill_obj = bpy.data.objects.new("Fill", fill)
    scene.collection.objects.link(fill_obj)
    fill_obj.rotation_euler = (math.radians(35), 0, math.radians(15))
    return sun_obj


def setup_camera(scene, *, loc=(0, -10.5, 9.2), look_at=(0, 0.9, 0.0), lens=32):
    cam_data = bpy.data.cameras.new("Cam")
    cam_data.lens = lens
    cam = bpy.data.objects.new("Cam", cam_data)
    scene.collection.objects.link(cam)
    cam.location = loc
    # Aim at the look_at point.
    from mathutils import Vector

    direction = Vector(look_at) - Vector(loc)
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    return cam


def mesh_object(name, mesh, mat=None, col=None):
    obj = bpy.data.objects.new(name, mesh)
    (col or bpy.context.scene.collection).objects.link(obj)
    if mat is not None:
        obj.data.materials.append(mat)
    return obj


def smooth(obj, subsurf=0):
    if subsurf:
        mod = obj.modifiers.new("Subsurf", "SUBSURF")
        mod.levels = subsurf
        mod.render_levels = subsurf
    for p in obj.data.polygons:
        p.use_smooth = True


def render(scene, path, *, res=(1170, 2340), samples=None, transparent=False):
    scene.render.resolution_x, scene.render.resolution_y = res
    scene.render.filepath = path
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = transparent
    if samples:
        scene.cycles.samples = samples
    bpy.ops.render.render(write_still=True)
