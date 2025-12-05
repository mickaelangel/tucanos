#!/bin/bash
# Installation des bindings Python

set -e

echo "=== Installation des bindings Python ==="

# VÃ©rifier Python
if ! command -v python3 &> /dev/null; then
    echo "ERREUR: Python3 n'est pas installÃ©"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo "ERREUR: pip3 n'est pas installÃ©"
    exit 1
fi

# Installer les wheels
echo "Installation des packages Python..."
pip3 install --user python/*.whl

echo "Installation Python terminÃ©e"
echo "Vous pouvez maintenant importer pytmesh et pytucanos"
