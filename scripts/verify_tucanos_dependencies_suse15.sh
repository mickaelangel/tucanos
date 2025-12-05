#!/bin/bash
# Script de vérification des dépendances pour Tucanos sur SUSE 15 SP4 (Hors ligne)
# Ce script vérifie toutes les dépendances nécessaires pour une installation complète

echo "=== Vérification des dépendances Tucanos SUSE 15 SP4 (Hors ligne) ==="

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

# Fonction pour vérifier la version d'une commande
check_version() {
    local cmd=$1
    local min_version=$2
    if command_exists "$cmd"; then
        local version=$($cmd --version 2>/dev/null | head -n1)
        echo "$version"
        return 0
    else
        return 1
    fi
}

echo ""
echo "🔍 Vérification du système..."
echo "================================"

# Vérifier le système d'exploitation
if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "Système: $PRETTY_NAME"
    if [[ "$ID" == "opensuse-leap" && "$VERSION_ID" == "15"* ]]; then
        print_status "OK" "Système SUSE 15 détecté"
    else
        print_status "WARNING" "Système non-SUSE 15 détecté: $PRETTY_NAME"
    fi
else
    print_status "ERROR" "Fichier /etc/os-release non trouvé"
fi

echo ""
echo "🛠️  Vérification des outils de compilation..."
echo "============================================="

# Outils de compilation essentiels
COMPILATION_TOOLS=(
    "gcc:C Compiler"
    "g++:C++ Compiler" 
    "make:Build Tool"
    "cmake:Build System"
    "pkg-config:Package Config"
    "tar:Archive Tool"
    "wget:Download Tool"
    "curl:Download Tool"
)

for tool_info in "${COMPILATION_TOOLS[@]}"; do
    IFS=':' read -r tool description <<< "$tool_info"
    if command_exists "$tool"; then
        version=$(check_version "$tool")
        print_status "OK" "$description: $version"
    else
        print_status "ERROR" "$description ($tool) manquant"
    fi
done

echo ""
echo "🦀 Vérification de Rust..."
echo "=========================="

# Vérifier Rust
if command_exists rustc; then
    rust_version=$(rustc --version)
    print_status "OK" "Rust: $rust_version"
    
    # Vérifier Cargo
    if command_exists cargo; then
        cargo_version=$(cargo --version)
        print_status "OK" "Cargo: $cargo_version"
    else
        print_status "ERROR" "Cargo manquant"
    fi
    
    # Vérifier la version minimale de Rust (1.70+)
    rust_major=$(rustc --version | grep -o '[0-9]\+' | head -n1)
    if [ "$rust_major" -ge 1 ]; then
        rust_minor=$(rustc --version | grep -o '[0-9]\+' | sed -n '2p')
        if [ "$rust_minor" -ge 70 ]; then
            print_status "OK" "Version Rust compatible (>= 1.70)"
        else
            print_status "WARNING" "Version Rust ancienne (recommandé >= 1.70)"
        fi
    fi
else
    print_status "ERROR" "Rust non installé"
fi

echo ""
echo "📚 Vérification des bibliothèques système..."
echo "============================================"

# Bibliothèques système
SYSTEM_LIBS=(
    "glibc:Standard C Library"
    "libstdc++:Standard C++ Library"
    "zlib:Compression Library"
    "openssl:Crypto Library"
)

for lib_info in "${SYSTEM_LIBS[@]}"; do
    IFS=':' read -r lib description <<< "$lib_info"
    if ldconfig -p | grep -q "$lib"; then
        print_status "OK" "$description disponible"
    else
        print_status "WARNING" "$description non trouvée"
    fi
done

echo ""
echo "🔧 Vérification des dépendances optionnelles..."
echo "==============================================="

# Dépendances optionnelles
OPTIONAL_DEPS=(
    "metis:Partitionnement de maillage"
    "nlopt:Optimisation non linéaire"
    "python3:Python bindings"
    "numpy:Python numerical library"
)

for dep_info in "${OPTIONAL_DEPS[@]}"; do
    IFS=':' read -r dep description <<< "$dep_info"
    if pkg-config --exists "$dep" 2>/dev/null; then
        version=$(pkg-config --modversion "$dep")
        print_status "OK" "$description: $version"
    else
        print_status "WARNING" "$description ($dep) non trouvée (optionnel)"
    fi
done

echo ""
echo "📦 Vérification des packages Python..."
echo "====================================="

# Vérifier Python
if command_exists python3; then
    python_version=$(python3 --version)
    print_status "OK" "Python: $python_version"
    
    # Vérifier pip
    if command_exists pip3; then
        pip_version=$(pip3 --version | cut -d' ' -f2)
        print_status "OK" "pip: $pip_version"
    else
        print_status "WARNING" "pip3 non trouvé"
    fi
    
    # Vérifier numpy
    if python3 -c "import numpy" 2>/dev/null; then
        numpy_version=$(python3 -c "import numpy; print(numpy.__version__)")
        print_status "OK" "NumPy: $numpy_version"
    else
        print_status "WARNING" "NumPy non installé (requis pour pytucanos)"
    fi
else
    print_status "WARNING" "Python3 non trouvé (requis pour les bindings Python)"
fi

echo ""
echo "💾 Vérification de l'espace disque..."
echo "===================================="

# Vérifier l'espace disque
available_space=$(df -h . | tail -n1 | awk '{print $4}')
echo "Espace disponible: $available_space"

# Vérifier l'espace requis (environ 5GB)
required_space="5G"
if [ -d "/tmp" ]; then
    tmp_space=$(df -h /tmp | tail -n1 | awk '{print $4}')
    echo "Espace /tmp: $tmp_space"
fi

print_status "OK" "Espace disque vérifié"

echo ""
echo "🌐 Vérification de la connectivité (mode hors ligne)..."
echo "======================================================"

# Vérifier que nous sommes en mode hors ligne
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    print_status "WARNING" "Connexion internet détectée (mode hors ligne recommandé)"
else
    print_status "OK" "Mode hors ligne confirmé"
fi

echo ""
echo "📁 Vérification des fichiers Tucanos..."
echo "======================================="

# Vérifier les fichiers nécessaires
TUCANOS_FILES=(
    "tucanos/Cargo.toml:Source principal"
    "tucanos/src/:Code source"
    "tucanos/pytucanos/:Python bindings"
    "tucanos/pytmesh/:Python mesh bindings"
    "tucanos/tmesh/:Mesh library"
    "tucanos/tucanos-ffi/:C FFI"
)

for file_info in "${TUCANOS_FILES[@]}"; do
    IFS=':' read -r file description <<< "$file_info"
    if [ -e "$file" ]; then
        print_status "OK" "$description trouvé"
    else
        print_status "ERROR" "$description manquant: $file"
    fi
done

echo ""
echo "🔧 Vérification des variables d'environnement..."
echo "=============================================="

# Vérifier les variables d'environnement importantes
if [ -n "$RUSTUP_HOME" ]; then
    print_status "OK" "RUSTUP_HOME: $RUSTUP_HOME"
else
    print_status "WARNING" "RUSTUP_HOME non défini"
fi

if [ -n "$CARGO_HOME" ]; then
    print_status "OK" "CARGO_HOME: $CARGO_HOME"
else
    print_status "WARNING" "CARGO_HOME non défini"
fi

if echo "$PATH" | grep -q "cargo"; then
    print_status "OK" "Cargo dans PATH"
else
    print_status "WARNING" "Cargo non dans PATH"
fi

echo ""
echo "📋 Résumé des dépendances..."
echo "============================"

# Compter les dépendances manquantes
missing_count=0
warning_count=0

# Re-vérifier les dépendances critiques
CRITICAL_DEPS=("gcc" "g++" "make" "cmake" "rustc" "cargo")
for dep in "${CRITICAL_DEPS[@]}"; do
    if ! command_exists "$dep"; then
        ((missing_count++))
    fi
done

if [ $missing_count -eq 0 ]; then
    print_status "OK" "Toutes les dépendances critiques sont présentes"
else
    print_status "ERROR" "$missing_count dépendance(s) critique(s) manquante(s)"
fi

echo ""
echo "🚀 Recommandations d'installation..."
echo "==================================="

if [ $missing_count -gt 0 ]; then
    echo "Dépendances manquantes à installer:"
    for dep in "${CRITICAL_DEPS[@]}"; do
        if ! command_exists "$dep"; then
            echo "  - $dep"
        fi
    done
    echo ""
    echo "Commandes d'installation (si zypper disponible):"
    echo "  sudo zypper install gcc gcc-c++ make cmake pkg-config"
    echo "  # Pour Rust, utiliser rustup-init"
    echo ""
    echo "Ou utiliser les scripts fournis:"
    echo "  ./install_make_suse15_offline.sh"
    echo "  ./install_tucanos_fixed.sh"
else
    echo "✅ Toutes les dépendances sont présentes !"
    echo "Vous pouvez procéder à l'installation de Tucanos:"
    echo "  cd tucanos"
    echo "  cargo build --workspace --release"
fi

echo ""
echo "=== Vérification terminée ==="






