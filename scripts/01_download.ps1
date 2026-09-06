# 01_download.ps1 — download Kang 2018 (GSE96583) raw count matrices
# Windows-native downloader (curl + tar are built into Windows 10/11).

$ErrorActionPreference = "Stop"

$series = "GSE96583"
$supplUrl = "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE96nnn/$series/suppl/${series}_RAW.tar"
$destDir = Join-Path $PSScriptRoot "..\data\raw"
$tarFile = Join-Path $destDir "${series}_RAW.tar"

New-Item -ItemType Directory -Force -Path $destDir | Out-Null

Write-Host "Downloading $supplUrl ..."
curl.exe -L --retry 3 -o $tarFile $supplUrl

if ((Get-Item $tarFile).Length -lt 1MB) {
    Write-Host "WARNING: downloaded file looks too small ($((Get-Item $tarFile).Length) bytes). Check the URL on the GEO page."
}

Write-Host "Extracting ..."
# tar is a built-in on Win10 1803+ / Win11
tar -xf $tarFile -C $destDir

Write-Host "Extracted files:"
Get-ChildItem $destDir | Select-Object Name, Length

Write-Host "Done. Raw matrices are in $destDir"