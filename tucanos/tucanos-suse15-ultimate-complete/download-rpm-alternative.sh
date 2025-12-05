#!/bin/bash
# Script ALTERNATIF pour télécharger les packages RPM
# Utilise plusieurs méthodes si zypper ne fonctionne pas

set -e

echo "==================================================================="
echo "  Téléchargement ALTERNATIF des packages RPM pour SUSE 15 SP4"
echo "==================================================================="
echo ""

# Détecter le système
if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "Système détecté: $PRETTY_NAME"
else
    echo "⚠ Impossible de détecter la distribution"
fi

echo ""

# Créer le répertoire
DEST_DIR="dependencies/system"
mkdir -p "$DEST_DIR"

echo "Choisissez la méthode de téléchargement:"
echo ""
echo "1) zypper download (nécessite SUSE avec zypper)"
echo "2) wget depuis les dépôts SUSE en ligne"
echo "3) Liste manuelle des URLs à télécharger"
echo "4) Installation minimale (packages essentiels seulement)"
echo ""
read -p "Votre choix (1-4): " choice

case $choice in
    1)
        echo ""
        echo "=== Méthode 1: zypper download ==="
        
        if ! command -v zypper &> /dev/null; then
            echo "❌ ERREUR: zypper non disponible"
            echo "Utilisez la méthode 2 ou 3"
            exit 1
        fi
        
        # Liste minimale de packages
        packages=(
            "gcc"
            "gcc-c++"
            "gcc7"
            "gcc7-c++"
            "make"
            "cmake"
            "pkg-config"
            "python3"
            "python3-devel"
            "python3-pip"
            "glibc-devel"
            "zlib-devel"
            "libopenssl-devel"
        )
        
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        for pkg in "${packages[@]}"; do
            echo "Téléchargement: $pkg"
            zypper download "$pkg" 2>/dev/null || echo "⚠ $pkg non trouvé"
        done
        
        # Copier les RPM
        find . -name "*.rpm" -exec cp {} "$DEST_DIR/" \;
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        ;;
        
    2)
        echo ""
        echo "=== Méthode 2: wget depuis dépôts SUSE ==="
        echo ""
        echo "⚠ Cette méthode nécessite de connaître les URLs exactes"
        echo ""
        
        # URLs de base pour SUSE 15 SP4
        BASE_URL="https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/"
        
        # Liste des packages avec versions approximatives
        declare -A packages=(
            ["gcc-7"]="gcc-7-*.x86_64.rpm"
            ["gcc7-c++"]="gcc7-c++-*.x86_64.rpm"
            ["make"]="make-*.x86_64.rpm"
            ["python3"]="python3-3*.x86_64.rpm"
        )
        
        echo "Téléchargement depuis OpenSUSE Leap 15.4..."
        echo "(Compatible avec SUSE 15 SP4)"
        echo ""
        
        cd "$DEST_DIR"
        
        # Exemple avec wget
        echo "Téléchargement de quelques packages essentiels..."
        
        # Cette partie nécessite les URLs exactes
        # L'utilisateur devra les compléter
        
        cat > "DOWNLOAD-URLS.txt" << 'EOF'
# URLs à télécharger manuellement
# Visitez: https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/

# Packages essentiels:
# - Cherchez "gcc-7" et téléchargez gcc-7-*.x86_64.rpm
# - Cherchez "gcc7-c++" et téléchargez gcc7-c++-*.x86_64.rpm
# - Cherchez "make" et téléchargez make-*.x86_64.rpm
# - Cherchez "python3" et téléchargez python3-3*.x86_64.rpm
# - Cherchez "python3-devel" et téléchargez python3-devel-*.x86_64.rpm
# - Cherchez "cmake" et téléchargez cmake-*.x86_64.rpm
# - Cherchez "pkg-config" et téléchargez pkg-config-*.x86_64.rpm

# Téléchargez chaque fichier et placez-le dans ce dossier
EOF
        
        echo "✓ Fichier DOWNLOAD-URLS.txt créé"
        echo ""
        echo "Consultez ce fichier pour les instructions"
        
        cd - > /dev/null
        ;;
        
    3)
        echo ""
        echo "=== Méthode 3: Liste d'URLs pour téléchargement manuel ==="
        
        cat > "$DEST_DIR/PACKAGES-TO-DOWNLOAD.txt" << 'EOF'
================================================================================
  PACKAGES RPM À TÉLÉCHARGER MANUELLEMENT POUR SUSE 15 SP4
================================================================================

SOURCE: https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/

Méthode:
1. Visitez l'URL ci-dessus dans votre navigateur
2. Utilisez Ctrl+F pour chercher chaque package
3. Téléchargez le fichier .rpm correspondant
4. Placez tous les .rpm dans dependencies/system/

================================================================================
  PACKAGES ESSENTIELS (OBLIGATOIRES)
================================================================================

[ ] gcc-7-*.x86_64.rpm
[ ] gcc7-c++-*.x86_64.rpm  
[ ] libstdc++6-devel-gcc7-*.x86_64.rpm
[ ] make-*.x86_64.rpm
[ ] pkg-config-*.x86_64.rpm
[ ] python3-3.*.x86_64.rpm
[ ] python3-devel-3.*.x86_64.rpm
[ ] python3-pip-*.noarch.rpm
[ ] glibc-devel-*.x86_64.rpm
[ ] linux-glibc-devel-*.noarch.rpm

================================================================================
  PACKAGES OPTIONNELS (RECOMMANDÉS)
================================================================================

[ ] cmake-*.x86_64.rpm
[ ] zlib-devel-*.x86_64.rpm
[ ] libopenssl-devel-*.x86_64.rpm
[ ] libbz2-devel-*.x86_64.rpm
[ ] git-core-*.x86_64.rpm
[ ] curl-*.x86_64.rpm
[ ] wget-*.x86_64.rpm

================================================================================
  POUR CHERCHER UN PACKAGE
================================================================================

Exemple pour gcc:
1. Ouvrez https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/
2. Appuyez sur Ctrl+F
3. Tapez "gcc-7"
4. Téléchargez "gcc-7-7.5.0+r278197-150000.4.27.1.x86_64.rpm" (ou version similaire)

================================================================================
  ALTERNATIVE: Utiliser le site packages.opensuse.org
================================================================================

1. Visitez: https://software.opensuse.org/package/gcc
2. Sélectionnez "openSUSE Leap 15.4"
3. Cliquez sur "Show experimental packages"
4. Téléchargez les .rpm

================================================================================
EOF
        
        echo "✓ Fichier créé: $DEST_DIR/PACKAGES-TO-DOWNLOAD.txt"
        echo ""
        echo "Consultez ce fichier pour la liste complète des packages"
        ;;
        
    4)
        echo ""
        echo "=== Méthode 4: Installation minimale ==="
        echo ""
        echo "Cette méthode suppose que certains packages sont déjà installés"
        echo "sur le système cible."
        echo ""
        
        cat > "$DEST_DIR/MINIMAL-INSTALL-NOTES.txt" << 'EOF'
INSTALLATION MINIMALE - SUSE 15 SP4
====================================

Si vous ne pouvez pas télécharger tous les packages RPM, vous pouvez:

1. Supposer que le système cible a déjà certains packages de base
2. Installer manuellement les packages manquants sur la machine cible
3. Utiliser uniquement Rust et Python depuis le package

PRÉREQUIS SUR LA MACHINE CIBLE:
---------------------------------

Packages système qui DOIVENT être déjà installés:
- gcc, gcc-c++ (compilateurs)
- make
- python3, python3-devel, python3-pip
- glibc-devel, libstdc++-devel
- zlib-devel, openssl-devel

Commande sur la machine cible (si elle a internet temporairement):
-------------------------------------------------------------------

sudo zypper install gcc gcc-c++ make python3 python3-devel python3-pip \
    glibc-devel libstdc++-devel zlib-devel libopenssl-devel pkg-config cmake

OU si la machine n'a jamais internet:
--------------------------------------

Demandez à l'administrateur système d'installer ces packages via
les DVD d'installation SUSE ou un dépôt local.

NOTRE PACKAGE FOURNIRA:
------------------------

✓ Rust complet (pas besoin de l'installer sur le système)
✓ Packages Python (maturin, numpy, etc.)
✓ Code source Tucanos
✓ Scripts de compilation

COMPILATION:
------------

Même sans tous les RPM, vous pouvez compiler si le système a les outils de base.
Le script install-complete-offline-improved.sh détectera ce qui manque.
EOF
        
        echo "✓ Fichier créé: $DEST_DIR/MINIMAL-INSTALL-NOTES.txt"
        echo ""
        echo "Cette approche suppose des packages pré-installés sur la cible"
        ;;
        
    *)
        echo "Choix invalide"
        exit 1
        ;;
esac

echo ""
echo "==================================================================="
echo "  Téléchargement terminé"
echo "==================================================================="

rpm_count=$(find "$DEST_DIR" -name "*.rpm" 2>/dev/null | wc -l)
echo ""
echo "Packages RPM actuellement dans $DEST_DIR: $rpm_count"
echo ""

if [ $rpm_count -eq 0 ]; then
    echo "⚠ Aucun package RPM téléchargé automatiquement"
    echo ""
    echo "Solutions:"
    echo "1. Consultez les fichiers créés dans $DEST_DIR/"
    echo "2. Téléchargez manuellement depuis https://download.opensuse.org"
    echo "3. Utilisez l'approche installation minimale"
fi

echo ""
echo "Pour nlopt, consultez: compile-nlopt-from-source.sh"






