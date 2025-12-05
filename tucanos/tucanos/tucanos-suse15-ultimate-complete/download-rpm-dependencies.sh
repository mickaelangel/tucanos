#!/bin/bash
# Script pour télécharger TOUS les packages RPM nécessaires pour SUSE 15 SP4
# À exécuter sur une machine SUSE 15 avec internet AVANT le transfert

set -e

echo "==================================================================="
echo "  Téléchargement des packages RPM pour installation hors ligne"
echo "  SUSE Linux Enterprise Server 15 SP4"
echo "==================================================================="
echo ""

# Vérifier qu'on est bien sur SUSE
if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "Système détecté: $PRETTY_NAME"
    if [[ "$ID" != "opensuse" && "$ID" != "sles" && "$ID" != "opensuse-leap" ]]; then
        echo "ATTENTION: Ce script est conçu pour SUSE Linux"
        echo "Vous êtes sur: $PRETTY_NAME"
        read -p "Continuer quand même? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo "ATTENTION: Impossible de détecter la distribution"
    read -p "Continuer quand même? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# Créer le répertoire de destination
DEST_DIR="dependencies/system"
mkdir -p "$DEST_DIR"

# Créer un répertoire temporaire pour les téléchargements
TEMP_DIR=$(mktemp -d)
echo "Répertoire temporaire: $TEMP_DIR"
echo ""

# Fonction pour télécharger un package et toutes ses dépendances
download_package() {
    local package=$1
    echo "----------------------------------------"
    echo "Téléchargement: $package"
    echo "----------------------------------------"
    
    # Utiliser zypper download avec résolution des dépendances
    cd "$TEMP_DIR"
    zypper --non-interactive download --dry-run "$package" 2>/dev/null || true
    zypper --non-interactive download "$package" || {
        echo "ATTENTION: Impossible de télécharger $package"
        return 1
    }
    
    echo "✓ $package téléchargé"
    echo ""
}

echo "=== PHASE 1: Compilateurs et outils de build ==="
echo ""

# Compilateurs C/C++
download_package "gcc"
download_package "gcc-c++"
download_package "gcc7"
download_package "gcc7-c++"

# Outils de build
download_package "make"
download_package "cmake"
download_package "automake"
download_package "autoconf"
download_package "libtool"
download_package "pkg-config"
download_package "m4"
download_package "patch"

echo ""
echo "=== PHASE 2: Bibliothèques de développement système ==="
echo ""

# Bibliothèques système essentielles
download_package "glibc-devel"
download_package "libstdc++6-devel-gcc7"
download_package "linux-glibc-devel"

# Bibliothèques courantes
download_package "zlib-devel"
download_package "bzip2"
download_package "libbz2-devel"
download_package "xz-devel"
download_package "libffi-devel"
download_package "libopenssl-devel"
download_package "openssl-devel"

echo ""
echo "=== PHASE 3: Python et dépendances ==="
echo ""

# Python 3.11 (ou version disponible)
download_package "python311"
download_package "python311-devel"
download_package "python311-pip"
download_package "python311-setuptools"
download_package "python311-wheel"

# Si python311 n'est pas disponible, essayer python3
download_package "python3" || true
download_package "python3-devel" || true
download_package "python3-pip" || true
download_package "python3-setuptools" || true
download_package "python3-wheel" || true
download_package "python3-numpy" || true
download_package "python3-numpy-devel" || true

echo ""
echo "=== PHASE 4: Bibliothèques mathématiques et scientifiques ==="
echo ""

# BLAS/LAPACK
download_package "libblas3"
download_package "liblapack3"
download_package "blas-devel"
download_package "lapack-devel"
download_package "openblas-devel" || true

# METIS (si disponible dans les dépôts)
download_package "metis" || echo "⚠ METIS non disponible dans les dépôts (sera compilé depuis les sources)"
download_package "metis-devel" || true
download_package "libmetis5" || true

# NLOPT
download_package "nlopt" || echo "⚠ NLOPT non disponible dans les dépôts (sera compilé depuis les sources)"
download_package "libnlopt0" || true
download_package "nlopt-devel" || true

# GMP (pour certaines dépendances)
download_package "gmp-devel" || true
download_package "mpfr-devel" || true

echo ""
echo "=== PHASE 5: Outils supplémentaires ==="
echo ""

# Git (utile pour le développement)
download_package "git" || true
download_package "git-core" || true

# Curl et wget
download_package "curl"
download_package "wget"
download_package "libcurl-devel"

# Utilitaires
download_package "tar"
download_package "gzip"
download_package "unzip"
download_package "which"
download_package "findutils"
download_package "binutils"

echo ""
echo "=== PHASE 6: Dépendances Rust optionnelles ==="
echo ""

# Bibliothèques qui peuvent être nécessaires pour certains crates Rust
download_package "libsqlite3-0" || true
download_package "sqlite3-devel" || true

echo ""
echo "=== Récupération des packages téléchargés ==="
echo ""

# Trouver tous les RPM téléchargés
find "$TEMP_DIR" -name "*.rpm" -type f | while read rpm_file; do
    rpm_name=$(basename "$rpm_file")
    
    # Vérifier si le fichier existe déjà
    if [ -f "$DEST_DIR/$rpm_name" ]; then
        echo "✓ Déjà présent: $rpm_name"
    else
        cp "$rpm_file" "$DEST_DIR/"
        echo "✓ Copié: $rpm_name"
    fi
done

# Compter les fichiers
rpm_count=$(find "$DEST_DIR" -name "*.rpm" | wc -l)
total_size=$(du -sh "$DEST_DIR" | cut -f1)

echo ""
echo "==================================================================="
echo "  Téléchargement terminé"
echo "==================================================================="
echo ""
echo "Packages RPM téléchargés: $rpm_count"
echo "Taille totale: $total_size"
echo "Emplacement: $DEST_DIR"
echo ""

# Créer un fichier de vérification
cat > "$DEST_DIR/PACKAGES-LIST.txt" << EOF
Liste des packages RPM téléchargés pour SUSE 15 SP4
Date: $(date)
Nombre de packages: $rpm_count
Taille totale: $total_size

Packages:
EOF

ls -lh "$DEST_DIR"/*.rpm >> "$DEST_DIR/PACKAGES-LIST.txt" 2>/dev/null || true

echo "Liste des packages sauvegardée dans: $DEST_DIR/PACKAGES-LIST.txt"
echo ""

# Nettoyer
rm -rf "$TEMP_DIR"
echo "Répertoire temporaire nettoyé"
echo ""

echo "=== Instructions suivantes ==="
echo ""
echo "1. Vérifiez le contenu de $DEST_DIR/"
echo "2. Téléchargez les dépendances Rust avec: ./download-rust-complete.sh"
echo "3. Transférez le package complet sur SUSE 15 SP4 hors ligne"
echo "4. Exécutez: ./install-complete-offline.sh"
echo ""
echo "✓ Prêt pour l'installation hors ligne !"

