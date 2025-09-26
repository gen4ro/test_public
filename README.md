# GAS Lab Metabolic Cage Data Template

This repository demonstrates how the GAS Lab prepares metabolic cage
experiments for public release.  It includes a single data conversion
pipeline plus a small bundle of example data that illustrate the expected
inputs and outputs.

The goal is to provide a minimal but reproducible template that other
projects can fork when publishing their own experiment-ready datasets.

---

## Repository layout

```
├── 01_convert_data.R   # Main R script that tidies raw XDR exports
├── data/
│   ├── mice.csv        # Example mouse metadata (output of the pipeline)
│   ├── genotypes.txt   # Genotype allow-list used downstream
│   ├── settings.R      # Shared configuration imported by analysis scripts
│   └── ts.csv          # (Generated) long-format time-series produced by the script
├── rawdata/            # (Not tracked) folders of `*.xdr.RData` files per experiment
├── LICENSE             # MIT License for the code
└── README.md           # Project overview (this file)
```

Only the `data/` directory is version-controlled.  Real projects keep the
large `rawdata/` directory out of Git by adding it to `.gitignore`.

---

## Core workflow: `01_convert_data.R`

The heart of the template is `01_convert_data.R`.  It performs three jobs:

1. **Load experiment settings** defined in `data/settings.R` (number of
   Stan chains, figure/report toggles, colour palettes, etc.).
2. **Read each `*.xdr.RData` file** found under `rawdata/<experiment>/` and
   collect the `all.data` object emitted by the XDR recording software.
3. **Write tidy CSVs**:
   - `data/mice.csv` – one row per mouse with identifying metadata and
     experiment conditions.
   - `data/ts.csv` – long-format VO2/RQ/VCO2 traces at 6-minute cadence,
     clipped to the first three days and augmented with a baseline-adjusted
     VO2 column.
   - `data/genotypes.txt` – list of genotype labels that downstream analysis
     scripts should keep.

Because the script is idempotent you can re-run it whenever new raw data are
added.  It recreates the CSVs from scratch each time.

### Generating pixel art

The repository includes `pixel_art_generator.py`, a small Python utility that
produces 128×128 PNG pixel art using randomly selected retro palettes.  Run it
from the repository root as follows:

````bash
python pixel_art_generator.py output.png --seed 123
````

Additional options can be listed with `--help`, allowing you to customise the
symmetry, palette, and density of the artwork.

The script relies on a small number of widely used R packages:

- [`tidyverse`](https://www.tidyverse.org/) for tibble manipulation and CSV IO.
- [`magrittr`](https://magrittr.tidyverse.org/) for the `%<>%` pipe used during
the time-series assembly.

Install them once per machine with:

```r
install.packages(c("tidyverse", "magrittr"))
```

---

## Working with the template

1. **Place raw data**: copy each experiment folder containing
   `*.xdr.RData` files into `rawdata/`.  The parent folder name becomes part of
   the genotype label (e.g. `QB_hetero`).
2. **Adjust configuration**: update `data/settings.R` to reflect the figures,
   colour schemes, or downstream modelling options you need.
3. **Run the converter**: from the repository root start an R session and run:

   ```r
   source("01_convert_data.R")
   ```

   The script produces fresh CSV outputs in `data/`.

4. **Continue the analysis**: load `data/mice.csv` and `data/ts.csv` in your
   notebooks or Stan workflows.  These tidy tables are suitable for ggplot,
   lme4, brms, CmdStanR, or any other downstream toolkit.

---

## What to learn next

To contribute productively you should be comfortable with:

- **Tidy data wrangling** – review the tidyverse `dplyr`, `tidyr`, and
  `readr` vignettes.
- **Time-series summarisation** – note how the script limits traces to three
  days and adds baseline-adjusted VO2.  Extending these transforms is a common
  task.
- **Stan/ Bayesian workflows** – many GAS Lab projects feed the tidy outputs
  into hierarchical Stan models.  Check out `CmdStanR` or `rstan` tutorials if
  you plan to work on modelling code.
- **Versioned data releases** – practice writing reproducible READMEs and
  changelogs so future collaborators understand how your dataset was created.

---

## Maintainer

- **Genshiro A. Sunagawa** — genshiro.sunagawa@riken.jp

Please cite the associated publication if you use this template in your own
work.  The code is released under the MIT License; figures and manuscripts
should retain their original CC BY 4.0 terms.
