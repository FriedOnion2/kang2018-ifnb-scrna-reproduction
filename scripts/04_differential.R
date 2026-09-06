# 04_differential.R — differential expression: stim vs ctrl (per cell type)
#
# Reproduces the paper's core claim: IFN-beta drives a broad ISG response that
# is stronger in monocytes and pDC than in T cells.

library(Seurat)
library(ggplot2)

immune.obj <- readRDS("data/processed/immune_annotated.rds")

# Seurat 5: merged objects keep per-sample layers; JoinLayers before DE.
immune.obj <- JoinLayers(immune.obj)

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

# Downsample so DoHeatmap stays fast and readable on ~29k cells.
set.seed(42)
Idents(immune.obj) <- "celltype.stim"
sub <- subset(immune.obj, downsample = 200)

p <- DoHeatmap(sub, features = isg_present, group.by = "celltype.stim",
               disp.min = -2.5, disp.max = 2.5) +
  ggtitle("ISG expression by cell type and condition (stim vs ctrl)")
ggsave("results/figures/isg_heatmap.pdf", p, width = 14, height = 9)

# --- Volcano-style summary of ISG up-regulation in monocytes ---------------
# Reproduces the paper's claim: ISGs are up-regulated by IFN-beta.
mono_de <- de_results[["CD14_Mono"]]
top <- head(mono_de[order(mono_de$avg_log2FC, decreasing = TRUE), ], 20)
top$gene <- rownames(top)
write.csv(top, "results/top20_DE_CD14_Mono_stim_vs_ctrl.csv", row.names = FALSE)

message("DE tables saved to results/de_results.rds")
message("ISG heatmap saved to results/figures/isg_heatmap.pdf")
message("Top DE genes (CD14 Mono, stim vs ctrl):")
print(top[, c("gene", "avg_log2FC", "p_val_adj")])