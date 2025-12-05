#!/bin/bash
# Script pour télécharger Rust COMPLET avec vendor pour installation hors ligne
# À exécuter sur une machine avec internet AVANT le transfert

set -e

echo "==================================================================="
echo "  Téléchargement de Rust complet pour installation hors ligne"
echo "==================================================================="
echo ""

# Créer les répertoires
RUST_DIR="/home/christophe/Documents/tucanos/tucanos/tucanos-suse15-ultimate-complete/dependencies/rust"
VENDOR_DIR="vendor"
mkdir -p "$RUST_DIR"

echo "=== PHASE 1: Téléchargement de rustup-init ==="
echo ""

if [ ! -f "$RUST_DIR/rustup-init" ]; then
    echo "Téléchargement de rustup-init..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$RUST_DIR/rustup-init"
    chmod +x "$RUST_DIR/rustup-init"
    echo "✓ rustup-init téléchargé"
else
    echo "✓ rustup-init déjà présent"
fi

echo ""
echo "=== PHASE 2: Installation temporaire de Rust ==="
echo ""

# Vérifier si Rust est déjà installé
if ! command -v rustc &> /dev/null; then
    echo "Installation de Rust (temporaire pour vendor)..."
    
    # Installer Rust dans un répertoire temporaire
    export RUSTUP_HOME="$PWD/temp_rustup"
    export CARGO_HOME="$PWD/temp_cargo"
    
    "$RUST_DIR/rustup-init" -y --default-toolchain stable --profile minimal
    
    # Activer l'environnement Rust
    source "$CARGO_HOME/env"
    
    TEMP_RUST=true
else
    echo "✓ Rust déjà installé: $(rustc --version)"
    TEMP_RUST=false
fi

echo ""
echo "=== PHASE 3: Téléchargement de la toolchain complète ==="
echo ""

# Lire la version de la toolchain depuis rust-toolchain.toml si elle existe
if [ -f "rust-toolchain.toml" ]; then
    TOOLCHAIN=$(grep "channel" rust-toolchain.toml | cut -d'"' -f2 || echo "stable")
else
    TOOLCHAIN="stable"
fi

echo "Toolchain: $TOOLCHAIN"
echo "Téléchargement de la toolchain $TOOLCHAIN pour x86_64-unknown-linux-gnu..."

rustup toolchain install $TOOLCHAIN
rustup component add rustfmt clippy

# Télécharger la toolchain complète
echo "Empaquetage de la toolchain..."

if [ "$TEMP_RUST" = true ]; then
    # Copier la toolchain téléchargée
    TOOLCHAIN_DIR="$RUSTUP_HOME/toolchains"
else
    TOOLCHAIN_DIR="$HOME/.rustup/toolchains"
fi

# Créer une archive de la toolchain
TOOLCHAIN_ARCHIVE="$RUST_DIR/rust-toolchain-${TOOLCHAIN}-x86_64-unknown-linux-gnu.tar.gz"

if [ -d "$TOOLCHAIN_DIR" ]; then
    echo "Création de l'archive de la toolchain..."
    tar czf "$TOOLCHAIN_ARCHIVE" -C "$TOOLCHAIN_DIR" .
    echo "✓ Toolchain archivée: $(du -sh "$TOOLCHAIN_ARCHIVE" | cut -f1)"
else
    echo "⚠ Répertoire toolchain non trouvé"
fi

echo ""
echo "=== PHASE 4: Vendor des dépendances Cargo ==="
echo ""

echo "Téléchargement de toutes les dépendances Cargo (crates)..."
echo "Ceci peut prendre plusieurs minutes..."

# Vendor toutes les dépendances
cargo vendor "$VENDOR_DIR" --versioned-dirs

echo "✓ Dépendances vendorées dans $VENDOR_DIR/"

# Créer la configuration cargo pour utiliser le vendor
mkdir -p .cargo
cat > .cargo/config.toml.vendor << 'EOF'
# Configuration pour utiliser les crates vendorées (hors ligne)
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"

[env]
# Configuration pour SUSE 15
RUSTFLAGS = "-C target-cpu=native"
EOF

echo "✓ Configuration cargo créée: .cargo/config.toml.vendor"
echo ""

# Créer une archive du vendor
echo "Création de l'archive vendor..."
VENDOR_ARCHIVE="$RUST_DIR/cargo-vendor.tar.gz"
tar czf "$VENDOR_ARCHIVE" "$VENDOR_DIR"
echo "✓ Vendor archivé: $(du -sh "$VENDOR_ARCHIVE" | cut -f1)"

echo ""
echo "=== PHASE 5: Téléchargement de cargo-binstall (optionnel) ==="
echo ""

# Cargo-binstall permet d'installer des binaires sans compilation
BINSTALL_URL="https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-gnu.tgz"
BINSTALL_FILE="$RUST_DIR/cargo-binstall.tgz"

if curl -L --fail "$BINSTALL_URL" -o "$BINSTALL_FILE" 2>/dev/null; then
    echo "✓ cargo-binstall téléchargé"
else
    echo "⚠ cargo-binstall non téléchargé (optionnel)"
fi

echo ""
echo "=== PHASE 6: Informations de version ==="
echo ""

# Créer un fichier d'information
cat > "$RUST_DIR/RUST-INFO.txt" << EOF
Rust Complet pour Installation Hors Ligne
==========================================

Date: $(date)
Toolchain: $TOOLCHAIN
Architecture: x86_64-unknown-linux-gnu

Composants:
-----------
- rustup-init: $(du -sh "$RUST_DIR/rustup-init" 2>/dev/null | cut -f1 || echo "N/A")
- Toolchain archive: $(du -sh "$TOOLCHAIN_ARCHIVE" 2>/dev/null | cut -f1 || echo "N/A")
- Cargo vendor: $(du -sh "$VENDOR_ARCHIVE" 2>/dev/null | cut -f1 || echo "N/A")
- cargo-binstall: $(du -sh "$BINSTALL_FILE" 2>/dev/null | cut -f1 || echo "N/A")

Versions installées:
-------------------
$(rustc --version 2>/dev/null || echo "rustc: N/A")
$(cargo --version 2>/dev/null || echo "cargo: N/A")

Installation hors ligne:
------------------------
1. Copier le package complet sur la machine cible
2. Exécuter: ./install-complete-offline.sh
3. La configuration cargo utilisera automatiquement les crates vendorées

Notes:
------
- Le vendor contient TOUTES les dépendances nécessaires
- Aucune connexion internet requise pour la compilation
- Les crates sont dans vendor/ et cargo-vendor.tar.gz
EOF

cat "$RUST_DIR/RUST-INFO.txt"

echo ""
echo "=== PHASE 7: Nettoyage ==="
echo ""

# Nettoyer l'installation temporaire de Rust
if [ "$TEMP_RUST" = true ]; then
    echo "Nettoyage de l'installation temporaire..."
    rm -rf temp_rustup temp_cargo
    echo "✓ Installation temporaire nettoyée"
fi

echo ""

# Statistiques finales
rust_size=$(du -sh "$RUST_DIR" | cut -f1)
vendor_size=$(du -sh "$VENDOR_DIR" 2>/dev/null | cut -f1 || echo "0")

echo "==================================================================="
echo "  Téléchargement Rust terminé"
echo "==================================================================="
echo ""
echo "Taille Rust: $rust_size"
echo "Taille Vendor: $vendor_size"
echo ""
echo "Fichiers créés:"
echo "  - $RUST_DIR/rustup-init"
echo "  - $RUST_DIR/rust-toolchain-*.tar.gz"
echo "  - $RUST_DIR/cargo-vendor.tar.gz"
echo "  - $VENDOR_DIR/ (dossier)"
echo "  - .cargo/config.toml.vendor"
echo ""
echo "=== Instructions suivantes ==="
echo ""
echo "1. Vérifiez que vendor/ contient toutes les dépendances"
echo "2. Téléchargez les RPM avec: ./download-rpm-dependencies.sh"
echo "3. Transférez le package complet sur SUSE 15 SP4"
echo "4. Sur la machine cible: ./install-complete-offline.sh"
echo ""
echo "✓ Package Rust complet prêt pour installation hors ligne !"

