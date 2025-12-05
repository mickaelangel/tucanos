#!/bin/bash
# Script de dÃ©ploiement pour SUSE 15

set -e

echo "=== DÃ©ploiement de Tucanos sur SUSE 15 ==="

# VÃ©rifier que nous sommes sur SUSE
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvÃ©"
    exit 1
fi

source /etc/os-release
if [[ "\" != "opensuse" && "\" != "sles" ]]; then
    echo "ATTENTION: Ce script est conÃ§u pour SUSE Linux"
    echo "Distribution dÃ©tectÃ©e: \"
    read -p "Continuer quand mÃªme? (y/N): " -n 1 -r
    echo
    if [[ ! \ =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Distribution: \"
echo ""

# Installer les dÃ©pendances systÃ¨me
echo "=== Installation des dÃ©pendances systÃ¨me ==="
echo "Mise Ã  jour du systÃ¨me..."
zypper refresh

echo "Installation des outils de dÃ©veloppement..."
zypper install -y gcc gcc-c++ make pkg-config

echo "Installation de Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

echo "Installation de Python (si nÃ©cessaire)..."
zypper install -y python3 python3-devel python3-pip

echo "DÃ©pendances installÃ©es"
echo ""

# ExÃ©cuter la compilation
echo "=== Compilation de Tucanos ==="
if [ -f "build-tucanos.sh" ]; then
    chmod +x build-tucanos.sh
    ./build-tucanos.sh
else
    echo "ERREUR: Script de compilation non trouvÃ©"
    exit 1
fi

echo "=== DÃ©ploiement terminÃ© ==="
