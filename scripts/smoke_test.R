# smoke test: progressively load packages to find the Mingw failure boundary
cat("R:", R.version.string, "\n")

trypkg <- function(p) {
  ok <- tryCatch({
    suppressPackageStartupMessages(library(p, character.only = TRUE))
    TRUE
  }, error = function(e) { cat("  FAIL:", conditionMessage(e), "\n"); FALSE })
  if (ok) cat("  OK:", p, "\n")
}

cat("--- core deps ---\n")
for (p in c("Matrix", "Rcpp", "RcppEigen", "RcppAnnoy", "RcppHNSW", "sp", "igraph", "spatstat.geom")) {
  trypkg(p)
}

cat("--- SeuratObject ---\n")
trypkg("SeuratObject")

cat("--- Seurat ---\n")
trypkg("Seurat")

cat("--- plotting stack ---\n")
for (p in c("ggplot2", "patchwork", "dplyr", "tidyr")) {
  trypkg(p)
}

cat("\nAll smoke tests done.\n")