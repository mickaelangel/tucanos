# Script PowerShell pour préparer la compilation de Tucanos pour SUSE 15
# Usage: .\prepare-tucanos.ps1

param(
    [switch]$WithMetis,
    [switch]$WithNlopt,
    [switch]$Debug,
    [switch]$NoPython,
    [switch]$NoFfi
)

Write-Host "=== Préparation de Tucanos pour SUSE 15 ===" -ForegroundColor Green

# Configuration
$BuildDir = "tucanos-build"
$InstallDir = "tucanos-install"
$RustVersion = "1.90.0"
$TargetArch = "x86_64-unknown-linux-gnu"

Write-Host "Architecture cible: $TargetArch" -ForegroundColor Yellow
Write-Host "Avec METIS: $WithMetis" -ForegroundColor Yellow
Write-Host "Avec NLOPT: $WithNlopt" -ForegroundColor Yellow
Write-Host "Mode debug: $Debug" -ForegroundColor Yellow
Write-Host "Build Python: $(-not $NoPython)" -ForegroundColor Yellow
Write-Host "Build FFI: $(-not $NoFfi)" -ForegroundColor Yellow
Write-Host ""

# Vérifier les prérequis
Write-Host "=== Vérification des prérequis ===" -ForegroundColor Green

# Vérifier Rust
try {
    $rustVersion = rustc --version
    Write-Host "Rust trouvé: $rustVersion" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Rust n'est pas installé" -ForegroundColor Red
    Write-Host "Installez Rust avec: https://rustup.rs/" -ForegroundColor Yellow
    exit 1
}

# Vérifier Git (optionnel, pour cloner si nécessaire)
try {
    $gitVersion = git --version
    Write-Host "Git trouvé: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "ATTENTION: Git n'est pas installé" -ForegroundColor Yellow
    Write-Host "Le code source sera téléchargé via PowerShell" -ForegroundColor Yellow
}

Write-Host "Prérequis OK" -ForegroundColor Green
Write-Host ""

# Créer les répertoires
Write-Host "=== Préparation des répertoires ===" -ForegroundColor Green
if (Test-Path $BuildDir) {
    Remove-Item -Recurse -Force $BuildDir
}
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
}

New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

Write-Host "Répertoires créés" -ForegroundColor Green
Write-Host ""

# Télécharger le code source si pas déjà fait
Write-Host "=== Téléchargement du code source ===" -ForegroundColor Green

$SourceZip = "tucanos-main.zip"
if (-not (Test-Path $SourceZip)) {
    Write-Host "Téléchargement de Tucanos depuis GitHub..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/tucanos/tucanos/archive/refs/heads/main.zip" -OutFile $SourceZip
        Write-Host "Téléchargement terminé" -ForegroundColor Green
    } catch {
        Write-Host "ERREUR lors du téléchargement: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Archive déjà présente: $SourceZip" -ForegroundColor Green
}

# Extraire l'archive
Write-Host "Extraction de l'archive..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $SourceZip -DestinationPath $BuildDir -Force
    Write-Host "Extraction terminée" -ForegroundColor Green
} catch {
    Write-Host "ERREUR lors de l'extraction: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Créer le script de compilation personnalisé
Write-Host "=== Création du script de compilation ===" -ForegroundColor Green

$BuildScript = @"
#!/bin/bash
# Script de compilation Tucanos pour SUSE 15 (généré automatiquement)

set -e

# Configuration
BUILD_DIR="."
INSTALL_DIR="../$InstallDir"
TARGET_ARCH="$TargetArch"

# Options
WITH_METIS=$($WithMetis.ToString().ToLower())
WITH_NLOPT=$($WithNlopt.ToString().ToLower())
DEBUG_BUILD=$($Debug.ToString().ToLower())
BUILD_PYTHON=$((-not $NoPython).ToString().ToLower())
BUILD_FFI=$((-not $NoFfi).ToString().ToLower())

echo "=== Compilation de Tucanos pour SUSE 15 ==="
echo "Architecture cible: \$TARGET_ARCH"
echo "Avec METIS: \$WITH_METIS"
echo "Avec NLOPT: \$WITH_NLOPT"
echo "Mode debug: \$DEBUG_BUILD"
echo "Build Python: \$BUILD_PYTHON"
echo "Build FFI: \$BUILD_FFI"
echo ""

# Vérifier les prérequis
echo "=== Vérification des prérequis ==="

# Vérifier Rust
if ! command -v rustc &> /dev/null; then
    echo "ERREUR: Rust n'est pas installé"
    echo "Installez Rust avec: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

RUST_VERSION_INSTALLED=\$(rustc --version | cut -d' ' -f2)
echo "Rust version: \$RUST_VERSION_INSTALLED"

# Vérifier les dépendances système
echo "Vérification des dépendances système..."

# Vérifier gcc/g++
if ! command -v gcc &> /dev/null; then
    echo "ERREUR: gcc n'est pas installé"
    echo "Installez avec: zypper install gcc gcc-c++"
    exit 1
fi

# Vérifier make
if ! command -v make &> /dev/null; then
    echo "ERREUR: make n'est pas installé"
    echo "Installez avec: zypper install make"
    exit 1
fi

# Vérifier pkg-config
if ! command -v pkg-config &> /dev/null; then
    echo "ERREUR: pkg-config n'est pas installé"
    echo "Installez avec: zypper install pkg-config"
    exit 1
fi

# Vérifier Python si nécessaire
if [ "\$BUILD_PYTHON" = true ]; then
    if ! command -v python3 &> /dev/null; then
        echo "ERREUR: Python3 n'est pas installé"
        echo "Installez avec: zypper install python3 python3-devel"
        exit 1
    fi
    
    if ! command -v pip3 &> /dev/null; then
        echo "ERREUR: pip3 n'est pas installé"
        echo "Installez avec: zypper install python3-pip"
        exit 1
    fi
fi

echo "Prérequis OK"
echo ""

# Configuration Rust
echo "=== Configuration Rust ==="
rustup target add \$TARGET_ARCH

# Configuration Cargo pour SUSE 15
mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[target.\$TARGET_ARCH]
linker = "gcc"

[env]
# Configuration pour SUSE 15
RUSTFLAGS = "-C target-cpu=native"
EOF

# Ajouter METIS si demandé
if [ "\$WITH_METIS" = true ]; then
    echo "METISDIR=\"/usr/local\"" >> .cargo/config.toml
fi

echo "Configuration Rust OK"
echo ""

# Compilation
echo "=== Compilation ==="

# Définir les features
FEATURES=""
if [ "\$WITH_METIS" = true ]; then
    FEATURES="\$FEATURES --features metis"
fi
if [ "\$WITH_NLOPT" = true ]; then
    FEATURES="\$FEATURES --features nlopt"
fi

# Mode de compilation
BUILD_MODE="--release"
if [ "\$DEBUG_BUILD" = true ]; then
    BUILD_MODE=""
fi

echo "Compilation des bibliothèques Rust..."
cargo build --workspace \$BUILD_MODE \$FEATURES --target \$TARGET_ARCH

echo "Compilation Rust OK"
echo ""

# Compilation FFI si demandé
if [ "\$BUILD_FFI" = true ]; then
    echo "=== Compilation FFI ==="
    cargo build --package tucanos-ffi \$BUILD_MODE \$FEATURES --target \$TARGET_ARCH
    
    # Copier les fichiers FFI
    mkdir -p "\$INSTALL_DIR/lib"
    mkdir -p "\$INSTALL_DIR/include"
    
    cp "target/\$TARGET_ARCH/release/libtucanos.so" "\$INSTALL_DIR/lib/"
    cp "target/\$TARGET_ARCH/release/tucanos.h" "\$INSTALL_DIR/include/"
    
    echo "FFI compilé et installé"
    echo ""
fi

# Compilation Python si demandé
if [ "\$BUILD_PYTHON" = true ]; then
    echo "=== Compilation Python bindings ==="
    
    # Installer les dépendances Python
    pip3 install --user maturin
    
    # Compiler pytmesh
    echo "Compilation de pytmesh..."
    cd pytmesh
    maturin build --release --target \$TARGET_ARCH \$FEATURES
    cd ..
    
    # Compiler pytucanos
    echo "Compilation de pytucanos..."
    cd pytucanos
    maturin build --release --target \$TARGET_ARCH \$FEATURES
    cd ..
    
    # Copier les wheels
    mkdir -p "\$INSTALL_DIR/python"
    cp pytmesh/target/wheels/*.whl "\$INSTALL_DIR/python/"
    cp pytucanos/target/wheels/*.whl "\$INSTALL_DIR/python/"
    
    echo "Python bindings compilés"
    echo ""
fi

echo "=== Compilation terminée ==="
echo "Package d'installation créé dans: \$INSTALL_DIR"
"@

$BuildScript | Out-File -FilePath "$BuildDir/build-tucanos.sh" -Encoding UTF8

# Créer les scripts d'installation
Write-Host "=== Création des scripts d'installation ===" -ForegroundColor Green

# Script d'installation système
$InstallSystemScript = @'
#!/bin/bash
# Installation système de Tucanos

set -e

INSTALL_PREFIX="/usr/local"
LIB_DIR="$INSTALL_PREFIX/lib"
INCLUDE_DIR="$INSTALL_PREFIX/include"

echo "=== Installation système de Tucanos ==="

# Vérifier les permissions
if [ "$EUID" -ne 0 ]; then
    echo "ERREUR: Ce script doit être exécuté en tant que root"
    exit 1
fi

# Créer les répertoires
mkdir -p "$LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# Installer les bibliothèques
echo "Installation des bibliothèques..."
cp lib/*.so "$LIB_DIR/"
cp include/*.h "$INCLUDE_DIR/"

# Mettre à jour ldconfig
echo "Mise à jour du cache des bibliothèques..."
ldconfig

echo "Installation système terminée"
echo "Les bibliothèques sont installées dans $LIB_DIR"
echo "Les en-têtes sont installés dans $INCLUDE_DIR"
'@

$InstallSystemScript | Out-File -FilePath "$InstallDir/install-system.sh" -Encoding UTF8

# Script d'installation Python
$InstallPythonScript = @'
#!/bin/bash
# Installation des bindings Python

set -e

echo "=== Installation des bindings Python ==="

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    echo "ERREUR: Python3 n'est pas installé"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo "ERREUR: pip3 n'est pas installé"
    exit 1
fi

# Installer les wheels
echo "Installation des packages Python..."
pip3 install --user python/*.whl

echo "Installation Python terminée"
echo "Vous pouvez maintenant importer pytmesh et pytucanos"
'@

$InstallPythonScript | Out-File -FilePath "$InstallDir/install-python.sh" -Encoding UTF8

# Script de test
$TestScript = @'
#!/bin/bash
# Test de l'installation de Tucanos

set -e

echo "=== Test de l'installation de Tucanos ==="

# Test FFI
echo "Test des bibliothèques FFI..."
if [ -f "lib/libtucanos.so" ]; then
    echo "✓ Bibliothèque FFI trouvée"
    ldd lib/libtucanos.so | head -5
else
    echo "✗ Bibliothèque FFI non trouvée"
fi

# Test Python
echo "Test des bindings Python..."
if command -v python3 &> /dev/null; then
    python3 -c "
try:
    import pytmesh
    print('✓ pytmesh importé avec succès')
except ImportError as e:
    print(f'✗ Erreur import pytmesh: {e}')

try:
    import pytucanos
    print('✓ pytucanos importé avec succès')
except ImportError as e:
    print(f'✗ Erreur import pytucanos: {e}')
"
else
    echo "✗ Python3 non disponible"
fi

echo "Test terminé"
'@

$TestScript | Out-File -FilePath "$InstallDir/test-installation.sh" -Encoding UTF8

# Documentation
$ReadmeContent = @"
# Installation de Tucanos pour SUSE 15

## Contenu du package

- `lib/`: Bibliothèques partagées (.so)
- `include/`: En-têtes C/C++ (.h)
- `python/`: Packages Python (.whl)
- `install-system.sh`: Script d'installation système
- `install-python.sh`: Script d'installation Python
- `test-installation.sh`: Script de test

## Installation

### 1. Installation système (requiert root)

```bash
sudo ./install-system.sh
```

### 2. Installation Python

```bash
./install-python.sh
```

### 3. Test de l'installation

```bash
./test-installation.sh
```

## Utilisation

### En C/C++

```c
#include <tucanos.h>
// Compiler avec: gcc -ltucanos
```

### En Python

```python
import pytmesh
import pytucanos
```

## Configuration compilée

- Architecture: $TargetArch
- METIS: $WithMetis
- NLOPT: $WithNlopt
- Mode debug: $Debug
- Build Python: $(-not $NoPython)
- Build FFI: $(-not $NoFfi)

## Dépendances système requises

- gcc/g++
- make
- pkg-config
- python3 (si bindings Python installés)
- pip3 (si bindings Python installés)

## Dépendances optionnelles

- METIS (pour le partitionnement de maillage)
- NLOPT (pour le lissage)

## Instructions de déploiement

1. Copiez le dossier `$InstallDir` sur la machine SUSE 15
2. Sur la machine SUSE 15, exécutez:
   ```bash
   cd $InstallDir
   sudo ./install-system.sh
   ./install-python.sh  # si nécessaire
   ./test-installation.sh
   ```

## Compilation sur la machine cible

Si vous préférez compiler directement sur la machine SUSE 15:

1. Copiez le dossier `$BuildDir` sur la machine cible
2. Sur la machine SUSE 15, exécutez:
   ```bash
   cd $BuildDir
   chmod +x build-tucanos.sh
   ./build-tucanos.sh
   ```
"@

$ReadmeContent | Out-File -FilePath "$InstallDir/README-INSTALL.md" -Encoding UTF8

# Créer un script de déploiement
$DeployScript = @"
#!/bin/bash
# Script de déploiement pour SUSE 15

set -e

echo "=== Déploiement de Tucanos sur SUSE 15 ==="

# Vérifier que nous sommes sur SUSE
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
if [[ "\$ID" != "opensuse" && "\$ID" != "sles" ]]; then
    echo "ATTENTION: Ce script est conçu pour SUSE Linux"
    echo "Distribution détectée: \$PRETTY_NAME"
    read -p "Continuer quand même? (y/N): " -n 1 -r
    echo
    if [[ ! \$REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Distribution: \$PRETTY_NAME"
echo ""

# Installer les dépendances système
echo "=== Installation des dépendances système ==="
echo "Mise à jour du système..."
zypper refresh

echo "Installation des outils de développement..."
zypper install -y gcc gcc-c++ make pkg-config

echo "Installation de Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

echo "Installation de Python (si nécessaire)..."
zypper install -y python3 python3-devel python3-pip

echo "Dépendances installées"
echo ""

# Exécuter la compilation
echo "=== Compilation de Tucanos ==="
if [ -f "build-tucanos.sh" ]; then
    chmod +x build-tucanos.sh
    ./build-tucanos.sh
else
    echo "ERREUR: Script de compilation non trouvé"
    exit 1
fi

echo "=== Déploiement terminé ==="
"@

$DeployScript | Out-File -FilePath "$InstallDir/deploy-suse15.sh" -Encoding UTF8

Write-Host "=== Préparation terminée ===" -ForegroundColor Green
Write-Host ""
Write-Host "Structure créée:" -ForegroundColor Yellow
Write-Host "  $BuildDir/ - Code source et script de compilation" -ForegroundColor White
Write-Host "  $InstallDir/ - Package d'installation" -ForegroundColor White
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Copiez le dossier '$BuildDir' sur la machine SUSE 15" -ForegroundColor White
Write-Host "2. Sur la machine SUSE 15, exécutez:" -ForegroundColor White
Write-Host "   cd $BuildDir" -ForegroundColor Cyan
Write-Host "   chmod +x build-tucanos.sh" -ForegroundColor Cyan
Write-Host "   ./build-tucanos.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "OU utilisez le package pré-compilé:" -ForegroundColor Yellow
Write-Host "1. Copiez le dossier '$InstallDir' sur la machine SUSE 15" -ForegroundColor White
Write-Host "2. Sur la machine SUSE 15, exécutez:" -ForegroundColor White
Write-Host "   cd $InstallDir" -ForegroundColor Cyan
Write-Host "   sudo ./install-system.sh" -ForegroundColor Cyan
Write-Host "   ./install-python.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "Documentation complète dans: $InstallDir/README-INSTALL.md" -ForegroundColor Green






