#!/bin/bash
# Script pour compiler NLOPT depuis les sources
# À exécuter sur la machine cible (peut être hors ligne si cmake est disponible)

set -e

echo "==================================================================="
echo "  Compilation de NLOPT depuis les sources"
echo "==================================================================="
echo ""

# Vérifier que la source est présente
NLOPT_ARCHIVE="dependencies/sources/nlopt-2.7.1.tar.gz"

if [ ! -f "$NLOPT_ARCHIVE" ]; then
    echo "❌ ERREUR: Archive NLOPT non trouvée: $NLOPT_ARCHIVE"
    echo ""
    echo "Téléchargez depuis: https://github.com/stevengj/nlopt/archive/v2.7.1.tar.gz"
    echo "Et placez-la dans dependencies/sources/"
    exit 1
fi

echo "✓ Archive NLOPT trouvée: $NLOPT_ARCHIVE"
echo ""

# Vérifier les prérequis
echo "Vérification des prérequis..."

if ! command -v gcc &> /dev/null; then
    echo "❌ gcc non trouvé"
    exit 1
fi

if ! command -v g++ &> /dev/null; then
    echo "❌ g++ non trouvé"
    exit 1
fi

if ! command -v make &> /dev/null; then
    echo "❌ make non trouvé"
    exit 1
fi

# Vérifier cmake
if command -v cmake &> /dev/null; then
    CMAKE_CMD="cmake"
    echo "✓ cmake système trouvé: $(cmake --version | head -1)"
elif [ -f "dependencies/sources/cmake-3.28.1-linux-x86_64.tar.gz" ]; then
    echo "Installation de cmake depuis les sources..."
    cd dependencies/sources
    tar xzf cmake-3.28.1-linux-x86_64.tar.gz
    CMAKE_CMD="$(pwd)/cmake-3.28.1-linux-x86_64/bin/cmake"
    export PATH="$(pwd)/cmake-3.28.1-linux-x86_64/bin:$PATH"
    cd - > /dev/null
    echo "✓ cmake local installé"
else
    echo "❌ cmake non trouvé"
    echo ""
    echo "Solutions:"
    echo "1. Installez cmake: sudo zypper install cmake"
    echo "2. Téléchargez cmake depuis: https://cmake.org/download/"
    exit 1
fi

echo ""
echo "✓ Tous les prérequis sont présents"
echo ""

# Créer un répertoire de build
BUILD_DIR="build-nlopt"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Extraire l'archive
echo "Extraction de NLOPT..."
tar xzf "../$NLOPT_ARCHIVE"

# Entrer dans le répertoire
cd nlopt-2.7.1

# Configuration
echo ""
echo "=== Configuration de NLOPT ==="
echo ""

# Choisir le préfixe d'installation
read -p "Installer dans /usr/local ? (y/N, N=installation locale): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    INSTALL_PREFIX="/usr/local"
    NEED_SUDO=true
    echo "Installation système dans: $INSTALL_PREFIX"
else
    INSTALL_PREFIX="$HOME/.local"
    NEED_SUDO=false
    echo "Installation locale dans: $INSTALL_PREFIX"
fi

mkdir -p build
cd build

$CMAKE_CMD \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    ..

echo ""
echo "=== Compilation de NLOPT ==="
echo ""

# Compiler
make -j$(nproc)

echo ""
echo "✓ Compilation terminée"
echo ""

# Installation
echo "=== Installation de NLOPT ==="
echo ""

if [ "$NEED_SUDO" = true ]; then
    echo "Installation système (nécessite sudo)..."
    sudo make install
    sudo ldconfig
else
    echo "Installation locale..."
    make install
    
    # Mettre à jour LD_LIBRARY_PATH
    echo ""
    echo "Ajoutez cette ligne à votre ~/.bashrc:"
    echo "export LD_LIBRARY_PATH=\"$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH\""
    echo ""
fi

# Vérification
echo ""
echo "=== Vérification de l'installation ==="
echo ""

if [ -f "$INSTALL_PREFIX/lib/libnlopt.so" ] || [ -f "$INSTALL_PREFIX/lib64/libnlopt.so" ]; then
    echo "✓ libnlopt.so installée"
    ls -lh "$INSTALL_PREFIX"/lib*/libnlopt.so* 2>/dev/null || true
else
    echo "⚠ libnlopt.so non trouvée"
fi

if [ -f "$INSTALL_PREFIX/include/nlopt.h" ]; then
    echo "✓ nlopt.h installé"
else
    echo "⚠ nlopt.h non trouvé"
fi

# Créer un fichier pkg-config si nécessaire
if [ "$NEED_SUDO" = false ]; then
    echo ""
    echo "Création du fichier pkg-config..."
    
    mkdir -p "$INSTALL_PREFIX/lib/pkgconfig"
    
    cat > "$INSTALL_PREFIX/lib/pkgconfig/nlopt.pc" << EOF
prefix=$INSTALL_PREFIX
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: NLopt
Description: nonlinear optimization library
Version: 2.7.1
Libs: -L\${libdir} -lnlopt
Cflags: -I\${includedir}
EOF
    
    echo "✓ nlopt.pc créé dans $INSTALL_PREFIX/lib/pkgconfig/"
    echo ""
    echo "Ajoutez cette ligne à votre ~/.bashrc:"
    echo "export PKG_CONFIG_PATH=\"$INSTALL_PREFIX/lib/pkgconfig:\$PKG_CONFIG_PATH\""
fi

# Nettoyer
cd ../../..
echo ""
read -p "Supprimer le répertoire de build? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$BUILD_DIR"
    echo "✓ Build directory supprimé"
fi

echo ""
echo "==================================================================="
echo "  NLOPT installé avec succès!"
echo "==================================================================="
echo ""
echo "Installation: $INSTALL_PREFIX"
echo ""

if [ "$NEED_SUDO" = false ]; then
    echo "⚠ IMPORTANT: Ajoutez ces lignes à votre ~/.bashrc:"
    echo ""
    echo "export LD_LIBRARY_PATH=\"$INSTALL_PREFIX/lib:\$LD_LIBRARY_PATH\""
    echo "export PKG_CONFIG_PATH=\"$INSTALL_PREFIX/lib/pkgconfig:\$PKG_CONFIG_PATH\""
    echo ""
    echo "Puis rechargez: source ~/.bashrc"
fi

echo ""
echo "Vous pouvez maintenant compiler Tucanos avec --features nlopt"






