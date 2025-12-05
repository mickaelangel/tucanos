#!/bin/bash
# Script de compilation Tucanos pour SUSE 15
# Usage: ./build-tucanos.sh [--with-metis] [--with-nlopt] [--debug]

set -e

# Configuration
BUILD_DIR="."
INSTALL_DIR="tucanos-install"
RUST_VERSION="1.90.0"

# Options par dÃ©faut
WITH_METIS=true
WITH_NLOPT=true
DEBUG_BUILD=false

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
        *)
            echo "Option inconnue: $1"
            echo "Usage: $0 [--with-metis] [--with-nlopt] [--debug]"
            exit 1
            ;;
    esac
done

echo "=== Compilation de Tucanos pour SUSE 15 ==="
echo "Avec METIS: $WITH_METIS"
echo "Avec NLOPT: $WITH_NLOPT"
echo "Mode debug: $DEBUG_BUILD"
echo ""

# VÃ©rifier les prÃ©requis
echo "=== VÃ©rification des prÃ©requis ==="

# VÃ©rifier Rust
if ! command -v rustc &> /dev/null; then
    echo "Installation de Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
fi

RUST_VERSION_INSTALLED=$(rustc --version | cut -d' ' -f2)
echo "Rust version: $RUST_VERSION_INSTALLED"

# VÃ©rifier les dÃ©pendances systÃ¨me
echo "VÃ©rification des dÃ©pendances systÃ¨me..."

# VÃ©rifier gcc/g++
if ! command -v gcc &> /dev/null; then
    echo "ERREUR: gcc n'est pas installÃ©"
    echo "Installez avec: zypper install gcc gcc-c++"
    exit 1
fi

# VÃ©rifier make
if ! command -v make &> /dev/null; then
    echo "ERREUR: make n'est pas installÃ©"
    echo "Installez avec: zypper install make"
    exit 1
fi

# VÃ©rifier pkg-config
if ! command -v pkg-config &> /dev/null; then
    echo "ERREUR: pkg-config n'est pas installÃ©"
    echo "Installez avec: zypper install pkg-config"
    exit 1
fi

# VÃ©rifier Python
if ! command -v python3 &> /dev/null; then
    echo "ERREUR: Python3 n'est pas installÃ©"
    echo "Installez avec: zypper install python3 python3-devel python3-pip"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo "ERREUR: pip3 n'est pas installÃ©"
    echo "Installez avec: zypper install python3-pip"
    exit 1
fi

# VÃ©rifier les dÃ©pendances optionnelles
if [ "$WITH_METIS" = true ]; then
    echo "VÃ©rification de METIS..."
    if ! pkg-config --exists metis; then
        echo "ATTENTION: METIS n'est pas trouvÃ© via pkg-config"
        echo "Vous devrez peut-Ãªtre dÃ©finir METISDIR dans .cargo/config.toml"
    fi
fi

if [ "$WITH_NLOPT" = true ]; then
    echo "VÃ©rification de NLOPT..."
    if ! pkg-config --exists nlopt; then
        echo "ATTENTION: NLOPT n'est pas trouvÃ© via pkg-config"
        echo "Installez avec: zypper install nlopt-devel"
    fi
fi

echo "PrÃ©requis OK"
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

# Ajouter METIS si demandÃ©
if [ "$WITH_METIS" = true ]; then
    echo "METISDIR="/usr/local"" >> .cargo/config.toml
fi

echo "Configuration Rust OK"
echo ""

# Compilation
echo "=== Compilation ==="

# DÃ©finir les features
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

echo "Compilation des bibliothÃ¨ques Rust..."
echo "Features: $FEATURES"
echo "Mode: $BUILD_MODE"

cargo build --workspace $BUILD_MODE $FEATURES

echo "Compilation Rust OK"
echo ""

# Compilation FFI
echo "=== Compilation FFI ==="
cargo build --package tucanos-ffi $BUILD_MODE $FEATURES

# CrÃ©er le rÃ©pertoire d'installation
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/include"

# Copier les fichiers FFI
cp "target/release/libtucanos.so" "$INSTALL_DIR/lib/"
cp "target/release/tucanos.h" "$INSTALL_DIR/include/"

echo "FFI compilÃ© et installÃ©"
echo ""

# Compilation Python
echo "=== Compilation Python bindings ==="

# Installer maturin
pip3 install --user maturin

# Compiler pytmesh
echo "Compilation de pytmesh..."
cd pytmesh
maturin build --release $FEATURES
cd ..

# Compiler pytucanos
echo "Compilation de pytucanos..."
cd pytucanos
maturin build --release $FEATURES
cd ..

# Copier les wheels
mkdir -p "$INSTALL_DIR/python"
cp pytmesh/target/wheels/*.whl "$INSTALL_DIR/python/"
cp pytucanos/target/wheels/*.whl "$INSTALL_DIR/python/"

echo "Python bindings compilÃ©s"
echo ""

# CrÃ©er les scripts d'installation
echo "=== CrÃ©ation des scripts d'installation ==="

# Script d'installation systÃ¨me
cat > "$INSTALL_DIR/install-system.sh" << 'EOF'
#!/bin/bash
# Installation systÃ¨me de Tucanos

set -e

INSTALL_PREFIX="/usr/local"
LIB_DIR="$INSTALL_PREFIX/lib"
INCLUDE_DIR="$INSTALL_PREFIX/include"

echo "=== Installation systÃ¨me de Tucanos ==="

# VÃ©rifier les permissions
if [ "$EUID" -ne 0 ]; then
    echo "ERREUR: Ce script doit Ãªtre exÃ©cutÃ© en tant que root"
    echo "Utilisez: sudo ./install-system.sh"
    exit 1
fi

# CrÃ©er les rÃ©pertoires
mkdir -p "$LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# Installer les bibliothÃ¨ques
echo "Installation des bibliothÃ¨ques..."
cp lib/*.so "$LIB_DIR/"

# Installer les en-tÃªtes
echo "Installation des en-tÃªtes..."
cp include/*.h "$INCLUDE_DIR/"

# Mettre Ã  jour ldconfig
echo "Mise Ã  jour du cache des bibliothÃ¨ques..."
ldconfig

echo ""
echo "=== Installation systÃ¨me terminÃ©e ==="
echo "Les bibliothÃ¨ques sont installÃ©es dans $LIB_DIR"
echo "Les en-tÃªtes sont installÃ©s dans $INCLUDE_DIR"
EOF

# Script d'installation Python
cat > "$INSTALL_DIR/install-python.sh" << 'EOF'
#!/bin/bash
# Installation des bindings Python

set -e

echo "=== Installation des bindings Python ==="

# Installer les wheels
echo "Installation des packages Python..."
pip3 install --user python/*.whl

echo ""
echo "=== Installation Python terminÃ©e ==="
echo "Vous pouvez maintenant importer pytmesh et pytucanos"
EOF

# Script de test
cat > "$INSTALL_DIR/test-installation.sh" << 'EOF'
#!/bin/bash
# Test de l'installation de Tucanos

set -e

echo "=== Test de l'installation de Tucanos ==="

# Test FFI
echo "Test des bibliothÃ¨ques FFI..."
if [ -f "lib/libtucanos.so" ]; then
    echo "âœ“ BibliothÃ¨que FFI trouvÃ©e"
    ldd lib/libtucanos.so | head -5
else
    echo "âœ— BibliothÃ¨que FFI non trouvÃ©e"
fi

# Test Python
echo "Test des bindings Python..."
if command -v python3 &> /dev/null; then
    python3 -c "
try:
    import pytmesh
    print('âœ“ pytmesh importÃ© avec succÃ¨s')
except ImportError as e:
    print(f'âœ— Erreur import pytmesh: {e}')

try:
    import pytucanos
    print('âœ“ pytucanos importÃ© avec succÃ¨s')
except ImportError as e:
    print(f'âœ— Erreur import pytucanos: {e}')
"
else
    echo "âœ— Python3 non disponible"
fi

echo "Test terminÃ©"
EOF

# Rendre les scripts exÃ©cutables
chmod +x "$INSTALL_DIR"/*.sh

echo "=== Compilation terminÃ©e ==="
echo "Package d'installation crÃ©Ã© dans: $INSTALL_DIR"
echo ""
echo "Pour installer:"
echo "1. cd $INSTALL_DIR"
echo "2. sudo ./install-system.sh"
echo "3. ./install-python.sh"
echo "4. ./test-installation.sh"
