# Script PowerShell pour télécharger METIS et NLOPT pour SUSE 15 SP4

Write-Host "=== Téléchargement de METIS et NLOPT pour SUSE 15 SP4 ===" -ForegroundColor Cyan
Write-Host ""

$Out = "suse-packages-optional"
New-Item -ItemType Directory -Path $Out -Force | Out-Null
New-Item -ItemType Directory -Path "$Out\sources" -Force | Out-Null

# URLs des sources
$Sources = @{
    "METIS" = @{
        "url" = "http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz"
        "file" = "metis-5.1.0.tar.gz"
    }
    "NLOPT" = @{
        "url" = "https://github.com/stevengj/nlopt/archive/refs/tags/v2.7.1.tar.gz"
        "file" = "nlopt-2.7.1.tar.gz"
    }
}

Write-Host "Téléchargement des sources..." -ForegroundColor Yellow

foreach ($pkg in $Sources.Keys) {
    $url = $Sources[$pkg]["url"]
    $file = $Sources[$pkg]["file"]
    $dest = Join-Path "$Out\sources" $file
    
    Write-Host "  Téléchargement de $pkg depuis $url..." -ForegroundColor White
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        if ((Get-Item $dest).Length -gt 0) {
            $size = [math]::Round((Get-Item $dest).Length / 1MB, 1)
            Write-Host "  ✓ $pkg téléchargé : $file ($size MB)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Échec : fichier vide" -ForegroundColor Red
            Remove-Item $dest -Force
        }
    } catch {
        Write-Host "  ✗ Erreur lors du téléchargement de $pkg : $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Création des scripts d'installation..." -ForegroundColor Yellow

# Script d'installation METIS
$metisScript = @'
#!/bin/bash
# Installation METIS pour SUSE 15 SP4

echo "=== Installation METIS ==="

# Vérifier si METIS est déjà installé
if command -v gpmetis >/dev/null 2>&1; then
    echo "✓ METIS déjà installé"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$SCRIPT_DIR/sources"

# Chercher les sources METIS
if [ ! -f "$SOURCES_DIR/metis-5.1.0.tar.gz" ]; then
    echo "✗ Sources METIS non trouvées dans $SOURCES_DIR"
    exit 1
fi

echo "Extraction de METIS..."
TEMP_DIR=$(mktemp -d)
tar xzf "$SOURCES_DIR/metis-5.1.0.tar.gz" -C "$TEMP_DIR"
cd "$TEMP_DIR/metis-5.1.0"

# Vérifier les dépendances
if ! command -v cmake >/dev/null 2>&1; then
    echo "✗ cmake requis pour compiler METIS"
    exit 1
fi

echo "Configuration de METIS..."
make config prefix=$HOME/.local

echo "Compilation de METIS..."
make -j$(nproc)

echo "Installation de METIS..."
make install

# Nettoyer
cd "$HOME"
rm -rf "$TEMP_DIR"

echo "✓ METIS installé avec succès !"
echo "  Installé dans: $HOME/.local/"
'@

# Script d'installation NLOPT  
$nloptScript = @'
#!/bin/bash
# Installation NLOPT pour SUSE 15 SP4

echo "=== Installation NLOPT ==="

# Vérifier si NLOPT est déjà installé
if pkg-config --exists nlopt 2>/dev/null; then
    echo "✓ NLOPT déjà installé"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$SCRIPT_DIR/sources"

# Chercher les sources NLOPT
if [ ! -f "$SOURCES_DIR/nlopt-2.7.1.tar.gz" ]; then
    echo "✗ Sources NLOPT non trouvées dans $SOURCES_DIR"
    exit 1
fi

echo "Extraction de NLOPT..."
TEMP_DIR=$(mktemp -d)
tar xzf "$SOURCES_DIR/nlopt-2.7.1.tar.gz" -C "$TEMP_DIR"
cd "$TEMP_DIR/nlopt-2.7.1"

# Vérifier les dépendances
if ! command -v cmake >/dev/null 2>&1; then
    echo "✗ cmake requis pour compiler NLOPT"
    exit 1
fi

echo "Configuration de NLOPT..."
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/.local

echo "Compilation de NLOPT..."
make -j$(nproc)

echo "Installation de NLOPT..."
make install

# Nettoyer
cd "$HOME"
rm -rf "$TEMP_DIR"

echo "✓ NLOPT installé avec succès !"
echo "  Installé dans: $HOME/.local/"
'@

# Sauvegarder les scripts
$metisScript | Out-File -FilePath "$Out\install_metis.sh" -Encoding UTF8 -NoNewline
$nloptScript | Out-File -FilePath "$Out\install_nlopt.sh" -Encoding UTF8 -NoNewline

# README
$readme = @"
# Installation METIS et NLOPT pour Tucanos

## Contenu

- ``metis-5.1.0.tar.gz`` - Sources METIS 5.1.0
- ``nlopt-2.7.1.tar.gz`` - Sources NLOPT 2.7.1
- ``install_metis.sh`` - Script d'installation METIS
- ``install_nlopt.sh`` - Script d'installation NLOPT

## Installation

### Sur SUSE 15 SP4 (avec les sources)

``````bash
# Installer METIS
chmod +x install_metis.sh
./install_metis.sh

# Installer NLOPT
chmod +x install_nlopt.sh
./install_nlopt.sh
``````

### Avec zypper (si connexion internet)

``````bash
# METIS
sudo zypper install metis-devel

# NLOPT
sudo zypper install nlopt-devel
``````

## Prérequis

- cmake
- make
- gcc/g++

## Note

Ces dépendances sont **optionnelles** pour Tucanos.

- **METIS** : Utilisé pour le partitionnement de maillage
- **NLOPT** : Utilisé pour le lissage de maillage

Tucanos peut compiler et fonctionner sans elles, mais avec des fonctionnalités réduites.
"@

$readme | Out-File -FilePath "$Out\README_METIS_NLOPT.md" -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Package METIS/NLOPT créé !" -ForegroundColor Green  
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Dossier : $Out\" -ForegroundColor Cyan
Write-Host ""
Write-Host "Contenu :" -ForegroundColor Yellow
Get-ChildItem "$Out\sources" | Select-Object Name, @{Name="Taille (MB)";Expression={[math]::Round($_.Length / 1MB, 1)}}
Write-Host ""
Write-Host "Pour l'utiliser :" -ForegroundColor Yellow
Write-Host "  1. Copier le dossier '$Out' dans le package Tucanos" -ForegroundColor White
Write-Host "  2. Sur SUSE 15 SP4, exécuter les scripts d'installation" -ForegroundColor White
Write-Host "  3. Recompiler Tucanos avec les features metis/nlopt" -ForegroundColor White





