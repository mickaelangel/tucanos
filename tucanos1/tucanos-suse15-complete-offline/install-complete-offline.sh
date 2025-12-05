#!/bin/bash
# Installation COMPLÃˆTE HORS LIGNE de Tucanos pour SUSE 15
# Inclut TOUTES les dÃ©pendances - AUCUNE connexion internet requise

set -e

echo "=== Installation COMPLÃˆTE HORS LIGNE de Tucanos sur SUSE 15 ==="
echo "Ce script installe TOUT sans connexion internet"
echo ""

# VÃ©rifier la distribution
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvÃ©"
    exit 1
fi

source /etc/os-release
echo "Distribution: $PRETTY_NAME"

if [[ "$ID" != "opensuse" && "$ID" != "sles" ]]; then
    echo "ATTENTION: Ce script est conÃ§u pour SUSE Linux"
    echo "Distribution dÃ©tectÃ©e: $PRETTY_NAME"
    read -p "Continuer quand mÃªme? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# Installation des dÃ©pendances systÃ¨me depuis les packages locaux
echo "=== Installation des dÃ©pendances systÃ¨me ==="

# VÃ©rifier si nous avons des packages RPM locaux
if [ -d "dependencies/system" ] && [ "" ]; then
    echo "Installation depuis les packages RPM locaux..."
    sudo rpm -ivh dependencies/system/*.rpm || true
else
    echo "ATTENTION: Aucun package RPM local trouvÃ©"
    echo "Les dÃ©pendances systÃ¨me doivent Ãªtre installÃ©es manuellement:"
    echo "  sudo zypper install gcc gcc-c++ make pkg-config"
    echo "  sudo zypper install python3 python3-devel python3-pip"
    echo "  sudo zypper install nlopt-devel"
    echo ""
    read -p "Continuer quand mÃªme? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# VÃ©rifier les outils de compilation
echo "VÃ©rification des outils de compilation..."

if ! command -v gcc &> /dev/null; then
    echo "ERREUR: gcc non trouvÃ©"
    echo "Installez avec: sudo zypper install gcc gcc-c++"
    exit 1
fi

if ! command -v make &> /dev/null; then
    echo "ERREUR: make non trouvÃ©"
    echo "Installez avec: sudo zypper install make"
    exit 1
fi

if ! command -v pkg-config &> /dev/null; then
    echo "ERREUR: pkg-config non trouvÃ©"
    echo "Installez avec: sudo zypper install pkg-config"
    exit 1
fi

echo "âœ“ Outils de compilation OK"

# VÃ©rifier Python
echo "VÃ©rification de Python..."

if ! command -v python3 &> /dev/null; then
    echo "ERREUR: python3 non trouvÃ©"
    echo "Installez avec: sudo zypper install python3 python3-devel"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo "ERREUR: pip3 non trouvÃ©"
    echo "Installez avec: sudo zypper install python3-pip"
    exit 1
fi

echo "âœ“ Python OK"

# Installation de Rust
echo ""
echo "=== Installation de Rust ==="

if ! command -v rustc &> /dev/null; then
    echo "Installation de Rust..."
    
    # VÃ©rifier si nous avons une installation locale de Rust
    if [ -f "dependencies/rust/rustup-init" ]; then
        echo "Installation depuis le package Rust local..."
        chmod +x dependencies/rust/rustup-init
        ./dependencies/rust/rustup-init -y
    else
        echo "ATTENTION: Aucun package Rust local trouvÃ©"
        echo "Rust doit Ãªtre installÃ© manuellement:"
        echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
        echo ""
        read -p "Continuer quand mÃªme? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    source ~/.cargo/env
else
    echo "Rust dÃ©jÃ  installÃ©: $(rustc --version)"
fi

# Installation de maturin
echo ""
echo "=== Installation de maturin ==="

if ! command -v maturin &> /dev/null; then
    echo "Installation de maturin..."
    
    # VÃ©rifier si nous avons des wheels Python locaux
    if [ -d "dependencies/python" ] && [ "" ]; then
        echo "Installation depuis les packages Python locaux..."
        pip3 install --user dependencies/python/*.whl
    else
        echo "Installation de maturin via pip..."
        pip3 install --user maturin
    fi
else
    echo "maturin dÃ©jÃ  installÃ©: $(maturin --version)"
fi

# VÃ©rifier les dÃ©pendances optionnelles
echo ""
echo "=== VÃ©rification des dÃ©pendances optionnelles ==="

# METIS
if pkg-config --exists metis 2>/dev/null; then
    echo "âœ“ METIS trouvÃ© via pkg-config"
elif [ -f /usr/local/lib/libmetis.so ] || [ -f /usr/lib/libmetis.so ]; then
    echo "âœ“ METIS trouvÃ© dans le systÃ¨me"
else
    echo "âš  METIS non trouvÃ© (optionnel)"
    if [ "true" = true ]; then
        echo "ATTENTION: METIS est requis pour cette compilation"
        echo "Installez METIS manuellement depuis: https://github.com/KarypisLab/METIS"
        exit 1
    fi
fi

# NLOPT
if pkg-config --exists nlopt 2>/dev/null; then
    echo "âœ“ NLOPT trouvÃ© via pkg-config"
elif [ -f /usr/local/lib/libnlopt.so ] || [ -f /usr/lib/libnlopt.so ]; then
    echo "âœ“ NLOPT trouvÃ© dans le systÃ¨me"
else
    echo "âš  NLOPT non trouvÃ© (optionnel)"
    if [ "true" = true ]; then
        echo "ATTENTION: NLOPT est requis pour cette compilation"
        echo "Installez NLOPT avec: sudo zypper install nlopt-devel"
        exit 1
    fi
fi

echo ""
echo "=== PrÃ©requis OK ==="
echo ""

# Configuration Rust
echo "=== Configuration Rust ==="

mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[env]
# Configuration pour SUSE 15
RUSTFLAGS = "-C target-cpu=native"
EOF

# Ajouter METIS si demandÃ©
if [ "true" = true ]; then
    echo "METISDIR="/usr/local"" >> .cargo/config.toml
fi

echo "Configuration Rust OK"
echo ""

# Compilation
echo "=== Compilation de Tucanos ==="

# DÃ©finir les features
FEATURES=""
if [ "true" = true ]; then
    FEATURES="$FEATURES --features metis"
fi
if [ "true" = true ]; then
    FEATURES="$FEATURES --features nlopt"
fi

# Mode de compilation
BUILD_MODE="--release"
if [ "false" = true ]; then
    BUILD_MODE=""
fi

echo "Compilation des bibliothÃ¨ques Rust..."
echo "Features: $FEATURES"
echo "Mode: $BUILD_MODE"

cargo build --workspace $BUILD_MODE $FEATURES

echo "Compilation Rust OK"
echo ""

# Compilation FFI
echo "=== Compilation FFI ==="
cargo build --package tucanos-ffi $BUILD_MODE $FEATURES

# CrÃ©er le rÃ©pertoire d'installation
mkdir -p "tucanos-install/lib"
mkdir -p "tucanos-install/include"

# Copier les fichiers FFI
cp "target/release/libtucanos.so" "tucanos-install/lib/"
cp "target/release/tucanos.h" "tucanos-install/include/"

echo "FFI compilÃ© et installÃ©"
echo ""

# Compilation Python
echo "=== Compilation Python bindings ==="

# Compiler pytmesh
echo "Compilation de pytmesh..."
cd pytmesh
maturin build --release $FEATURES
cd ..

# Compiler pytucanos
echo "Compilation de pytucanos..."
cd pytucanos
maturin build --release $FEATURES
cd ..

# Copier les wheels
mkdir -p "tucanos-install/python"
cp pytmesh/target/wheels/*.whl "tucanos-install/python/"
cp pytucanos/target/wheels/*.whl "tucanos-install/python/"

echo "Python bindings compilÃ©s"
echo ""

# CrÃ©er les scripts d'installation
echo "=== CrÃ©ation des scripts d'installation ==="

# Script d'installation systÃ¨me
cat > "tucanos-install/install-system.sh" << 'EOF'
#!/bin/bash
# Installation systÃ¨me de Tucanos

set -e

INSTALL_PREFIX="/usr/local"
LIB_DIR="$INSTALL_PREFIX/lib"
INCLUDE_DIR="$INSTALL_PREFIX/include"

echo "=== Installation systÃ¨me de Tucanos ==="

# VÃ©rifier les permissions
if [ "$EUID" -ne 0 ]; then
    echo "ERREUR: Ce script doit Ãªtre exÃ©cutÃ© en tant que root"
    echo "Utilisez: sudo ./install-system.sh"
    exit 1
fi

# CrÃ©er les rÃ©pertoires
mkdir -p "$LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# Installer les bibliothÃ¨ques
echo "Installation des bibliothÃ¨ques..."
cp lib/*.so "$LIB_DIR/"

# Installer les en-tÃªtes
echo "Installation des en-tÃªtes..."
cp include/*.h "$INCLUDE_DIR/"

# Mettre Ã  jour ldconfig
echo "Mise Ã  jour du cache des bibliothÃ¨ques..."
ldconfig

echo ""
echo "=== Installation systÃ¨me terminÃ©e ==="
echo "Les bibliothÃ¨ques sont installÃ©es dans $LIB_DIR"
echo "Les en-tÃªtes sont installÃ©s dans $INCLUDE_DIR"
EOF

# Script d'installation Python
cat > "tucanos-install/install-python.sh" << 'EOF'
#!/bin/bash
# Installation des bindings Python

set -e

echo "=== Installation des bindings Python ==="

# Installer les wheels
echo "Installation des packages Python..."
pip3 install --user python/*.whl

echo ""
echo "=== Installation Python terminÃ©e ==="
echo "Vous pouvez maintenant importer pytmesh et pytucanos"
EOF

# Script de test
cat > "tucanos-install/test-installation.sh" << 'EOF'
#!/bin/bash
# Test de l'installation de Tucanos

set -e

echo "=== Test de l'installation de Tucanos ==="

# Test FFI
echo "Test des bibliothÃ¨ques FFI..."
if [ -f "lib/libtucanos.so" ]; then
    echo "âœ“ BibliothÃ¨que FFI trouvÃ©e"
    ldd lib/libtucanos.so | head -5
else
    echo "âœ— BibliothÃ¨que FFI non trouvÃ©e"
fi

# Test Python
echo "Test des bindings Python..."
if command -v python3 &> /dev/null; then
    python3 -c "
try:
    import pytmesh
    print('âœ“ pytmesh importÃ© avec succÃ¨s')
except ImportError as e:
    print(f'âœ— Erreur import pytmesh: {e}')

try:
    import pytucanos
    print('âœ“ pytucanos importÃ© avec succÃ¨s')
except ImportError as e:
    print(f'âœ— Erreur import pytucanos: {e}')
"
else
    echo "âœ— Python3 non disponible"
fi

echo "Test terminÃ©"
EOF

# Rendre les scripts exÃ©cutables
chmod +x "tucanos-install"/*.sh

echo "=== Compilation terminÃ©e ==="
echo "Package d'installation crÃ©Ã© dans: tucanos-install"
echo ""
echo "Pour installer:"
echo "1. cd tucanos-install"
echo "2. sudo ./install-system.sh"
echo "3. ./install-python.sh"
echo "4. ./test-installation.sh"
