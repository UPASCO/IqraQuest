#!/usr/bin/env python3
"""App Store validation rejects app icons that carry an alpha channel.

The Flutter test renderer (tool/app_icon_renderer_test.dart) can only
emit RGBA PNGs, so this converts every icon in the iOS appiconset to
straight RGB. The artwork is fully opaque, so this is lossless.

Run after regenerating the icons:
    flutter test tool/app_icon_renderer_test.dart
    python3 tool/strip_icon_alpha.py
"""
import pathlib
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is required: pip install pillow")

APPICONSET = pathlib.Path(__file__).resolve().parent.parent / (
    "ios/Runner/Assets.xcassets/AppIcon.appiconset"
)

converted = 0
for png in sorted(APPICONSET.glob("*.png")):
    with Image.open(png) as im:
        if im.mode == "RGB":
            continue
        im.convert("RGB").save(png, optimize=True)
        converted += 1
    print(f"  RGB  {png.name}")

print(f"{converted} icon(s) converted to RGB in {APPICONSET}")
