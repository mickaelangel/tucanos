#!/bin/bash
# Script d'installation des dépendances manquantes pour Tucanos sur SUSE 15 SP4
# Ce script installe automatiquement toutes les dépendances manquantes

echo "=== Installation des dépendances manquantes pour Tucanos SUSE 15 SP4 ==="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [ "$status" = "WARNING" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    else
        echo -e "${RED}❌ $message${NC}"
    fi
}

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fonction pour installer les dépendances via zypper
install_via_zypper() {
    local packages=("$@")
    echo "Installation via zypper: ${packages[*]}"
    
    if command_exists zypper; then
        sudo zypper install -y "${packages[@]}"
        return $?
    else
        print_status "ERROR" "zypper non disponible"
        return 1
    fi
}

# Fonction pour installer depuis les paquets RPM locaux
install_from_rpm() {
    local package_name=$1
    local rpm_file=$2
    
    if [ -f "$rpm_file" ]; then
        echo "Installation depuis RPM: $rpm_file"
        sudo rpm -ivh "$rpm_file" --force --nodeps
        return $?
    else
        print_status "WARNING" "RPM non trouvé: $rpm_file"
        return 1
    fi
}

# Fonction pour compiler depuis les sources
compile_from_source() {
    local package_name=$1
    local source_file=$2
    local configure_args=$3
    
    if [ -f "$source_file" ]; then
        echo "Compilation depuis les sources: $package_name"
        
        # Extraire les sources
        tar xzf "$source_file"
        cd "${source_file%.tar.gz}"
        
        # Configuration
        if [ -f "configure" ]; then
            ./configure $configure_args
        elif [ -f "CMakeLists.txt" ]; then
            mkdir -p build && cd build
            cmake .. $configure_args
        fi
        
        # Compilation
        make -j$(nproc)
        
        # Installation
        sudo make install
        
        cd - > /dev/null
        return $?
    else
        print_status "WARNING" "Sources non trouvées: $source_file"
        return 1
    fi
}

echo ""
echo "🔍 Vérification des dépendances manquantes..."
echo "============================================="

# Liste des dépendances critiques
CRITICAL_DEPS=(
    "gcc:C Compiler:gcc"
    "g++:C++ Compiler:gcc-c++"
    "make:Build Tool:make"
    "cmake:Build System:cmake"
    "pkg-config:Package Config:pkg-config"
    "tar:Archive Tool:tar"
)

# Liste des dépendances optionnelles
OPTIONAL_DEPS=(
    "metis:Partitionnement:metis-devel"
    "nlopt:Optimisation:nlopt-devel"
    "python3:Python:python3"
    "pip3:Python Package Manager:python3-pip"
)

missing_critical=()
missing_optional=()

# Vérifier les dépendances critiques
for dep_info in "${CRITICAL_DEPS[@]}"; do
    IFS=':' read -r cmd description package <<< "$dep_info"
    if ! command_exists "$cmd"; then
        missing_critical+=("$package")
        print_status "ERROR" "$description ($cmd) manquant"
    else
        print_status "OK" "$description disponible"
    fi
done

# Vérifier les dépendances optionnelles
for dep_info in "${OPTIONAL_DEPS[@]}"; do
    IFS=':' read -r cmd description package <<< "$dep_info"
    if ! command_exists "$cmd"; then
        missing_optional+=("$package")
        print_status "WARNING" "$description ($cmd) manquant"
    else
        print_status "OK" "$description disponible"
    fi
done

echo ""
echo "🛠️  Installation des dépendances critiques..."
echo "============================================"

if [ ${#missing_critical[@]} -gt 0 ]; then
    echo "Dépendances critiques manquantes: ${missing_critical[*]}"
    
    # Essayer d'installer via zypper
    if command_exists zypper; then
        print_status "OK" "Installation via zypper..."
        if install_via_zypper "${missing_critical[@]}"; then
            print_status "OK" "Dépendances critiques installées via zypper"
        else
            print_status "WARNING" "Échec de l'installation via zypper"
        fi
    else
        print_status "WARNING" "zypper non disponible, tentative d'installation manuelle..."
        
        # Essayer d'installer depuis les RPM locaux
        for package in "${missing_critical[@]}"; do
            rpm_file=$(find . -name "*${package}*" -name "*.rpm" | head -n1)
            if [ -n "$rpm_file" ]; then
                install_from_rpm "$package" "$rpm_file"
            else
                print_status "WARNING" "RPM non trouvé pour $package"
            fi
        done
    fi
else
    print_status "OK" "Toutes les dépendances critiques sont présentes"
fi

echo ""
echo "🔧 Installation des dépendances optionnelles..."
echo "=============================================="

if [ ${#missing_optional[@]} -gt 0 ]; then
    echo "Dépendances optionnelles manquantes: ${missing_optional[*]}"
    
    # Essayer d'installer via zypper
    if command_exists zypper; then
        print_status "OK" "Installation des dépendances optionnelles via zypper..."
        if install_via_zypper "${missing_optional[@]}"; then
            print_status "OK" "Dépendances optionnelles installées via zypper"
        else
            print_status "WARNING" "Échec de l'installation des dépendances optionnelles via zypper"
        fi
    else
        print_status "WARNING" "zypper non disponible pour les dépendances optionnelles"
    fi
else
    print_status "OK" "Toutes les dépendances optionnelles sont présentes"
fi

echo ""
echo "🦀 Vérification et installation de Rust..."
echo "========================================="

if ! command_exists rustc; then
    print_status "WARNING" "Rust non installé, installation nécessaire..."
    
    # Vérifier si rustup-init existe
    if [ -f "rustup-init" ]; then
        print_status "OK" "rustup-init trouvé, installation de Rust..."
        chmod +x rustup-init
        ./rustup-init -y --default-toolchain stable-x86_64-unknown-linux-gnu
        source ~/.cargo/env
        
        if command_exists rustc; then
            print_status "OK" "Rust installé avec succès: $(rustc --version)"
        else
            print_status "ERROR" "Échec de l'installation de Rust"
        fi
    else
        print_status "ERROR" "rustup-init non trouvé, impossible d'installer Rust"
        echo "Veuillez télécharger rustup-init depuis https://rustup.rs/"
    fi
else
    print_status "OK" "Rust déjà installé: $(rustc --version)"
fi

echo ""
echo "📦 Installation des packages Python..."
echo "====================================="

# Vérifier Python
if ! command_exists python3; then
    print_status "WARNING" "Python3 non installé"
    if command_exists zypper; then
        install_via_zypper "python3" "python3-pip"
    fi
else
    print_status "OK" "Python3 disponible: $(python3 --version)"
fi

# Vérifier NumPy
if python3 -c "import numpy" 2>/dev/null; then
    print_status "OK" "NumPy disponible"
else
    print_status "WARNING" "NumPy non installé"
    if command_exists pip3; then
        echo "Installation de NumPy via pip3..."
        pip3 install numpy
    else
        print_status "WARNING" "pip3 non disponible pour installer NumPy"
    fi
fi

echo ""
echo "🔍 Vérification finale..."
echo "========================"

# Re-vérifier toutes les dépendances
all_ok=true

for dep_info in "${CRITICAL_DEPS[@]}"; do
    IFS=':' read -r cmd description package <<< "$dep_info"
    if ! command_exists "$cmd"; then
        print_status "ERROR" "$description ($cmd) toujours manquant"
        all_ok=false
    fi
done

if [ "$all_ok" = true ]; then
    print_status "OK" "Toutes les dépendances critiques sont maintenant disponibles"
    echo ""
    echo "🚀 Vous pouvez maintenant installer Tucanos:"
    echo "   cd tucanos"
    echo "   cargo build --workspace --release"
    echo ""
    echo "Ou utiliser le script d'installation:"
    echo "   ./install_tucanos_fixed.sh"
else
    print_status "ERROR" "Certaines dépendances critiques sont toujours manquantes"
    echo ""
    echo "Solutions alternatives:"
    echo "1. Installer manuellement les paquets manquants"
    echo "2. Utiliser les scripts d'installation spécifiques"
    echo "3. Compiler depuis les sources"
fi

echo ""
echo "=== Installation des dépendances terminée ==="






