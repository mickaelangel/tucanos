# Script pour créer un package de compilation complet pour SUSE 15
# Ce package contient tout le nécessaire pour compiler Tucanos sur SUSE 15

param(
    [switch]$WithMetis,
    [switch]$WithNlopt,
    [switch]$Debug
)

Write-Host "=== Création du package de compilation pour SUSE 15 ===" -ForegroundColor Green

# Configuration
$SourceDir = "tucanos-main"
$PackageDir = "tucanos-suse15-build-package"
$RustVersion = "1.90.0"

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  METIS: $WithMetis" -ForegroundColor White
Write-Host "  NLOPT: $WithNlopt" -ForegroundColor White
Write-Host "  Debug: $Debug" -ForegroundColor White
Write-Host ""

# Nettoyer et créer le package
if (Test-Path $PackageDir) {
    Remove-Item -Recurse -Force $PackageDir
}
New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

# Copier le code source
Write-Host "=== Copie du code source ===" -ForegroundColor Green
Copy-Item -Path "$SourceDir\*" -Destination $PackageDir -Recurse -Force

# Créer le script de compilation pour SUSE 15
Write-Host "=== Création du script de compilation ===" -ForegroundColor Green

$BuildScript = @"
#!/bin/bash
# Script de compilation Tucanos pour SUSE 15
# Usage: ./build-tucanos.sh [--with-metis] [--with-nlopt] [--debug]

set -e

# Configuration
BUILD_DIR="."
INSTALL_DIR="tucanos-install"
RUST_VERSION="$RustVersion"

# Options par défaut
WITH_METIS=$($WithMetis.ToString().ToLower())
WITH_NLOPT=$($WithNlopt.ToString().ToLower())
DEBUG_BUILD=$($Debug.ToString().ToLower())

# Parse arguments
while [[ `$# -gt 0 ]]; do
    case `$1 in
        --with-metis)
            WITH_METIS=true
            shift
            ;;
        --with-nlopt)
            WITH_NLOPT=true
            shift
            ;;
        --debug)
            DEBUG_BUILD=true
            shift
            ;;
        *)
            echo "Option inconnue: `$1"
            echo "Usage: `$0 [--with-metis] [--with-nlopt] [--debug]"
            exit 1
            ;;
    esac
done

echo "=== Compilation de Tucanos pour SUSE 15 ==="
echo "Avec METIS: `$WITH_METIS"
echo "Avec NLOPT: `$WITH_NLOPT"
echo "Mode debug: `$DEBUG_BUILD"
echo ""

# Vérifier les prérequis
echo "=== Vérification des prérequis ==="

# Vérifier Rust
if ! command -v rustc &> /dev/null; then
    echo "Installation de Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
fi

RUST_VERSION_INSTALLED=`$(rustc --version | cut -d' ' -f2)
echo "Rust version: `$RUST_VERSION_INSTALLED"

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

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    echo "ERREUR: Python3 n'est pas installé"
    echo "Installez avec: zypper install python3 python3-devel python3-pip"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo "ERREUR: pip3 n'est pas installé"
    echo "Installez avec: zypper install python3-pip"
    exit 1
fi

# Vérifier les dépendances optionnelles
if [ "`$WITH_METIS" = true ]; then
    echo "Vérification de METIS..."
    if ! pkg-config --exists metis; then
        echo "ATTENTION: METIS n'est pas trouvé via pkg-config"
        echo "Vous devrez peut-être définir METISDIR dans .cargo/config.toml"
    fi
fi

if [ "`$WITH_NLOPT" = true ]; then
    echo "Vérification de NLOPT..."
    if ! pkg-config --exists nlopt; then
        echo "ATTENTION: NLOPT n'est pas trouvé via pkg-config"
        echo "Installez avec: zypper install nlopt-devel"
    fi
fi

echo "Prérequis OK"
echo ""

# Configuration Rust
echo "=== Configuration Rust ==="

# Configuration Cargo pour SUSE 15
mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[env]
# Configuration pour SUSE 15
RUSTFLAGS = "-C target-cpu=native"
EOF

# Ajouter METIS si demandé
if [ "`$WITH_METIS" = true ]; then
    echo "METISDIR=`"/usr/local`"" >> .cargo/config.toml
fi

echo "Configuration Rust OK"
echo ""

# Compilation
echo "=== Compilation ==="

# Définir les features
FEATURES=""
if [ "`$WITH_METIS" = true ]; then
    FEATURES="`$FEATURES --features metis"
fi
if [ "`$WITH_NLOPT" = true ]; then
    FEATURES="`$FEATURES --features nlopt"
fi

# Mode de compilation
BUILD_MODE="--release"
if [ "`$DEBUG_BUILD" = true ]; then
    BUILD_MODE=""
fi

echo "Compilation des bibliothèques Rust..."
echo "Features: `$FEATURES"
echo "Mode: `$BUILD_MODE"

cargo build --workspace `$BUILD_MODE `$FEATURES

echo "Compilation Rust OK"
echo ""

# Compilation FFI
echo "=== Compilation FFI ==="
cargo build --package tucanos-ffi `$BUILD_MODE `$FEATURES

# Créer le répertoire d'installation
mkdir -p "`$INSTALL_DIR/lib"
mkdir -p "`$INSTALL_DIR/include"

# Copier les fichiers FFI
cp "target/release/libtucanos.so" "`$INSTALL_DIR/lib/"
cp "target/release/tucanos.h" "`$INSTALL_DIR/include/"

echo "FFI compilé et installé"
echo ""

# Compilation Python
echo "=== Compilation Python bindings ==="

# Installer maturin
pip3 install --user maturin

# Compiler pytmesh
echo "Compilation de pytmesh..."
cd pytmesh
maturin build --release `$FEATURES
cd ..

# Compiler pytucanos
echo "Compilation de pytucanos..."
cd pytucanos
maturin build --release `$FEATURES
cd ..

# Copier les wheels
mkdir -p "`$INSTALL_DIR/python"
cp pytmesh/target/wheels/*.whl "`$INSTALL_DIR/python/"
cp pytucanos/target/wheels/*.whl "`$INSTALL_DIR/python/"

echo "Python bindings compilés"
echo ""

# Créer les scripts d'installation
echo "=== Création des scripts d'installation ==="

# Script d'installation système
cat > "`$INSTALL_DIR/install-system.sh" << 'EOF'
#!/bin/bash
# Installation système de Tucanos

set -e

INSTALL_PREFIX="/usr/local"
LIB_DIR="`$INSTALL_PREFIX/lib"
INCLUDE_DIR="`$INSTALL_PREFIX/include"

echo "=== Installation système de Tucanos ==="

# Vérifier les permissions
if [ "`$EUID" -ne 0 ]; then
    echo "ERREUR: Ce script doit être exécuté en tant que root"
    echo "Utilisez: sudo ./install-system.sh"
    exit 1
fi

# Créer les répertoires
mkdir -p "`$LIB_DIR"
mkdir -p "`$INCLUDE_DIR"

# Installer les bibliothèques
echo "Installation des bibliothèques..."
cp lib/*.so "`$LIB_DIR/"

# Installer les en-têtes
echo "Installation des en-têtes..."
cp include/*.h "`$INCLUDE_DIR/"

# Mettre à jour ldconfig
echo "Mise à jour du cache des bibliothèques..."
ldconfig

echo ""
echo "=== Installation système terminée ==="
echo "Les bibliothèques sont installées dans `$LIB_DIR"
echo "Les en-têtes sont installés dans `$INCLUDE_DIR"
EOF

# Script d'installation Python
cat > "`$INSTALL_DIR/install-python.sh" << 'EOF'
#!/bin/bash
# Installation des bindings Python

set -e

echo "=== Installation des bindings Python ==="

# Installer les wheels
echo "Installation des packages Python..."
pip3 install --user python/*.whl

echo ""
echo "=== Installation Python terminée ==="
echo "Vous pouvez maintenant importer pytmesh et pytucanos"
EOF

# Script de test
cat > "`$INSTALL_DIR/test-installation.sh" << 'EOF'
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
EOF

# Rendre les scripts exécutables
chmod +x "`$INSTALL_DIR"/*.sh

echo "=== Compilation terminée ==="
echo "Package d'installation créé dans: `$INSTALL_DIR"
echo ""
echo "Pour installer:"
echo "1. cd `$INSTALL_DIR"
echo "2. sudo ./install-system.sh"
echo "3. ./install-python.sh"
echo "4. ./test-installation.sh"
"@

$BuildScript | Out-File -FilePath "$PackageDir/build-tucanos.sh" -Encoding UTF8

# Créer un script d'installation automatique des dépendances
$DepsScript = @'
#!/bin/bash
# Installation automatique des dépendances pour SUSE 15

set -e

echo "=== Installation des dépendances pour Tucanos sur SUSE 15 ==="

# Vérifier que nous sommes sur SUSE
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse" && "$ID" != "sles" ]]; then
    echo "ATTENTION: Ce script est conçu pour SUSE Linux"
    echo "Distribution détectée: $PRETTY_NAME"
    read -p "Continuer quand même? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Distribution: $PRETTY_NAME"
echo ""

# Mise à jour du système
echo "=== Mise à jour du système ==="
sudo zypper refresh

# Installation des dépendances de base
echo "=== Installation des dépendances de base ==="
sudo zypper install -y gcc gcc-c++ make pkg-config

# Installation de Python
echo "=== Installation de Python ==="
sudo zypper install -y python3 python3-devel python3-pip

# Installation de Rust
echo "=== Installation de Rust ==="
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    echo "Rust installé"
else
    echo "Rust déjà installé: $(rustc --version)"
fi

# Installation des dépendances optionnelles
echo "=== Installation des dépendances optionnelles ==="

# METIS (optionnel)
read -p "Installer METIS pour le partitionnement de maillage? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation de METIS..."
    # Note: METIS n'est pas dans les dépôts standard de SUSE
    echo "ATTENTION: METIS n'est pas disponible dans les dépôts standard de SUSE"
    echo "Vous devrez l'installer manuellement depuis https://github.com/KarypisLab/METIS"
fi

# NLOPT (optionnel)
read -p "Installer NLOPT pour l'optimisation? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation de NLOPT..."
    sudo zypper install -y nlopt-devel
fi

echo ""
echo "=== Installation des dépendances terminée ==="
echo "Vous pouvez maintenant compiler Tucanos avec:"
echo "  ./build-tucanos.sh"
'@

$DepsScript | Out-File -FilePath "$PackageDir/install-dependencies.sh" -Encoding UTF8

# Créer la documentation
$ReadmeContent = @"
# Package de compilation Tucanos pour SUSE 15

## Description

Ce package contient tout le nécessaire pour compiler et installer Tucanos sur SUSE 15.

## Contenu

- **Code source** : Dépôt complet de Tucanos
- **Scripts de compilation** : Automatisation de la compilation
- **Scripts d'installation** : Installation des dépendances et du logiciel
- **Documentation** : Instructions complètes

## Installation rapide

### 1. Installation des dépendances

```bash
chmod +x install-dependencies.sh
./install-dependencies.sh
```

### 2. Compilation

```bash
chmod +x build-tucanos.sh
./build-tucanos.sh
```

### 3. Installation

```bash
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh
```

## Installation manuelle

### Prérequis système

```bash
# Mise à jour du système
sudo zypper refresh

# Dépendances de base
sudo zypper install gcc gcc-c++ make pkg-config

# Python
sudo zypper install python3 python3-devel python3-pip

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
```

### Dépendances optionnelles

```bash
# NLOPT (pour l'optimisation)
sudo zypper install nlopt-devel

# METIS (pour le partitionnement - installation manuelle requise)
# Téléchargez depuis: https://github.com/KarypisLab/METIS
```

### Compilation

```bash
# Compilation standard
./build-tucanos.sh

# Avec METIS
./build-tucanos.sh --with-metis

# Avec NLOPT
./build-tucanos.sh --with-nlopt

# Mode debug
./build-tucanos.sh --debug

# Toutes les options
./build-tucanos.sh --with-metis --with-nlopt --debug
```

## Configuration compilée

- **Architecture** : x86_64-unknown-linux-gnu
- **METIS** : $WithMetis
- **NLOPT** : $WithNlopt
- **Mode debug** : $Debug

## Utilisation après installation

### En C/C++

```c
#include <tucanos.h>

int main() {
    tucanos_init_log();
    // Votre code ici
    return 0;
}
```

Compilation :
```bash
gcc -I/usr/local/include -L/usr/local/lib -ltucanos votre_programme.c -o votre_programme
```

### En Python

```python
import pytmesh
import pytucanos

# Votre code Python ici
```

## Structure du package

```
tucanos-suse15-build-package/
├── build-tucanos.sh           # Script de compilation principal
├── install-dependencies.sh    # Installation des dépendances
├── tucanos/                   # Code source principal
├── tmesh/                     # Code source tmesh
├── pytmesh/                   # Bindings Python pytmesh
├── pytucanos/                 # Bindings Python pytucanos
├── tucanos-ffi/              # Interface FFI
└── README-INSTALL.md          # Cette documentation
```

## Dépannage

### Erreur de compilation Rust

```bash
# Vérifier la version de Rust
rustc --version

# Mettre à jour Rust
rustup update
```

### Erreur de dépendances système

```bash
# Vérifier les dépendances
pkg-config --list-all | grep -E "(metis|nlopt)"

# Installer les dépendances manquantes
sudo zypper install gcc gcc-c++ make pkg-config
```

### Erreur Python

```bash
# Vérifier Python
python3 --version
pip3 --version

# Réinstaller les bindings
pip3 install --user --force-reinstall tucanos-install/python/*.whl
```

## Support

- **Documentation officielle** : https://github.com/tucanos/tucanos
- **Issues** : https://github.com/tucanos/tucanos/issues
- **Licence** : LGPL-2.1

## Notes techniques

- Compilé avec Rust $RustVersion
- Optimisé pour SUSE 15 (x86_64)
- Compatible avec SUSE Linux Enterprise Server 15 et openSUSE Leap 15.x
- Support des fonctionnalités optionnelles selon la configuration
"@

$ReadmeContent | Out-File -FilePath "$PackageDir/README-INSTALL.md" -Encoding UTF8

# Créer un script de déploiement complet
$DeployScript = @'
#!/bin/bash
# Déploiement complet de Tucanos sur SUSE 15

set -e

echo "=== Déploiement complet de Tucanos sur SUSE 15 ==="

# Vérifier les permissions
if [ "$EUID" -eq 0 ]; then
    echo "ERREUR: Ne pas exécuter ce script en tant que root"
    echo "Ce script vous demandera sudo quand nécessaire"
    exit 1
fi

# Installation des dépendances
echo "=== Installation des dépendances ==="
chmod +x install-dependencies.sh
./install-dependencies.sh

# Compilation
echo "=== Compilation de Tucanos ==="
chmod +x build-tucanos.sh
./build-tucanos.sh

# Installation
echo "=== Installation de Tucanos ==="
cd tucanos-install
sudo ./install-system.sh
./install-python.sh

# Test
echo "=== Test de l'installation ==="
./test-installation.sh

echo ""
echo "=== Déploiement terminé ==="
echo "Tucanos est maintenant installé et testé sur votre système SUSE 15"
echo ""
echo "Vous pouvez maintenant utiliser:"
echo "  - Les bibliothèques C/C++ : #include <tucanos.h>"
echo "  - Les bindings Python : import pytmesh, pytucanos"
'@

$DeployScript | Out-File -FilePath "$PackageDir/deploy-complete.sh" -Encoding UTF8

# Créer un fichier de vérification
$VerificationFile = @"
# Package de compilation Tucanos pour SUSE 15

Date de création: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Configuration: METIS=$WithMetis, NLOPT=$WithNlopt, Debug=$Debug

Contenu du package:
- Code source: ✓
- Script de compilation: ✓
- Script d'installation des dépendances: ✓
- Script de déploiement complet: ✓
- Documentation: ✓

Instructions de déploiement:
1. Copiez ce dossier sur votre machine SUSE 15
2. Exécutez: chmod +x *.sh
3. Exécutez: ./deploy-complete.sh

OU installation manuelle:
1. ./install-dependencies.sh
2. ./build-tucanos.sh
3. cd tucanos-install && sudo ./install-system.sh && ./install-python.sh

Documentation complète: README-INSTALL.md
"@

$VerificationFile | Out-File -FilePath "$PackageDir/VERIFICATION.txt" -Encoding UTF8

Write-Host ""
Write-Host "=== PACKAGE CRÉÉ ===" -ForegroundColor Green
Write-Host ""
Write-Host "Package de compilation: $PackageDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Contenu du package:" -ForegroundColor White
Get-ChildItem -Path $PackageDir -Recurse | ForEach-Object {
    Write-Host "  $($_.FullName.Replace((Get-Location).Path + '\', ''))" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "Instructions de déploiement:" -ForegroundColor Yellow
Write-Host "1. Copiez le dossier '$PackageDir' sur votre machine SUSE 15" -ForegroundColor White
Write-Host "2. Sur SUSE 15, exécutez:" -ForegroundColor White
Write-Host "   cd $PackageDir" -ForegroundColor Cyan
Write-Host "   chmod +x *.sh" -ForegroundColor Cyan
Write-Host "   ./deploy-complete.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "OU installation manuelle:" -ForegroundColor Yellow
Write-Host "   ./install-dependencies.sh" -ForegroundColor Cyan
Write-Host "   ./build-tucanos.sh" -ForegroundColor Cyan
Write-Host "   cd tucanos-install && sudo ./install-system.sh && ./install-python.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "Documentation complète: $PackageDir/README-INSTALL.md" -ForegroundColor Green





