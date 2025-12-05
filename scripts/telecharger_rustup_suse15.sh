#!/bin/bash
# Script pour télécharger rustup-init pour SUSE 15 (Linux)
# À exécuter sur un système connecté à internet

echo "=== Téléchargement de rustup-init pour SUSE 15 ==="

# Vérifier si wget ou curl est disponible
if command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget"
elif command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -O"
else
    echo "Erreur: wget ou curl requis pour télécharger rustup-init"
    exit 1
fi

echo "Téléchargement de rustup-init pour Linux..."

# Télécharger rustup-init (script shell, pas .exe)
$DOWNLOAD_CMD https://sh.rustup.rs

# Renommer le fichier téléchargé
if [ -f "sh.rustup.rs" ]; then
    mv sh.rustup.rs rustup-init
    chmod +x rustup-init
    echo "✓ rustup-init téléchargé et rendu exécutable"
    echo "Fichier: rustup-init (script shell pour Linux)"
    echo "Taille: $(ls -lh rustup-init | awk '{print $5}')"
else
    echo "✗ Erreur lors du téléchargement"
    exit 1
fi

echo ""
echo "=== Instructions pour SUSE 15 ==="
echo "1. Copiez 'rustup-init' sur votre serveur SUSE 15"
echo "2. Sur SUSE 15, exécutez:"
echo "   chmod +x rustup-init"
echo "   ./rustup-init -y --default-toolchain stable-x86_64-unknown-linux-gnu"
echo "   source ~/.cargo/env"
echo ""
echo "Note: rustup-init est un script shell (.sh), pas un fichier .exe"





