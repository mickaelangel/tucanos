#!/bin/bash
# Script de prÃ©paration pour installation hors ligne

set -e

echo "=== PrÃ©paration pour installation HORS LIGNE de Tucanos ==="
echo ""

# VÃ©rifier la distribution
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvÃ©"
    exit 1
fi

source /etc/os-release
echo "Distribution: $PRETTY_NAME"

if [[ "$ID" != "opensuse" && "$ID" != "sles" ]]; then
    echo "ATTENTION: Ce script est conÃ§u pour SUSE Linux"
    echo "Distribution dÃ©tectÃ©e: $PRETTY_NAME"
    read -p "Continuer quand mÃªme? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# Installation des dÃ©pendances systÃ¨me
echo "=== Installation des dÃ©pendances systÃ¨me ==="
echo "Mise Ã  jour du systÃ¨me..."
sudo zypper refresh

echo "Installation des outils de dÃ©veloppement..."
sudo zypper install -y gcc gcc-c++ make pkg-config

echo "Installation de Python..."
sudo zypper install -y python3 python3-devel python3-pip

echo "Installation de NLOPT (optionnel)..."
sudo zypper install -y nlopt-devel

echo "DÃ©pendances systÃ¨me installÃ©es"
echo ""

# Installation de Rust
echo "=== Installation de Rust ==="
if ! command -v rustc &> /dev/null; then
    echo "Installation de Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    echo "Rust installÃ©"
else
    echo "Rust dÃ©jÃ  installÃ©: $(rustc --version)"
fi

echo ""

# Installation de maturin
echo "=== Installation de maturin ==="
pip3 install --user maturin

echo ""

# Information sur METIS
echo "=== Information sur METIS ==="
echo "METIS n'est pas disponible dans les dÃ©pÃ´ts standard de SUSE"
echo "Pour l'installer manuellement:"
echo "1. TÃ©lÃ©chargez depuis: https://github.com/KarypisLab/METIS"
echo "2. Compilez et installez selon les instructions"
echo "3. Configurez METISDIR dans .cargo/config.toml si nÃ©cessaire"
echo ""

echo "=== PrÃ©paration terminÃ©e ==="
echo "Vous pouvez maintenant transfÃ©rer ce package sur une machine hors ligne"
echo "et exÃ©cuter: ./build-tucanos-offline.sh"
