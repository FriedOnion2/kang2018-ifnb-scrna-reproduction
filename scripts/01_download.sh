#!/usr/bin/env bash
# 01_download.sh — download Kang et al. 2018 raw count matrices from GEO.
set -euo pipefail

SRC="https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE96583&format=file"
DEST="data/raw"
mkdir -p "$DEST"

# Two supplementary files: control (GSM2560248) and stimulated (GSM2560249)
# barcodes/genes/matrix for each. Adjust URLs to the exact supplementary file
# names you see on the GEO page if they differ.
wget -c -P "$DEST" "${SRC}&file=GSM2560248%5Fbarcodes%2Etsv%2Egz"
wget -c -P "$DEST" "${SRC}&file=GSM2560248%5Fgenes%2Etsv%2Egz"
wget -c -P "$DEST" "${SRC}&file=GSM2560248%5Fmatrix%2Emtx%2Egz"
wget -c -P "$DEST" "${SRC}&file=GSM2560249%5Fbarcodes%2Etsv%2Egz"
wget -c -P "$DEST" "${SRC}&file=GSM2560249%5Fgenes%2Etsv%2Egz"
wget -c -P "$DEST" "${SRC}&file=GSM2560249%5Fmatrix%2Emtx%2Egz"

# Record checksums so downstream users verify identical downloads.
( cd "$DEST" && md5sum *.gz > md5sums.txt )
echo "Done. Verify with: md5sum -c $DEST/md5sums.txt"