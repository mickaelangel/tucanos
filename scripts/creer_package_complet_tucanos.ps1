# Script PowerShell pour créer le package complet Tucanos offline
# À exécuter sur Windows avec une connexion internet

Write-Host "=== Création du package complet Tucanos offline ===" -ForegroundColor Cyan
Write-Host ""

$PackageDir = "tucanos-complete-offline-final"
$CurrentDir = Get-Location

# Nettoyer le dossier s'il existe
if (Test-Path $PackageDir) {
    Write-Host "Nettoyage du dossier existant..." -ForegroundColor Yellow
    Remove-Item -Path $PackageDir -Recurse -Force
}

# Créer le répertoire du package
New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

Write-Host "Vérification et copie des composants..." -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier et copier les sources Tucanos
$tucanosFound = $false
$tucanosSource = $null

# Essayer différents emplacements
$possibleLocations = @(
    "tucanos-main",
    "tucanos-suse15-package\tucanos",
    "tucanos-complete-offline\tucanos",
    "tucanos-complete-offline\tucanos-offline-bundle\tucanos"
)

foreach ($loc in $possibleLocations) {
    if (Test-Path $loc) {
        Write-Host "✓ Sources Tucanos trouvées dans : $loc" -ForegroundColor Green
        $tucanosSource = $loc
        $tucanosFound = $true
        break
    }
}

if ($tucanosFound) {
    Write-Host "✓ Copie des sources Tucanos..." -ForegroundColor Green
    Copy-Item -Path $tucanosSource -Destination "$PackageDir\tucanos-main" -Recurse -Force
} else {
    Write-Host "✗ Sources Tucanos non trouvées" -ForegroundColor Red
    Write-Host "Emplacements testés :" -ForegroundColor Yellow
    $possibleLocations | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkGray }
    Write-Host ""
    Write-Host "Solution : Téléchargez les sources depuis https://github.com/tucanos/tucanos" -ForegroundColor Yellow
    exit 1
}

# 2. Vérifier et copier le package Rust offline
if (Test-Path "rust-offline-package") {
    Write-Host "✓ Copie du package Rust offline..." -ForegroundColor Green
    Copy-Item -Path "rust-offline-package" -Destination "$PackageDir\rust-offline-package" -Recurse -Force
} else {
    Write-Host "⚠ Package Rust offline non trouvé (optionnel si Rust déjà installé)" -ForegroundColor Yellow
}

# 3. Vérifier et copier le bundle make
if (Test-Path "C:\Users\mickaelangel\suse-packages") {
    Write-Host "✓ Copie du bundle make..." -ForegroundColor Green
    Copy-Item -Path "C:\Users\mickaelangel\suse-packages" -Destination "$PackageDir\suse-packages" -Recurse -Force
} elseif (Test-Path "suse-packages") {
    Write-Host "✓ Copie du bundle make..." -ForegroundColor Green
    Copy-Item -Path "suse-packages" -Destination "$PackageDir\suse-packages" -Recurse -Force
} else {
    Write-Host "✗ Bundle make non trouvé" -ForegroundColor Red
    Write-Host "Création du bundle make..." -ForegroundColor Yellow
    
    if (Test-Path "create_make_offline_bundle.ps1") {
        & .\create_make_offline_bundle.ps1
        if (Test-Path "C:\Users\mickaelangel\suse-packages") {
            Copy-Item -Path "C:\Users\mickaelangel\suse-packages" -Destination "$PackageDir\suse-packages" -Recurse -Force
            Write-Host "✓ Bundle make créé et copié" -ForegroundColor Green
        }
    } else {
        Write-Host "ERREUR: Script create_make_offline_bundle.ps1 non trouvé" -ForegroundColor Red
        exit 1
    }
}

# 3.5. Copier les dépendances Cargo vendorisées
$cargoVendorFound = $false
$cargoVendorPaths = @(
    "cargo-vendor-complet",
    "tucanos-complete-offline\cargo-dependencies",
    "tucanos-complete-offline\cargo-vendor",
    "cargo-vendor"
)

foreach ($vendorPath in $cargoVendorPaths) {
    if (Test-Path $vendorPath) {
        $fileCount = (Get-ChildItem $vendorPath -File -Recurse).Count
        Write-Host "✓ Copie des dépendances Cargo depuis : $vendorPath ($fileCount fichiers)" -ForegroundColor Green
        Copy-Item -Path $vendorPath -Destination "$PackageDir\cargo-vendor" -Recurse -Force
        $cargoVendorFound = $true
        break
    }
}

if (-not $cargoVendorFound) {
    Write-Host "⚠ Dépendances Cargo (cargo-vendor) non trouvées" -ForegroundColor Yellow
    Write-Host "  Le package nécessitera une connexion internet pour compiler Tucanos" -ForegroundColor DarkYellow
}

# 3.6. Copier METIS et NLOPT optionnels
if (Test-Path "suse-packages-optional") {
    Write-Host "✓ Copie de METIS et NLOPT (optionnels)..." -ForegroundColor Green
    Copy-Item -Path "suse-packages-optional" -Destination "$PackageDir\suse-packages-optional" -Recurse -Force
} else {
    Write-Host "⚠ Package METIS/NLOPT non trouvé (optionnel)" -ForegroundColor Yellow
    Write-Host "  Exécutez download_metis_nlopt.ps1 pour les inclure" -ForegroundColor DarkYellow
}

# 3.7. Copier les dépendances GitHub pour mode 100% offline
if (Test-Path "tucanos-100-percent-offline") {
    Write-Host "✓ Copie des dépendances GitHub (coupe, etc.)..." -ForegroundColor Green
    Copy-Item -Path "tucanos-100-percent-offline" -Destination "$PackageDir\github-dependencies-offline" -Recurse -Force
} elseif (Test-Path "tucanos-complete-offline\github-dependencies") {
    Write-Host "✓ Copie des dépendances GitHub depuis tucanos-complete-offline..." -ForegroundColor Green
    Copy-Item -Path "tucanos-complete-offline\github-dependencies" -Destination "$PackageDir\github-dependencies-offline" -Recurse -Force
} else {
    Write-Host "⚠ Dépendances GitHub non trouvées" -ForegroundColor Yellow
    Write-Host "  Exécutez create_full_offline_package.ps1 pour mode 100% offline" -ForegroundColor DarkYellow
    Write-Host "  Sans cela, une connexion internet sera nécessaire pour 'coupe'" -ForegroundColor DarkYellow
}

# 4. Copier les scripts d'installation
Write-Host "✓ Copie des scripts d'installation..." -ForegroundColor Green

# Scripts principaux
Copy-Item -Path "install_tucanos_suse15_offline.sh" -Destination "$PackageDir\install_tucanos_suse15_offline.sh" -Force

# Scripts avec sudo
if (Test-Path "install_gcc_offline.sh") {
    Copy-Item -Path "install_gcc_offline.sh" -Destination "$PackageDir\install_gcc_offline.sh" -Force
}

# Scripts SANS sudo
$noSudoScripts = @(
    "install_tucanos_no_sudo.sh",
    "install_gcc_no_sudo.sh",
    "install_make_no_sudo.sh"
)

foreach ($script in $noSudoScripts) {
    if (Test-Path $script) {
        Write-Host "✓ Copie du script sans sudo: $script" -ForegroundColor Green
        Copy-Item -Path $script -Destination "$PackageDir\$script" -Force
    }
}

# 5. Copier la documentation supplémentaire
if (Test-Path "README_INSTALLATION_SANS_SUDO.md") {
    Write-Host "✓ Copie de la documentation sans sudo..." -ForegroundColor Green
    Copy-Item -Path "README_INSTALLATION_SANS_SUDO.md" -Destination "$PackageDir\README_INSTALLATION_SANS_SUDO.md" -Force
}

# 6. Créer le README
Write-Host "✓ Création de la documentation..." -ForegroundColor Green

$ReadmeContent = @"
# Installation complète de Tucanos sur SUSE 15 SP4 (Hors ligne)

Ce package contient tout le nécessaire pour installer Tucanos sur SUSE 15 SP4 sans connexion internet.

## Contenu du package

- ``tucanos-main/`` - Sources de Tucanos
- ``rust-offline-package/`` - Package Rust offline (toolchain complet)
- ``suse-packages/`` - Bundle make et dépendances (sources)
- ``install_tucanos_suse15_offline.sh`` - Script d'installation automatique

## Prérequis sur le serveur SUSE 15 SP4

Le serveur doit avoir au minimum :
- **gcc** et **g++** installés (pour compiler make et les dépendances natives)
- **tar** et **gzip** (normalement présents par défaut)
- Accès **sudo** pour l'installation globale

Si gcc n'est pas disponible, installez-le d'abord :
``````bash
sudo zypper install gcc gcc-c++
``````

## Installation rapide

### 1. Transférer le package sur le serveur SUSE 15 SP4

**Option A - SCP (si réseau disponible) :**
``````bash
scp tucanos-complete-offline-final.tar.gz user@server:/home/user/
``````

**Option B - Clé USB :**
- Copiez le fichier .tar.gz sur une clé USB
- Montez la clé sur le serveur
- Copiez le fichier vers /home/user/

### 2. Sur le serveur SUSE 15 SP4

``````bash
# Extraire le package
tar xzf tucanos-complete-offline-final.tar.gz

# Accéder au dossier
cd tucanos-complete-offline-final

# Rendre le script exécutable
chmod +x install_tucanos_suse15_offline.sh

# Lancer l'installation
./install_tucanos_suse15_offline.sh
``````

## Ce que fait le script d'installation

Le script effectue automatiquement les étapes suivantes :

1. ✓ **Vérification du système** (SUSE 15 SP4)
2. ✓ **Installation de make** (compilation depuis les sources si absent)
3. ✓ **Installation de Rust** (depuis le package offline si absent)
4. ✓ **Compilation de Tucanos** (avec fonctionnalités disponibles)
5. ✓ **Installation globale** (optionnel, demande confirmation)
6. ✓ **Tests de validation**

## Dépendances optionnelles

Pour activer toutes les fonctionnalités de Tucanos, vous pouvez installer :

### NLOPT (pour le lissage de maillage)
``````bash
sudo zypper install nlopt-devel
``````

### METIS (pour le partitionnement de maillage)
``````bash
sudo zypper install metis-devel
``````

**Note :** Ces dépendances sont optionnelles. Tucanos se compilera sans elles, mais avec des fonctionnalités réduites.

## Vérification après installation

``````bash
# Vérifier make
make --version

# Vérifier Rust
rustc --version
cargo --version

# Vérifier Tucanos
cd tucanos-main
cargo test --release
``````

## Structure après installation

``````
/usr/local/bin/make          # make installé
~/.cargo/                    # Rust toolchain
~/.rustup/                   # Rustup (si installé)
/usr/local/lib/libtucanos.so # Bibliothèque Tucanos (si installation globale)
/usr/local/include/tucanos.h # Headers Tucanos (si installation globale)
``````

## Dépannage

### make : command not found
- Vérifiez que gcc est installé : ``gcc --version``
- Installez gcc : ``sudo zypper install gcc``
- Relancez le script d'installation

### Erreur de compilation Rust
- Vérifiez l'espace disque : ``df -h`` (minimum 5 GB recommandé)
- Vérifiez la mémoire : ``free -h`` (minimum 2 GB recommandé)
- Compilez avec moins de parallélisme : ``cargo build --release -j 2``

### Erreur NLOPT ou METIS
- Ces dépendances sont optionnelles
- Tucanos se compile sans elles (fonctionnalités réduites)
- Pour les activer, installez-les avec zypper (nécessite connexion internet)

### Erreur de permissions
- Assurez-vous d'avoir les droits sudo
- Vérifiez les permissions du dossier : ``ls -la``

## Utilisation de Tucanos

### API C
``````c
#include <tucanos.h>
// Votre code ici
``````

### API Python (si bindings compilés)
``````python
import pytucanos
# Votre code ici
``````

### Bibliothèque partagée
``````bash
# Linker avec : -ltucanos
gcc mon_programme.c -ltucanos -o mon_programme
``````

## Taille du package

- Sources Tucanos : ~10-20 MB
- Rust offline : ~150-200 MB
- Bundle make : ~130 MB (sources gcc + make)
- **Total compressé : ~200-300 MB**
- **Total décompressé : ~400-500 MB**

## Support et documentation

- **Tucanos GitHub :** https://github.com/tucanos/tucanos
- **Documentation Rust :** https://www.rust-lang.org/
- **SUSE 15 Documentation :** https://documentation.suse.com/

## Version

- Tucanos : dernière version (main branch)
- Rust : 1.89.0
- Make : 4.3 / 4.2.1
- GCC : 7.5.0 / 8.5.0 (sources pour compilation)

---

**Créé le :** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Package généré automatiquement pour installation offline sur SUSE 15 SP4**
"@

$ReadmeContent | Out-File -FilePath "$PackageDir\README_INSTALLATION_COMPLETE.md" -Encoding UTF8

# 6. Créer un script de vérification
$VerifyScript = @'
#!/bin/bash
# Script de vérification du package offline

echo "=== Vérification du package Tucanos offline ==="
echo ""

errors=0

# Vérifier les composants
echo "Vérification des composants..."

if [ -d "tucanos-main" ]; then
    echo "✓ Sources Tucanos présentes"
    echo "  $(du -sh tucanos-main | cut -f1)"
else
    echo "✗ Sources Tucanos manquantes"
    ((errors++))
fi

if [ -d "suse-packages/sources" ]; then
    if [ -f "suse-packages/sources/make-4.3.tar.gz" ] || [ -f "suse-packages/sources/make-4.2.1.tar.gz" ]; then
        echo "✓ Sources make présentes"
        ls -lh suse-packages/sources/*.tar.gz | awk '{print "  " $9 ": " $5}'
    else
        echo "✗ Sources make manquantes"
        ((errors++))
    fi
else
    echo "✗ Dossier suse-packages/sources manquant"
    ((errors++))
fi

if [ -f "install_tucanos_suse15_offline.sh" ]; then
    echo "✓ Script d'installation présent"
    if [ -x "install_tucanos_suse15_offline.sh" ]; then
        echo "✓ Script d'installation exécutable"
    else
        echo "⚠ Script d'installation non exécutable (correction...)"
        chmod +x install_tucanos_suse15_offline.sh
    fi
else
    echo "✗ Script d'installation manquant"
    ((errors++))
fi

if [ -d "rust-offline-package" ]; then
    echo "✓ Package Rust présent"
    echo "  $(du -sh rust-offline-package | cut -f1)"
else
    echo "⚠ Package Rust manquant (Rust doit être déjà installé sur le serveur)"
fi

echo ""
echo "Taille totale du package :"
du -sh . | cut -f1

echo ""
if [ $errors -eq 0 ]; then
    echo "✓✓✓ Package complet et prêt pour le transfert ! ✓✓✓"
    echo ""
    echo "Prochaines étapes :"
    echo "1. Compresser : cd .. && tar czf tucanos-complete-offline-final.tar.gz tucanos-complete-offline-final/"
    echo "2. Transférer sur SUSE 15 SP4 : scp tucanos-complete-offline-final.tar.gz user@server:/home/user/"
    echo "3. Sur le serveur : tar xzf tucanos-complete-offline-final.tar.gz"
    echo "4. Installer : cd tucanos-complete-offline-final && ./install_tucanos_suse15_offline.sh"
else
    echo "✗✗✗ $errors erreur(s) détectée(s) ✗✗✗"
    exit 1
fi
'@

$VerifyScript | Out-File -FilePath "$PackageDir\VERIFIER_PACKAGE.sh" -Encoding UTF8

# 7. Créer un fichier de résumé
$SummaryContent = @"
# Package Tucanos Offline - Résumé

**Date de création :** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Système cible :** SUSE Linux Enterprise Server 15 SP4 (hors ligne)

## Contenu vérifié

"@

$components = @()

if (Test-Path "$PackageDir\tucanos-main") {
    $size = (Get-ChildItem "$PackageDir\tucanos-main" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    $components += "- ✓ Sources Tucanos ($([math]::Round($size, 1)) MB)"
}

if (Test-Path "$PackageDir\rust-offline-package") {
    $size = (Get-ChildItem "$PackageDir\rust-offline-package" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    $components += "- ✓ Package Rust offline ($([math]::Round($size, 1)) MB)"
}

if (Test-Path "$PackageDir\suse-packages") {
    $size = (Get-ChildItem "$PackageDir\suse-packages" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    $components += "- ✓ Bundle make + sources GCC ($([math]::Round($size, 1)) MB)"
}

if (Test-Path "$PackageDir\install_tucanos_suse15_offline.sh") {
    $components += "- ✓ Script d'installation automatique"
}

$SummaryContent += ($components -join "`n")

$totalSize = (Get-ChildItem $PackageDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
$SummaryContent += @"


## Taille totale

- **Non compressé :** $([math]::Round($totalSize, 1)) MB
- **Estimé compressé (tar.gz) :** ~$([math]::Round($totalSize * 0.3, 1)) MB

## Installation

1. Transférer le package sur SUSE 15 SP4
2. Extraire : ``tar xzf tucanos-complete-offline-final.tar.gz``
3. Exécuter : ``cd tucanos-complete-offline-final && ./install_tucanos_suse15_offline.sh``

Le script installera automatiquement :
- make (si absent)
- Rust (si absent)
- Tucanos (compilation complète)

## Prérequis sur le serveur

- gcc et g++ (pour compiler make)
- tar et gzip
- sudo (pour installation globale)

Pour installer gcc si nécessaire :
``````bash
sudo zypper install gcc gcc-c++
``````

## Fichiers générés

- ``README_INSTALLATION_COMPLETE.md`` - Documentation complète
- ``VERIFIER_PACKAGE.sh`` - Script de vérification
- ``RESUME_PACKAGE.txt`` - Ce fichier

---

**Package prêt pour déploiement offline !**
"@

$SummaryContent | Out-File -FilePath "$PackageDir\RESUME_PACKAGE.txt" -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ Package créé avec succès !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Dossier : $PackageDir\" -ForegroundColor Cyan
Write-Host "Taille totale : $([math]::Round($totalSize, 1)) MB (non compressé)" -ForegroundColor Cyan
Write-Host ""

Write-Host "Contenu du package :" -ForegroundColor Yellow
Get-ChildItem $PackageDir | Select-Object Mode, @{Name="Taille";Expression={
    if ($_.PSIsContainer) {
        $size = (Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        "$([math]::Round($size, 1)) MB"
    } else {
        "$([math]::Round($_.Length / 1MB, 2)) MB"
    }
}}, Name | Format-Table -AutoSize

Write-Host ""
Write-Host "Prochaines étapes :" -ForegroundColor Yellow
Write-Host "1. Vérifier le package :" -ForegroundColor White
Write-Host "   bash $PackageDir\VERIFIER_PACKAGE.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Compresser le package :" -ForegroundColor White
Write-Host "   tar -czf tucanos-complete-offline-final.tar.gz $PackageDir\" -ForegroundColor Gray
Write-Host "   (sous Linux/WSL ou 7-Zip sous Windows)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "3. Transférer sur SUSE 15 SP4 :" -ForegroundColor White
Write-Host "   scp tucanos-complete-offline-final.tar.gz user@server:/home/user/" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Sur le serveur, installer :" -ForegroundColor White
Write-Host "   tar xzf tucanos-complete-offline-final.tar.gz" -ForegroundColor Gray
Write-Host "   cd tucanos-complete-offline-final" -ForegroundColor Gray
Write-Host "   ./install_tucanos_suse15_offline.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "Documentation complète : $PackageDir\README_INSTALLATION_COMPLETE.md" -ForegroundColor Cyan
Write-Host ""

