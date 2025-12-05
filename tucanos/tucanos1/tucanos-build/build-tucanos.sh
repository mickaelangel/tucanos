#!/bin/bash
# Script de compilation Tucanos pour SUSE 15 (gÃ©nÃ©rÃ© automatiquement)

set -e

# Configuration
BUILD_DIR="."
INSTALL_DIR="../tucanos-install"
TARGET_ARCH="x86_64-unknown-linux-gnu"

# Options
WITH_METIS=false
WITH_NLOPT=false
DEBUG_BUILD=false
BUILD_PYTHON=true
BUILD_FFI=true

echo "=== Compilation de Tucanos pour SUSE 15 ==="
echo "Architecture cible: \"
echo "Avec METIS: \"
echo "Avec NLOPT: \"
echo "Mode debug: \"
echo "Build Python: \"
echo "Build FFI: \"
echo ""

# VÃ©rifier les prÃ©requis
echo "=== VÃ©rification des prÃ©requis ==="

# VÃ©rifier Rust
if ! command -v rustc &> /dev/null; then
    echo "ERREUR: Rust n'est pas installÃ©"
    echo "Installez Rust avec: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

RUST_VERSION_INSTALLED=\
echo "Rust version: \"

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

# VÃ©rifier Python si nÃ©cessaire
if [ "\" = true ]; then
    if ! command -v python3 &> /dev/null; then
        echo "ERREUR: Python3 n'est pas installÃ©"
        echo "Installez avec: zypper install python3 python3-devel"
        exit 1
    fi
    
    if ! command -v pip3 &> /dev/null; then
        echo "ERREUR: pip3 n'est pas installÃ©"
        echo "Installez avec: zypper install python3-pip"
        exit 1
    fi
fi

echo "PrÃ©requis OK"
echo ""

# Configuration Rust
echo "=== Configuration Rust ==="
rustup target add \

# Configuration Cargo pour SUSE 15
mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[target.\]
linker = "gcc"

[env]
# Configuration pour SUSE 15
RUSTFLAGS = "-C target-cpu=native"
EOF

# Ajouter METIS si demandÃ©
if [ "\" = true ]; then
    echo "METISDIR=\"/usr/local\"" >> .cargo/config.toml
fi

echo "Configuration Rust OK"
echo ""

# Compilation
echo "=== Compilation ==="

# DÃ©finir les features
FEATURES=""
if [ "\" = true ]; then
    FEATURES="\ --features metis"
fi
if [ "\" = true ]; then
    FEATURES="\ --features nlopt"
fi

# Mode de compilation
BUILD_MODE="--release"
if [ "\" = true ]; then
    BUILD_MODE=""
fi

echo "Compilation des bibliothÃ¨ques Rust..."
cargo build --workspace \ \ --target \

echo "Compilation Rust OK"
echo ""

# Compilation FFI si demandÃ©
if [ "\" = true ]; then
    echo "=== Compilation FFI ==="
    cargo build --package tucanos-ffi \ \ --target \
    
    # Copier les fichiers FFI
    mkdir -p "\/lib"
    mkdir -p "\/include"
    
    cp "target/\/release/libtucanos.so" "\/lib/"
    cp "target/\/release/tucanos.h" "\/include/"
    
    echo "FFI compilÃ© et installÃ©"
    echo ""
fi

# Compilation Python si demandÃ©
if [ "\" = true ]; then
    echo "=== Compilation Python bindings ==="
    
    # Installer les dÃ©pendances Python
    pip3 install --user maturin
    
    # Compiler pytmesh
    echo "Compilation de pytmesh..."
    cd pytmesh
    maturin build --release --target \ \
    cd ..
    
    # Compiler pytucanos
    echo "Compilation de pytucanos..."
    cd pytucanos
    maturin build --release --target \ \
    cd ..
    
    # Copier les wheels
    mkdir -p "\/python"
    cp pytmesh/target/wheels/*.whl "\/python/"
    cp pytucanos/target/wheels/*.whl "\/python/"
    
    echo "Python bindings compilÃ©s"
    echo ""
fi

echo "=== Compilation terminÃ©e ==="
echo "Package d'installation crÃ©Ã© dans: \"
