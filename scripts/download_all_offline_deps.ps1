# Script pour créer un VRAI package offline avec cargo vendor complet

Write-Host "=== Création package Tucanos VRAIMENT offline ===" -ForegroundColor Cyan
Write-Host ""

# Vérifier que git est disponible
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "✗ git requis pour cloner coupe" -ForegroundColor Red
    exit 1
}

# Vérifier que cargo est disponible
if (!(Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "✗ cargo requis pour vendor" -ForegroundColor Red
    exit 1
}

Write-Host "Clonage du repository Tucanos..." -ForegroundColor Yellow

# Cloner Tucanos si pas déjà fait
if (!(Test-Path "tucanos-repo")) {
    git clone https://github.com/tucanos/tucanos.git tucanos-repo
} else {
    Write-Host "Repository déjà cloné, mise à jour..." -ForegroundColor Yellow
    cd tucanos-repo
    git pull
    cd ..
}

Write-Host ""
Write-Host "Création du vendor complet avec cargo vendor..." -ForegroundColor Yellow
cd tucanos-repo

# Vendor toutes les dépendances
cargo vendor ../tucanos-vendor-complete

cd ..

Write-Host ""
Write-Host "✓ Vendor complet créé !" -ForegroundColor Green
Write-Host ""

# Calculer la taille
$vendorSize = (Get-ChildItem "tucanos-vendor-complete" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Taille du vendor complet : $([math]::Round($vendorSize, 1)) MB" -ForegroundColor Cyan

Write-Host ""
Write-Host "Maintenant créons le package final..." -ForegroundColor Yellow





