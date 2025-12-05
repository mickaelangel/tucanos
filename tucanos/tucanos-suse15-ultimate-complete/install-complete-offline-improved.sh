#!/bin/bash
# Installation COMPLETE HORS LIGNE de Tucanos pour SUSE 15
# Version améliorée avec support complet des packages RPM et vendor

set -e

echo "==================================================================="
echo "  Installation COMPLETE HORS LIGNE de Tucanos sur SUSE 15"
echo "==================================================================="
echo "Ce script installe TOUT sans connexion internet"
echo ""

# Vérifier la distribution
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
echo "Distribution: $PRETTY_NAME"

if [[ "$ID" != "opensuse" && "$ID" != "sles" ]]; then
    echo "ATTENTION: Ce script est conçu pour SUSE Linux"
    echo "Distribution détectée: $PRETTY_NAME"
    read -p "Continuer quand même? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "==================================================================="
echo "  PHASE 1: Installation des dépendances système"
echo "==================================================================="
echo ""

# Vérifier si nous avons des packages RPM locaux
if [ -d "dependencies/system" ] && [ "$(ls -A dependencies/system/*.rpm 2>/dev/null)" ]; then
    rpm_count=$(ls dependencies/system/*.rpm | wc -l)
    echo "Packages RPM trouvés: $rpm_count"
    echo ""
    
    # Installer les packages RPM
    echo "Installation des packages système..."
    echo "(Ceci peut prendre quelques minutes et afficher des avertissements)"
    echo ""
    
    # Méthode 1: Essayer avec zypper (préféré pour résoudre les dépendances)
    if command -v zypper &> /dev/null; then
        echo "Installation avec zypper..."
        sudo zypper install -y --allow-unsigned-rpm dependencies/system/*.rpm 2>&1 | \
            grep -v "already installed" || true
    else
        # Méthode 2: rpm directement
        echo "Installation avec rpm..."
        sudo rpm -ivh --force dependencies/system/*.rpm 2>&1 | \
            grep -v "already installed" || true
    fi
    
    echo ""
    echo "✓ Installation des packages RPM terminée"
else
    echo "⚠ ATTENTION: Aucun package RPM trouvé dans dependencies/system/"
    echo ""
    echo "Vous devez installer manuellement:"
    echo "  sudo zypper install gcc gcc-c++ make cmake pkg-config"
    echo "  sudo zypper install python3 python3-devel python3-pip"
    echo "  sudo zypper install glibc-devel libstdc++-devel"
    echo "  sudo zypper install zlib-devel openssl-devel"
    echo ""
    read -p "Avez-vous installé ces packages? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "==================================================================="
echo "  PHASE 2: Vérification des outils de compilation"
echo "==================================================================="
echo ""

# Vérifier les outils essentiels
MISSING_TOOLS=0

check_tool() {
    local tool=$1
    local package=$2
    
    if command -v "$tool" &> /dev/null; then
        echo "✓ $tool trouvé: $(command -v $tool)"
    else
        echo "✗ $tool manquant (paquet: $package)"
        MISSING_TOOLS=1
    fi
}

check_tool gcc "gcc"
check_tool g++ "gcc-c++"
check_tool make "make"
check_tool pkg-config "pkg-config"
check_tool python3 "python3"
check_tool pip3 "python3-pip"

if [ $MISSING_TOOLS -eq 1 ]; then
    echo ""
    echo "ERREUR: Des outils essentiels sont manquants"
    echo "Installez-les avec zypper ou ajoutez les RPM dans dependencies/system/"
    exit 1
fi

echo ""
echo "✓ Tous les outils de compilation sont présents"

echo ""
echo "==================================================================="
echo "  PHASE 3: Installation de Rust"
echo "==================================================================="
echo ""

if ! command -v rustc &> /dev/null; then
    echo "Installation de Rust..."
    
    # Vérifier si nous avons rustup-init local
    if [ -f "dependencies/rust/rustup-init" ]; then
        echo "Installation depuis rustup-init local..."
        chmod +x dependencies/rust/rustup-init
        
        # Installer sans téléchargement si possible
        dependencies/rust/rustup-init -y --default-toolchain stable --profile minimal
        
        source ~/.cargo/env
        echo "✓ Rust installé: $(rustc --version)"
    else
        echo "ERREUR: rustup-init non trouvé dans dependencies/rust/"
        echo "Vous devez installer Rust manuellement ou ajouter rustup-init"
        exit 1
    fi
else
    echo "✓ Rust déjà installé: $(rustc --version)"
    source ~/.cargo/env 2>/dev/null || true
fi

echo ""
echo "==================================================================="
echo "  PHASE 4: Configuration Cargo avec vendor"
echo "==================================================================="
echo ""

# Activer le vendor si disponible
if [ -d "vendor" ] && [ "$(ls -A vendor)" ]; then
    echo "✓ Dossier vendor trouvé"
    
    # Utiliser la config vendor si elle existe
    if [ -f ".cargo/config.toml.vendor" ]; then
        echo "Configuration cargo pour utiliser le vendor..."
        cp .cargo/config.toml.vendor .cargo/config.toml
        echo "✓ Cargo configuré pour mode hors ligne (vendor)"
    else
        # Créer la config manuellement
        mkdir -p .cargo
        cat > .cargo/config.toml << 'EOF'
[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "vendor"

[env]
RUSTFLAGS = "-C target-cpu=native"
EOF
        echo "✓ Configuration cargo créée"
    fi
    
    OFFLINE_MODE="--offline"
    echo "✓ Mode hors ligne activé"
else
    echo "⚠ Vendor non trouvé - les crates seront téléchargées depuis internet"
    OFFLINE_MODE=""
    
    # Configuration cargo sans vendor
    mkdir -p .cargo
    cat > .cargo/config.toml << 'EOF'
[env]
RUSTFLAGS = "-C target-cpu=native"
EOF
fi

echo ""
echo "==================================================================="
echo "  PHASE 5: Installation des dépendances Python"
echo "==================================================================="
echo ""

# Installer les wheels Python locaux
if [ -d "dependencies/python/python" ] && [ "$(ls -A dependencies/python/python/*.whl 2>/dev/null)" ]; then
    echo "Installation des packages Python locaux..."
    
    # Installer chaque wheel individuellement
    for wheel in dependencies/python/python/*.whl; do
        wheel_name=$(basename "$wheel")
        echo "  - Installation de $wheel_name..."
        pip3 install --user --no-deps --no-index "$wheel" 2>/dev/null || \
            pip3 install --user --force-reinstall --no-deps "$wheel" || true
    done
    
    echo "✓ Packages Python installés"
else
    echo "⚠ Packages Python locaux non trouvés"
    echo "Installation via pip (nécessite internet)..."
    pip3 install --user setuptools wheel maturin numpy
fi

# Vérifier maturin
if command -v maturin &> /dev/null; then
    echo "✓ maturin disponible: $(maturin --version)"
else
    echo "⚠ maturin non trouvé dans PATH"
    echo "Ajout de ~/.local/bin au PATH..."
    export PATH="$HOME/.local/bin:$PATH"
    
    if command -v maturin &> /dev/null; then
        echo "✓ maturin trouvé: $(maturin --version)"
    else
        echo "ERREUR: maturin toujours non disponible"
        exit 1
    fi
fi

echo ""
echo "==================================================================="
echo "  PHASE 6: Vérification des bibliothèques optionnelles"
echo "==================================================================="
echo ""

# METIS
if pkg-config --exists metis 2>/dev/null; then
    echo "✓ METIS trouvé via pkg-config"
    USE_METIS=true
elif [ -f /usr/local/lib/libmetis.so ] || [ -f /usr/lib/libmetis.so ] || [ -f /usr/lib64/libmetis.so ]; then
    echo "✓ METIS trouvé dans le système"
    USE_METIS=true
else
    echo "⚠ METIS non trouvé"
    echo "  Source disponible: dependencies/sources/metis-master.tar.gz"
    echo "  Vous pouvez le compiler ou désactiver METIS"
    USE_METIS=false
fi

# NLOPT
if pkg-config --exists nlopt 2>/dev/null; then
    echo "✓ NLOPT trouvé via pkg-config"
    USE_NLOPT=true
elif [ -f /usr/local/lib/libnlopt.so ] || [ -f /usr/lib/libnlopt.so ] || [ -f /usr/lib64/libnlopt.so ]; then
    echo "✓ NLOPT trouvé dans le système"
    USE_NLOPT=true
else
    echo "⚠ NLOPT non trouvé"
    echo "  Source disponible: dependencies/sources/nlopt-2.7.1.tar.gz"
    echo "  Vous pouvez le compiler ou désactiver NLOPT"
    USE_NLOPT=false
fi

echo ""
echo "==================================================================="
echo "  PHASE 7: Compilation de Tucanos"
echo "==================================================================="
echo ""

# Définir les features
FEATURES=""
if [ "$USE_METIS" = true ]; then
    FEATURES="$FEATURES --features metis"
    echo "✓ Feature METIS activée"
fi
if [ "$USE_NLOPT" = true ]; then
    FEATURES="$FEATURES --features nlopt"
    echo "✓ Feature NLOPT activée"
fi

echo ""
echo "Compilation des bibliothèques Rust..."
echo "Mode: release"
echo "Features:$FEATURES"
echo "Offline: $OFFLINE_MODE"
echo ""

cargo build --workspace --release $FEATURES $OFFLINE_MODE

echo ""
echo "✓ Compilation Rust terminée"

echo ""
echo "==================================================================="
echo "  PHASE 8: Compilation FFI"
echo "==================================================================="
echo ""

cargo build --package tucanos-ffi --release $FEATURES $OFFLINE_MODE

# Créer le répertoire d'installation
mkdir -p "tucanos-install/lib"
mkdir -p "tucanos-install/include"

# Copier les fichiers FFI
if [ -f "target/release/libtucanos.so" ]; then
    cp "target/release/libtucanos.so" "tucanos-install/lib/"
    echo "✓ libtucanos.so copié"
fi

if [ -f "target/release/tucanos.h" ]; then
    cp "target/release/tucanos.h" "tucanos-install/include/"
    echo "✓ tucanos.h copié"
fi

echo ""
echo "==================================================================="
echo "  PHASE 9: Compilation des bindings Python"
echo "==================================================================="
echo ""

# Compiler pytmesh
echo "Compilation de pytmesh..."
cd pytmesh
maturin build --release $FEATURES $OFFLINE_MODE
cd ..
echo "✓ pytmesh compilé"

# Compiler pytucanos
echo "Compilation de pytucanos..."
cd pytucanos
maturin build --release $FEATURES $OFFLINE_MODE
cd ..
echo "✓ pytucanos compilé"

# Copier les wheels
mkdir -p "tucanos-install/python"
find pytmesh/target/wheels -name "*.whl" -exec cp {} "tucanos-install/python/" \; 2>/dev/null || true
find pytucanos/target/wheels -name "*.whl" -exec cp {} "tucanos-install/python/" \; 2>/dev/null || true

wheel_count=$(ls tucanos-install/python/*.whl 2>/dev/null | wc -l)
echo "✓ $wheel_count wheels Python créés"

echo ""
echo "==================================================================="
echo "  PHASE 10: Création des scripts d'installation"
echo "==================================================================="
echo ""

# Script d'installation système
cat > "tucanos-install/install-system.sh" << 'EOF'
#!/bin/bash
# Installation système de Tucanos

set -e

INSTALL_PREFIX="/usr/local"
LIB_DIR="$INSTALL_PREFIX/lib"
INCLUDE_DIR="$INSTALL_PREFIX/include"

echo "=== Installation système de Tucanos ==="

if [ "$EUID" -ne 0 ]; then
    echo "ERREUR: Ce script doit être exécuté en tant que root"
    echo "Utilisez: sudo ./install-system.sh"
    exit 1
fi

mkdir -p "$LIB_DIR"
mkdir -p "$INCLUDE_DIR"

if [ -f "lib/libtucanos.so" ]; then
    cp lib/*.so "$LIB_DIR/"
    echo "✓ Bibliothèques installées"
fi

if [ -f "include/tucanos.h" ]; then
    cp include/*.h "$INCLUDE_DIR/"
    echo "✓ En-têtes installés"
fi

ldconfig

echo ""
echo "=== Installation système terminée ==="
echo "Bibliothèques: $LIB_DIR"
echo "En-têtes: $INCLUDE_DIR"
EOF

# Script d'installation Python
cat > "tucanos-install/install-python.sh" << 'EOF'
#!/bin/bash
# Installation des bindings Python

set -e

echo "=== Installation des bindings Python ==="

if [ ! -d "python" ] || [ -z "$(ls python/*.whl 2>/dev/null)" ]; then
    echo "ERREUR: Aucun wheel Python trouvé"
    exit 1
fi

for wheel in python/*.whl; do
    echo "Installation de $(basename $wheel)..."
    pip3 install --user --force-reinstall "$wheel"
done

echo ""
echo "=== Installation Python terminée ==="
echo "Vous pouvez maintenant utiliser pytmesh et pytucanos"
EOF

# Script de test
cat > "tucanos-install/test-installation.sh" << 'EOF'
#!/bin/bash
# Test de l'installation

set -e

echo "=== Test de l'installation de Tucanos ==="

# Test Python
echo ""
echo "Test des bindings Python:"
python3 << 'PYTEST'
try:
    import pytmesh
    print("✓ pytmesh importé avec succès")
    print(f"  Version: {pytmesh.__version__ if hasattr(pytmesh, '__version__') else 'N/A'}")
except ImportError as e:
    print(f"✗ Erreur import pytmesh: {e}")

try:
    import pytucanos
    print("✓ pytucanos importé avec succès")
    print(f"  Version: {pytucanos.__version__ if hasattr(pytucanos, '__version__') else 'N/A'}")
except ImportError as e:
    print(f"✗ Erreur import pytucanos: {e}")
PYTEST

echo ""
echo "=== Test terminé ==="
EOF

chmod +x tucanos-install/*.sh

echo "✓ Scripts d'installation créés"

echo ""
echo "==================================================================="
echo "  COMPILATION TERMINÉE AVEC SUCCÈS!"
echo "==================================================================="
echo ""
echo "Package d'installation créé dans: tucanos-install/"
echo ""
echo "Pour installer:"
echo "  1. cd tucanos-install"
echo "  2. sudo ./install-system.sh    (bibliothèques système)"
echo "  3. ./install-python.sh         (bindings Python)"
echo "  4. ./test-installation.sh      (tester l'installation)"
echo ""
echo "✓ Installation hors ligne terminée!"
echo ""

