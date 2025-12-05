#!/bin/bash
# Installation g++ depuis les sources GCC (mode offline)

echo "=========================================="
echo "  Installation g++ depuis sources GCC"
echo "  Installation dans ~/.local/"
echo "=========================================="
echo ""

# Vérifier si g++ est déjà installé
if command -v g++ >/dev/null 2>&1; then
    echo "✓ g++ déjà installé : $(g++ --version | head -n1)"
    exit 0
fi

# Vérifier gcc (requis pour compiler GCC lui-même)
if ! command -v gcc >/dev/null 2>&1; then
    echo "✗ gcc requis pour compiler g++"
    echo "Demandez à l'admin : sudo zypper install gcc"
    exit 1
fi

# Vérifier make
if ! command -v make >/dev/null 2>&1; then
    echo "✗ make requis"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GCC_SOURCES="$SCRIPT_DIR/gcc-sources-offline"

# Vérifier la présence des sources GCC
if [ ! -d "$GCC_SOURCES" ]; then
    echo "✗ Dossier gcc-sources-offline non trouvé"
    echo ""
    echo "⚠️  Installation de g++ depuis les sources nécessite :"
    echo "  - ~110 MB de sources GCC"
    echo "  - 1-2 heures de compilation"
    echo "  - Plusieurs Go d'espace disque"
    echo ""
    echo "Solution RECOMMANDÉE : Demander à l'admin d'installer g++ :"
    echo "  sudo zypper install gcc-c++"
    exit 1
fi

GCC_TARBALL=$(find "$GCC_SOURCES" -name "gcc-*.tar.gz" -o -name "gcc-*.tar.xz" | head -n1)

if [ -z "$GCC_TARBALL" ] || [ ! -f "$GCC_TARBALL" ]; then
    echo "✗ Sources GCC non trouvées dans $GCC_SOURCES"
    exit 1
fi

echo "✓ Sources GCC trouvées : $(basename "$GCC_TARBALL")"
echo ""
echo "⚠️  ATTENTION :"
echo "  - Compilation de GCC prend 1-2 heures"
echo "  - Nécessite plusieurs Go d'espace disque"
echo "  - Utilisation intensive du CPU"
echo ""
echo "Il est FORTEMENT RECOMMANDÉ de demander à l'admin :"
echo "  sudo zypper install gcc-c++"
echo ""
read -p "Voulez-vous vraiment compiler GCC depuis les sources? (oui/non) " -r
if [[ ! $REPLY =~ ^[Oo][Uu][Ii]$ ]]; then
    echo "Installation annulée"
    exit 0
fi

echo ""
echo "Extraction des sources GCC..."
TEMP_DIR=$(mktemp -d)
tar xf "$GCC_TARBALL" -C "$TEMP_DIR"
GCC_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "gcc-*" | head -n1)

if [ -z "$GCC_DIR" ]; then
    echo "✗ Erreur lors de l'extraction"
    rm -rf "$TEMP_DIR"
    exit 1
fi

cd "$GCC_DIR"

# Extraire les dépendances GCC dans le bon répertoire
echo "Extraction des dépendances GCC..."

# GMP
if [ -f "$GCC_SOURCES/gmp-6.1.2.tar.xz" ]; then
    echo "  Extraction GMP..."
    tar xf "$GCC_SOURCES/gmp-6.1.2.tar.xz"
    ln -sf gmp-6.1.2 gmp
fi

# MPFR
if [ -f "$GCC_SOURCES/mpfr-4.0.2.tar.xz" ]; then
    echo "  Extraction MPFR..."
    tar xf "$GCC_SOURCES/mpfr-4.0.2.tar.xz"
    ln -sf mpfr-4.0.2 mpfr
fi

# MPC
if [ -f "$GCC_SOURCES/mpc-1.1.0.tar.gz" ]; then
    echo "  Extraction MPC..."
    tar xf "$GCC_SOURCES/mpc-1.1.0.tar.gz"
    ln -sf mpc-1.1.0 mpc
fi

# ISL
if [ -f "$GCC_SOURCES/isl-0.18.tar.bz2" ]; then
    echo "  Extraction ISL..."
    tar xf "$GCC_SOURCES/isl-0.18.tar.bz2"
    ln -sf isl-0.18 isl
fi

echo "✓ Dépendances extraites et liées"

echo ""
echo "Configuration de GCC (C et C++ seulement)..."
mkdir -p build
cd build

../configure \
    --prefix="$HOME/.local" \
    --enable-languages=c,c++ \
    --disable-multilib \
    --disable-bootstrap \
    --enable-checking=release

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de la configuration"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo ""
echo "Compilation de GCC (cela prend 1-2 heures)..."
echo "Début : $(date)"
make -j$(nproc) || make -j2

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de la compilation"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo ""
echo "Installation de GCC dans $HOME/.local/..."
make install

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de l'installation"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Nettoyer
cd "$HOME"
rm -rf "$TEMP_DIR"

# Ajouter au PATH si nécessaire
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

echo ""
echo "✅ g++ installé avec succès !"
echo "Version : $(g++ --version | head -n1)"
echo ""
echo "Activez avec : source ~/.bashrc"
echo ""
echo "Vous pouvez maintenant installer METIS et NLOPT :"
echo "  cd suse-packages-optional"
echo "  bash install_metis.sh"
echo "  bash install_nlopt.sh"

