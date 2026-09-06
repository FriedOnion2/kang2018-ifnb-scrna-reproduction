# 01_stim_vs_ctrl.R — load Kang 2018 (GSE96583) ctrl + stim from raw GEO files
#
# GSE96583 supplementary layout (verified against the actual download):
#   - GSM2560248 = control  (matrix: GSM2560248_2.1.mtx.gz)
#   - GSM2560249 = IFN-beta stimulated (matrix: GSM2560249_2.2.mtx.gz)
#   - shared gene list: GSE96583_batch2.genes.tsv.gz (35635 genes, ENSG + symbol)
#   - shared barcode files: GSM2560248_barcodes.tsv.gz / GSM2560249_barcodes.tsv.gz
#
# The mtx files are "matrix coordinate real general" with 35635 genes x ~14k
# cells. We pass explicit file paths to Read10X because the file names do not
# follow the default 10x trio (barcodes.tsv.gz / genes.tsv.gz / matrix.mtx.gz).

suppressPackageStartupMessages(library(Seurat))

raw <- "data/raw"

read_kang <- function(mtx_file, barcodes_file, genes_file, project) {
  # ReadMtx reads arbitrary-named matrix.triplets (the GSE96583 mtx files are
  # "matrix coordinate real general", not the default 10x trio).
  counts <- ReadMtx(
    mtx        = file.path(raw, mtx_file),
    cells      = file.path(raw, barcodes_file),
    features   = file.path(raw, genes_file),
    feature.column = 2,      # gene symbol is the 2nd column of batch2.genes.tsv
    skip.cell = 0,           # barcodes file has no header
    skip.feature = 0         # genes file has no header
  )
  CreateSeuratObject(counts = counts, project = project, min.cells = 3, min.features = 200)
}

ctrl <- read_kang("GSM2560248_2.1.mtx.gz", "GSM2560248_barcodes.tsv.gz",
                  "GSE96583_batch2.genes.tsv.gz", "IMMUNE_CTRL")
stim <- read_kang("GSM2560249_2.2.mtx.gz", "GSM2560249_barcodes.tsv.gz",
                  "GSE96583_batch2.genes.tsv.gz", "IMMUNE_STIM")

ctrl$stim <- "CTRL"
stim$stim <- "STIM"

immune.obj <- merge(ctrl, y = stim, add.cell.ids = c("CTRL", "STIM"))
immune.obj$celltype.stim <- paste(immune.obj$orig.ident, immune.obj$stim, sep = "_")

dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
saveRDS(immune.obj, "data/processed/immune_merged_raw.rds")
message("Merged object saved to data/processed/immune_merged_raw.rds")
message(sprintf("Genes x cells: %d x %d", nrow(immune.obj), ncol(immune.obj)))