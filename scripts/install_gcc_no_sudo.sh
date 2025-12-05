#!/bin/bash
# Script d'installation gcc pour SUSE 15 SP4 (Sans sudo)
# Ce script compile et installe gcc dans ~/.local/

set -e  # Arrêter en cas d'erreur

echo "=== Installation GCC sur SUSE 15 SP4 (Sans sudo) ==="

# Fonction pour afficher les messages
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[✓]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[✗]\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33m[⚠]\033[0m $1"
}

# Vérifier si gcc est déjà installé
if command -v gcc >/dev/null 2>&1; then
    GCC_VERSION=$(gcc -dumpversion)
    log_success "GCC est déjà installé : version $GCC_VERSION"
    gcc --version | head -n1
    exit 0
fi

log_warning "GCC n'est pas installé"
log_info "ATTENTION: Compiler GCC depuis les sources SANS SUDO est complexe"
log_info "et nécessite des prérequis système qui peuvent nécessiter sudo"
echo ""

# Créer les répertoires locaux
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/lib"
mkdir -p "$HOME/.local/include"

# Vérifier les prérequis de base
if ! command -v tar >/dev/null 2>&1; then
    log_error "tar n'est pas disponible"
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    log_error "make n'est pas disponible"
    log_info "Installez make d'abord avec install_make_no_sudo.sh"
    exit 1
fi

# Déterminer le répertoire de travail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$SCRIPT_DIR"

# Chercher les sources gcc
GCC_SOURCE=""
GCC_VERSION=""

for loc in "$SOURCES_DIR" "$SOURCES_DIR/sources" "$SOURCES_DIR/../suse-packages/sources" "suse-packages/sources"; do
    if [ -f "$loc/gcc-8.5.0.tar.xz" ]; then
        GCC_SOURCE="$loc/gcc-8.5.0.tar.xz"
        GCC_VERSION="8.5.0"
        log_success "Sources GCC trouvées : $GCC_SOURCE"
        break
    elif [ -f "$loc/gcc-7.5.0.tar.xz" ]; then
        GCC_SOURCE="$loc/gcc-7.5.0.tar.xz"
        GCC_VERSION="7.5.0"
        log_success "Sources GCC trouvées : $GCC_SOURCE"
        break
    fi
done

if [ -z "$GCC_SOURCE" ]; then
    log_error "Sources GCC non trouvées"
    exit 1
fi

# Vérifier l'espace disque (besoin de ~10-15 GB)
AVAILABLE_SPACE=$(df -BG "$HOME" | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 15 ]; then
    log_warning "Espace disque faible dans $HOME : ${AVAILABLE_SPACE}GB"
    log_warning "La compilation de GCC nécessite environ 15 GB"
    read -p "Continuer quand même ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Vérifier les prérequis GCC
log_warning "GCC nécessite GMP, MPFR, MPC pour compiler"
log_info "Ces bibliothèques doivent être disponibles sur le système"

# Essayer de vérifier si les bibliothèques de développement sont disponibles
PREREQ_OK=true

for lib in gmp mpfr mpc; do
    if ! ldconfig -p 2>/dev/null | grep -q "lib${lib}.so"; then
        log_warning "Bibliothèque ${lib} non trouvée dans ldconfig"
        PREREQ_OK=false
    fi
done

if [ "$PREREQ_OK" = false ]; then
    log_warning "Prérequis manquants détectés"
    log_info "Sans sudo, impossible d'installer les prérequis système"
    log_info ""
    log_info "Solutions:"
    log_info "  1. Demander à l'administrateur d'installer:"
    log_info "     sudo zypper install gmp-devel mpfr-devel mpc-devel"
    log_info "  2. Compiler et installer GMP, MPFR, MPC dans ~/.local/ d'abord"
    log_info "  3. Utiliser une machine avec gcc déjà installé"
    echo ""
    read -p "Continuer quand même (peut échouer) ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Créer un répertoire de build temporaire
BUILD_DIR="$HOME/tmp/gcc-build-$$"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

log_info "Extraction de GCC $GCC_VERSION..."
tar xf "$GCC_SOURCE"

cd "gcc-$GCC_VERSION"

# Télécharger les prérequis (si connexion internet disponible)
if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
    log_info "Tentative de téléchargement des prérequis GCC..."
    if [ -f "contrib/download_prerequisites" ]; then
        ./contrib/download_prerequisites || log_warning "Échec du téléchargement des prérequis"
    fi
fi

# Créer un répertoire de build séparé
mkdir -p ../gcc-build
cd ../gcc-build

log_info "Configuration de GCC $GCC_VERSION pour installation dans ~/.local/..."
log_info "Cela peut prendre plusieurs minutes..."

# Configuration pour installation locale
../gcc-$GCC_VERSION/configure \
    --prefix="$HOME/.local" \
    --enable-languages=c,c++ \
    --disable-multilib \
    --disable-bootstrap \
    --enable-checking=release

if [ $? -ne 0 ]; then
    log_error "Erreur lors de la configuration de GCC"
    log_info "Cela peut être dû aux prérequis manquants (GMP, MPFR, MPC)"
    cd "$HOME"
    rm -rf "$BUILD_DIR"
    exit 1
fi

log_info "Compilation de GCC $GCC_VERSION..."
log_info "Cela peut prendre 30 minutes à 2 heures..."

# Compiler
make -j$(nproc) || make -j2

if [ $? -ne 0 ]; then
    log_error "Erreur lors de la compilation de GCC"
    cd "$HOME"
    rm -rf "$BUILD_DIR"
    exit 1
fi

log_info "Installation de GCC $GCC_VERSION dans ~/.local/..."
make install

if [ $? -ne 0 ]; then
    log_error "Erreur lors de l'installation de GCC"
    cd "$HOME"
    rm -rf "$BUILD_DIR"
    exit 1
fi

# Ajouter ~/.local/bin au PATH si nécessaire
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
    log_info "~/.local/bin ajouté au PATH"
fi

# Configurer LD_LIBRARY_PATH
if [[ ":$LD_LIBRARY_PATH:" != *":$HOME/.local/lib:"* ]]; then
    echo "export LD_LIBRARY_PATH=\"\$HOME/.local/lib:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
    export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
    log_info "~/.local/lib ajouté à LD_LIBRARY_PATH"
fi

if [[ ":$LD_LIBRARY_PATH:" != *":$HOME/.local/lib64:"* ]]; then
    echo "export LD_LIBRARY_PATH=\"\$HOME/.local/lib64:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
    export LD_LIBRARY_PATH="$HOME/.local/lib64:$LD_LIBRARY_PATH"
fi

# Nettoyer
cd "$HOME"
rm -rf "$BUILD_DIR"

# Vérification
if command -v gcc >/dev/null 2>&1; then
    log_success "GCC installé avec succès dans ~/.local/ !"
    gcc --version | head -n1
    g++ --version | head -n1
else
    log_error "GCC n'est pas disponible après installation"
    log_info "Vérifiez que ~/.local/bin est dans votre PATH"
    log_info "Exécutez: source ~/.bashrc"
    exit 1
fi

log_success "Installation terminée !"
echo ""
echo "Pour activer immédiatement:"
echo "  source ~/.bashrc"





