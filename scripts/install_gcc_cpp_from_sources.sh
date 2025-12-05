#!/bin/bash
# Installation g++ depuis les sources GCC (inclus dans le package gcc que vous avez déjà)

echo "=== Installation g++ depuis les sources GCC ==="

# Vérifier si g++ est déjà installé
if command -v g++ >/dev/null 2>&1; then
    echo "✓ g++ déjà installé : $(g++ --version | head -n1)"
    exit 0
fi

# Vérifier si gcc est installé
if ! command -v gcc >/dev/null 2>&1; then
    echo "✗ gcc requis (installez-le d'abord)"
    exit 1
fi

# Chercher les sources GCC
GCC_SOURCE=""
if [ -d "gcc-sources" ]; then
    GCC_SOURCE=$(find gcc-sources -name "gcc-*.tar.gz" -o -name "gcc-*.tar.xz" | head -n1)
elif [ -d "dependencies/sources" ]; then
    GCC_SOURCE=$(find dependencies/sources -name "gcc-*.tar.gz" -o -name "gcc-*.tar.xz" | head -n1)
fi

if [ -z "$GCC_SOURCE" ] || [ ! -f "$GCC_SOURCE" ]; then
    echo "⚠️  Sources GCC non trouvées"
    echo ""
    echo "Solution alternative : Demander à l'admin d'installer g++ :"
    echo "  sudo zypper install gcc-c++"
    echo ""
    echo "OU télécharger GCC sur une machine avec Internet :"
    echo "  wget https://ftp.gnu.org/gnu/gcc/gcc-7.5.0/gcc-7.5.0.tar.gz"
    exit 1
fi

echo "✓ Sources GCC trouvées : $GCC_SOURCE"
echo "⚠️  ATTENTION : Compiler GCC prend 1-2 heures et beaucoup d'espace disque"
echo "   Il est recommandé de demander à l'admin : sudo zypper install gcc-c++"
read -p "Voulez-vous continuer la compilation? (oui/non) " -r
if [[ ! $REPLY =~ ^[Oo][Uu][Ii]$ ]]; then
    echo "Installation annulée"
    exit 0
fi

# Vérifier make
if ! command -v make >/dev/null 2>&1; then
    echo "✗ make requis"
    exit 1
fi

echo "Extraction des sources GCC..."
TEMP_DIR=$(mktemp -d)
tar xf "$GCC_SOURCE" -C "$TEMP_DIR"
GCC_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "gcc-*" | head -n1)

if [ -z "$GCC_DIR" ]; then
    echo "✗ Erreur lors de l'extraction"
    rm -rf "$TEMP_DIR"
    exit 1
fi

cd "$GCC_DIR"

echo "Téléchargement des prérequis GCC..."
./contrib/download_prerequisites || {
    echo "⚠️  Impossible de télécharger les prérequis (machine hors ligne)"
    echo "GCC nécessite : GMP, MPFR, MPC, ISL"
}

echo "Configuration de GCC (C et C++ uniquement)..."
mkdir -p build
cd build

../configure \
    --prefix="$HOME/.local" \
    --enable-languages=c,c++ \
    --disable-multilib \
    --disable-bootstrap

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de la configuration"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Compilation de GCC (cela peut prendre 1-2 heures)..."
make -j$(nproc)

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de la compilation"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

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

echo ""
echo "✅ g++ installé avec succès !"
echo "Version : $(g++ --version | head -n1)"




