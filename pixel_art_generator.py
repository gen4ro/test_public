"""Generate 128x128 pixel art images with simple symmetry and palettes.

This module exposes a command line interface as well as a Python API for
creating small pixel art images.  The output is a PNG file containing an
image that is 128x128 pixels by default.  The script chooses colours from a
set of retro-inspired palettes and fills a coarse grid, optionally applying
symmetry rules to keep the artwork coherent.
"""
from __future__ import annotations

import argparse
import random
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Sequence, Tuple


# A collection of palettes loosely inspired by 8-bit era consoles.  The
# palettes are intentionally small to give the generated artwork a distinct
# retro look.
PALETTES: Sequence[Sequence[Tuple[int, int, int]]] = (
    ((26, 28, 44), (93, 39, 93), (177, 62, 83), (239, 125, 87), (255, 205, 117)),
    ((7, 48, 66), (231, 111, 81), (244, 162, 97), (233, 196, 106), (42, 157, 143)),
    ((40, 42, 54), (68, 71, 90), (189, 147, 249), (255, 85, 85), (80, 250, 123)),
    ((15, 32, 39), (52, 78, 65), (158, 174, 162), (242, 233, 228), (215, 38, 56)),
    ((30, 30, 30), (70, 70, 70), (120, 120, 120), (200, 200, 200), (250, 250, 250)),
)


@dataclass(frozen=True)
class PixelArtConfig:
    """Configuration for a pixel art render."""

    size: int = 128
    grid_cells: int = 16
    symmetry: str = "vertical"
    palette_index: int | None = None
    background_ratio: float = 0.45

    def __post_init__(self) -> None:  # type: ignore[override]
        if self.size % self.grid_cells != 0:
            raise ValueError("size must be divisible by grid_cells for clean pixels")
        if self.symmetry not in {"none", "vertical", "horizontal", "quadrant"}:
            raise ValueError("symmetry must be one of: none, vertical, horizontal, quadrant")
        if not (0.0 <= self.background_ratio <= 1.0):
            raise ValueError("background_ratio must be between 0.0 and 1.0")
        if self.symmetry in {"vertical", "horizontal", "quadrant"} and self.grid_cells % 2 != 0:
            raise ValueError("grid_cells must be even when using the selected symmetry")


def _choose_palette(rng: random.Random, palette_index: int | None) -> Sequence[Tuple[int, int, int]]:
    if palette_index is None:
        return rng.choice(PALETTES)
    try:
        return PALETTES[palette_index]
    except IndexError as exc:
        raise ValueError(f"Invalid palette_index {palette_index!r}. There are {len(PALETTES)} palettes.") from exc


def _apply_symmetry_row(row: List[Tuple[int, int, int]], symmetry: str) -> List[Tuple[int, int, int]]:
    if symmetry == "none":
        return row
    half = len(row) // 2
    if symmetry == "vertical":
        mirrored = row[:half]
        return mirrored + list(reversed(mirrored))
    if symmetry == "horizontal":
        return row
    if symmetry == "quadrant":
        mirrored = row[:half]
        return mirrored + list(reversed(mirrored))
    return row
def _mirror_grid_horizontally(grid: List[List[Tuple[int, int, int]]]) -> None:
    half = len(grid) // 2
    for y in range(half):
        grid[-(y + 1)] = list(grid[y])


def _determine_background(palette: Sequence[Tuple[int, int, int]]) -> Tuple[int, int, int]:
    # Choose the darkest colour as the background to reduce visual noise.
    return min(palette, key=sum)


def _png_chunk(chunk_type: bytes, data: bytes) -> bytes:
    return (
        struct.pack(">I", len(data))
        + chunk_type
        + data
        + struct.pack(">I", zlib.crc32(chunk_type + data) & 0xFFFFFFFF)
    )


def _write_png(path: Path, width: int, height: int, rows: Sequence[bytes]) -> None:
    header = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    raw = b"".join(b"\x00" + row for row in rows)
    compressed = zlib.compress(raw)

    with path.open("wb") as fh:
        fh.write(header)
        fh.write(_png_chunk(b"IHDR", ihdr))
        fh.write(_png_chunk(b"IDAT", compressed))
        fh.write(_png_chunk(b"IEND", b""))


def generate_pixel_art(
    output_path: Path,
    config: PixelArtConfig | None = None,
    *,
    seed: int | None = None,
) -> Path:
    """Generate a pixel art image and save it to *output_path*.

    Parameters
    ----------
    output_path:
        Location of the PNG file that will be written.
    config:
        Configuration describing how the artwork should be generated.  When not
        provided the default :class:`PixelArtConfig` is used.
    seed:
        Optional random seed for reproducibility.
    """

    cfg = config or PixelArtConfig()
    rng = random.Random(seed)

    palette = list(_choose_palette(rng, cfg.palette_index))
    background_colour = _determine_background(palette)

    cell_size = cfg.size // cfg.grid_cells
    grid: List[List[Tuple[int, int, int]]] = []

    for _ in range(cfg.grid_cells):
        row = []
        for _ in range(cfg.grid_cells // (2 if cfg.symmetry in {"vertical", "quadrant"} else 1)):
            if rng.random() < cfg.background_ratio:
                row.append(background_colour)
            else:
                row.append(rng.choice(palette))
        if cfg.symmetry in {"vertical", "quadrant"}:
            row = _apply_symmetry_row(row, "vertical")
        else:
            row = _apply_symmetry_row(row, cfg.symmetry)
        grid.append(row)

    if cfg.symmetry in {"horizontal", "quadrant"}:
        _mirror_grid_horizontally(grid)
    elif cfg.symmetry == "none":
        pass

    pixel_rows: List[bytes] = []
    for row in grid:
        expanded_row: List[Tuple[int, int, int]] = []
        for colour in row:
            expanded_row.extend([colour] * cell_size)

        row_bytes = bytearray()
        for colour in expanded_row:
            row_bytes.extend(colour)

        for _ in range(cell_size):
            pixel_rows.append(bytes(row_bytes))

    _write_png(output_path, cfg.size, cfg.size, pixel_rows)
    return output_path


def _parse_args(args: Iterable[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate simple 128x128 pixel art images.")
    parser.add_argument("output", type=Path, help="Destination PNG file.")
    parser.add_argument("--seed", type=int, default=None, help="Optional random seed for reproducibility.")
    parser.add_argument(
        "--palette",
        type=int,
        default=None,
        help=f"Palette index to use (0 to {len(PALETTES) - 1}).  Random when omitted.",
    )
    parser.add_argument(
        "--symmetry",
        choices=["none", "vertical", "horizontal", "quadrant"],
        default="vertical",
        help="Symmetry mode applied to the coarse grid.",
    )
    parser.add_argument(
        "--grid-cells",
        type=int,
        default=16,
        help="Number of cells across and down in the coarse grid (must divide 128).",
    )
    parser.add_argument(
        "--background-ratio",
        type=float,
        default=0.45,
        help="Probability of using the background colour for each cell.",
    )
    return parser.parse_args(args)


def main(cli_args: Iterable[str] | None = None) -> Path:
    args = _parse_args(cli_args)
    config = PixelArtConfig(
        size=128,
        grid_cells=args.grid_cells,
        symmetry=args.symmetry,
        palette_index=args.palette,
        background_ratio=args.background_ratio,
    )
    return generate_pixel_art(args.output, config=config, seed=args.seed)


if __name__ == "__main__":
    main()
