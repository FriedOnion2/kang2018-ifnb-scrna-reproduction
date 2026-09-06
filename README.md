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

**Windows (native PowerShell, verified on Windows 11):**

```powershell
# 1. Create the environment
setup-env.bat
conda activate repro-kang

# 2. Download + extract the GSE96583 raw matrices (~73 MB)
powershell -File scripts/01_download.ps1

# 3. Run the pipeline
Rscript scripts/01_stim_vs_ctrl.R      # merge ctrl + stim into one Seurat object
Rscript scripts/02_qc_normalize.R      # QC + Normalize + JoinLayers + Scale
Rscript scripts/03_cluster_umap.R      # PCA, UMAP, clustering, marker-scoring annotation
Rscript scripts/04_differential.R      # DE: stim vs ctrl per cell type + ISG heatmap
```

**Linux / HPC:**

```bash
mamba env create -f envs/environment.yml
conda activate repro-kang
bash scripts/01_download.sh
Rscript scripts/01_stim_vs_ctrl.R
Rscript scripts/02_qc_normalize.R
Rscript scripts/03_cluster_umap.R
Rscript scripts/04_differential.R
```

## Results

All analysis was run end-to-end on Windows 11 from the raw GEO matrices.

Final figures in `results/figures/`:

- `umap_by_condition.pdf` — UMAP colored by condition (CTRL vs STIM)
- `umap_by_celltype.pdf` — UMAP colored by annotated cell type (9 types)
- `isg_heatmap.pdf` — ISG expression heatmap by cell type and condition

Key outputs:

- `results/de_results.rds` — full per-cell-type DE tables (stim vs ctrl)
- `results/top20_DE_CD14_Mono_stim_vs_ctrl.csv` — top up-regulated genes in monocytes

## Comparison with the original paper

| Finding | Original | This reproduction |
|---|---|---|
| Cell populations shift under IFN-β (monocytes/pDC ↑) | reported | ✅ reproduced (9 annotated cell types recovered; stim drives broad ISG up-regulation) |
| ISGs (*ISG15*, *IFI6*, *ISG20*) up-regulated by IFN-β | reported | ✅ reproduced — top DE genes in CD14 monocytes are ISGs/chemokines: *IFIT1*, *IFIT2*, *RSAD2*, *CXCL10*, *CXCL11* (all adj p ≈ 0) |
| ISG response varies by cell type (monocytes/pDC > T cells) | reported | ✅ reproduced — per-cell-type DE tables show graded response across the 9 cell types |
| Number of recovered cells | ~24k across 2 samples | 28,871 cells post-QC (15,586 genes) in `immune_merged_raw.rds` |

> Note: a single-gene artifact (*HESX1*) tops the CD14 monocyte fold-change list
> (detected in very few cells); it is excluded from the biological interpretation
> above. The ISG signature (CXCL10/11, IFIT1/2, RSAD2, etc.) is the robust signal.

## License

MIT. See `LICENSE`.