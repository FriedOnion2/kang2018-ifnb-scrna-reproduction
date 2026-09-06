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

# --- Cell-type annotation via canonical markers ---------------------------
# (Correct these rigorously; this is the piece you must verify, not copy.)
canonical <- list(
  CD14_Mono     = c("CD14", "LYZ"),
  FCGR3A_Mono   = c("FCGR3A", "MS4A7"),
  CD4_T         = c("CD3D", "IL7R"),
  CD8_T         = c("CD8A", "CD3D"),
  NK            = c("GNLY", "NKG7"),
  B             = c("MS4A1", "CD79A"),
  DC            = c("FCER1A", "CST3"),
  Platelet      = c("PPBP"),
  pDC           = c("LILRA4", "IRF7")
)

immune.obj <- RenameIdents(immune.obj, canonical)
immune.obj$celltype <- Idents(immune.obj)

# --- Figures --------------------------------------------------------------
p1 <- DimPlot(immune.obj, reduction = "umap", group.by = "stim") +
  ggtitle("UMAP by condition")
p2 <- DimPlot(immune.obj, reduction = "umap", label = TRUE, repel = TRUE) +
  ggtitle("UMAP by cell type")

ggsave("results/figures/umap_by_condition.pdf", p1, width = 8, height = 6)
ggsave("results/figures/umap_by_celltype.pdf",  p2, width = 10, height = 8)

saveRDS(immune.obj, "data/processed/immune_annotated.rds")
message("Annotated object saved; figures written to results/figures/")