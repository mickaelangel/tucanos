#!/bin/bash

################################################################################
# Script d'Installation Hors Ligne - Tucanos pour SUSE 15 SP4
# Version: 2.0
# Date: 2025-10-09
################################################################################

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Fonction pour vérifier une commande
check_command() {
    if command -v "$1" &> /dev/null; then
        log_success "$1 est disponible"
        return 0
    else
        log_warning "$1 n'est pas disponible"
        return 1
    fi
}

################################################################################
# ÉTAPE 0: Vérifications préliminaires
################################################################################

log_info "======================================================================"
log_info "Installation Hors Ligne de Tucanos pour SUSE 15 SP4"
log_info "======================================================================"
echo ""

# Vérifier qu'on est dans le bon dossier
if [ ! -f "Cargo.toml" ] || [ ! -d "dependencies" ]; then
    log_error "Ce script doit être exécuté depuis le dossier tucanos-suse15-ultimate-complete"
    exit 1
fi

log_success "Dossier d'installation vérifié"
INSTALL_DIR=$(pwd)
BUILD_DIR="$INSTALL_DIR/build-temp"
FINAL_DIR="$INSTALL_DIR/tucanos-install"

log_info "Dossier d'installation: $INSTALL_DIR"
log_info "Dossier de build: $BUILD_DIR"
log_info "Dossier final: $FINAL_DIR"
echo ""

################################################################################
# ÉTAPE 1: Installation des packages RPM système
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 1: Installation des packages RPM système"
log_info "======================================================================"
echo ""

if [ -d "dependencies/system" ] && [ "$(ls -A dependencies/system/*.rpm 2>/dev/null)" ]; then
    log_info "Installation des RPM depuis dependencies/system/..."
    sudo rpm -Uvh --force --nodeps dependencies/system/*.rpm 2>&1 | grep -v "already installed" || true
    log_success "RPM de dependencies/system/ installés"
fi

if [ -d "dependencies/repo-sle-update" ]; then
    log_info "Installation des RPM depuis dependencies/repo-sle-update/..."
    find dependencies/repo-sle-update -name "*.rpm" -exec sudo rpm -Uvh --force --nodeps {} \; 2>&1 | grep -v "already installed" || true
    log_success "RPM de repo-sle-update/ installés"
fi

echo ""
log_success "Packages RPM installés"
echo ""

################################################################################
# ÉTAPE 2: Installation de Rust
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 2: Installation de Rust (hors ligne)"
log_info "======================================================================"
echo ""

export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"

if [ -f "$HOME/.cargo/bin/rustc" ]; then
    log_info "Rust est déjà installé: $(rustc --version 2>/dev/null || echo 'version inconnue')"
else
    log_info "Installation de Rust depuis les archives..."
    
    if [ -f "dependencies/rust/install_rust_offline.sh" ]; then
        log_info "Utilisation du script install_rust_offline.sh"
        cd dependencies/rust
        bash install_rust_offline.sh
        cd "$INSTALL_DIR"
    else
        # Installation manuelle
        log_info "Installation manuelle de Rust..."
        
        RUST_DIR="$BUILD_DIR/rust-install"
        mkdir -p "$RUST_DIR"
        
        # Extraire les archives Rust
        for tarball in dependencies/rust/*.tar.gz; do
            if [ -f "$tarball" ]; then
                log_info "Extraction de $(basename $tarball)..."
                tar xzf "$tarball" -C "$RUST_DIR"
            fi
        done
        
        # Installer les composants
        for component_dir in "$RUST_DIR"/*/; do
            if [ -f "$component_dir/install.sh" ]; then
                log_info "Installation de $(basename $component_dir)..."
                cd "$component_dir"
                ./install.sh --prefix="$HOME/.cargo" --disable-ldconfig
                cd "$INSTALL_DIR"
            fi
        done
    fi
fi

# Configurer l'environnement
export PATH="$HOME/.cargo/bin:$PATH"
source "$HOME/.cargo/env" 2>/dev/null || true

# Vérifier l'installation
if check_command rustc && check_command cargo; then
    log_success "Rust installé: $(rustc --version)"
    log_success "Cargo installé: $(cargo --version)"
else
    log_error "Erreur lors de l'installation de Rust"
    exit 1
fi

echo ""

################################################################################
# ÉTAPE 3: Configuration de Cargo pour mode offline
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 3: Configuration de Cargo (mode offline)"
log_info "======================================================================"
echo ""

mkdir -p .cargo

# Créer un registre local pour les crates
if [ -d "dependencies/rust/cargo-dependencies" ]; then
    log_info "Configuration du registre local de crates..."
    
    CARGO_REGISTRY="$HOME/.cargo/registry"
    mkdir -p "$CARGO_REGISTRY/cache/github.com-1ecc6299db9ec823"
    
    # Copier les fichiers .crate
    log_info "Copie des fichiers .crate dans le registre local..."
    cp -v dependencies/rust/cargo-dependencies/*.crate "$CARGO_REGISTRY/cache/github.com-1ecc6299db9ec823/" || true
    
    log_success "Fichiers .crate copiés dans le registre cargo"
fi

# Configuration cargo pour mode offline
cat > .cargo/config.toml << 'EOF'
[build]
jobs = 4

[net]
offline = true

[term]
verbose = false
EOF

log_success "Configuration cargo créée (mode offline)"
echo ""

################################################################################
# ÉTAPE 4: Installation des packages Python
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 4: Installation des packages Python"
log_info "======================================================================"
echo ""

if ! check_command python3; then
    log_error "Python3 n'est pas installé"
    exit 1
fi

log_info "Version Python: $(python3 --version)"

# Installer les wheels Python
if [ -d "dependencies/python/python" ]; then
    log_info "Installation des packages Python depuis les wheels..."
    
    for wheel in dependencies/python/python/*.whl; do
        if [ -f "$wheel" ]; then
            log_info "Installation de $(basename $wheel)..."
            pip3 install --user --no-index --no-deps "$wheel" || \
            pip3 install --user --force-reinstall --no-index --no-deps "$wheel"
        fi
    done
    
    log_success "Packages Python installés"
else
    log_warning "Aucun wheel Python trouvé"
fi

# Vérifier que maturin est disponible
export PATH="$HOME/.local/bin:$PATH"

if ! check_command maturin; then
    log_warning "maturin non trouvé dans le PATH"
    log_info "Ajout de ~/.local/bin au PATH"
fi

echo ""

################################################################################
# ÉTAPE 5: Compilation de METIS (optionnel)
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 5: Compilation de METIS"
log_info "======================================================================"
echo ""

METIS_INSTALLED=false

if [ -f "/usr/local/lib/libmetis.so" ] || [ -f "/usr/lib64/libmetis.so" ]; then
    log_info "METIS déjà installé"
    METIS_INSTALLED=true
else
    if [ -f "dependencies/sources/metis-master.tar.gz" ]; then
        log_info "Compilation de METIS depuis les sources..."
        
        mkdir -p "$BUILD_DIR"
        cd "$BUILD_DIR"
        
        tar xzf "$INSTALL_DIR/dependencies/sources/metis-master.tar.gz"
        cd metis-master
        
        make config prefix=/usr/local
        make -j4
        
        log_info "Installation de METIS (nécessite sudo)..."
        sudo make install
        sudo ldconfig
        
        cd "$INSTALL_DIR"
        METIS_INSTALLED=true
        log_success "METIS compilé et installé"
    else
        log_warning "METIS non trouvé, compilation sans METIS"
    fi
fi

echo ""

################################################################################
# ÉTAPE 6: Compilation de NLOPT (optionnel)
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 6: Compilation de NLOPT"
log_info "======================================================================"
echo ""

NLOPT_INSTALLED=false

if [ -f "/usr/local/lib/libnlopt.so" ] || [ -f "/usr/lib64/libnlopt.so" ]; then
    log_info "NLOPT déjà installé"
    NLOPT_INSTALLED=true
else
    if [ -f "dependencies/sources/nlopt-2.7.1.tar.gz" ]; then
        log_info "Compilation de NLOPT depuis les sources..."
        
        mkdir -p "$BUILD_DIR"
        cd "$BUILD_DIR"
        
        # Extraire cmake si nécessaire
        if ! check_command cmake; then
            log_info "Extraction de cmake..."
            tar xzf "$INSTALL_DIR/dependencies/sources/cmake-3.28.1-linux-x86_64.tar.gz"
            export PATH="$BUILD_DIR/cmake-3.28.1-linux-x86_64/bin:$PATH"
        fi
        
        tar xzf "$INSTALL_DIR/dependencies/sources/nlopt-2.7.1.tar.gz"
        cd nlopt-2.7.1
        mkdir -p build
        cd build
        
        cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
        make -j4
        
        log_info "Installation de NLOPT (nécessite sudo)..."
        sudo make install
        sudo ldconfig
        
        cd "$INSTALL_DIR"
        NLOPT_INSTALLED=true
        log_success "NLOPT compilé et installé"
    else
        log_warning "NLOPT non trouvé, compilation sans NLOPT"
    fi
fi

echo ""

################################################################################
# ÉTAPE 7: Compilation de Tucanos (bibliothèque principale)
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 7: Compilation de Tucanos (bibliothèque Rust)"
log_info "======================================================================"
echo ""

cd "$INSTALL_DIR"

# Préparer les features
FEATURES=""
if [ "$METIS_INSTALLED" = true ]; then
    FEATURES="metis"
    log_info "Compilation avec support METIS"
fi
if [ "$NLOPT_INSTALLED" = true ]; then
    if [ -n "$FEATURES" ]; then
        FEATURES="$FEATURES,nlopt"
    else
        FEATURES="nlopt"
    fi
    log_info "Compilation avec support NLOPT"
fi

log_info "Compilation de Tucanos avec features: ${FEATURES:-none}"

# Essayer avec le mode offline d'abord
log_info "Tentative de compilation en mode offline..."
if [ -n "$FEATURES" ]; then
    cargo build --release --features "$FEATURES" --offline 2>&1 | tee build.log || {
        log_warning "Échec en mode offline, tentative en mode normal..."
        cargo build --release --features "$FEATURES" 2>&1 | tee build.log
    }
else
    cargo build --release --offline 2>&1 | tee build.log || {
        log_warning "Échec en mode offline, tentative en mode normal..."
        cargo build --release 2>&1 | tee build.log
    }
fi

if [ -f "target/release/libtucanos_ffi.so" ]; then
    log_success "Bibliothèque Tucanos compilée: target/release/libtucanos_ffi.so"
else
    log_error "Erreur: libtucanos_ffi.so non trouvée"
    log_info "Consultez build.log pour plus de détails"
    exit 1
fi

echo ""

################################################################################
# ÉTAPE 8: Compilation des bindings Python (pytmesh)
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 8: Compilation de pytmesh (bindings Python)"
log_info "======================================================================"
echo ""

cd "$INSTALL_DIR/pytmesh"

log_info "Compilation de pytmesh avec maturin..."
maturin build --release --offline 2>&1 | tee ../pytmesh-build.log || {
    log_warning "Échec en mode offline, tentative en mode normal..."
    maturin build --release 2>&1 | tee ../pytmesh-build.log
}

PYTMESH_WHEEL=$(find target/wheels -name "pytmesh-*.whl" 2>/dev/null | head -1)
if [ -f "$PYTMESH_WHEEL" ]; then
    log_success "pytmesh compilé: $PYTMESH_WHEEL"
else
    log_error "Erreur: wheel pytmesh non trouvé"
    exit 1
fi

cd "$INSTALL_DIR"
echo ""

################################################################################
# ÉTAPE 9: Compilation des bindings Python (pytucanos)
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 9: Compilation de pytucanos (bindings Python)"
log_info "======================================================================"
echo ""

cd "$INSTALL_DIR/pytucanos"

log_info "Compilation de pytucanos avec maturin..."

# Préparer les features pour pytucanos
if [ -n "$FEATURES" ]; then
    maturin build --release --features "$FEATURES" --offline 2>&1 | tee ../pytucanos-build.log || {
        log_warning "Échec en mode offline, tentative en mode normal..."
        maturin build --release --features "$FEATURES" 2>&1 | tee ../pytucanos-build.log
    }
else
    maturin build --release --offline 2>&1 | tee ../pytucanos-build.log || {
        log_warning "Échec en mode offline, tentative en mode normal..."
        maturin build --release 2>&1 | tee ../pytucanos-build.log
    }
fi

PYTUCANOS_WHEEL=$(find target/wheels -name "pytucanos-*.whl" 2>/dev/null | head -1)
if [ -f "$PYTUCANOS_WHEEL" ]; then
    log_success "pytucanos compilé: $PYTUCANOS_WHEEL"
else
    log_error "Erreur: wheel pytucanos non trouvé"
    exit 1
fi

cd "$INSTALL_DIR"
echo ""

################################################################################
# ÉTAPE 10: Création du package d'installation final
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 10: Création du package d'installation final"
log_info "======================================================================"
echo ""

rm -rf "$FINAL_DIR"
mkdir -p "$FINAL_DIR"/{lib,include,python,bin}

# Copier la bibliothèque FFI
log_info "Copie de la bibliothèque Tucanos FFI..."
if [ -f "target/release/libtucanos_ffi.so" ]; then
    cp target/release/libtucanos_ffi.so "$FINAL_DIR/lib/"
    log_success "libtucanos_ffi.so copié"
fi

# Copier les headers C (si disponibles)
if [ -f "tucanos-ffi/tucanos.h" ]; then
    cp tucanos-ffi/tucanos.h "$FINAL_DIR/include/"
    log_success "tucanos.h copié"
fi

# Copier les wheels Python
log_info "Copie des wheels Python..."
cp "$PYTMESH_WHEEL" "$FINAL_DIR/python/" 2>/dev/null || true
cp "$PYTUCANOS_WHEEL" "$FINAL_DIR/python/" 2>/dev/null || true
log_success "Wheels Python copiés"

# Créer les scripts d'installation
cat > "$FINAL_DIR/install-system.sh" << 'EOFINSTALL'
#!/bin/bash
# Installation système de Tucanos (nécessite sudo)

echo "Installation de la bibliothèque Tucanos dans /usr/local/lib..."
sudo cp lib/libtucanos_ffi.so /usr/local/lib/
sudo chmod 755 /usr/local/lib/libtucanos_ffi.so

if [ -f include/tucanos.h ]; then
    echo "Installation du header dans /usr/local/include..."
    sudo cp include/tucanos.h /usr/local/include/
fi

echo "Mise à jour du cache des bibliothèques..."
sudo ldconfig

echo ""
echo "✓ Installation système terminée"
echo ""
echo "La bibliothèque est maintenant disponible dans /usr/local/lib"
EOFINSTALL

cat > "$FINAL_DIR/install-python.sh" << 'EOFPYTHON'
#!/bin/bash
# Installation Python de Tucanos (utilisateur)

echo "Installation des packages Python..."

for wheel in python/*.whl; do
    if [ -f "$wheel" ]; then
        echo "Installation de $(basename $wheel)..."
        pip3 install --user --force-reinstall "$wheel"
    fi
done

echo ""
echo "✓ Installation Python terminée"
echo ""
echo "Ajoutez ceci à votre ~/.bashrc si nécessaire:"
echo "export PATH=\"\$HOME/.local/bin:\$PATH\"
EOFPYTHON

cat > "$FINAL_DIR/test-installation.sh" << 'EOFTEST'
#!/bin/bash
# Test de l'installation Tucanos

echo "======================================================================"
echo "Test de l'installation Tucanos"
echo "======================================================================"
echo ""

# Test bibliothèque système
echo "1. Test de la bibliothèque système..."
if ldconfig -p | grep -q tucanos; then
    echo "   ✓ libtucanos_ffi.so trouvée dans le cache système"
else
    echo "   ✗ libtucanos_ffi.so non trouvée"
fi
echo ""

# Test Python
echo "2. Test des modules Python..."
python3 << 'PYEOF'
try:
    import pytmesh
    print("   ✓ pytmesh importé avec succès")
    print(f"     Version: {pytmesh.__version__ if hasattr(pytmesh, '__version__') else 'inconnue'}")
except ImportError as e:
    print(f"   ✗ Erreur import pytmesh: {e}")

try:
    import pytucanos
    print("   ✓ pytucanos importé avec succès")
    print(f"     Version: {pytucanos.__version__ if hasattr(pytucanos, '__version__') else 'inconnue'}")
except ImportError as e:
    print(f"   ✗ Erreur import pytucanos: {e}")
PYEOF

echo ""
echo "======================================================================"
echo "Test terminé"
echo "======================================================================"
EOFTEST

chmod +x "$FINAL_DIR"/*.sh

# Créer un README
cat > "$FINAL_DIR/README.txt" << 'EOFREADME'
# Package d'installation Tucanos pour SUSE 15 SP4

## Installation

### 1. Installation système (nécessite sudo)
sudo ./install-system.sh

### 2. Installation Python (utilisateur)
./install-python.sh

### 3. Test
./test-installation.sh

## Contenu

- lib/           : Bibliothèques système (.so)
- include/       : Headers C
- python/        : Wheels Python (pytmesh, pytucanos)
- *.sh           : Scripts d'installation

## Utilisation Python

```python
import pytmesh
import pytucanos

# Votre code ici
```

## Support

Pour plus d'informations, consultez la documentation dans le dossier parent.
EOFREADME

log_success "Package d'installation créé dans: $FINAL_DIR"
echo ""

################################################################################
# ÉTAPE 11: Nettoyage
################################################################################

log_info "======================================================================"
log_info "ÉTAPE 11: Nettoyage"
log_info "======================================================================"
echo ""

log_info "Nettoyage des fichiers temporaires..."
rm -rf "$BUILD_DIR"
log_success "Nettoyage terminé"
echo ""

################################################################################
# RÉSUMÉ FINAL
################################################################################

log_info "======================================================================"
log_success "INSTALLATION TERMINÉE AVEC SUCCÈS !"
log_info "======================================================================"
echo ""
log_info "Le package d'installation final se trouve dans:"
log_info "  $FINAL_DIR"
echo ""
log_info "Pour finaliser l'installation:"
echo ""
echo "  cd $FINAL_DIR"
echo "  sudo ./install-system.sh      # Installation système"
echo "  ./install-python.sh           # Installation Python"
echo "  ./test-installation.sh        # Test"
echo ""
log_info "Fichiers générés:"
log_info "  - lib/libtucanos_ffi.so     : Bibliothèque FFI C"
log_info "  - include/tucanos.h         : Header C"
log_info "  - python/pytmesh-*.whl      : Binding Python tmesh"
log_info "  - python/pytucanos-*.whl    : Binding Python tucanos"
echo ""
log_success "Profitez de Tucanos ! 🚀"
echo ""

################################################################################



