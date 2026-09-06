# 01_stim_vs_ctrl.R — load Kang 2018 data (mirrors Seurat's official tutorial)
#
# Purpose: make the raw GEO matrices reproducible and identical to the
# well-known "stim vs ctrl" PBMC dataset used throughout the Seurat docs.

library(Seurat)

# --- Download-free load: read the raw matrices from data/raw ----------------
ctrl <- Read10X(data.dir = "data/raw/GSM2560248")
stim <- Read10X(data.dir = "data/raw/GSM2560249")

ctrl  <- CreateSeuratObject(counts = ctrl,  project = "IMMUNE_CTRL")
stim  <- CreateSeuratObject(counts = stim,  project = "IMMUNE_STIM")

ctrl$stim  <- "CTRL"
stim$stim  <- "STIM"

immune.obj <- merge(ctrl, y = stim, add.cell.ids = c("CTRL", "STIM"))
immune.obj$celltype.stim <- paste(immune.obj$orig.ident, immune.obj$stim, sep = "_")

saveRDS(immune.obj, "data/processed/immune_merged_raw.rds")
message("Merged object saved to data/processed/immune_merged_raw.rds")
message(sprintf("Genes x cells: %d x %d", nrow(immune.obj), ncol(immune.obj)))