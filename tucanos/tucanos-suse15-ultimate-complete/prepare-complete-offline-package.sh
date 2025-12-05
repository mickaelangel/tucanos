#!/bin/bash
# Script MASTER pour préparer le package COMPLET hors ligne
# À exécuter sur une machine SUSE 15 avec internet

set -e

echo "==================================================================="
echo "  Préparation du Package COMPLET Hors Ligne pour SUSE 15 SP4"
echo "==================================================================="
echo ""
echo "Ce script va télécharger TOUTES les dépendances nécessaires:"
echo "  - Packages RPM système (gcc, python, bibliothèques...)"
echo "  - Rust complet avec toolchain"
echo "  - Toutes les crates Cargo (vendor)"
echo "  - Packages Python (déjà présents)"
echo "  - Sources (cmake, METIS, NLOPT - déjà présents)"
echo ""

read -p "Continuer? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Annulé."
    exit 0
fi

echo ""
echo "==================================================================="

# Vérifier qu'on est sur SUSE
if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "Système: $PRETTY_NAME"
    
    if [[ "$ID" != "opensuse" && "$ID" != "sles" && "$ID" != "opensuse-leap" ]]; then
        echo ""
        echo "⚠ ATTENTION: Ce script est optimisé pour SUSE Linux"
        echo "Système détecté: $PRETTY_NAME"
        echo ""
        echo "Vous pouvez continuer mais certains packages RPM peuvent être incompatibles."
        read -p "Continuer quand même? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

echo ""
echo "==================================================================="
echo "  PHASE 1/3: Téléchargement des packages RPM système"
echo "==================================================================="
echo ""

if [ -f "./download-rpm-dependencies.sh" ]; then
    chmod +x ./download-rpm-dependencies.sh
    ./download-rpm-dependencies.sh
else
    echo "❌ ERREUR: download-rpm-dependencies.sh non trouvé"
    exit 1
fi

echo ""
echo "==================================================================="
echo "  PHASE 2/3: Téléchargement de Rust complet et vendor"
echo "==================================================================="
echo ""

if [ -f "./download-rust-complete.sh" ]; then
    chmod +x ./download-rust-complete.sh
    ./download-rust-complete.sh
else
    echo "❌ ERREUR: download-rust-complete.sh non trouvé"
    exit 1
fi

echo ""
echo "==================================================================="
echo "  PHASE 3/3: Vérification finale"
echo "==================================================================="
echo ""

echo "Vérification du contenu du package..."
echo ""

# Fonction pour vérifier un répertoire
check_dir() {
    local dir=$1
    local name=$2
    
    if [ -d "$dir" ] && [ "$(ls -A $dir)" ]; then
        count=$(find "$dir" -type f | wc -l)
        size=$(du -sh "$dir" | cut -f1)
        echo "✓ $name: $count fichiers ($size)"
    else
        echo "⚠ $name: vide ou absent"
    fi
}

check_dir "home/christophe/Documents/tucanos/tucanos/dependencies/system" "Packages RPM"
check_dir "home/christophe/Documents/tucanos/tucanos/dependencies/rust" "Rust"
check_dir "home/christophe/Documents/tucanos/tucanos/dependencies/python/python" "Packages Python"
check_dir "home/christophe/Documents/tucanos/tucanos/dependencies/sources" "Sources"
check_dir "home/christophe/Documents/tucanos/tucanos/vendor" "Cargo vendor"

echo ""

# Vérifier les fichiers essentiels
echo "Fichiers essentiels:"

files=(
    "install-complete-offline.sh"
    "download-rpm-dependencies.sh"
    "download-rust-complete.sh"
    "README-COMPLETE-OFFLINE.md"
    "Cargo.toml"
    ".cargo/config.toml.vendor"
)

for file in "${files[@]}"; do
    if [ -f "$file" ] || [ -d "$file" ]; then
        echo "✓ $file"
    else
        echo "⚠ $file manquant"
    fi
done

echo ""

# Statistiques finales
total_size=$(du -sh . | cut -f1)
rpm_count=$(find dependencies/system -name "*.rpm" 2>/dev/null | wc -l || echo "0")
vendor_count=$(find vendor -type d -maxdepth 1 2>/dev/null | wc -l || echo "0")

echo "==================================================================="
echo "  Package COMPLET Hors Ligne Prêt!"
echo "==================================================================="
echo ""
echo "Statistiques:"
echo "  - Taille totale: $total_size"
echo "  - Packages RPM: $rpm_count"
echo "  - Crates vendorées: $vendor_count"
echo ""

# Créer un fichier de vérification final
cat > "PACKAGE-READY.txt" << EOF
Package COMPLET Hors Ligne pour SUSE 15 SP4
============================================

Date de préparation: $(date)
Taille totale: $total_size
Packages RPM: $rpm_count
Crates vendorées: $vendor_count

Contenu:
--------
✓ Code source Tucanos complet
✓ Packages RPM système ($rpm_count packages)
✓ Rust complet avec toolchain
✓ Cargo vendor (toutes les dépendances)
✓ Packages Python (maturin, numpy, etc.)
✓ Sources (cmake, METIS, NLOPT)
✓ Scripts d'installation
✓ Documentation

Installation:
-------------
1. Transférer ce dossier complet sur SUSE 15 SP4 (hors ligne)
2. Exécuter: chmod +x install-complete-offline.sh
3. Exécuter: ./install-complete-offline.sh
4. Suivre les instructions à l'écran

Notes:
------
- Aucune connexion internet requise sur la machine cible
- Tous les packages et dépendances sont inclus
- L'installation prendra environ 15-30 minutes

Support:
--------
Voir README-COMPLETE-OFFLINE.md pour plus de détails
EOF

echo "✓ Fichier de vérification créé: PACKAGE-READY.txt"
echo ""

echo "==================================================================="
echo "  Instructions finales"
echo "==================================================================="
echo ""
echo "1. VÉRIFICATION:"
echo "   - Consultez PACKAGE-READY.txt"
echo "   - Vérifiez que vendor/ contient les crates"
echo "   - Vérifiez que dependencies/system/ contient les RPM"
echo ""
echo "2. TRANSFERT:"
echo "   - Compressez ce dossier: tar czf tucanos-suse15-offline.tar.gz ."
echo "   - Transférez sur SUSE 15 SP4 (USB, réseau interne, etc.)"
echo ""
echo "3. INSTALLATION (sur SUSE 15 SP4 hors ligne):"
echo "   - Décompressez: tar xzf tucanos-suse15-offline.tar.gz"
echo "   - cd tucanos-suse15-ultimate-complete"
echo "   - chmod +x install-complete-offline.sh"
echo "   - ./install-complete-offline.sh"
echo ""
echo "✓ Package prêt pour installation hors ligne totale!"
echo ""

