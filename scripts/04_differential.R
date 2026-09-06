# 04_differential.R — differential expression: stim vs ctrl (per cell type)
#
# Reproduces the paper's core claim: IFN-beta drives a broad ISG response that
# is stronger in monocytes and pDC than in T cells.

library(Seurat)
library(ggplot2)

immune.obj <- readRDS("data/processed/immune_annotated.rds")

# Set identity to condition-within-cell-type so DE is per cell type
immune.obj$celltype.stim <- paste(Idents(immune.obj), immune.obj$stim, sep = "_")
Idents(immune.obj) <- "celltype.stim"

# For each cell type, stim vs ctrl
celltypes <- levels(as.factor(immune.obj$celltype))
de_results <- list()
for (ct in celltypes) {
  g1 <- paste0(ct, "_STIM")
  g2 <- paste0(ct, "_CTRL")
  de_results[[ct]] <- FindMarkers(immune.obj, ident.1 = g1, ident.2 = g2,
                                  verbose = FALSE)
}

# Save full DE tables
dir.create("results", showWarnings = FALSE)
saveRDS(de_results, "results/de_results.rds")

# --- ISG summary heatmap (the headline figure) ---------------------------
isg <- c("ISG15", "IFI6", "IFI27", "ISG20", "MX1", "IFIT1", "IFIT3", "OAS1")
isg_present <- intersect(isg, rownames(immune.obj))

p <- DoHeatmap(immune.obj, features = isg_present) +
  ggtitle("ISG expression by cell type (stim vs ctrl)")
ggsave("results/figures/isg_heatmap.pdf", p, width = 12, height = 8)

message("DE tables saved to results/de_results.rds")
message("ISG heatmap saved to results/figures/isg_heatmap.pdf")