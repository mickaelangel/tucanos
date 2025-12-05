#!/bin/bash
# DÃ©ploiement complet de Tucanos sur SUSE 15

set -e

echo "=== DÃ©ploiement complet de Tucanos sur SUSE 15 ==="

# VÃ©rifier les permissions
if [ "$EUID" -eq 0 ]; then
    echo "ERREUR: Ne pas exÃ©cuter ce script en tant que root"
    echo "Ce script vous demandera sudo quand nÃ©cessaire"
    exit 1
fi

# Installation des dÃ©pendances
echo "=== Installation des dÃ©pendances ==="
chmod +x install-dependencies.sh
./install-dependencies.sh

# Compilation
echo "=== Compilation de Tucanos ==="
chmod +x build-tucanos.sh
./build-tucanos.sh

# Installation
echo "=== Installation de Tucanos ==="
cd tucanos-install
sudo ./install-system.sh
./install-python.sh

# Test
echo "=== Test de l'installation ==="
./test-installation.sh

echo ""
echo "=== DÃ©ploiement terminÃ© ==="
echo "Tucanos est maintenant installÃ© et testÃ© sur votre systÃ¨me SUSE 15"
echo ""
echo "Vous pouvez maintenant utiliser:"
echo "  - Les bibliothÃ¨ques C/C++ : #include <tucanos.h>"
echo "  - Les bindings Python : import pytmesh, pytucanos"
