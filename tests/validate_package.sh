#!/bin/bash
# Script de validation du package Tucanos offline
# Vérifie que tous les composants nécessaires sont présents

set -e

echo "=========================================="
echo "  Validation du Package Tucanos Offline"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $description: $file (MANQUANT)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

function check_dir() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        local count=$(find "$dir" -type f | wc -l)
        echo -e "${GREEN}✓${NC} $description: $dir ($count fichiers)"
        return 0
    else
        echo -e "${RED}✗${NC} $description: $dir (MANQUANT)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

function check_optional_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description: $file"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $description: $file (optionnel, non présent)"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

echo "=== Vérification des Scripts ==="
check_file "install_tucanos_offline.sh" "Script d'installation principal"
check_file "install_tucanos_custom.sh" "Script d'installation personnalisée" || true

echo ""
echo "=== Vérification des Sources Tucanos ==="
check_dir "sources/tucanos-main" "Sources Tucanos"
check_file "sources/tucanos-main/Cargo.toml" "Configuration Cargo"

echo ""
echo "=== Vérification de Rust Offline ==="
if [ -d "rust-offline-package" ]; then
    check_file "rust-offline-package/rustc-1.89.0-x86_64-unknown-linux-gnu.tar.gz" "Rustc 1.89.0"
    check_file "rust-offline-package/cargo-1.89.0-x86_64-unknown-linux-gnu.tar.gz" "Cargo 1.89.0"
    check_file "rust-offline-package/rust-std-1.89.0-x86_64-unknown-linux-gnu.tar.gz" "Rust Std 1.89.0"
    check_file "rust-offline-package/install_rust_offline.sh" "Script installation Rust"
else
    echo -e "${YELLOW}⚠${NC} rust-offline-package/ (non présent - nécessaire pour offline)"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=== Vérification des Dépendances Vendorisées ==="
if [ -d "cargo-vendor" ]; then
    vendor_count=$(find cargo-vendor -name "*.crate" 2>/dev/null | wc -l)
    if [ $vendor_count -gt 0 ]; then
        echo -e "${GREEN}✓${NC} cargo-vendor: $vendor_count packages .crate"
    else
        echo -e "${RED}✗${NC} cargo-vendor vide ou incomplet"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠${NC} cargo-vendor/ (non présent - nécessaire pour offline)"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=== Vérification des Dépendances GitHub ==="
if [ -d "github-dependencies-offline" ]; then
    check_file "github-dependencies-offline/github-dependencies/coupe-20f0de6.zip" "Dépendance coupe"
    check_file "github-dependencies-offline/github-dependencies/metis-rs-d31aa3e.zip" "Dépendance metis-rs"
    check_file "github-dependencies-offline/github-dependencies/minimeshb-0.1.0.zip" "Dépendance minimeshb"
    check_file "github-dependencies-offline/install_github_dependencies.sh" "Script installation GitHub deps"
else
    echo -e "${YELLOW}⚠${NC} github-dependencies-offline/ (non présent)"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=== Vérification des Packages SUSE ==="
check_optional_file "suse-packages/sources/make-4.3.tar.gz" "Sources make 4.3"
check_optional_file "suse-packages/sources/gcc-7.5.0.tar.xz" "Sources GCC 7.5.0"

echo ""
echo "=== Vérification des Packages Optionnels ==="
check_optional_file "suse-packages-optional/sources/metis-5.2.1.tar.gz" "Sources METIS 5.2.1"
check_optional_file "suse-packages-optional/sources/nlopt-2.7.1.tar.gz" "Sources NLOPT 2.7.1"
check_optional_file "suse-packages-optional/install_metis.sh" "Script installation METIS"
check_optional_file "suse-packages-optional/install_nlopt.sh" "Script installation NLOPT"

echo ""
echo "=== Vérification de la Documentation ==="
check_file "README.md" "README principal" || check_file "LIRE_MOI_INSTALLATION.md" "Guide installation"
check_file "docs/LIRE_MOI_INSTALLATION.md" "Guide d'installation" || true
check_file "docs/INSTALLATION_DEPUIS_GIT.md" "Guide installation Git" || true

echo ""
echo "=========================================="
echo "  Résumé de la Validation"
echo "=========================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓✓✓ PACKAGE COMPLET ET VALIDE ✓✓✓${NC}"
    echo ""
    echo "Le package contient tous les composants nécessaires"
    echo "pour une installation 100% offline de Tucanos."
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ PACKAGE FONCTIONNEL AVEC AVERTISSEMENTS ⚠${NC}"
    echo ""
    echo "Erreurs : $ERRORS"
    echo "Avertissements : $WARNINGS"
    echo ""
    echo "Le package est fonctionnel mais certains composants optionnels manquent."
    echo "L'installation peut nécessiter une connexion internet."
    exit 0
else
    echo -e "${RED}✗✗✗ PACKAGE INCOMPLET ✗✗✗${NC}"
    echo ""
    echo "Erreurs : $ERRORS"
    echo "Avertissements : $WARNINGS"
    echo ""
    echo "Le package est incomplet. Certains composants critiques manquent."
    echo "Utilisez les scripts de création du package pour télécharger"
    echo "tous les composants nécessaires."
    exit 1
fi

