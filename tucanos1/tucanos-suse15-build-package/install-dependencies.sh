#!/bin/bash
# Installation automatique des dÃ©pendances pour SUSE 15

set -e

echo "=== Installation des dÃ©pendances pour Tucanos sur SUSE 15 ==="

# VÃ©rifier que nous sommes sur SUSE
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvÃ©"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse" && "$ID" != "sles" ]]; then
    echo "ATTENTION: Ce script est conÃ§u pour SUSE Linux"
    echo "Distribution dÃ©tectÃ©e: $PRETTY_NAME"
    read -p "Continuer quand mÃªme? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Distribution: $PRETTY_NAME"
echo ""

# Mise Ã  jour du systÃ¨me
echo "=== Mise Ã  jour du systÃ¨me ==="
sudo zypper refresh

# Installation des dÃ©pendances de base
echo "=== Installation des dÃ©pendances de base ==="
sudo zypper install -y gcc gcc-c++ make pkg-config

# Installation de Python
echo "=== Installation de Python ==="
sudo zypper install -y python3 python3-devel python3-pip

# Installation de Rust
echo "=== Installation de Rust ==="
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    echo "Rust installÃ©"
else
    echo "Rust dÃ©jÃ  installÃ©: $(rustc --version)"
fi

# Installation des dÃ©pendances optionnelles
echo "=== Installation des dÃ©pendances optionnelles ==="

# METIS (optionnel)
read -p "Installer METIS pour le partitionnement de maillage? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation de METIS..."
    # Note: METIS n'est pas dans les dÃ©pÃ´ts standard de SUSE
    echo "ATTENTION: METIS n'est pas disponible dans les dÃ©pÃ´ts standard de SUSE"
    echo "Vous devrez l'installer manuellement depuis https://github.com/KarypisLab/METIS"
fi

# NLOPT (optionnel)
read -p "Installer NLOPT pour l'optimisation? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation de NLOPT..."
    sudo zypper install -y nlopt-devel
fi

echo ""
echo "=== Installation des dÃ©pendances terminÃ©e ==="
echo "Vous pouvez maintenant compiler Tucanos avec:"
echo "  ./build-tucanos.sh"
