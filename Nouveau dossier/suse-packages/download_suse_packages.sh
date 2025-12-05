#!/bin/bash
# Script pour télécharger les paquets SUSE 15 nécessaires
# À exécuter sur un système connecté à internet

echo "=== Téléchargement des paquets SUSE 15 ==="

# Créer les répertoires
mkdir -p RPMS
mkdir -p repodata

# URLs des dépôts SUSE 15
BASE_URL="https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64"

# Liste des paquets nécessaires
PACKAGES=(
    "gcc"
    "gcc-c++"
    "make"
    "cmake"
    "tar"
    "pkg-config"
    "glibc-devel"
    "libstdc++-devel"
    "binutils"
    "kernel-default-devel"
    "libgcc_s1"
    "libstdc++6"
    "glibc"
    "libc6"
    "zlib-devel"
    "libffi-devel"
    "openssl-devel"
    "curl-devel"
    "expat-devel"
    "gettext-devel"
    "perl"
    "python3"
    "python3-devel"
    "python3-pip"
)

echo "Téléchargement des paquets..."

for package in "${PACKAGES[@]}"; do
    echo "Téléchargement de $package..."
    
    # Essayer de télécharger le paquet principal
    wget -q --show-progress "$BASE_URL/$package-*.rpm" -P RPMS/ 2>/dev/null || echo "  ⚠️  $package non trouvé"
    
    # Essayer de télécharger les dépendances
    wget -q --show-progress "$BASE_URL/$package-devel-*.rpm" -P RPMS/ 2>/dev/null || true
    wget -q --show-progress "$BASE_URL/lib$package-*.rpm" -P RPMS/ 2>/dev/null || true
done

echo "Téléchargement terminé !"
echo "Paquets téléchargés dans le répertoire RPMS/"

# Créer un fichier de liste
ls -la RPMS/*.rpm > packages_list.txt
echo "Liste des paquets créée: packages_list.txt"

echo ""
echo "=== Instructions pour SUSE 15 ==="
echo "1. Copiez le répertoire RPMS/ sur votre serveur SUSE 15"
echo "2. Installez les paquets avec:"
echo "   sudo zypper install RPMS/*.rpm"
echo "3. Ou créez un dépôt local:"
echo "   sudo zypper addrepo RPMS/ local-repo"
echo "   sudo zypper refresh"
echo "   sudo zypper install gcc gcc-c++ make cmake"


