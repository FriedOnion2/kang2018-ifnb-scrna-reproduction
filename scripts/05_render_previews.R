# render previews as PNG (GitHub renders PNG inline; PDF kept as vector source)
suppressPackageStartupMessages(library(Seurat))
suppressPackageStartupMessages(library(ggplot2))

immune.obj <- readRDS("data/processed/immune_annotated.rds")

p1 <- DimPlot(immune.obj, reduction = "umap", group.by = "stim") +
  ggtitle("UMAP by condition") + NoLegend()
p2 <- DimPlot(immune.obj, reduction = "umap", group.by = "celltype",
              label = TRUE, repel = TRUE) +
  ggtitle("UMAP by cell type")

ggsave("results/figures/umap_by_condition.png", p1, width = 7, height = 6, dpi = 150)
ggsave("results/figures/umap_by_celltype.png", p2, width = 8, height = 7, dpi = 150)
message("PNG previews written.")