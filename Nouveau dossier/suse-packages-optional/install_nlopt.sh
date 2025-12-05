#!/bin/bash
# Installation NLOPT pour SUSE 15 SP4 (100% Offline)

echo "=== Installation NLOPT ==="

# Vérifier si NLOPT est déjà installé
if pkg-config --exists nlopt 2>/dev/null; then
    echo "✓ NLOPT déjà installé : $(pkg-config --modversion nlopt)"
    exit 0
fi

# Vérifier aussi si la bibliothèque est présente
if [ -f "$HOME/.local/lib/libnlopt.so" ]; then
    echo "✓ NLOPT déjà installé dans ~/.local/"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$SCRIPT_DIR/sources"

# Chercher les sources NLOPT
if [ ! -f "$SOURCES_DIR/nlopt-2.7.1.tar.gz" ]; then
    echo "✗ Sources NLOPT non trouvées dans $SOURCES_DIR"
    echo "Cherché : $SOURCES_DIR/nlopt-2.7.1.tar.gz"
    exit 1
fi

echo "✓ Sources NLOPT 2.7.1 trouvées"

# Vérifier les dépendances
if ! command -v cmake >/dev/null 2>&1; then
    echo "✗ cmake requis pour compiler NLOPT"
    echo "Installation : sudo zypper install cmake"
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    echo "✗ make requis pour compiler NLOPT"
    echo "Installez make d'abord ou utilisez ../install_make_no_sudo.sh"
    exit 1
fi

if ! command -v gcc >/dev/null 2>&1; then
    echo "✗ gcc requis pour compiler NLOPT"
    echo "Installation : sudo zypper install gcc"
    exit 1
fi

if ! command -v g++ >/dev/null 2>&1; then
    echo "✗ g++ (compilateur C++) requis pour compiler NLOPT"
    echo "Installation : sudo zypper install gcc-c++"
    exit 1
fi

echo "✓ cmake trouvé : $(cmake --version | head -n1)"
echo "✓ make trouvé : $(make --version | head -n1)"
echo "✓ gcc trouvé : $(gcc --version | head -n1)"
echo "✓ g++ trouvé : $(g++ --version | head -n1)"

# Créer les répertoires locaux
mkdir -p "$HOME/.local/lib"
mkdir -p "$HOME/.local/include"
mkdir -p "$HOME/.local/lib/pkgconfig"

echo "Extraction de NLOPT 2.7.1..."
TEMP_DIR=$(mktemp -d)
tar xzf "$SOURCES_DIR/nlopt-2.7.1.tar.gz" -C "$TEMP_DIR"
cd "$TEMP_DIR/nlopt-2.7.1"

echo "Configuration de NLOPT..."
mkdir -p build
cd build

# Configuration pour installation locale
cmake .. \
    -DCMAKE_INSTALL_PREFIX="$HOME/.local" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DNLOPT_PYTHON=OFF \
    -DNLOPT_OCTAVE=OFF \
    -DNLOPT_MATLAB=OFF \
    -DNLOPT_GUILE=OFF \
    -DNLOPT_SWIG=OFF

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de la configuration de NLOPT"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Compilation de NLOPT..."
make -j$(nproc) || make -j2

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de la compilation de NLOPT"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Installation de NLOPT dans $HOME/.local/..."
make install

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de l'installation de NLOPT"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Configurer LD_LIBRARY_PATH
if [[ ":$LD_LIBRARY_PATH:" != *":$HOME/.local/lib:"* ]]; then
    echo "export LD_LIBRARY_PATH=\"\$HOME/.local/lib:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
    echo "✓ LD_LIBRARY_PATH configuré dans ~/.bashrc"
fi

# Configurer PKG_CONFIG_PATH
if [[ ":$PKG_CONFIG_PATH:" != *":$HOME/.local/lib/pkgconfig:"* ]]; then
    echo "export PKG_CONFIG_PATH=\"\$HOME/.local/lib/pkgconfig:\$PKG_CONFIG_PATH\"" >> ~/.bashrc
    echo "✓ PKG_CONFIG_PATH configuré dans ~/.bashrc"
fi

# Nettoyer
cd "$HOME"
rm -rf "$TEMP_DIR"

echo ""
echo "✅ NLOPT installé avec succès !"
echo "  Installé dans   : $HOME/.local/"
echo "  Bibliothèque    : $HOME/.local/lib/libnlopt.so"
echo "  Headers         : $HOME/.local/include/nlopt.h"
echo "  pkg-config      : $HOME/.local/lib/pkgconfig/nlopt.pc"
echo ""
echo "Pour utiliser immédiatement :"
echo "  source ~/.bashrc"
echo ""
echo "Pour vérifier :"
echo "  pkg-config --modversion nlopt"
echo "  ls -lh ~/.local/lib/libnlopt.so"
