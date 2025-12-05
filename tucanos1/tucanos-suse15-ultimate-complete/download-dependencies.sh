#!/bin/bash
# Script pour tÃ©lÃ©charger TOUTES les dÃ©pendances nÃ©cessaires
# Ã€ exÃ©cuter sur une machine avec internet AVANT le transfert

set -e

echo "=== TÃ©lÃ©chargement des dÃ©pendances pour installation hors ligne ==="
echo ""

# CrÃ©er les rÃ©pertoires
mkdir -p dependencies/rust
mkdir -p dependencies/python
mkdir -p dependencies/system

echo "=== TÃ©lÃ©chargement de Rust ==="
echo "TÃ©lÃ©chargement de rustup-init..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o dependencies/rust/rustup-init
chmod +x dependencies/rust/rustup-init

echo "Rust tÃ©lÃ©chargÃ©"
echo ""

echo "=== TÃ©lÃ©chargement des packages Python ==="
echo "TÃ©lÃ©chargement de maturin et dÃ©pendances..."

# CrÃ©er un environnement virtuel temporaire
python3 -m venv temp_env
source temp_env/bin/activate

# TÃ©lÃ©charger les packages Python
pip download maturin
pip download setuptools
pip download wheel
pip download pyo3
pip download numpy

# DÃ©placer les wheels
mv temp_env/lib/python*/site-packages/*.whl dependencies/python/ 2>/dev/null || true
mv *.whl dependencies/python/ 2>/dev/null || true

# Nettoyer
deactivate
rm -rf temp_env

echo "Packages Python tÃ©lÃ©chargÃ©s"
echo ""

echo "=== TÃ©lÃ©chargement des packages systÃ¨me ==="
echo "ATTENTION: Les packages RPM doivent Ãªtre tÃ©lÃ©chargÃ©s manuellement"
echo "Depuis les dÃ©pÃ´ts SUSE:"
echo "  - gcc, gcc-c++, make, pkg-config"
echo "  - python3, python3-devel, python3-pip"
echo "  - nlopt-devel"
echo ""
echo "Placez les fichiers .rpm dans le dossier dependencies/system/"
echo ""

echo "=== TÃ©lÃ©chargement terminÃ© ==="
echo "Vous pouvez maintenant transfÃ©rer ce package sur SUSE 15"
echo "et exÃ©cuter: ./install-complete-offline.sh"
