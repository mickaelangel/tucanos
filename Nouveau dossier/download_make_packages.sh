#!/bin/bash
# Script pour télécharger les paquets make pour SUSE 15 SP4
# À exécuter sur un système connecté à internet

echo "=== Téléchargement des paquets make pour SUSE 15 SP4 ==="

# Créer les répertoires
mkdir -p suse-packages/RPMS
mkdir -p suse-packages/sources

# URLs des dépôts SUSE 15 SP4
BASE_URL="https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64"

# Liste des paquets make et dépendances
PACKAGES=(
    "make"
    "gcc"
    "gcc-c++"
    "glibc-devel"
    "libstdc++-devel"
    "binutils"
    "kernel-default-devel"
)

echo "Téléchargement des paquets make et dépendances..."

for package in "${PACKAGES[@]}"; do
    echo "Téléchargement de $package..."
    
    # Essayer de télécharger le paquet principal
    wget -q --show-progress "$BASE_URL/$package-*.rpm" -P suse-packages/RPMS/ 2>/dev/null || echo "  ⚠️  $package non trouvé"
    
    # Essayer de télécharger les dépendances
    wget -q --show-progress "$BASE_URL/$package-devel-*.rpm" -P suse-packages/RPMS/ 2>/dev/null || true
    wget -q --show-progress "$BASE_URL/lib$package-*.rpm" -P suse-packages/RPMS/ 2>/dev/null || true
done

# Télécharger les sources de make
echo "Téléchargement des sources de make..."
wget -q --show-progress "https://ftp.gnu.org/gnu/make/make-4.3.tar.gz" -P suse-packages/sources/ 2>/dev/null || echo "  ⚠️  Sources make-4.3 non trouvées"
wget -q --show-progress "https://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz" -P suse-packages/sources/ 2>/dev/null || echo "  ⚠️  Sources make-4.2.1 non trouvées"

echo "Téléchargement terminé !"
echo "Paquets téléchargés dans suse-packages/RPMS/"
echo "Sources téléchargées dans suse-packages/sources/"

# Créer un fichier de liste
ls -la suse-packages/RPMS/*.rpm > suse-packages/packages_list.txt 2>/dev/null || echo "Aucun paquet RPM trouvé"
ls -la suse-packages/sources/*.tar.gz > suse-packages/sources_list.txt 2>/dev/null || echo "Aucune source trouvée"

echo ""
echo "=== Instructions pour SUSE 15 SP4 (hors ligne) ==="
echo "1. Copiez le répertoire suse-packages/ sur votre serveur SUSE 15 SP4"
echo "2. Sur le serveur, exécutez:"
echo "   chmod +x install_make_suse15_offline.sh"
echo "   ./install_make_suse15_offline.sh"
echo ""
echo "Ou installation manuelle:"
echo "   sudo rpm -ivh suse-packages/RPMS/make-*.rpm"
echo "   sudo rpm -ivh suse-packages/RPMS/gcc-*.rpm"
echo "   sudo rpm -ivh suse-packages/RPMS/glibc-devel-*.rpm"

echo ""
echo "=== Vérification ==="
echo "Paquets RPM téléchargés:"
ls -la suse-packages/RPMS/*.rpm 2>/dev/null | wc -l | xargs echo "Nombre de paquets:"
echo ""
echo "Sources téléchargées:"
ls -la suse-packages/sources/*.tar.gz 2>/dev/null | wc -l | xargs echo "Nombre de sources:"






