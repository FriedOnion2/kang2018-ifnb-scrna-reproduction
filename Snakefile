# Snakefile — one-command reproduction of the Kang 2018 pipeline.
#
# Run:  snakemake -c all
# The DAG: download → merge → qc → cluster/annotate → DE → PNG previews.

configfile: "config/config.yaml"

# Final artifacts we want to exist after a full run.
rule all:
    input:
        "results/figures/isg_heatmap.pdf",
        "results/figures/umap_by_condition.pdf",
        "results/figures/umap_by_celltype.pdf",
        "results/figures/umap_by_condition.png",
        "results/figures/umap_by_celltype.png",
        "results/de_results.rds",
        "results/top20_DE_CD14_Mono_stim_vs_ctrl.csv"

# Download writes a sentinel file so Snakemake knows it completed (directory
# targets are unreliable for incremental detection).
rule download:
    output:
        "data/raw/.download_complete"
    shell:
        "bash scripts/01_download.sh && touch data/raw/.download_complete"

rule merge:
    input:
        "data/raw/.download_complete"
    output:
        "data/processed/immune_merged_raw.rds"
    shell:
        "Rscript scripts/01_stim_vs_ctrl.R"

rule qc_norm:
    input:
        "data/processed/immune_merged_raw.rds"
    output:
        "data/processed/immune_qc_norm.rds"
    shell:
        "Rscript scripts/02_qc_normalize.R"

rule cluster_umap:
    input:
        "data/processed/immune_qc_norm.rds"
    output:
        "data/processed/immune_annotated.rds",
        "results/figures/umap_by_condition.pdf",
        "results/figures/umap_by_celltype.pdf"
    shell:
        "Rscript scripts/03_cluster_umap.R"

rule differential:
    input:
        "data/processed/immune_annotated.rds"
    output:
        "results/de_results.rds",
        "results/figures/isg_heatmap.pdf",
        "results/top20_DE_CD14_Mono_stim_vs_ctrl.csv"
    shell:
        "Rscript scripts/04_differential.R"

rule render_previews:
    input:
        "data/processed/immune_annotated.rds"
    output:
        "results/figures/umap_by_condition.png",
        "results/figures/umap_by_celltype.png"
    shell:
        "Rscript scripts/05_render_previews.R"