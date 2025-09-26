# GAS Lab Public Repo Template

This repository provides example materials and analysis code shared publicly by  
the Laboratory for Hibernation Biology (GAS Lab), RIKEN BDR.  
It serves as a template for structuring, documenting, and releasing research code.

------------------------------------------------------------------------

**Date:** 2025-09-25  
**Maintainer:** Genshiro A. Sunagawa  
**Contact:** genshiro.sunagawa@riken.jp

------------------------------------------------------------------------

## Purpose

Provide a clean, reproducible template for sharing code and analysis used in publications.  
Researchers can fork this repository as a starting point for their own public releases.

------------------------------------------------------------------------

## Folder Structure

- **(root)/**
  - `README.md` — detailed project description (can be used as manuscript-specific README)  
  - `mogemoge/` — example folder for scripts or analysis pipelines  
  - `.gitignore` — excludes temporary or large files from version control  
  - `LICENSE` — license information for this repository  

------------------------------------------------------------------------

## Usage

1. Clone the repository:
    ````bash
    git clone https://github.com/USERNAME/REPOSITORY.git
    ````
2. Check dependencies (see individual script headers or requirements files).
3. Run scripts as described in `README.md`.

### Generating pixel art

The repository includes `pixel_art_generator.py`, a small Python utility that
produces 128×128 PNG pixel art using randomly selected retro palettes.  Run it
from the repository root as follows:

````bash
python pixel_art_generator.py output.png --seed 123
````

Additional options can be listed with `--help`, allowing you to customise the
symmetry, palette, and density of the artwork.

------------------------------------------------------------------------

## Notes

- Please cite the associated publication when using this code.  
- Figures and text in associated manuscripts: **CC BY 4.0**  
- Code in this repository: **MIT License**  

------------------------------------------------------------------------

## License

The source code is released under the terms of the MIT License (see [LICENSE](LICENSE)).  
Associated manuscripts and figures are distributed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).

------------------------------------------------------------------------

## Version History

- **v1.0 (2025-09-25)** — Initial public release  
