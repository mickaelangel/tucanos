#!/bin/bash
# Script d'installation Tucanos pour SUSE 15 SP4 - 100% Offline
# Installation dans ~/.local/ (pas de sudo requis)

set -e

echo "=========================================="
echo "  Installation Tucanos SUSE 15 SP4"
echo "  Mode: 100% Offline - Sans sudo"
echo "=========================================="
echo ""

# Créer les répertoires
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/lib"
mkdir -p "$HOME/.local/include"

# Ajouter au PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$HOME/.local/bin:$PATH"

# 1. Vérifier gcc
if ! command -v gcc &>/dev/null; then
    echo "✗ gcc requis. Demandez à l'admin: sudo zypper install gcc gcc-c++"
    exit 1
fi
echo "✓ gcc: $(gcc --version | head -n1)"

# 2. Installer make si nécessaire
if ! command -v make &>/dev/null; then
    echo "Installation de make..."
    tar xzf suse-packages/sources/make-4.3.tar.gz -C /tmp
    cd /tmp/make-4.3
    ./configure --prefix="$HOME/.local" && make -j$(nproc) && make install
    cd - >/dev/null
    rm -rf /tmp/make-4.3
fi
echo "✓ make: $(make --version | head -n1)"

# 3. Installer Rust si nécessaire
if ! command -v rustc &>/dev/null; then
    echo "Installation de Rust..."
    cd rust-offline-package
    for tar in *.tar.gz; do
        tar xzf "$tar"
        dir="${tar%.tar.gz}"
        cd "$dir"
        ./install.sh --prefix="$HOME/.local" --disable-ldconfig
        cd ..
    done
    cd ..
fi
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
echo "✓ Rust: $(rustc --version)"

# 4. Compiler Tucanos
cd tucanos-main

# Déterminer si on a un workspace imbriqué
if [ -f "tucanos/Cargo.toml" ] && [ -f "Cargo.toml" ]; then
    echo "Workspace imbriqué détecté, compilation depuis tucanos/"
    cd tucanos
    VENDOR_PATH="../../cargo-vendor"
else
    VENDOR_PATH="../cargo-vendor"
fi

# Configuration Cargo
mkdir -p .cargo

# Configuration Cargo pour mode 100% offline avec vendor complet
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

echo "✓ Configuration Cargo offline créée - TOUTES les dépendances vendorisées"

echo "Compilation de Tucanos..."
cargo build --release

# 6. Installer
cp target/release/libtucanos.so "$HOME/.local/lib/" 2>/dev/null || true
cp target/release/tucanos.h "$HOME/.local/include/" 2>/dev/null || true

# Configuration LD_LIBRARY_PATH
if [[ ":$LD_LIBRARY_PATH:" != *":$HOME/.local/lib:"* ]]; then
    echo 'export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"' >> ~/.bashrc
fi

echo ""
echo "=========================================="
echo "✓ Tucanos installé avec succès !"
echo "=========================================="
echo ""

# 5. Installation optionnelle de METIS et NLOPT
echo "Installation des dépendances optionnelles (METIS, NLOPT)..."
echo ""

# Vérifier g++
if command -v g++ &>/dev/null; then
    echo "✓ g++ disponible : $(g++ --version | head -n1)"
    echo "Installation de METIS et NLOPT..."
    
    cd ..
    if [ -d "suse-packages-optional" ]; then
        cd suse-packages-optional
        
        # Installer METIS
        if [ -f "install_metis.sh" ]; then
            echo ""
            echo "--- Installation METIS ---"
            bash install_metis.sh || echo "⚠️  METIS non installé (non critique)"
        fi
        
        # Installer NLOPT
        if [ -f "install_nlopt.sh" ]; then
            echo ""
            echo "--- Installation NLOPT ---"
            bash install_nlopt.sh || echo "⚠️  NLOPT non installé (non critique)"
        fi
        
        cd ..
    fi
else
    echo "⚠️  g++ non disponible - METIS et NLOPT ne seront pas installés"
    echo ""
    echo "Pour installer g++, demandez à l'administrateur :"
    echo "  sudo zypper install gcc-c++"
    echo ""
    echo "Puis relancez l'installation de METIS/NLOPT :"
    echo "  cd suse-packages-optional"
    echo "  bash install_metis.sh"
    echo "  bash install_nlopt.sh"
    echo ""
    echo "Note: Tucanos fonctionne sans METIS et NLOPT (fonctionnalités optionnelles)"
fi

echo ""
echo "=========================================="
echo "✅ Installation complète !"
echo "=========================================="
echo ""
echo "Activez l'environnement avec:"
echo "  source ~/.bashrc"
echo ""
echo "Fichiers installés:"
echo "  Tucanos: $HOME/.local/lib/libtucanos.so"
if command -v gpmetis &>/dev/null; then
    echo "  METIS: ✓ Installé"
else
    echo "  METIS: ✗ Non installé (optionnel)"
fi
if [ -f "$HOME/.local/lib/libnlopt.so" ]; then
    echo "  NLOPT: ✓ Installé"
else
    echo "  NLOPT: ✗ Non installé (optionnel)"
fi

