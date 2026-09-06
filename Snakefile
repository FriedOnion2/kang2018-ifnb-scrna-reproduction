# Snakefile — one-command reproduction of the whole pipeline.

configfile: "config/config.yaml"

rule all:
    input:
        "results/figures/isg_heatmap.pdf",
        "results/figures/umap_by_condition.pdf",
        "results/de_results.rds"

rule download:
    output:
        directory("data/raw")
    shell:
        "bash scripts/01_download.sh"

rule merge:
    input:
        "data/raw"
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
        "results/figures/isg_heatmap.pdf"
    shell:
        "Rscript scripts/04_differential.R"