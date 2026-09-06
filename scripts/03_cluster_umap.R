# 03_cluster_umap.R — PCA, UMAP, clustering, cell-type annotation

library(Seurat)
library(ggplot2)
library(patchwork)

immune.obj <- readRDS("data/processed/immune_qc_norm.rds")

# --- PCA + UMAP + clustering ---------------------------------------------
immune.obj <- RunPCA(immune.obj, features = VariableFeatures(immune.obj))
immune.obj <- FindNeighbors(immune.obj, dims = 1:30)
immune.obj <- FindClusters(immune.obj, resolution = 0.5)
immune.obj <- RunUMAP(immune.obj, dims = 1:30)

# --- Cell-type annotation via canonical marker scoring --------------------
# Score each cell against canonical marker sets (AddModuleScore), then label
# each cell by its highest-scoring cell type. This is reproducible and
# interpretable (vs. ad-hoc manual assignment). Marker sets follow PBMC
# conventions from Kang et al. and the Seurat PBMC tutorials.
markers <- list(
  CD14_Mono     = c("CD14", "LYZ", "S100A8", "S100A9"),
  FCGR3A_Mono   = c("FCGR3A", "MS4A7", "LST1"),
  CD4_T         = c("CD3D", "IL7R", "CD4"),
  CD8_T         = c("CD8A", "CD8B", "CD3D"),
  NK            = c("GNLY", "NKG7", "KLRD1"),
  B             = c("MS4A1", "CD79A", "CD79B"),
  DC            = c("FCER1A", "CST3", "CLEC9A"),
  Platelet      = c("PPBP", "PF4"),
  pDC           = c("LILRA4", "IRF7", "GZMB")
)

# Keep only genes present in the dataset
markers <- lapply(markers, function(g) g[g %in% rownames(immune.obj)])

immune.obj <- AddModuleScore(immune.obj, features = markers, name = "celltype_score")
score_cols <- paste0("celltype_score", seq_along(markers))

# Assign each cell the cell type with the max module score
score_mat <- FetchData(immune.obj, vars = score_cols)
best_idx  <- max.col(as.matrix(score_mat), ties.method = "first")
celltype_name <- names(markers)[best_idx]
immune.obj$celltype <- celltype_name
Idents(immune.obj) <- "celltype"

message("Cell-type assignment (top counts):")
print(sort(table(immune.obj$celltype), decreasing = TRUE))

# --- Figures --------------------------------------------------------------
p1 <- DimPlot(immune.obj, reduction = "umap", group.by = "stim") +
  ggtitle("UMAP by condition")
p2 <- DimPlot(immune.obj, reduction = "umap", label = TRUE, repel = TRUE) +
  ggtitle("UMAP by cell type")

ggsave("results/figures/umap_by_condition.pdf", p1, width = 8, height = 6)
ggsave("results/figures/umap_by_celltype.pdf",  p2, width = 10, height = 8)

saveRDS(immune.obj, "data/processed/immune_annotated.rds")
message("Annotated object saved; figures written to results/figures/")