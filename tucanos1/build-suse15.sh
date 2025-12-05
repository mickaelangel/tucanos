#!/bin/bash
# Script de compilation Tucanos pour SUSE 15
# Usage: ./build-suse15.sh [--with-metis] [--with-nlopt] [--debug]

set -e

# Configuration
BUILD_DIR="tucanos-build"
INSTALL_DIR="tucanos-install"
RUST_VERSION="1.90.0"
TARGET_ARCH="x86_64-unknown-linux-gnu"

# Options par défaut
WITH_METIS=false
WITH_NLOPT=false
DEBUG_BUILD=false
BUILD_PYTHON=true
BUILD_FFI=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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
        --no-python)
            BUILD_PYTHON=false
            shift
            ;;
        --no-ffi)
            BUILD_FFI=false
            shift
            ;;
        *)
            echo "Option inconnue: $1"
            echo "Usage: $0 [--with-metis] [--with-nlopt] [--debug] [--no-python] [--no-ffi]"
            exit 1
            ;;
    esac
done

echo "=== Compilation de Tucanos pour SUSE 15 ==="
echo "Architecture cible: $TARGET_ARCH"
echo "Avec METIS: $WITH_METIS"
echo "Avec NLOPT: $WITH_NLOPT"
echo "Mode debug: $DEBUG_BUILD"
echo "Build Python: $BUILD_PYTHON"
echo "Build FFI: $BUILD_FFI"
echo ""

# Vérifier les prérequis
echo "=== Vérification des prérequis ==="

# Vérifier Rust
if ! command -v rustc &> /dev/null; then
    echo "ERREUR: Rust n'est pas installé"
    echo "Installez Rust avec: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

RUST_VERSION_INSTALLED=$(rustc --version | cut -d' ' -f2)
echo "Rust version: $RUST_VERSION_INSTALLED"

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
if [ "$BUILD_PYTHON" = true ]; then
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

# Vérifier les dépendances optionnelles
if [ "$WITH_METIS" = true ]; then
    echo "Vérification de METIS..."
    if ! pkg-config --exists metis; then
        echo "ATTENTION: METIS n'est pas trouvé via pkg-config"
        echo "Vous devrez peut-être définir METISDIR dans .cargo/config.toml"
    fi
fi

if [ "$WITH_NLOPT" = true ]; then
    echo "Vérification de NLOPT..."
    if ! pkg-config --exists nlopt; then
        echo "ATTENTION: NLOPT n'est pas trouvé via pkg-config"
        echo "Installez avec: zypper install nlopt-devel"
    fi
fi

echo "Prérequis OK"
echo ""

# Créer les répertoires
echo "=== Préparation des répertoires ==="
mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"
cd "$BUILD_DIR"

# Copier le code source
echo "Copie du code source..."
cp -r ../tucanos-main/* .

echo ""

# Configuration Rust
echo "=== Configuration Rust ==="
rustup target add $TARGET_ARCH

# Configuration Cargo pour SUSE 15
mkdir -p .cargo
cat > .cargo/config.toml << EOF
[target.$TARGET_ARCH]
linker = "gcc"

[env]
# Configuration pour SUSE 15
RUSTFLAGS = "-C target-cpu=native"

EOF

# Ajouter METIS si demandé
if [ "$WITH_METIS" = true ]; then
    echo "METISDIR=\"/usr/local\"" >> .cargo/config.toml
fi

echo "Configuration Rust OK"
echo ""

# Compilation
echo "=== Compilation ==="

# Définir les features
FEATURES=""
if [ "$WITH_METIS" = true ]; then
    FEATURES="$FEATURES --features metis"
fi
if [ "$WITH_NLOPT" = true ]; then
    FEATURES="$FEATURES --features nlopt"
fi

# Mode de compilation
BUILD_MODE="--release"
if [ "$DEBUG_BUILD" = true ]; then
    BUILD_MODE=""
fi

echo "Compilation des bibliothèques Rust..."
cargo build --workspace $BUILD_MODE $FEATURES --target $TARGET_ARCH

echo "Compilation Rust OK"
echo ""

# Compilation FFI si demandé
if [ "$BUILD_FFI" = true ]; then
    echo "=== Compilation FFI ==="
    cargo build --package tucanos-ffi $BUILD_MODE $FEATURES --target $TARGET_ARCH
    
    # Copier les fichiers FFI
    mkdir -p "../$INSTALL_DIR/lib"
    mkdir -p "../$INSTALL_DIR/include"
    
    cp "target/$TARGET_ARCH/release/libtucanos.so" "../$INSTALL_DIR/lib/"
    cp "target/$TARGET_ARCH/release/tucanos.h" "../$INSTALL_DIR/include/"
    
    echo "FFI compilé et installé"
    echo ""
fi

# Compilation Python si demandé
if [ "$BUILD_PYTHON" = true ]; then
    echo "=== Compilation Python bindings ==="
    
    # Installer les dépendances Python
    pip3 install --user maturin
    
    # Compiler pytmesh
    echo "Compilation de pytmesh..."
    cd pytmesh
    maturin build --release --target $TARGET_ARCH $FEATURES
    cd ..
    
    # Compiler pytucanos
    echo "Compilation de pytucanos..."
    cd pytucanos
    maturin build --release --target $TARGET_ARCH $FEATURES
    cd ..
    
    # Copier les wheels
    mkdir -p "../$INSTALL_DIR/python"
    cp pytmesh/target/wheels/*.whl "../$INSTALL_DIR/python/"
    cp pytucanos/target/wheels/*.whl "../$INSTALL_DIR/python/"
    
    echo "Python bindings compilés"
    echo ""
fi

# Créer les scripts d'installation
echo "=== Création des scripts d'installation ==="

# Script d'installation système
cat > "../$INSTALL_DIR/install-system.sh" << 'EOF'
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
EOF

# Script d'installation Python
cat > "../$INSTALL_DIR/install-python.sh" << 'EOF'
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
EOF

# Script de test
cat > "../$INSTALL_DIR/test-installation.sh" << 'EOF'
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

# Documentation d'installation
cat > "../$INSTALL_DIR/README-INSTALL.md" << EOF
# Installation de Tucanos pour SUSE 15

## Contenu du package

- \`lib/\`: Bibliothèques partagées (.so)
- \`include/\`: En-têtes C/C++ (.h)
- \`python/\`: Packages Python (.whl)
- \`install-system.sh\`: Script d'installation système
- \`install-python.sh\`: Script d'installation Python
- \`test-installation.sh\`: Script de test

## Installation

### 1. Installation système (requiert root)

\`\`\`bash
sudo ./install-system.sh
\`\`\`

### 2. Installation Python

\`\`\`bash
./install-python.sh
\`\`\`

### 3. Test de l'installation

\`\`\`bash
./test-installation.sh
\`\`\`

## Utilisation

### En C/C++

\`\`\`c
#include <tucanos.h>
// Compiler avec: gcc -ltucanos
\`\`\`

### En Python

\`\`\`python
import pytmesh
import pytucanos
\`\`\`

## Configuration compilée

- Architecture: $TARGET_ARCH
- METIS: $WITH_METIS
- NLOPT: $WITH_NLOPT
- Mode debug: $DEBUG_BUILD
- Build Python: $BUILD_PYTHON
- Build FFI: $BUILD_FFI

## Dépendances système requises

- gcc/g++
- make
- pkg-config
- python3 (si bindings Python installés)
- pip3 (si bindings Python installés)

## Dépendances optionnelles

- METIS (pour le partitionnement de maillage)
- NLOPT (pour le lissage)
EOF

# Rendre les scripts exécutables
chmod +x "../$INSTALL_DIR"/*.sh

echo "=== Compilation terminée ==="
echo "Package d'installation créé dans: $INSTALL_DIR"
echo ""
echo "Pour installer sur la machine SUSE 15:"
echo "1. Copiez le dossier $INSTALL_DIR sur la machine cible"
echo "2. Exécutez: cd $INSTALL_DIR && sudo ./install-system.sh"
echo "3. Exécutez: ./install-python.sh (si nécessaire)"
echo "4. Testez avec: ./test-installation.sh"
echo ""
echo "Documentation complète dans: $INSTALL_DIR/README-INSTALL.md"






