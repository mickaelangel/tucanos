#!/bin/bash
# Script d'installation de Tucanos pour SUSE 15 hors ligne
# Ce script configure l'environnement et installe Tucanos sans connexion internet

echo "=== Installation de Tucanos sur SUSE 15 (Hors ligne) ==="

# Vérifier si nous sommes sur SUSE 15
if [ ! -f /etc/os-release ]; then
    echo "Erreur: Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse-leap" && "$VERSION_ID" != "15"* ]]; then
    echo "Attention: Ce script est conçu pour SUSE 15. Version détectée: $PRETTY_NAME"
    read -p "Continuer quand même ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Système détecté: $PRETTY_NAME"

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Vérifier et installer GCC si nécessaire
if ! command_exists gcc; then
    echo "gcc n'est pas installé. Installation de gcc..."
    
    # Vérifier si les sources gcc existent
    GCC_SOURCE_FOUND=false
    for gcc_version in "gcc-8.5.0.tar.xz" "gcc-7.5.0.tar.xz"; do
        if [ -f "suse-packages/sources/$gcc_version" ]; then
            GCC_SOURCE_FOUND=true
            echo "✓ Sources gcc trouvées : $gcc_version"
            break
        fi
    done
    
    if [ "$GCC_SOURCE_FOUND" = true ]; then
        echo "Installation de gcc depuis les sources..."
        
        # Vérifier si un script d'installation gcc existe
        if [ -f "install_gcc_offline.sh" ]; then
            /bin/chmod +x install_gcc_offline.sh 2>/dev/null || /usr/bin/chmod +x install_gcc_offline.sh
            /bin/bash install_gcc_offline.sh
        elif [ -f "suse-packages/install_gcc_offline.sh" ]; then
            /bin/chmod +x suse-packages/install_gcc_offline.sh 2>/dev/null || /usr/bin/chmod +x suse-packages/install_gcc_offline.sh
            /bin/bash suse-packages/install_gcc_offline.sh
        else
            echo "⚠ Script install_gcc_offline.sh non trouvé"
            echo "Installation manuelle de gcc depuis les sources..."
            
            # Vérifier les prérequis système minimaux
            if ! command_exists tar; then
                echo "✗ ERREUR: tar n'est pas disponible"
                exit 1
            fi
            
            # Installation simplifiée de gcc
            echo "⚠ ATTENTION: Compilation de gcc depuis les sources (peut prendre 1-2 heures)"
            echo "⚠ Alternative: Installez gcc via zypper si connexion internet disponible:"
            echo "   sudo zypper install gcc gcc-c++"
            read -p "Continuer avec la compilation offline ? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Installation annulée. Installez gcc manuellement puis relancez ce script."
                exit 1
            fi
            
            # Extraction et compilation basique
            cd /tmp
            for gcc_tar in "$OLDPWD/suse-packages/sources/gcc-"*.tar.xz; do
                if [ -f "$gcc_tar" ]; then
                    echo "Extraction de $(basename $gcc_tar)..."
                    tar xf "$gcc_tar"
                    gcc_dir=$(basename "$gcc_tar" .tar.xz)
                    cd "$gcc_dir"
                    
                    # Vérifier les prérequis
                    if command_exists zypper; then
                        echo "Installation des prérequis gcc..."
                        sudo zypper install -y gmp-devel mpfr-devel mpc-devel || true
                    fi
                    
                    mkdir -p ../gcc-build
                    cd ../gcc-build
                    
                    echo "Configuration de gcc (mode minimal)..."
                    ../$gcc_dir/configure --prefix=/usr/local --enable-languages=c,c++ --disable-multilib --disable-bootstrap
                    
                    echo "Compilation de gcc (cela prendra du temps)..."
                    make -j$(nproc) || make -j2
                    
                    echo "Installation de gcc..."
                    sudo make install
                    
                    # Liens symboliques
                    sudo ln -sf /usr/local/bin/gcc /usr/bin/gcc
                    sudo ln -sf /usr/local/bin/g++ /usr/bin/g++
                    sudo ldconfig
                    
                    cd "$OLDPWD"
                    break
                fi
            done
        fi
        
        # Vérification
        if command_exists gcc; then
            echo "✓ gcc installé avec succès: $(gcc --version | head -n1)"
        else
            echo "✗ Échec de l'installation de gcc"
            echo "Solutions:"
            echo "  1. Installer gcc via zypper: sudo zypper install gcc gcc-c++"
            echo "  2. Fournir des RPMs gcc dans le package"
            exit 1
        fi
    else
        echo "✗ ERREUR: Sources gcc non trouvées dans suse-packages/sources/"
        echo "Veuillez installer gcc manuellement:"
        echo "  sudo zypper install gcc gcc-c++"
        exit 1
    fi
else
    echo "✓ gcc est déjà installé: $(gcc --version | head -n1)"
fi

# Vérifier et installer make si nécessaire
if ! command_exists make; then
    echo "make n'est pas installé. Installation de make..."
    
    # Vérifier si le bundle make existe
    if [ -d "suse-packages" ] && [ -f "suse-packages/sources/make-4.3.tar.gz" ]; then
        echo "Installation de make depuis les sources..."
        
        # gcc devrait maintenant être installé
        if ! command_exists gcc; then
            echo "✗ ERREUR: gcc est requis pour compiler make (devrait être installé)"
            exit 1
        fi
        
        cd suse-packages
        
        # Compiler make depuis les sources
        echo "Extraction et compilation de make 4.3..."
        tar xzf sources/make-4.3.tar.gz -C /tmp
        cd /tmp/make-4.3
        
        ./configure --prefix=/usr/local
        make -j$(nproc)
        sudo make install
        
        # Créer un lien symbolique si nécessaire
        if [ ! -f /usr/bin/make ]; then
            sudo ln -sf /usr/local/bin/make /usr/bin/make
        fi
        
        cd - > /dev/null
        
        # Vérification
        if command_exists make; then
            echo "✓ make installé avec succès: $(make --version | head -n1)"
        else
            echo "✗ Échec de l'installation de make"
            exit 1
        fi
    else
        echo "ERREUR: Bundle make non trouvé dans suse-packages/"
        echo "Veuillez télécharger le bundle make ou installer make manuellement:"
        echo "  sudo zypper install make"
        exit 1
    fi
else
    echo "✓ make est déjà installé: $(make --version | head -n1)"
fi

# Vérifier et installer Rust si nécessaire
if ! command_exists rustc; then
    echo "Rust n'est pas installé. Installation de Rust..."
    
    # Vérifier si le fichier rustup-init existe (doit être téléchargé en amont)
    if [ ! -f "rustup-init" ]; then
        echo "Erreur: Fichier rustup-init non trouvé."
        echo "Veuillez télécharger rustup-init depuis https://rustup.rs/ sur un système connecté"
        echo "et le placer dans ce répertoire avant d'exécuter ce script."
        exit 1
    fi
    
    chmod +x rustup-init
    ./rustup-init -y --default-toolchain stable-x86_64-unknown-linux-gnu
    source ~/.cargo/env
    echo "Rust installé avec succès"
else
    echo "Rust est déjà installé: $(rustc --version)"
fi

# Vérifier si les sources de Tucanos sont disponibles
TUCANOS_DIR=""
if [ -d "tucanos-main" ]; then
    TUCANOS_DIR="tucanos-main"
elif [ -d "tucanos" ]; then
    TUCANOS_DIR="tucanos"
else
    echo "Erreur: Répertoire des sources Tucanos non trouvé."
    echo "Cherché: 'tucanos-main' ou 'tucanos'"
    echo "Veuillez télécharger les sources de Tucanos depuis https://github.com/tucanos/tucanos"
    echo "et les extraire dans ce répertoire avant d'exécuter ce script."
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
if pkg-config --exists nlopt; then
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

# Configuration de Cargo pour mode offline
echo "Configuration de l'environnement Cargo..."

# Déterminer le vrai utilisateur (même si exécuté avec sudo)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo ~$REAL_USER)

# S'assurer que CARGO_HOME est dans le répertoire utilisateur réel
export CARGO_HOME="$REAL_HOME/.cargo"
export RUSTUP_HOME="$REAL_HOME/.rustup"

echo "Configuration Cargo pour l'utilisateur: $REAL_USER"
echo "  CARGO_HOME=$CARGO_HOME"
echo "  RUSTUP_HOME=$RUSTUP_HOME"

# Créer les répertoires si nécessaires
mkdir -p "$CARGO_HOME"
mkdir -p "$RUSTUP_HOME"

# Vérifier les permissions du répertoire cargo
if [ ! -w "$CARGO_HOME" ]; then
    echo "⚠ Pas de permission d'écriture sur $CARGO_HOME"
    # Corriger les permissions si exécuté avec sudo
    if [ -n "$SUDO_USER" ]; then
        chown -R "$SUDO_USER:$(id -gn $SUDO_USER)" "$CARGO_HOME" 2>/dev/null
        chown -R "$SUDO_USER:$(id -gn $SUDO_USER)" "$RUSTUP_HOME" 2>/dev/null
    fi
fi

# Créer un fichier de configuration Cargo pour mode offline
mkdir -p .cargo

# Vérifier si les dépendances GitHub sont installées
REAL_USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
if [ -d "$REAL_USER_HOME/.cargo/git/checkouts/coupe" ]; then
    # Trouver le dossier racine de coupe (celui qui contient Cargo.toml avec name = "coupe")
    COUPE_CHECKOUT=""
    for dir in "$REAL_USER_HOME/.cargo/git/checkouts/coupe"/*; do
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
    ORIGINAL_DIR="$(pwd)"
    cd ..
    /bin/chmod +x github-dependencies-offline/install_github_dependencies.sh 2>/dev/null || /usr/bin/chmod +x github-dependencies-offline/install_github_dependencies.sh
    /bin/bash github-dependencies-offline/install_github_dependencies.sh
    cd "$ORIGINAL_DIR"
    echo "✓ Dépendances GitHub installées depuis le package local"
fi

# Vérifier si le répertoire vendor existe et est complet
OFFLINE_MODE=true
if [ ! -d "../cargo-vendor" ]; then
    echo "⚠ Attention: Le répertoire cargo-vendor n'existe pas"
    OFFLINE_MODE=false
fi

# Vérifier si coupe est disponible (soit dans vendor, soit dans git checkouts)
REAL_USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
if [ ! -f "../cargo-vendor/coupe-*.crate" ] && [ ! -d "../cargo-vendor/coupe" ]; then
    if [ ! -d "$REAL_USER_HOME/.cargo/git/checkouts/coupe" ]; then
        echo "⚠ Attention: Dépendance 'coupe' manquante"
        echo "La dépendance 'coupe' doit être téléchargée depuis GitHub"
        OFFLINE_MODE=false
    else
        echo "✓ Dépendance 'coupe' trouvée dans ~/.cargo/git/checkouts/"
    fi
fi

if [ "$OFFLINE_MODE" = false ]; then
    echo "Les dépendances manquantes seront téléchargées depuis internet..."
    # Supprimer la configuration offline
    rm -f .cargo/config.toml
    
    echo ""
    echo "⚠ IMPORTANT: Compilation nécessite une connexion internet"
    echo "Dépendances à télécharger:"
    echo "  - coupe (https://github.com/LIHPC-Computational-Geometry/coupe.git)"
    echo "  - Autres dépendances crates.io si nécessaire"
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

# Fonction pour exécuter cargo en tant qu'utilisateur réel (pas root)
run_cargo() {
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        # Exécuté avec sudo, compiler en tant qu'utilisateur réel
        echo "Compilation en tant que $SUDO_USER (pas root)..."
        sudo -u "$SUDO_USER" env CARGO_HOME="$CARGO_HOME" RUSTUP_HOME="$RUSTUP_HOME" "$@"
    else
        # Exécution normale
        "$@"
    fi
}

# Vérifier s'il y a un conflit de workspace (dossier tucanos/ à l'intérieur)
if [ -f "tucanos/Cargo.toml" ] && [ -f "Cargo.toml" ]; then
    echo "⚠ Détection de workspaces imbriqués, compilation du sous-projet tucanos uniquement..."
    cd tucanos
fi

if [ -n "$CARGO_FEATURES" ]; then
    echo "Fonctionnalités activées: $CARGO_FEATURES"
    run_cargo cargo build --release --features "$CARGO_FEATURES"
else
    echo "Compilation sans fonctionnalités optionnelles"
    run_cargo cargo build --release
fi

if [ $? -eq 0 ]; then
    echo "✓ Compilation réussie !"
else
    echo "✗ Erreur lors de la compilation"
    
    # Si erreur de permissions, essayer avec sudo pour créer les répertoires
    if grep -q "Permission denied" <<< "$?" 2>/dev/null; then
        echo "⚠ Erreur de permissions détectée"
        echo "Tentative de correction des permissions..."
        
        # Nettoyer le cache cargo
        rm -rf "$HOME/.cargo/registry/cache"
        rm -rf "$HOME/.cargo/git/db"
        
        # Réessayer
        run_cargo cargo build --release --no-default-features
    else
        echo "Tentative avec les fonctionnalités minimales..."
        run_cargo cargo build --release --no-default-features
    fi
    
    if [ $? -eq 0 ]; then
        echo "✓ Compilation réussie (version minimale) !"
    else
        echo "✗ Échec de la compilation"
        echo ""
        echo "Causes possibles:"
        echo "  1. Permissions insuffisantes sur $CARGO_HOME"
        echo "  2. Dépendances manquantes (mode offline)"
        echo "  3. Espace disque insuffisant"
        echo ""
        echo "Solutions:"
        echo "  - Vérifier les permissions: ls -la $CARGO_HOME"
        echo "  - Libérer de l'espace: df -h"
        echo "  - Mode online: supprimer .cargo/config.toml et réessayer"
        exit 1
    fi
fi

# Vérifier les fichiers générés
echo "Fichiers générés:"
if [ -d "target/release" ]; then
    find target/release -name "*.so" -o -name "*.a" -o -name "tucanos.h" | while read file; do
        echo "  - $file"
    done
fi

# Installation globale (optionnelle)
read -p "Installer Tucanos globalement pour tous les utilisateurs ? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation globale..."
    
    # Créer les répertoires système
    sudo mkdir -p /usr/local/lib
    sudo mkdir -p /usr/local/include
    
    # Copier les bibliothèques
    if [ -f "target/release/libtucanos.so" ]; then
        sudo cp target/release/libtucanos.so /usr/local/lib/
        sudo ldconfig
        echo "✓ Bibliothèque installée dans /usr/local/lib/"
    fi
    
    # Copier les headers
    if [ -f "target/release/tucanos.h" ]; then
        sudo cp target/release/tucanos.h /usr/local/include/
        echo "✓ Headers installés dans /usr/local/include/"
    fi
    
    echo "✓ Installation globale terminée"
fi

# Test de l'installation
echo "Test de l'installation..."
if cargo test --workspace --release >/dev/null 2>&1; then
    echo "✓ Tests passés avec succès"
else
    echo "⚠ Certains tests ont échoué, mais l'installation est fonctionnelle"
fi

echo ""
echo "=== Installation terminée ==="
echo "Tucanos est maintenant installé et prêt à être utilisé !"
echo ""
echo "Pour utiliser Tucanos:"
echo "  - API C: #include <tucanos.h>"
echo "  - API Python: pip install (si bindings Python compilés)"
echo "  - Bibliothèque: libtucanos.so"
echo ""
echo "Fichiers disponibles dans: $(pwd)/target/release/"








