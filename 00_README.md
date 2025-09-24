# GAS Lab Analysis Template

This is the **standard analysis folder template of the Laboratory for Hibernation Biology, RIKEN BDR**. It provides a unified structure for reproducible data analysis and collaborative work under Git version control.

これは、**理研BDR 冬眠生物学研究室の標準解析フォルダテンプレート**です。再現性のあるデータ解析とラボ内での解析共有・協働を目的とした統一的な構造を提供します。

*(This file is written in Markdown. You can view it nicely formatted in GitHub, VS Code, or RStudio. In other editors, it is readable as plain text.)*

------------------------------------------------------------------------

**Date:** 2025-08-23\
**Maintainer:** Genshiro A. Sunagawa\
**Contact:** [genshiro.sunagawa\@riken.jp](mailto:genshiro.sunagawa@riken.jp){.email}

------------------------------------------------------------------------

## Folder structure

-   **(root)**
    -   Contains analysis scripts.\
        Scripts are numbered with two digits from 00 to 99 in execution order.\
        Typically, `README.md` (this file) and `01_convert_data.R` are fixed.
    -   Also contains `.gitignore` and project configuration files.
-   **rawdata/**
    -   Raw experimental data as obtained.
    -   **Not tracked by Git** (too large/private).
    -   Structure depends on data acquisition.
-   **data/**
    -   Processed data converted from `rawdata`, used for analysis.
    -   **Ignored by Git until publication.**\
        After publication, finalized datasets can be added to the repository.
    -   Includes `settings.R`, a shared R script with common routines and settings.
-   **output/**
    -   Stores outputs other than figures.
    -   **Not tracked by Git.**
    -   Organized as:\
        `output/<script_name>/<datetime>/...`
-   **figure/**
    -   Stores output figures.
    -   **Not tracked by Git.**
    -   Same structure as **output/**.
-   **log/**
    -   Stores log files.
    -   **Not tracked by Git.**
    -   Same structure as **output/**.
-   **stan/**
    -   Stan model source files (`*.stan`) are tracked.
    -   Compiled artifacts (`*.hpp`, `*.o`, `*.so`, etc.) are **ignored by Git**.

------------------------------------------------------------------------

## Representative scripts

-   `01_convert_data.R` — Convert raw data into analyzable format
-   `nn_fit_model.R` — Fit a Stan model
-   `nn_output_figures.R` — Generate figures from analysis results

------------------------------------------------------------------------

## Notes on Git management

-   **Always commit scripts and configuration files** (`*.R`, `*.stan`, `settings.R`, `.gitignore`).
-   **Do not commit rawdata, large outputs, or logs.**
-   If you need to share data, provide a minimal test dataset or point to the storage location.
-   Use clear commit messages that describe **why** changes were made.

------------------------------------------------------------------------

## How to reproduce an analysis

1.  Obtain the required `rawdata/` from the shared storage (not included in Git).
2.  Run `01_convert_data.R` to generate `data/`.
3.  Run subsequent scripts (`nn_fit_model.R`, `nn_output_figures.R`, etc.) in order.
4.  Outputs will be created under `output/`, `figure/`, and `log/`.

------------------------------------------------------------------------

## Git workflow rules (Lab standard — *trial operation*)

> These rules are currently under **trial operation** in our lab.\
> They may be revised when moving to full-scale operation.

-   **Branching**
    -   Use `main` for stable code
    -   Create `feature/<topic>` branches for new analyses.
    -   Use `hotfix/<issue>` for urgent bug fixes.
-   **Commit messages**
    -   Write clear, short messages in English.
    -   Example:
        -   `Add new Stan model for glucose analysis`
        -   `Fix bug in 01_convert_data.R`
-   **Data policy**
    -   Do not commit `rawdata/` or `data/` (except small test datasets).
    -   Use shared lab storage for large/raw data.
-   **Pull / Merge**
    -   Do not push directly to `main`.
    -   Use Pull Requests or confirm with the team before merging.
-   **Tags**
    -   Tag important milestones (e.g., paper submission).

------------------------------------------------------------------------
