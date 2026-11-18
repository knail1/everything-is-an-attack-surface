#!/usr/bin/env python3
"""
Render poisoned_doc.txt into poisoned_onboarding.png — a clean, high-contrast
"screenshot" of an onboarding doc with the hidden agent instruction rendered as
plain text. Large legible mono + a bundled font => tesseract reads it identically
every run (the determinism the live demo depends on). Run once; commit the PNG.

    python author_image.py            # writes poisoned_onboarding.png
"""
import os

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
FONT_CANDIDATES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
    "/Library/Fonts/Menlo.ttc",
    "/System/Library/Fonts/Menlo.ttc",
]


def load_font(size):
    for p in FONT_CANDIDATES:
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()


def main():
    text = open(os.path.join(HERE, "poisoned_doc.txt")).read().rstrip("\n")
    lines = text.split("\n")
    fs, pad, lh = 26, 48, 40
    font = load_font(fs)
    # Size the canvas to the WIDEST line so nothing is clipped — OCR needs the whole
    # command, and a clipped quote breaks the payload.
    probe = ImageDraw.Draw(Image.new("RGB", (10, 10)))
    max_w = max(probe.textlength(line, font=font) for line in lines)
    width = int(max_w) + pad * 2
    height = pad * 2 + lh * len(lines)
    img = Image.new("RGB", (width, height), "white")
    d = ImageDraw.Draw(img)
    for i, line in enumerate(lines):
        d.text((pad, pad + i * lh), line, fill="black", font=font)
    out = os.path.join(HERE, "poisoned_onboarding.png")
    img.save(out)
    print("wrote", out, img.size)


if __name__ == "__main__":
    main()
