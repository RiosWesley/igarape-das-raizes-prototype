from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageOps


SOURCE_FRAME_COUNT = 6
ATLAS_FRAME_COUNT = 8
CELL_WIDTH = 192
CELL_HEIGHT = 208
TARGET_BASELINE = 203
TARGET_MAX_HEIGHT = 198


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("a running frame has no visible pixels")
    return bbox


def remove_small_components(image: Image.Image, minimum_area: int = 80) -> Image.Image:
    """Keep the connected actor and discard pixels bleeding in from neighboring frames."""
    rgba = image.copy().convert("RGBA")
    alpha = bytearray(rgba.getchannel("A").tobytes())
    width, height = rgba.size
    visited = bytearray(width * height)
    components: list[list[int]] = []
    for start in range(width * height):
        if visited[start] or alpha[start] == 0:
            continue
        stack = [start]
        visited[start] = 1
        component: list[int] = []
        while stack:
            index = stack.pop()
            component.append(index)
            x = index % width
            y = index // width
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    if dx == 0 and dy == 0:
                        continue
                    nx = x + dx
                    ny = y + dy
                    if nx < 0 or nx >= width or ny < 0 or ny >= height:
                        continue
                    neighbor = ny * width + nx
                    if not visited[neighbor] and alpha[neighbor] > 0:
                        visited[neighbor] = 1
                        stack.append(neighbor)
        components.append(component)

    if components:
        main_component = max(components, key=len)
        main_pixels = set(main_component)
        for component in components:
            if component is main_component:
                continue
            for index in component:
                if index not in main_pixels:
                    alpha[index] = 0
    rgba.putalpha(Image.frombytes("L", (width, height), bytes(alpha)))
    return rgba


def source_frames(source: Image.Image) -> list[tuple[Image.Image, int, tuple[int, int, int, int]]]:
    frames: list[tuple[Image.Image, int, tuple[int, int, int, int]]] = []
    for index in range(SOURCE_FRAME_COUNT):
        left = round(index * source.width / SOURCE_FRAME_COUNT)
        right = round((index + 1) * source.width / SOURCE_FRAME_COUNT)
        frame = remove_small_components(source.crop((left, 0, right, source.height)))
        frames.append((frame, right - left, alpha_bbox(frame)))
    return frames


def normalize_frames(source: Image.Image) -> list[Image.Image]:
    raw_frames = source_frames(source)
    max_height = max(bbox[3] - bbox[1] for _, _, bbox in raw_frames)
    scale = TARGET_MAX_HEIGHT / float(max_height)
    normalized: list[Image.Image] = []
    for frame, slot_width, bbox in raw_frames:
        left, top, right, bottom = bbox
        visible = frame.crop(bbox)
        width = max(1, round(visible.width * scale))
        height = max(1, round(visible.height * scale))
        visible = visible.resize((width, height), Image.Resampling.NEAREST)

        cell = Image.new("RGBA", (CELL_WIDTH, CELL_HEIGHT), (0, 0, 0, 0))
        source_slot_center = slot_width * 0.5
        destination_left = round(CELL_WIDTH * 0.5 + (left - source_slot_center) * scale)
        destination_top = TARGET_BASELINE - height
        cell.alpha_composite(visible, (destination_left, destination_top))
        normalized.append(cell)
    return normalized


def write_row(frames: list[Image.Image], output_dir: Path, mirror: bool) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    row = [ImageOps.mirror(frame) if mirror else frame for frame in frames]
    # The Codex atlas keeps 8 cells per row. The game uses the six supplied
    # cells; the last two are harmless repeats so the atlas stays rectangular.
    row.extend([row[0].copy(), row[1].copy()])
    for index, frame in enumerate(row):
        frame.save(output_dir / f"{index:02d}.png")

    strip = Image.new("RGBA", (CELL_WIDTH * ATLAS_FRAME_COUNT, CELL_HEIGHT), (0, 0, 0, 0))
    for index, frame in enumerate(row):
        strip.alpha_composite(frame, (index * CELL_WIDTH, 0))
    strip.save(output_dir.parent.parent / ("decoded-running-left-user.png" if mirror else "decoded-running-right-user.png"))


def main() -> None:
    parser = argparse.ArgumentParser(description="Normalize a user-provided six-frame running strip into the Eric atlas contract.")
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--frames-output", required=True, type=Path)
    args = parser.parse_args()

    with Image.open(args.source) as image:
        normalized = normalize_frames(image.convert("RGBA"))
    write_row(normalized, args.frames_output / "running-right", mirror=False)
    write_row(normalized, args.frames_output / "running-left", mirror=True)
    print({
        "source": str(args.source.resolve()),
        "source_frames": SOURCE_FRAME_COUNT,
        "atlas_cells": ATLAS_FRAME_COUNT,
        "cell": [CELL_WIDTH, CELL_HEIGHT],
        "baseline": TARGET_BASELINE,
        "output": str(args.frames_output.resolve()),
    })


if __name__ == "__main__":
    main()
