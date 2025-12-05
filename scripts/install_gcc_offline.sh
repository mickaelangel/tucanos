#!/bin/bash
# Script d'installation gcc pour SUSE 15 SP4 (Hors ligne)
# Ce script compile et installe gcc depuis les sources

set -e  # Arrêter en cas d'erreur

echo "=== Installation GCC sur SUSE 15 SP4 (Hors ligne) ==="

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

log_info "GCC n'est pas installé, compilation depuis les sources..."

# Vérifier les prérequis de base
if ! command -v tar >/dev/null 2>&1; then
    log_error "tar n'est pas disponible"
    exit 1
fi

# Déterminer le répertoire de travail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$SCRIPT_DIR"

# Chercher les sources gcc dans différents emplacements
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
    log_error "Le fichier gcc-8.5.0.tar.xz ou gcc-7.5.0.tar.xz doit être présent"
    exit 1
fi

# Vérifier l'espace disque (besoin de ~10-15 GB)
AVAILABLE_SPACE=$(df -BG /tmp | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 15 ]; then
    log_warning "Espace disque faible dans /tmp : ${AVAILABLE_SPACE}GB"
    log_warning "La compilation de GCC nécessite environ 15 GB"
    read -p "Continuer quand même ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Créer un répertoire de build temporaire
BUILD_DIR="/tmp/gcc-build-$$"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

log_info "Extraction de GCC $GCC_VERSION..."
tar xf "$GCC_SOURCE"

cd "gcc-$GCC_VERSION"

log_info "Téléchargement des prérequis GCC..."
# GCC nécessite GMP, MPFR, MPC, ISL
# Le script contrib/download_prerequisites les télécharge automatiquement
# Mais en mode offline, on doit les fournir

# Vérifier si les prérequis sont déjà présents
if [ ! -d "gmp" ] && [ ! -d "mpfr" ] && [ ! -d "mpc" ]; then
    log_warning "Les bibliothèques de prérequis (GMP, MPFR, MPC) ne sont pas présentes"
    log_warning "GCC nécessite ces bibliothèques pour compiler"
    
    # Essayer de les installer via le système si disponibles
    log_info "Tentative d'installation via zypper..."
    if command -v zypper >/dev/null 2>&1; then
        if sudo zypper install -y gmp-devel mpfr-devel mpc-devel 2>/dev/null; then
            log_success "Prérequis installés via zypper"
        else
            log_error "Impossible d'installer les prérequis"
            log_error "En mode offline, vous devez fournir les sources de GMP, MPFR, MPC"
            cd /
            rm -rf "$BUILD_DIR"
            exit 1
        fi
    else
        log_error "zypper non disponible et prérequis manquants"
        cd /
        rm -rf "$BUILD_DIR"
        exit 1
    fi
fi

# Créer un répertoire de build séparé (recommandé)
mkdir -p ../gcc-build
cd ../gcc-build

log_info "Configuration de GCC $GCC_VERSION..."
log_info "Cela peut prendre plusieurs minutes..."

# Configuration minimale de GCC
../gcc-$GCC_VERSION/configure \
    --prefix=/usr/local \
    --enable-languages=c,c++ \
    --disable-multilib \
    --disable-bootstrap \
    --enable-checking=release

if [ $? -ne 0 ]; then
    log_error "Erreur lors de la configuration de GCC"
    cd /
    rm -rf "$BUILD_DIR"
    exit 1
fi

log_info "Compilation de GCC $GCC_VERSION..."
log_info "Cela peut prendre 30 minutes à 2 heures selon votre machine..."
log_info "Utilisez -j pour paralléliser : make -j$(nproc)"

# Compiler avec tous les cœurs disponibles
make -j$(nproc)

if [ $? -ne 0 ]; then
    log_error "Erreur lors de la compilation de GCC"
    log_warning "Tentative avec moins de parallélisme..."
    make -j2
    if [ $? -ne 0 ]; then
        log_error "Échec de la compilation de GCC"
        cd /
        rm -rf "$BUILD_DIR"
        exit 1
    fi
fi

log_info "Installation de GCC $GCC_VERSION..."
sudo make install

if [ $? -ne 0 ]; then
    log_error "Erreur lors de l'installation de GCC"
    cd /
    rm -rf "$BUILD_DIR"
    exit 1
fi

# Mettre à jour les liens symboliques
if [ ! -f /usr/bin/gcc ]; then
    sudo ln -sf /usr/local/bin/gcc /usr/bin/gcc
fi

if [ ! -f /usr/bin/g++ ]; then
    sudo ln -sf /usr/local/bin/g++ /usr/bin/g++
fi

# Mettre à jour ldconfig
sudo ldconfig

# Nettoyer
cd /
rm -rf "$BUILD_DIR"

# Vérification
if command -v gcc >/dev/null 2>&1; then
    log_success "GCC installé avec succès !"
    gcc --version | head -n1
    g++ --version | head -n1
else
    log_error "GCC n'est pas disponible après installation"
    exit 1
fi

log_success "Installation terminée !"






