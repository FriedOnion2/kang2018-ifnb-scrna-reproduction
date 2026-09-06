# 02_qc_normalize.R — QC, normalize, find variable features, scale

library(Seurat)

immune.obj <- readRDS("data/processed/immune_merged_raw.rds")

# --- QC: keep cells with sane feature counts and low mitochondrial fraction -
immune.obj[["percent.mt"]] <- PercentageFeatureSet(immune.obj, pattern = "^MT-")
immune.obj <- subset(immune.obj,
                     subset = nFeature_RNA > 200 & nFeature_RNA < 5000 &
                              percent.mt < 10)

# --- Normalize + variable features + scale --------------------------------
immune.obj <- NormalizeData(immune.obj)
# Seurat 5: merge() leaves per-sample layers; join before downstream DE/figure.
immune.obj <- JoinLayers(immune.obj)
immune.obj <- FindVariableFeatures(immune.obj,
                                   selection.method = "vst", nfeatures = 2000)
all.genes <- rownames(immune.obj)
immune.obj <- ScaleData(immune.obj, features = all.genes)

saveRDS(immune.obj, "data/processed/immune_qc_norm.rds")
message(sprintf("After QC: %d genes x %d cells",
                nrow(immune.obj), ncol(immune.obj)))