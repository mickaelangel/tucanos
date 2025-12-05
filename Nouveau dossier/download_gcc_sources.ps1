# Télécharger les sources GCC pour compilation hors ligne de g++
$ErrorActionPreference = "Continue"

Write-Host "`n=== Téléchargement des sources GCC ===" -ForegroundColor Cyan

# Créer le dossier de destination
$targetDir = "gcc-sources-offline"
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

# Version GCC compatible avec SUSE 15 SP4 (qui a GCC 7.5.0)
# On télécharge GCC 7.5.0 pour être compatible
$gccVersion = "7.5.0"
$gccUrl = "https://ftp.gnu.org/gnu/gcc/gcc-$gccVersion/gcc-$gccVersion.tar.gz"
$gccFile = Join-Path $targetDir "gcc-$gccVersion.tar.gz"

Write-Host "`nTéléchargement GCC $gccVersion..." -ForegroundColor Yellow
Write-Host "URL: $gccUrl" -ForegroundColor Gray
Write-Host "⚠️  Attention : Fichier très gros (~110 MB), cela peut prendre du temps" -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $gccUrl -OutFile $gccFile -TimeoutSec 600
    
    if (Test-Path $gccFile) {
        $size = (Get-Item $gccFile).Length / 1MB
        Write-Host "✓ GCC téléchargé : $([math]::Round($size, 1)) MB" -ForegroundColor Green
    }
}
catch {
    Write-Host "✗ Échec du téléchargement de GCC" -ForegroundColor Red
    Write-Host "Erreur : $($_.Exception.Message)" -ForegroundColor Red
}

# Télécharger les dépendances de GCC (GMP, MPFR, MPC, ISL)
Write-Host "`nTéléchargement des dépendances GCC..." -ForegroundColor Yellow

$dependencies = @{
    "GMP" = "https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz"
    "MPFR" = "https://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz"
    "MPC" = "https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz"
    "ISL" = "https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2"
}

foreach ($dep in $dependencies.GetEnumerator()) {
    $name = $dep.Key
    $url = $dep.Value
    $filename = Split-Path $url -Leaf
    $output = Join-Path $targetDir $filename
    
    Write-Host "`nTéléchargement $name..." -ForegroundColor Cyan
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $output -TimeoutSec 300
        
        if (Test-Path $output) {
            $size = (Get-Item $output).Length / 1MB
            Write-Host "  ✓ $name : $([math]::Round($size, 1)) MB" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  ✗ Échec : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Résumé ===" -ForegroundColor Cyan
$totalSize = (Get-ChildItem $targetDir -File | Measure-Object -Property Length -Sum).Sum / 1MB
$fileCount = (Get-ChildItem $targetDir -File).Count
Write-Host "Fichiers téléchargés : $fileCount" -ForegroundColor Green
Write-Host "Taille totale : $([math]::Round($totalSize, 1)) MB" -ForegroundColor Green
Write-Host "`nDossier : $targetDir" -ForegroundColor Yellow



