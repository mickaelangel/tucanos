#!/bin/bash
# Script d'installation Tucanos pour SUSE 15 SP4 - 100% Offline
# Installation avec choix du répertoire d'installation

set -e

# ========================================
# Configuration du répertoire d'installation
# ========================================

# Par défaut: ~/.local
# Personnalisable avec: PREFIX=/chemin/custom bash install_tucanos_custom.sh
INSTALL_PREFIX="${PREFIX:-$HOME/.local}"

echo "=========================================="
echo "  Installation Tucanos SUSE 15 SP4"
echo "  Mode: 100% Offline - Sans sudo"
echo "  Répertoire: $INSTALL_PREFIX"
echo "=========================================="
echo ""

# Validation du répertoire
if [ ! -d "$INSTALL_PREFIX" ]; then
    echo "📁 Création du répertoire d'installation: $INSTALL_PREFIX"
    mkdir -p "$INSTALL_PREFIX" || {
        echo "❌ Impossible de créer $INSTALL_PREFIX"
        echo "💡 Essayez avec sudo ou choisissez un autre répertoire:"
        echo "   PREFIX=/autre/chemin bash $0"
        exit 1
    }
fi

# Créer les sous-répertoires
mkdir -p "$INSTALL_PREFIX/bin"
mkdir -p "$INSTALL_PREFIX/lib"
mkdir -p "$INSTALL_PREFIX/include"

echo "✓ Répertoire d'installation: $INSTALL_PREFIX"
echo ""

# ========================================
# Configuration de l'environnement
# ========================================

# Ajouter au PATH (si pas déjà fait)
if [[ ":$PATH:" != *":$INSTALL_PREFIX/bin:"* ]]; then
    export PATH="$INSTALL_PREFIX/bin:$PATH"
    echo "📝 Ajout au PATH dans ~/.bashrc"
    echo "" >> ~/.bashrc
    echo "# Tucanos installation - $(date)" >> ~/.bashrc
    echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=\"$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
fi

# ========================================
# 1. Vérifier gcc
# ========================================
if ! command -v gcc &>/dev/null; then
    echo "❌ gcc requis. Demandez à l'admin: sudo zypper install gcc gcc-c++"
    exit 1
fi
echo "✓ gcc: $(gcc --version | head -n1)"

# ========================================
# 2. Installer make si nécessaire
# ========================================
if ! command -v make &>/dev/null; then
    echo "📦 Installation de make..."
    
    # Vérifier si les sources make sont disponibles
    if [ -f "suse-packages/sources/make-4.3.tar.gz" ]; then
        tar xzf suse-packages/sources/make-4.3.tar.gz -C /tmp
        cd /tmp/make-4.3
        ./configure --prefix="$INSTALL_PREFIX" && make -j$(nproc) && make install
        cd - >/dev/null
        rm -rf /tmp/make-4.3
        echo "✓ make installé dans $INSTALL_PREFIX/bin"
    else
        echo "⚠️  Sources make non trouvées. Téléchargez le package complet."
    fi
fi
echo "✓ make: $(make --version | head -n1)"

# ========================================
# 3. Installer Rust si nécessaire
# ========================================
if ! command -v rustc &>/dev/null; then
    echo "📦 Installation de Rust..."
    
    # Vérifier si le package Rust offline est disponible
    if [ -d "rust-offline-package" ]; then
        cd rust-offline-package
        for tar in *.tar.gz; do
            [ -f "$tar" ] || continue
            tar xzf "$tar"
            dir="${tar%.tar.gz}"
            cd "$dir"
            ./install.sh --prefix="$INSTALL_PREFIX" --disable-ldconfig
            cd ..
        done
        cd ..
        echo "✓ Rust installé"
    else
        echo "⚠️  Package Rust offline non trouvé."
        echo "💡 Téléchargez le package complet depuis GitHub"
    fi
fi

# Charger l'environnement Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
if command -v rustc &>/dev/null; then
    echo "✓ Rust: $(rustc --version)"
else
    echo "❌ Rust non disponible. Installation impossible."
    exit 1
fi

# ========================================
# 4. Compiler Tucanos
# ========================================
echo ""
echo "🔨 Compilation de Tucanos..."

# Vérifier si les sources sont disponibles
if [ ! -d "sources/tucanos-main" ]; then
    echo "❌ Sources Tucanos non trouvées dans sources/tucanos-main"
    echo "💡 Assurez-vous d'être dans le bon répertoire ou clonez:"
    echo "   git clone https://github.com/mickaelangel/tucanos.git"
    exit 1
fi

cd sources/tucanos-main

# Déterminer si on a un workspace imbriqué
if [ -f "tucanos/Cargo.toml" ] && [ -f "Cargo.toml" ]; then
    echo "📂 Workspace imbriqué détecté"
    cd tucanos
    VENDOR_PATH="../../../cargo-vendor"
else
    VENDOR_PATH="../../cargo-vendor"
fi

# Vérifier si cargo-vendor existe
if [ ! -d "$VENDOR_PATH" ]; then
    echo "⚠️  cargo-vendor non trouvé"
    echo "💡 Compilation en mode online (nécessite internet)"
    cargo build --release
else
    # Configuration Cargo pour mode offline
    mkdir -p .cargo
    
    cat > .cargo/config.toml << EOF
[source.crates-io]
replace-with = "vendored-sources"

[source."git+https://github.com/LIHPC-Computational-Geometry/coupe.git?rev=20f0de6"]
git = "https://github.com/LIHPC-Computational-Geometry/coupe.git"
rev = "20f0de6"
replace-with = "vendored-sources"

[source."git+https://github.com/tucanos/metis-rs.git?rev=d31aa3e"]
git = "https://github.com/tucanos/metis-rs.git"
rev = "d31aa3e"
replace-with = "vendored-sources"

[source."git+https://github.com/tucanos/minimeshb.git?tag=0.1.0"]
git = "https://github.com/tucanos/minimeshb.git"
tag = "0.1.0"
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "$VENDOR_PATH"

[build]
jobs = 4
EOF

    echo "✓ Configuration Cargo offline créée"
    cargo build --release --offline
fi

echo "✓ Compilation réussie !"

# ========================================
# 5. Installer les fichiers compilés
# ========================================
echo ""
echo "📦 Installation dans $INSTALL_PREFIX..."

# Copier les bibliothèques et headers
if [ -f "target/release/libtucanos.so" ]; then
    cp target/release/libtucanos.so "$INSTALL_PREFIX/lib/"
    echo "✓ libtucanos.so → $INSTALL_PREFIX/lib/"
fi

if [ -f "target/release/tucanos.h" ]; then
    cp target/release/tucanos.h "$INSTALL_PREFIX/include/"
    echo "✓ tucanos.h → $INSTALL_PREFIX/include/"
fi

# Configuration LD_LIBRARY_PATH
if [[ ":$LD_LIBRARY_PATH:" != *":$INSTALL_PREFIX/lib:"* ]]; then
    export LD_LIBRARY_PATH="$INSTALL_PREFIX/lib:$LD_LIBRARY_PATH"
fi

echo ""
echo "=========================================="
echo "✅ Tucanos installé avec succès !"
echo "=========================================="
echo ""
echo "📍 Emplacement: $INSTALL_PREFIX"
echo ""
echo "Fichiers installés:"
echo "  - $INSTALL_PREFIX/lib/libtucanos.so"
echo "  - $INSTALL_PREFIX/include/tucanos.h"
echo ""
echo "🔧 Pour utiliser Tucanos, activez l'environnement:"
echo "  source ~/.bashrc"
echo ""
echo "Ou ajoutez manuellement:"
echo "  export PATH=\"$INSTALL_PREFIX/bin:\$PATH\""
echo "  export LD_LIBRARY_PATH=\"$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH\""
echo ""

