#!/bin/bash
# Installation METIS pour SUSE 15 SP4

echo "=== Installation METIS ==="

# Vérifier si METIS est déjà installé
if command -v gpmetis >/dev/null 2>&1; then
    echo "✓ METIS déjà installé"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_DIR="$SCRIPT_DIR/sources"

# Chercher les sources METIS (version 5.2.1 ou 5.1.0)
METIS_SOURCE=""
if [ -f "$SOURCES_DIR/metis-5.2.1.tar.gz" ]; then
    METIS_SOURCE="$SOURCES_DIR/metis-5.2.1.tar.gz"
    METIS_VERSION="5.2.1"
elif [ -f "$SOURCES_DIR/metis-5.1.0.tar.gz" ]; then
    METIS_SOURCE="$SOURCES_DIR/metis-5.1.0.tar.gz"
    METIS_VERSION="5.1.0"
else
    echo "✗ Sources METIS non trouvées dans $SOURCES_DIR"
    exit 1
fi

echo "✓ Sources METIS $METIS_VERSION trouvées"

# Vérifier les dépendances
if ! command -v cmake >/dev/null 2>&1; then
    echo "✗ cmake requis pour compiler METIS"
    echo "Installation: sudo zypper install cmake"
    exit 1
fi

if ! command -v make >/dev/null 2>&1; then
    echo "✗ make requis pour compiler METIS"
    exit 1
fi

if ! command -v gcc >/dev/null 2>&1; then
    echo "✗ gcc requis pour compiler METIS"
    echo "Installation : sudo zypper install gcc"
    exit 1
fi

if ! command -v g++ >/dev/null 2>&1; then
    echo "✗ g++ (compilateur C++) requis pour compiler METIS"
    echo "Installation : sudo zypper install gcc-c++"
    exit 1
fi

echo "✓ cmake trouvé : $(cmake --version | head -n1)"
echo "✓ make trouvé : $(make --version | head -n1)"
echo "✓ gcc trouvé : $(gcc --version | head -n1)"
echo "✓ g++ trouvé : $(g++ --version | head -n1)"

echo "Extraction de METIS $METIS_VERSION..."
TEMP_DIR=$(mktemp -d)
tar xzf "$METIS_SOURCE" -C "$TEMP_DIR"

# Déterminer le nom du dossier extrait
if [ "$METIS_VERSION" = "5.2.1" ]; then
    cd "$TEMP_DIR/METIS-5.2.1"
else
    cd "$TEMP_DIR/metis-$METIS_VERSION"
fi

echo "Configuration de METIS..."
make config prefix=$HOME/.local

echo "Compilation de METIS..."
make -j$(nproc) || make -j2

echo "Installation de METIS dans $HOME/.local/..."
make install

# Ajouter au LD_LIBRARY_PATH si nécessaire
if [[ ":$LD_LIBRARY_PATH:" != *":$HOME/.local/lib:"* ]]; then
    echo "export LD_LIBRARY_PATH=\"\$HOME/.local/lib:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
fi

# Ajouter au PKG_CONFIG_PATH
if [[ ":$PKG_CONFIG_PATH:" != *":$HOME/.local/lib/pkgconfig:"* ]]; then
    echo "export PKG_CONFIG_PATH=\"\$HOME/.local/lib/pkgconfig:\$PKG_CONFIG_PATH\"" >> ~/.bashrc
fi

# Nettoyer
cd "$HOME"
rm -rf "$TEMP_DIR"

echo "✓ METIS installé avec succès !"
echo "  Installé dans: $HOME/.local/"
echo "  Binaires: $HOME/.local/bin/"
echo "  Bibliothèques: $HOME/.local/lib/"
echo ""
echo "Pour utiliser immédiatement:"
echo "  source ~/.bashrc"
