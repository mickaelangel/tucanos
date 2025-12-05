# Script PowerShell pour télécharger TOUTES les dépendances nécessaires
# À exécuter sur une machine avec internet AVANT le transfert

Write-Host "=== Téléchargement des dépendances pour installation hors ligne ===" -ForegroundColor Green

# Créer les répertoires
New-Item -ItemType Directory -Path "dependencies" -Force | Out-Null
New-Item -ItemType Directory -Path "dependencies/rust" -Force | Out-Null
New-Item -ItemType Directory -Path "dependencies/python" -Force | Out-Null
New-Item -ItemType Directory -Path "dependencies/system" -Force | Out-Null

Write-Host "=== Téléchargement de Rust ===" -ForegroundColor Yellow
try {
    Write-Host "Téléchargement de rustup-init..." -ForegroundColor White
    Invoke-WebRequest -Uri "https://sh.rustup.rs" -OutFile "dependencies/rust/rustup-init"
    Write-Host "✓ Rust téléchargé" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur lors du téléchargement de Rust: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Téléchargement des packages Python ===" -ForegroundColor Yellow
Write-Host "Téléchargement de maturin et dépendances..." -ForegroundColor White

try {
    # Créer un environnement virtuel temporaire
    Write-Host "Création de l'environnement virtuel temporaire..." -ForegroundColor White
    python -m venv temp_env
    & "temp_env\Scripts\Activate.ps1"
    
    # Télécharger les packages Python
    Write-Host "Téléchargement des packages Python..." -ForegroundColor White
    pip download maturin
    pip download setuptools
    pip download wheel
    pip download pyo3
    pip download numpy
    
    # Déplacer les wheels
    Write-Host "Déplacement des packages..." -ForegroundColor White
    Move-Item -Path "*.whl" -Destination "dependencies/python/" -Force -ErrorAction SilentlyContinue
    
    # Nettoyer
    Write-Host "Nettoyage..." -ForegroundColor White
    deactivate
    Remove-Item -Recurse -Force temp_env -ErrorAction SilentlyContinue
    
    Write-Host "✓ Packages Python téléchargés" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur lors du téléchargement des packages Python: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Téléchargement des packages système ===" -ForegroundColor Yellow
Write-Host "ATTENTION: Les packages RPM doivent être téléchargés manuellement" -ForegroundColor Red
Write-Host "Depuis les dépôts SUSE:" -ForegroundColor White
Write-Host "  - gcc, gcc-c++, make, pkg-config" -ForegroundColor Cyan
Write-Host "  - python3, python3-devel, python3-pip" -ForegroundColor Cyan
Write-Host "  - nlopt-devel" -ForegroundColor Cyan
Write-Host ""
Write-Host "Placez les fichiers .rpm dans le dossier dependencies/system/" -ForegroundColor White
Write-Host ""

Write-Host "=== Téléchargement terminé ===" -ForegroundColor Green
Write-Host "Vous pouvez maintenant transférer ce package sur SUSE 15" -ForegroundColor White
Write-Host "et exécuter: ./install-complete-offline.sh" -ForegroundColor White




