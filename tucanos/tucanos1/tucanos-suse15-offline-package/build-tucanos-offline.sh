#!/bin/bash
# Installation HORS LIGNE de Tucanos pour SUSE 15
# Ce script ne nÃ©cessite AUCUNE connexion internet

set -e

echo "=== Installation HORS LIGNE de Tucanos sur SUSE 15 ==="
echo "ATTENTION: Ce script nÃ©cessite que les dÃ©pendances soient dÃ©jÃ  installÃ©es"
echo ""

# VÃ©rifier les prÃ©requis
echo "=== VÃ©rification des prÃ©requis ==="

# VÃ©rifier Rust
if ! command -v rustc &> /dev/null; then
    echo "ERREUR: Rust n'est pas installÃ©"
    echo "Installez Rust manuellement depuis le package fourni ou avec:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    exit 1
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

# VÃ©rifier maturin
if ! command -v maturin &> /dev/null; then
    echo "Installation de maturin..."
    pip3 install --user maturin
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
if [ "true" = true ]; then
    echo "METISDIR="/usr/local"" >> .cargo/config.toml
fi

echo "Configuration Rust OK"
echo ""

# Compilation
echo "=== Compilation ==="

# DÃ©finir les features
FEATURES=""
if [ "true" = true ]; then
    FEATURES="$FEATURES --features metis"
fi
if [ "true" = true ]; then
    FEATURES="$FEATURES --features nlopt"
fi

# Mode de compilation
BUILD_MODE="--release"
if [ "false" = true ]; then
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
mkdir -p "tucanos-install/lib"
mkdir -p "tucanos-install/include"

# Copier les fichiers FFI
cp "target/release/libtucanos.so" "tucanos-install/lib/"
cp "target/release/tucanos.h" "tucanos-install/include/"

echo "FFI compilÃ© et installÃ©"
echo ""

# Compilation Python
echo "=== Compilation Python bindings ==="

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
mkdir -p "tucanos-install/python"
cp pytmesh/target/wheels/*.whl "tucanos-install/python/"
cp pytucanos/target/wheels/*.whl "tucanos-install/python/"

echo "Python bindings compilÃ©s"
echo ""

# CrÃ©er les scripts d'installation
echo "=== CrÃ©ation des scripts d'installation ==="

# Script d'installation systÃ¨me
cat > "tucanos-install/install-system.sh" << 'EOF'
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
cat > "tucanos-install/install-python.sh" << 'EOF'
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
cat > "tucanos-install/test-installation.sh" << 'EOF'
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
chmod +x "tucanos-install"/*.sh

echo "=== Compilation terminÃ©e ==="
echo "Package d'installation crÃ©Ã© dans: tucanos-install"
echo ""
echo "Pour installer:"
echo "1. cd tucanos-install"
echo "2. sudo ./install-system.sh"
echo "3. ./install-python.sh"
echo "4. ./test-installation.sh"
