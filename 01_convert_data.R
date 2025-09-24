# convert_data.R
#
# Purpose
#   Convert raw XDR-derived RData files in ./rawdata/* into two tidy CSVs:
#     - data/mice.csv : one row per mouse with experimental metadata
#     - data/ts.csv   : long-format time series (≤ first 3 days) per mouse
#
# Inputs
#   - ./rawdata/<dir>/*.xdr.RData      (each contains an object `all.data`)
#   - data/settings.R                  (project-level settings; sourced at start)
#
# Outputs
#   - data/mice.csv                    (mouse-level metadata table)
#   - data/ts.csv                      (VO2/RQ/VCO2 at 6-min cadence, clipped at 3 days)
#   - data/genotypes.txt               (whitelist used downstream)
#
# Assumptions
#   - Each RData file, when loaded, provides `all.data` with:
#       all.data$exp.info$mouse.info   (list-like; includes id, strain, birthday, etc.)
#       all.data$final.df              (data.frame with datetime, VO2, VCO2, RQ)
#   - The raw data is sampled every 6 minutes.
#   - Genotype label is derived from parent folder name (e.g., QC/QB/QT/...) and
#     strain patterns, collapsed into "hetero" vs "homo" (heterozygous/homozygous).
#
# Version History
#   2024-10-21  First release — GAS (genshiro.sunagawa@riken.jp)
#   2025-02-21  Include homozygous mice in the filter/labels — GAS
#
# Contact
#   GAS — genshiro.sunagawa@riken.jp
#
# ------------------------------------------------------------------------------

source(file.path("data", "settings.R"))
datetime <- format(Sys.time(), "%Y%m%d%H%M%S")
process_name <- "01_convert_data"

library(tidyverse)
library(magrittr)

# Ensure output directory exists (idempotent)
dir.create(file.path("data"), showWarnings = FALSE, recursive = TRUE)

# ---------------------------------------------------------------------------
# Load all XDR RData files and build:
#   - xdr_dat : named list of `all.data` objects keyed by mouse id
#   - mice_df : mouse-level metadata table (one row per mouse)
# ---------------------------------------------------------------------------
xdr_dat <- list()
mice_df <- tibble()

for (dr in dir("rawdata")) {
  base_folder <- file.path("rawdata", dr)
  # Match all files in the folder; adjust pattern if you need stricter matching
  filenames <- list.files(base_folder, sprintf("xdr$"))

  for (fn in filenames) {
    # Each file defines `all.data`
    load(file.path(base_folder, fn))

    # Keep a copy keyed by mouse id for later time-series assembly
    xdr_dat[[all.data$exp.info$mouse.info$id]] <- all.data

    # Extract and normalize mouse-level metadata
    record <- tibble(
      all.data$exp.info$mouse.info,
      TA = all.data$exp.info$TA,
      exp_id = all.data$exp.info$exp.name,
      start_datetime = as.character(all.data$exp.info$start.dt),
      end_datetime   = as.character(all.data$exp.info$end.dt)
    ) %>%
      select(-pos, -dsi, -ends_with("exists"), -survival) %>%
      rename(
        birthdate = birthday,
        start_bw  = start.bw,
        end_bw    = end.bw
      ) %>%
      mutate(birthdate = ymd(birthdate)) %>%
      mutate(
        # Genotype label = <parent_folder>_(hetero|homo)
        # Heterozygosity inferred from strain string patterns
        genotype = sprintf(
          "%s_%s",
          dr,
          ifelse(
            str_detect(strain, pattern = "(\\+\\/-|cre\\/\\+|cre-delta-pA\\/\\+)"),
            "hetero",
            "homo"
          )
        )
      )

    mice_df <- bind_rows(mice_df, record)
  }
}

# ---------------------------------------------------------------------------
# Build long-format time-series table (6-min resolution) from xdr_dat
# Keep only the first 3 days (≤ 4320 minutes)
# ---------------------------------------------------------------------------
ts_df <- tibble()

for (i in seq(mice_df$id)) {
  mid <- mice_df$id[i]
  ts_length <- length(xdr_dat[[mid]]$final.df$VO2)

  temp_ts_df <- tibble(
    id       = mid,
    genotype = mice_df$genotype[i],
    time     = seq(0, ts_length - 1) * 6,  # minutes since start (6-min cadence)
    datetime = xdr_dat[[mid]]$final.df$datetime,
    VO2      = xdr_dat[[mid]]$final.df$VO2,
    RQ       = xdr_dat[[mid]]$final.df$RQ,
    VCO2     = xdr_dat[[mid]]$final.df$VCO2
  ) %>%
    filter(time >= 0)

  ts_df %<>% bind_rows(temp_ts_df)
}

# Clip to the first 3 days (3 * 24 * 60 = 4320 minutes)
ts_df %<>% filter(time < 1440 * 3)

ts_df %<>%
  group_by(id) %>%
  mutate(VO2_baseline = median(VO2[time < 1440], na.rm = TRUE),
         VO2_bs = VO2 - VO2_baseline) %>%
  ungroup()

# ---------------------------------------------------------------------------
# Write outputs
# ---------------------------------------------------------------------------
genotypes <- c(
  "QC_hetero", "QB_hetero", "QT_hetero", "QT_homo",
  "QI_hetero", "QI_homo", "QD_hetero", "QD_homo"
)
write_lines(genotypes, file.path("data", "genotypes.txt"))

mice_df %>% write_csv(file.path("data", "mice.csv"))
ts_df   %>% write_csv(file.path("data", "ts.csv"))
