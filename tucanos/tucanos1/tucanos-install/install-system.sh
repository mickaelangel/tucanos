#!/bin/bash
# Installation systÃ¨me de Tucanos

set -e

INSTALL_PREFIX="/usr/local"
LIB_DIR="$INSTALL_PREFIX/lib"
INCLUDE_DIR="$INSTALL_PREFIX/include"

echo "=== Installation systÃ¨me de Tucanos ==="

# VÃ©rifier les permissions
if [ "$EUID" -ne 0 ]; then
    echo "ERREUR: Ce script doit Ãªtre exÃ©cutÃ© en tant que root"
    exit 1
fi

# CrÃ©er les rÃ©pertoires
mkdir -p "$LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# Installer les bibliothÃ¨ques
echo "Installation des bibliothÃ¨ques..."
cp lib/*.so "$LIB_DIR/"
cp include/*.h "$INCLUDE_DIR/"

# Mettre Ã  jour ldconfig
echo "Mise Ã  jour du cache des bibliothÃ¨ques..."
ldconfig

echo "Installation systÃ¨me terminÃ©e"
echo "Les bibliothÃ¨ques sont installÃ©es dans $LIB_DIR"
echo "Les en-tÃªtes sont installÃ©s dans $INCLUDE_DIR"
