#!/usr/bin/env bash
# 01_download.sh — download Kang et al. 2018 (GSE96583) raw matrices (Linux/HPC).
set -euo pipefail

BASE="https://ftp.ncbi.nlm.nih.gov/geo/series/GSE96nnn/GSE96583/suppl"
DEST="data/raw"
mkdir -p "$DEST"

echo "Downloading GSE96583_RAW.tar (~73 MB) ..."
curl -L --retry 3 -o "$DEST/GSE96583_RAW.tar" "$BASE/GSE96583_RAW.tar"

echo "Downloading gene list (batch2, 35635 genes) ..."
curl -L --retry 3 -o "$DEST/GSE96583_batch2.genes.tsv.gz" \
  "$BASE/GSE96583_batch2.genes.tsv.gz"

echo "Extracting ..."
tar -xf "$DEST/GSE96583_RAW.tar" -C "$DEST"

# Record checksums so downstream users verify identical downloads.
( cd "$DEST" && md5sum *.gz *.tar > md5sums.txt )
echo "Done. Files in $DEST:"
ls -lh "$DEST"