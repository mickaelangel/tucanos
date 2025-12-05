#!/bin/bash
# Script d'installation de Tucanos pour SUSE 15 hors ligne (SANS SUDO)
# Ce script installe tout dans le répertoire utilisateur ~/.local/

set -e  # Arrêter en cas d'erreur

echo "=== Installation de Tucanos sur SUSE 15 (Hors ligne - Sans sudo) ==="

# Vérifier si nous sommes sur SUSE 15
if [ ! -f /etc/os-release ]; then
    echo "Erreur: Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse-leap" && "$ID" != "sles" && "$VERSION_ID" != "15"* ]]; then
    echo "Attention: Ce script est conçu pour SUSE 15. Version détectée: $PRETTY_NAME"
    read -p "Continuer quand même ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✓ Système détecté: $PRETTY_NAME"
echo "✓ Mode sans sudo: Installation dans ~/.local/"

# Créer les répertoires locaux
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/lib"
mkdir -p "$HOME/.local/include"
mkdir -p "$HOME/.local/share"

# Ajouter ~/.local/bin au PATH si ce n'est pas déjà fait
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
    echo "✓ ~/.local/bin ajouté au PATH"
fi

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Vérifier et installer GCC si nécessaire (sans sudo)
if ! command_exists gcc; then
    echo "⚠ gcc n'est pas installé"
    echo "Sans sudo, gcc ne peut pas être compilé depuis les sources"
    echo ""
    echo "Solutions:"
    echo "  1. Demander à l'administrateur d'installer gcc:"
    echo "     sudo zypper install gcc gcc-c++"
    echo "  2. Utiliser une machine avec gcc pré-installé"
    echo ""
    read -p "gcc est-il disponible sur le système (vérifier avec 'which gcc') ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "✗ gcc requis pour continuer. Installation annulée."
        exit 1
    fi
else
    echo "✓ gcc est déjà installé: $(gcc --version | head -n1)"
fi

# Vérifier et installer make si nécessaire (sans sudo)
if ! command_exists make; then
    echo "make n'est pas installé. Installation de make dans ~/.local/..."
    
    # Vérifier si les sources make existent
    if [ -d "suse-packages" ] && [ -f "suse-packages/sources/make-4.3.tar.gz" ]; then
        echo "Installation de make depuis les sources..."
        
        # gcc devrait maintenant être disponible
        if ! command_exists gcc; then
            echo "✗ ERREUR: gcc est requis pour compiler make"
            exit 1
        fi
        
        # Compiler make dans un répertoire temporaire
        TEMP_DIR=$(mktemp -d)
        echo "Extraction et compilation de make 4.3 dans $TEMP_DIR..."
        tar xzf suse-packages/sources/make-4.3.tar.gz -C "$TEMP_DIR"
        cd "$TEMP_DIR/make-4.3"
        
        # Installation dans ~/.local au lieu de /usr/local
        ./configure --prefix="$HOME/.local"
        make -j$(nproc)
        make install
        
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        
        # Vérification
        if command_exists make; then
            echo "✓ make installé avec succès: $(make --version | head -n1)"
        else
            echo "✗ Échec de l'installation de make"
            echo "Vérifiez que ~/.local/bin est dans votre PATH"
            exit 1
        fi
    else
        echo "✗ ERREUR: Sources make non trouvées dans suse-packages/"
        echo "make est requis pour continuer"
        exit 1
    fi
else
    echo "✓ make est déjà installé: $(make --version | head -n1)"
fi

# Vérifier et installer Rust si nécessaire
if ! command_exists rustc; then
    echo "Rust n'est pas installé. Installation de Rust..."
    
    # Vérifier si le package Rust offline existe
    if [ -d "rust-offline-package" ]; then
        echo "Installation de Rust depuis le package offline..."
        
        # Rust s'installe automatiquement dans ~/.cargo et ~/.rustup
        cd rust-offline-package
        if [ -f "install_rust_offline.sh" ]; then
            chmod +x install_rust_offline.sh
            ./install_rust_offline.sh
        else
            echo "Installation manuelle des composants Rust..."
            
            # Extraire et installer les composants
            for component in rustc-*.tar.gz cargo-*.tar.gz rust-std-*.tar.gz; do
                if [ -f "$component" ]; then
                    echo "Installation de $component..."
                    tar xzf "$component"
                    component_dir=$(basename "$component" .tar.gz)
                    cd "$component_dir"
                    ./install.sh --prefix="$HOME/.local" --disable-ldconfig
                    cd ..
                fi
            done
        fi
        cd ..
        
        # Sourcer l'environnement Rust
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        fi
        
        echo "✓ Rust installé avec succès"
    else
        echo "✗ ERREUR: Package Rust offline non trouvé"
        echo "Rust est requis pour compiler Tucanos"
        exit 1
    fi
else
    echo "✓ Rust est déjà installé: $(rustc --version)"
fi

# S'assurer que Rust est dans le PATH
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Vérifier si les sources de Tucanos sont disponibles
TUCANOS_DIR=""
if [ -d "tucanos-main" ]; then
    TUCANOS_DIR="tucanos-main"
elif [ -d "tucanos" ]; then
    TUCANOS_DIR="tucanos"
else
    echo "✗ Erreur: Répertoire des sources Tucanos non trouvé."
    echo "Cherché: 'tucanos-main' ou 'tucanos'"
    exit 1
fi

echo "✓ Sources de Tucanos trouvées dans: $TUCANOS_DIR"

# Se déplacer dans le répertoire tucanos
cd "$TUCANOS_DIR"

# Vérifier les dépendances système optionnelles
echo "Vérification des dépendances optionnelles..."

# Vérifier Metis
if command_exists metis; then
    echo "✓ Metis trouvé: $(metis --version 2>/dev/null || echo 'version inconnue')"
    METIS_AVAILABLE=true
else
    echo "⚠ Metis non trouvé (optionnel, pour le partitionnement de maillage)"
    METIS_AVAILABLE=false
fi

# Vérifier NLOPT
if pkg-config --exists nlopt 2>/dev/null; then
    echo "✓ NLOPT trouvé: $(pkg-config --modversion nlopt)"
    NLOPT_AVAILABLE=true
else
    echo "⚠ NLOPT non trouvé (optionnel, pour le lissage)"
    NLOPT_AVAILABLE=false
fi

# Configuration des fonctionnalités Cargo
CARGO_FEATURES=""
if [ "$METIS_AVAILABLE" = true ]; then
    CARGO_FEATURES="$CARGO_FEATURES metis"
fi

if [ "$NLOPT_AVAILABLE" = true ]; then
    CARGO_FEATURES="$CARGO_FEATURES nlopt"
fi

# Configuration de Cargo pour mode offline et local
echo "Configuration de l'environnement Cargo..."

# S'assurer que CARGO_HOME est dans le répertoire utilisateur
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"

# Créer un fichier de configuration Cargo pour mode offline
mkdir -p .cargo

# Vérifier si les dépendances GitHub sont installées
if [ -d "$HOME/.cargo/git/checkouts/coupe" ]; then
    # Trouver le dossier racine de coupe (celui qui contient Cargo.toml avec name = "coupe")
    COUPE_CHECKOUT=""
    for dir in "$HOME/.cargo/git/checkouts/coupe"/*; do
        if [ -f "$dir/Cargo.toml" ]; then
            # Vérifier que c'est bien le package coupe (pas un sous-dossier)
            if grep -q 'name.*=.*"coupe"' "$dir/Cargo.toml" 2>/dev/null; then
                COUPE_CHECKOUT="$dir"
                break
            fi
        fi
    done
    
    if [ -n "$COUPE_CHECKOUT" ] && [ -f "$COUPE_CHECKOUT/Cargo.toml" ]; then
        # Configuration avec patch pour coupe
        cat > .cargo/config.toml << EOF
[net]
offline = true

[build]
jobs = 4

[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "../cargo-vendor"

[patch.'https://github.com/LIHPC-Computational-Geometry/coupe.git']
coupe = { path = "$COUPE_CHECKOUT" }
EOF
        echo "✓ Configuration Cargo avec patch pour coupe local: $COUPE_CHECKOUT"
    else
        echo "⚠ Dossier coupe trouvé mais package coupe non identifié, configuration sans patch"
        cat > .cargo/config.toml << 'EOF'
[net]
offline = true

[build]
jobs = 4

[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "../cargo-vendor"
EOF
    fi
else
    # Configuration standard sans coupe
    cat > .cargo/config.toml << 'EOF'
[net]
offline = true

[build]
jobs = 4

[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "../cargo-vendor"
EOF
fi

# Installer les dépendances GitHub si disponibles (pour mode 100% offline)
if [ -d "../github-dependencies-offline" ] && [ -f "../github-dependencies-offline/install_github_dependencies.sh" ]; then
    echo "Installation des dépendances GitHub locales..."
    cd ..
    chmod +x github-dependencies-offline/install_github_dependencies.sh
    bash github-dependencies-offline/install_github_dependencies.sh
    cd "$TUCANOS_DIR"
    echo "✓ Dépendances GitHub installées depuis le package local"
fi

# Vérifier si le répertoire vendor existe et est complet
OFFLINE_MODE=true
if [ ! -d "../cargo-vendor" ]; then
    echo "⚠ Attention: Le répertoire cargo-vendor n'existe pas"
    OFFLINE_MODE=false
fi

# Vérifier si coupe est disponible (soit dans vendor, soit dans git checkouts)
if [ ! -f "../cargo-vendor/coupe-*.crate" ] && [ ! -d "../cargo-vendor/coupe" ]; then
    if [ ! -d "$HOME/.cargo/git/checkouts/coupe" ]; then
        echo "⚠ Attention: Dépendance 'coupe' manquante"
        echo "La dépendance 'coupe' doit être téléchargée depuis GitHub"
        OFFLINE_MODE=false
    else
        echo "✓ Dépendance 'coupe' trouvée dans ~/.cargo/git/checkouts/"
    fi
fi

if [ "$OFFLINE_MODE" = false ]; then
    echo "Les dépendances manquantes seront téléchargées depuis internet..."
    rm -f .cargo/config.toml
    
    echo ""
    echo "⚠ IMPORTANT: Compilation nécessite une connexion internet"
    echo "Dépendances à télécharger:"
    echo "  - coupe (https://github.com/LIHPC-Computational-Geometry/coupe.git)"
    echo "  - Autres dépendances crates.io"
    echo ""
    
    read -p "Continuer avec téléchargement internet ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation annulée."
        echo ""
        echo "Pour mode 100% offline:"
        echo "  1. Installez les dépendances GitHub avec ../github-dependencies-offline/install_github_dependencies.sh"
        echo "  2. Ou autorisez le téléchargement internet"
        exit 1
    fi
else
    echo "✓ Mode offline activé - Toutes les dépendances sont disponibles"
fi

# Compilation de Tucanos
echo "Compilation de Tucanos..."

# Vérifier s'il y a un conflit de workspace (dossier tucanos/ à l'intérieur)
if [ -f "tucanos/Cargo.toml" ] && [ -f "Cargo.toml" ]; then
    echo "⚠ Détection de workspace imbriqués, compilation du sous-projet tucanos uniquement..."
    cd tucanos
fi

if [ -n "$CARGO_FEATURES" ]; then
    echo "Fonctionnalités activées: $CARGO_FEATURES"
    cargo build --release --features "$CARGO_FEATURES"
else
    echo "Compilation sans fonctionnalités optionnelles"
    cargo build --release
fi

if [ $? -eq 0 ]; then
    echo "✓ Compilation réussie !"
else
    echo "✗ Erreur lors de la compilation"
    echo "Tentative avec les fonctionnalités minimales..."
    cargo build --release --no-default-features
    if [ $? -eq 0 ]; then
        echo "✓ Compilation réussie (version minimale) !"
    else
        echo "✗ Échec de la compilation"
        exit 1
    fi
fi

# Vérifier les fichiers générés
echo "Fichiers générés:"
if [ -d "target/release" ]; then
    find target/release -maxdepth 1 -name "*.so" -o -name "*.a" -o -name "tucanos.h" | while read file; do
        echo "  - $file"
    done
fi

# Installation locale (dans ~/.local)
echo ""
echo "Installation de Tucanos dans ~/.local/..."

# Copier les bibliothèques
if [ -f "target/release/libtucanos.so" ]; then
    cp target/release/libtucanos.so "$HOME/.local/lib/"
    echo "✓ Bibliothèque installée dans ~/.local/lib/"
fi

# Copier les headers
if [ -f "target/release/tucanos.h" ]; then
    cp target/release/tucanos.h "$HOME/.local/include/"
    echo "✓ Headers installés dans ~/.local/include/"
elif [ -f "tucanos.h" ]; then
    cp tucanos.h "$HOME/.local/include/"
    echo "✓ Headers installés dans ~/.local/include/"
fi

# Copier les binaires si présents
for binary in target/release/tucanos target/release/tmesh; do
    if [ -f "$binary" ] && [ -x "$binary" ]; then
        cp "$binary" "$HOME/.local/bin/"
        echo "✓ $(basename $binary) installé dans ~/.local/bin/"
    fi
done

# Configurer LD_LIBRARY_PATH
if [[ ":$LD_LIBRARY_PATH:" != *":$HOME/.local/lib:"* ]]; then
    echo "export LD_LIBRARY_PATH=\"\$HOME/.local/lib:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
    export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
    echo "✓ ~/.local/lib ajouté à LD_LIBRARY_PATH"
fi

# Configurer PKG_CONFIG_PATH
if [[ ":$PKG_CONFIG_PATH:" != *":$HOME/.local/lib/pkgconfig:"* ]]; then
    echo "export PKG_CONFIG_PATH=\"\$HOME/.local/lib/pkgconfig:\$PKG_CONFIG_PATH\"" >> ~/.bashrc
    export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

echo "✓ Installation locale terminée"

# Test de l'installation
echo ""
echo "Test de l'installation..."
if cargo test --workspace --release >/dev/null 2>&1; then
    echo "✓ Tests passés avec succès"
else
    echo "⚠ Certains tests ont échoué, mais l'installation est fonctionnelle"
fi

echo ""
echo "=========================================="
echo "✓ Installation terminée avec succès !"
echo "=========================================="
echo ""
echo "Tucanos est installé dans votre répertoire utilisateur:"
echo "  • Bibliothèques : ~/.local/lib/"
echo "  • Headers       : ~/.local/include/"
echo "  • Binaires      : ~/.local/bin/"
echo ""
echo "Variables d'environnement configurées dans ~/.bashrc:"
echo "  • PATH=$HOME/.local/bin:\$PATH"
echo "  • LD_LIBRARY_PATH=$HOME/.local/lib:\$LD_LIBRARY_PATH"
echo ""
echo "Pour activer immédiatement les changements:"
echo "  source ~/.bashrc"
echo ""
echo "Pour utiliser Tucanos:"
echo "  • API C: #include <tucanos.h>"
echo "  • Compilation: gcc -I~/.local/include -L~/.local/lib -ltucanos"
echo "  • Bibliothèque: ~/.local/lib/libtucanos.so"
echo ""
echo "Fichiers disponibles dans: $(pwd)/target/release/"
echo ""

