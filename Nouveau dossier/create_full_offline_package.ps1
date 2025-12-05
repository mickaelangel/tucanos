# Script pour créer un package Tucanos 100% offline
# Télécharge toutes les dépendances incluant 'coupe' depuis GitHub

Write-Host "=== Création du package Tucanos 100% OFFLINE ===" -ForegroundColor Cyan
Write-Host ""

$Out = "tucanos-100-percent-offline"
New-Item -ItemType Directory -Path $Out -Force | Out-Null
New-Item -ItemType Directory -Path "$Out\github-dependencies" -Force | Out-Null

# 1. Télécharger la dépendance 'coupe' depuis GitHub
Write-Host "Téléchargement de 'coupe' depuis GitHub..." -ForegroundColor Yellow

$coupeUrl = "https://github.com/LIHPC-Computational-Geometry/coupe/archive/20f0de6.zip"
$coupeDest = "$Out\github-dependencies\coupe-20f0de6.zip"

try {
    Invoke-WebRequest -Uri $coupeUrl -OutFile $coupeDest -UseBasicParsing
    if ((Get-Item $coupeDest).Length -gt 0) {
        $size = [math]::Round((Get-Item $coupeDest).Length / 1KB, 1)
        Write-Host "✓ coupe téléchargé : $size KB" -ForegroundColor Green
    } else {
        Write-Host "✗ Échec : fichier vide" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Erreur lors du téléchargement de coupe : $_" -ForegroundColor Red
}

# 2. Télécharger aussi metis-rs et minimeshb (autres dépendances GitHub potentielles)
Write-Host ""
Write-Host "Téléchargement d'autres dépendances GitHub..." -ForegroundColor Yellow

$githubDeps = @{
    "metis-rs" = "https://github.com/LIHPC-Computational-Geometry/metis-rs/archive/d31aa3e.zip"
    "minimeshb" = "https://github.com/tucanos/minimeshb/archive/refs/tags/0.1.0.zip"
}

foreach ($dep in $githubDeps.Keys) {
    $url = $githubDeps[$dep]
    $fileName = "$dep-" + ($url -split '/')[-1]
    $dest = "$Out\github-dependencies\$fileName"
    
    Write-Host "  Téléchargement de $dep..." -ForegroundColor White
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        if ((Get-Item $dest).Length -gt 0) {
            $size = [math]::Round((Get-Item $dest).Length / 1KB, 1)
            Write-Host "  ✓ $dep téléchargé : $size KB" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ⚠ Échec : $dep (peut ne pas être nécessaire)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Création du script d'installation des dépendances GitHub..." -ForegroundColor Yellow

# Script pour installer les dépendances GitHub
$installGithubScript = @'
#!/bin/bash
# Installation des dépendances GitHub pour Tucanos

echo "=== Installation des dépendances GitHub ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_DIR="$SCRIPT_DIR/github-dependencies"

# Créer le répertoire .cargo/git/checkouts local
mkdir -p "$HOME/.cargo/git/checkouts"

# Fonction pour installer une dépendance GitHub
install_github_dep() {
    local name=$1
    local zip_pattern=$2
    local target_dir=$3
    
    echo "Installation de $name..."
    
    # Chercher le fichier zip
    local zip_file=$(find "$GITHUB_DIR" -name "$zip_pattern" | head -n1)
    
    if [ -z "$zip_file" ]; then
        echo "⚠ $name non trouvé (peut ne pas être nécessaire)"
        return 1
    fi
    
    echo "  Extraction de $(basename $zip_file)..."
    
    # Extraire dans un répertoire temporaire
    local temp_dir=$(mktemp -d)
    unzip -q "$zip_file" -d "$temp_dir"
    
    # Trouver le dossier extrait
    local extracted=$(find "$temp_dir" -maxdepth 1 -type d ! -path "$temp_dir" | head -n1)
    
    if [ -n "$extracted" ]; then
        # Créer le répertoire cible dans cargo
        local cargo_checkout="$HOME/.cargo/git/checkouts/$target_dir"
        mkdir -p "$cargo_checkout"
        
        # Copier les fichiers
        cp -r "$extracted"/* "$cargo_checkout/"
        
        echo "  ✓ $name installé dans $cargo_checkout"
    fi
    
    rm -rf "$temp_dir"
}

# Installer coupe (obligatoire)
echo ""
echo "Installation de 'coupe' (dépendance obligatoire)..."
install_github_dep "coupe" "coupe-*.zip" "coupe"

# Installer metis-rs si présent
install_github_dep "metis-rs" "metis-rs-*.zip" "metis-rs"

# Installer minimeshb si présent  
install_github_dep "minimeshb" "minimeshb-*.zip" "minimeshb"

echo ""
echo "✓ Dépendances GitHub installées avec succès !"
'@

$installGithubScript | Out-File -FilePath "$Out\install_github_dependencies.sh" -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "Création du README..." -ForegroundColor Yellow

$readme = @"
# Dépendances GitHub pour Tucanos

## Contenu

Ce package contient les dépendances GitHub nécessaires pour Tucanos :

- **coupe** : Bibliothèque de partitionnement (obligatoire pour tmesh)
- **metis-rs** : Bindings Rust pour METIS (optionnel)
- **minimeshb** : Utilitaires mesh (optionnel)

## Installation

``````bash
# Installer les dépendances GitHub
chmod +x install_github_dependencies.sh
./install_github_dependencies.sh
``````

Cela copiera les dépendances dans ``~/.cargo/git/checkouts/``

## Intégration dans le package Tucanos

Copiez ce dossier dans le package Tucanos principal :

``````bash
# Copier dans le package
cp -r $Out ../tucanos-complete-offline-final/
``````

## Utilisation

Après installation des dépendances GitHub, vous pouvez compiler Tucanos en mode offline :

``````bash
cd tucanos-main
cargo build --release --offline
``````

Les dépendances GitHub seront utilisées depuis ``~/.cargo/git/checkouts/``
"@

$readme | Out-File -FilePath "$Out\README_GITHUB_DEPS.md" -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Dépendances GitHub téléchargées !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Dossier : $Out\" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fichiers téléchargés :" -ForegroundColor Yellow
Get-ChildItem "$Out\github-dependencies" | Select-Object Name, @{Name="Taille (KB)";Expression={[math]::Round($_.Length / 1KB, 1)}}
Write-Host ""
Write-Host "Prochaines étapes :" -ForegroundColor Yellow
Write-Host "  1. Intégrer au package Tucanos" -ForegroundColor White
Write-Host "  2. Sur SUSE 15, installer les dépendances GitHub d'abord" -ForegroundColor White
Write-Host "  3. Puis compiler Tucanos en mode offline" -ForegroundColor White





