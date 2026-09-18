from pathlib import Path

from PIL import Image, ImageOps


RUN_DIR = Path(__file__).resolve().parent
SOURCE_DIR = RUN_DIR / "frames-v3b" / "running-right"
OUTPUT = RUN_DIR / "decoded" / "running-right.png"


def frame(index: int) -> Image.Image:
    return Image.open(SOURCE_DIR / f"{index:02d}.png").convert("RGBA")


def mirror_lower_body(image: Image.Image, split_y: int = 108) -> Image.Image:
    """Swap the planted leg while preserving Eric's right-facing upper body."""
    width, height = image.size
    result = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    result.alpha_composite(image.crop((0, 0, width, split_y)), (0, 0))
    lower = image.crop((0, split_y, width, height))
    result.alpha_composite(ImageOps.mirror(lower), (0, split_y))
    return result


def main() -> None:
    # The generated source supplies the same Eric identity and several upper-body
    # phases. The lower-body mirror creates the missing opposite-foot contacts.
    cycle = [
        frame(0),                         # contact A: right boot forward
        frame(1),                         # passing A: rear boot lifted
        mirror_lower_body(frame(3)),     # contact B: feet swapped
        mirror_lower_body(frame(2)),     # passing B: opposite knee
        frame(7),                         # contact A variation
        frame(5),                         # passing A variation
        mirror_lower_body(frame(4)),     # contact B variation
        mirror_lower_body(frame(6)),     # passing B variation
    ]
    strip = Image.new("RGBA", (192 * len(cycle), 208), (0, 0, 0, 0))
    for index, image in enumerate(cycle):
        strip.alpha_composite(image, (index * 192, 0))
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    strip.save(OUTPUT)
    print({"output": str(OUTPUT), "frames": len(cycle), "split_y": 108})


if __name__ == "__main__":
    main()
