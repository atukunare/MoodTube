from __future__ import annotations

from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "marketing" / "google-ads"
OUT.mkdir(parents=True, exist_ok=True)

HOME = ROOT / "marketing" / "06-home-dark.png"
DIAL = ROOT / "marketing" / "07-mooddial-dark.png"
ICON = ROOT / "icon" / "moodtune_store_icon_512.png"


FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Avenir Next.ttc",
    "/System/Library/Fonts/Supplemental/Arial.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
]


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    for path in FONT_CANDIDATES:
        if Path(path).exists():
            try:
                index = 2 if bold and path.endswith(".ttc") else 0
                return ImageFont.truetype(path, size=size, index=index)
            except OSError:
                continue
    return ImageFont.load_default()


def gradient(size: tuple[int, int]) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size, "#090913")
    px = img.load()
    stops = [
        (0.00, (9, 9, 19)),
        (0.25, (24, 29, 74)),
        (0.52, (55, 34, 95)),
        (0.74, (144, 51, 116)),
        (1.00, (255, 138, 86)),
    ]
    for y in range(h):
        for x in range(w):
            t = (x / max(1, w - 1) * 0.68) + (y / max(1, h - 1) * 0.32)
            for i in range(len(stops) - 1):
                if stops[i][0] <= t <= stops[i + 1][0]:
                    a, ca = stops[i]
                    b, cb = stops[i + 1]
                    u = (t - a) / (b - a)
                    col = tuple(int(ca[j] * (1 - u) + cb[j] * u) for j in range(3))
                    px[x, y] = col
                    break
    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((-w * 0.16, -h * 0.32, w * 0.55, h * 0.58), fill=(91, 140, 255, 135))
    gd.ellipse((w * 0.45, -h * 0.24, w * 1.18, h * 0.72), fill=(255, 94, 138, 110))
    gd.ellipse((w * 0.60, h * 0.36, w * 1.18, h * 1.12), fill=(255, 138, 86, 85))
    glow = glow.filter(ImageFilter.GaussianBlur(int(min(w, h) * 0.11)))
    return Image.alpha_composite(img.convert("RGBA"), glow)


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def crop_phone(path: Path, target_h: int) -> Image.Image:
    src = Image.open(path).convert("RGBA")
    w, h = src.size
    scale = target_h / h
    target_w = int(w * scale)
    shot = src.resize((target_w, target_h), Image.Resampling.LANCZOS)
    pad = max(10, int(target_w * 0.035))
    frame = Image.new("RGBA", (target_w + pad * 2, target_h + pad * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(frame)
    shadow = Image.new("RGBA", frame.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((pad - 2, pad + 12, pad + target_w + 2, pad + target_h + 18), radius=int(target_w * 0.12), fill=(0, 0, 0, 160))
    shadow = shadow.filter(ImageFilter.GaussianBlur(max(12, pad * 2)))
    frame.alpha_composite(shadow)
    draw.rounded_rectangle((pad - 6, pad - 6, pad + target_w + 6, pad + target_h + 6), radius=int(target_w * 0.13), fill=(16, 16, 27), outline=(255, 255, 255, 80), width=max(2, pad // 4))
    mask = rounded_mask((target_w, target_h), int(target_w * 0.10))
    frame.paste(shot, (pad, pad), mask)
    return frame


def draw_text(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, size: int, fill: str | tuple[int, int, int, int] = "white", bold: bool = False, max_width: int | None = None, line_gap: int = 8) -> int:
    f = font(size, bold=bold)
    x, y = xy
    lines = text.splitlines() or [text]
    if max_width:
        words = text.replace("\n", " ").split()
        lines = []
        line = ""
        for word in words:
            trial = f"{line} {word}".strip()
            if draw.textbbox((0, 0), trial, font=f)[2] <= max_width or not line:
                line = trial
            else:
                lines.append(line)
                line = word
        if line:
            lines.append(line)
    for line in lines:
        draw.text((x, y), line, font=f, fill=fill)
        y += size + line_gap
    return y


def badge(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, size: int = 24) -> None:
    f = font(size, bold=True)
    x, y = xy
    bbox = draw.textbbox((0, 0), text, font=f)
    pad_x, pad_y = 22, 12
    rect = (x, y, x + bbox[2] + pad_x * 2, y + bbox[3] + pad_y * 2)
    draw.rounded_rectangle(rect, radius=999, fill=(255, 255, 255, 238), outline=(255, 255, 255, 255), width=1)
    draw.text((x + pad_x, y + pad_y - 2), text, font=f, fill=(28, 25, 47, 255))


def paste_icon(canvas: Image.Image, xy: tuple[int, int], size: int) -> None:
    icon = Image.open(ICON).convert("RGBA").resize((size, size), Image.Resampling.LANCZOS)
    canvas.alpha_composite(icon, xy)


def save_rgb(img: Image.Image, path: Path) -> None:
    img.convert("RGB").save(path, quality=95, optimize=True)


def landscape() -> None:
    img = gradient((1200, 628))
    draw = ImageDraw.Draw(img)
    phone = crop_phone(HOME, 560)
    img.alpha_composite(phone, (780, 44))
    paste_icon(img, (74, 72), 76)
    draw_text(draw, (166, 84), "MoodTube", 34, bold=True)
    y = draw_text(draw, (74, 174), "Music for your exact mood", 66, bold=True, max_width=650, line_gap=10)
    y = draw_text(draw, (78, y + 12), "Spin the dial and discover long playlists for focus, sleep, workouts, and late nights.", 29, fill=(235, 232, 255, 230), max_width=610, line_gap=8)
    badge(draw, (78, y + 28), "Free on Google Play", 25)
    badge(draw, (346, y + 28), "No music downloads", 25)
    save_rgb(img, OUT / "moodtube-google-display-1200x628.png")


def square() -> None:
    img = gradient((1200, 1200))
    draw = ImageDraw.Draw(img)
    phone = crop_phone(DIAL, 650)
    img.alpha_composite(phone, (462, 108))
    paste_icon(img, (96, 104), 96)
    draw_text(draw, (210, 126), "MoodTube", 42, bold=True)
    y = draw_text(draw, (96, 804), "Pick a mood.\nPress play.", 78, bold=True, line_gap=6)
    y = draw_text(draw, (100, y + 18), "Personalized long-play music discovery powered by your feeling.", 32, fill=(241, 238, 255, 230), max_width=850, line_gap=8)
    badge(draw, (100, y + 34), "Focus", 28)
    badge(draw, (224, y + 34), "Sleep", 28)
    badge(draw, (342, y + 34), "Workout", 28)
    badge(draw, (506, y + 34), "Late Night", 28)
    save_rgb(img, OUT / "moodtube-google-square-1200x1200.png")


def portrait() -> None:
    img = gradient((960, 1200))
    draw = ImageDraw.Draw(img)
    phone = crop_phone(HOME, 690)
    img.alpha_composite(phone, (560, 454))
    paste_icon(img, (74, 82), 82)
    draw_text(draw, (174, 102), "MoodTube", 36, bold=True)
    y = draw_text(draw, (72, 228), "Your mood has a soundtrack", 64, bold=True, max_width=610, line_gap=8)
    y = draw_text(draw, (76, y + 18), "Find the right YouTube playlist for how you feel right now.", 30, fill=(239, 236, 255, 232), max_width=560, line_gap=8)
    badge(draw, (76, y + 34), "Mood dial", 25)
    badge(draw, (250, y + 34), "Smart picks", 25)
    badge(draw, (76, y + 94), "Save favorites", 25)
    save_rgb(img, OUT / "moodtube-google-portrait-960x1200.png")


if __name__ == "__main__":
    landscape()
    square()
    portrait()
    print(f"Saved ads to {OUT}")
