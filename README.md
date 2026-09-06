# Reproduction: Kang et al. 2018 — IFN-β stimulation of PBMCs (scRNA-seq)

**One-line summary**: Reproduce the core single-cell findings of Kang et al., *Nature Biotechnology* (2018) on IFN-β–stimulated peripheral blood mononuclear cells, using a fully reproducible, version-controlled pipeline.

## What this project does

- Downloads the published 10x scRNA-seq data (GSE96583: GSM2560248 = control, GSM2560249 = stimulated).
- Runs a standard single-cell pipeline: QC → normalization → clustering → UMAP → differential expression.
- Reproduces the paper's headline results:
  1. **The cell populations change upon stimulation** (cluster composition shifts).
  2. **ISG response** — interferon-stimulated genes (e.g. *ISG15*, *IFI6*, *ISG20*) are strongly up-regulated in the stimulated condition.
  3. **The ISG response is not uniform** — it varies by cell type (pDC and monocytes respond more strongly than T cells).

## Data source

| Item | Value |
|---|---|
| Paper | Kang et al., "Multiplexed droplet single-cell RNA-sequencing using natural genetic variation", *Nat Biotechnol* 36, 89–94 (2018) |
| GEO accession | [GSE96583](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE96583) |
| Control sample | GSM2560248 (untreated PBMC, ~12.7k cells) |
| Stimulated sample | GSM2560249 (IFN-β treated, ~11.8k cells) |
| Format | 10x Genomics, raw count matrices (genes × barcodes) |

## Environment

Locked with conda/mamba (see `envs/environment.yml`):

```bash
mamba env create -f envs/environment.yml
conda activate repro-kang
```

## Reproduce in one command

```bash
# 1. Download data
bash scripts/01_download.sh

# 2. Run the full pipeline (or run each script in order)
snakemake -c all
```

Individual steps (if running without Snakemake):

```bash
Rscript scripts/02_qc_normalize.R       # QC + Normalize/VarFeatures
Rscript scripts/03_cluster_umap.R       # PCA, UMAP, clustering, cell-type annotation
Rscript scripts/04_differential.R       # DE: control vs stimulated (per cell type)
```

## Results

Final figures in `results/figures/`:

- `umap_by_condition.pdf` — UMAP colored by condition + by cluster
- `de_volcano.pdf` — volcano / DE summary showing ISG up-regulation
- `isg_heatmap.pdf` — ISG expression heatmap by cell type

## Comparison with the original paper

| Finding | Original | This reproduction |
|---|---|---|
| pDC/monocyte cluster composition change under IFN-β | reported | [to fill] |
| ISG15 / IFI6 / ISG20 up-regulated | reported | [to fill] |
| ISG response cell-type heterogeneity | reported | [to fill] |

## License

MIT. See `LICENSE`.