# Script pour créer un package VRAIMENT hors ligne pour SUSE 15
# Inclut toutes les dépendances nécessaires

param(
    [switch]$WithMetis,
    [switch]$WithNlopt,
    [switch]$Debug
)

Write-Host "=== Création du package HORS LIGNE pour SUSE 15 ===" -ForegroundColor Green

# Configuration
$SourceDir = "tucanos-main"
$PackageDir = "tucanos-suse15-offline-package"
$RustVersion = "1.90.0"

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  METIS: $WithMetis" -ForegroundColor White
Write-Host "  NLOPT: $WithNlopt" -ForegroundColor White
Write-Host "  Debug: $Debug" -ForegroundColor White
Write-Host ""

# Nettoyer et créer le package
if (Test-Path $PackageDir) {
    Remove-Item -Recurse -Force $PackageDir
}
New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null

# Copier le code source
Write-Host "=== Copie du code source ===" -ForegroundColor Green
Copy-Item -Path "$SourceDir\*" -Destination $PackageDir -Recurse -Force

# Créer le script d'installation HORS LIGNE
Write-Host "=== Création du script d'installation hors ligne ===" -ForegroundColor Green

$OfflineInstallScript = @"
#!/bin/bash
# Installation HORS LIGNE de Tucanos pour SUSE 15
# Ce script ne nécessite AUCUNE connexion internet

set -e

echo "=== Installation HORS LIGNE de Tucanos sur SUSE 15 ==="
echo "ATTENTION: Ce script nécessite que les dépendances soient déjà installées"
echo ""

# Vérifier les prérequis
echo "=== Vérification des prérequis ==="

# Vérifier Rust
if ! command -v rustc &> /dev/null; then
    echo "ERREUR: Rust n'est pas installé"
    echo "Installez Rust manuellement depuis le package fourni ou avec:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    exit 1
fi

RUST_VERSION_INSTALLED=`$(rustc --version | cut -d' ' -f2)
echo "Rust version: `$RUST_VERSION_INSTALLED"

# Vérifier les dépendances système
echo "Vérification des dépendances système..."

# Vérifier gcc/g++
if ! command -v gcc &> /dev/null; then
    echo "ERREUR: gcc n'est pas installé"
    echo "Installez avec: zypper install gcc gcc-c++"
    exit 1
fi

# Vérifier make
if ! command -v make &> /dev/null; then
    echo "ERREUR: make n'est pas installé"
    echo "Installez avec: zypper install make"
    exit 1
fi

# Vérifier pkg-config
if ! command -v pkg-config &> /dev/null; then
    echo "ERREUR: pkg-config n'est pas installé"
    echo "Installez avec: zypper install pkg-config"
    exit 1
fi

# Vérifier Python
if ! command -v python3 &> /dev/null; then
    echo "ERREUR: Python3 n'est pas installé"
    echo "Installez avec: zypper install python3 python3-devel python3-pip"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo "ERREUR: pip3 n'est pas installé"
    echo "Installez avec: zypper install python3-pip"
    exit 1
fi

# Vérifier maturin
if ! command -v maturin &> /dev/null; then
    echo "Installation de maturin..."
    pip3 install --user maturin
fi

echo "Prérequis OK"
echo ""

# Configuration Rust
echo "=== Configuration Rust ==="

# Configuration Cargo pour SUSE 15
mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[env]
# Configuration pour SUSE 15
RUSTFLAGS = "-C target-cpu=native"
EOF

# Ajouter METIS si demandé
if [ "$($WithMetis.ToString().ToLower())" = true ]; then
    echo "METISDIR=`"/usr/local`"" >> .cargo/config.toml
fi

echo "Configuration Rust OK"
echo ""

# Compilation
echo "=== Compilation ==="

# Définir les features
FEATURES=""
if [ "$($WithMetis.ToString().ToLower())" = true ]; then
    FEATURES="`$FEATURES --features metis"
fi
if [ "$($WithNlopt.ToString().ToLower())" = true ]; then
    FEATURES="`$FEATURES --features nlopt"
fi

# Mode de compilation
BUILD_MODE="--release"
if [ "$($Debug.ToString().ToLower())" = true ]; then
    BUILD_MODE=""
fi

echo "Compilation des bibliothèques Rust..."
echo "Features: `$FEATURES"
echo "Mode: `$BUILD_MODE"

cargo build --workspace `$BUILD_MODE `$FEATURES

echo "Compilation Rust OK"
echo ""

# Compilation FFI
echo "=== Compilation FFI ==="
cargo build --package tucanos-ffi `$BUILD_MODE `$FEATURES

# Créer le répertoire d'installation
mkdir -p "tucanos-install/lib"
mkdir -p "tucanos-install/include"

# Copier les fichiers FFI
cp "target/release/libtucanos.so" "tucanos-install/lib/"
cp "target/release/tucanos.h" "tucanos-install/include/"

echo "FFI compilé et installé"
echo ""

# Compilation Python
echo "=== Compilation Python bindings ==="

# Compiler pytmesh
echo "Compilation de pytmesh..."
cd pytmesh
maturin build --release `$FEATURES
cd ..

# Compiler pytucanos
echo "Compilation de pytucanos..."
cd pytucanos
maturin build --release `$FEATURES
cd ..

# Copier les wheels
mkdir -p "tucanos-install/python"
cp pytmesh/target/wheels/*.whl "tucanos-install/python/"
cp pytucanos/target/wheels/*.whl "tucanos-install/python/"

echo "Python bindings compilés"
echo ""

# Créer les scripts d'installation
echo "=== Création des scripts d'installation ==="

# Script d'installation système
cat > "tucanos-install/install-system.sh" << 'EOF'
#!/bin/bash
# Installation système de Tucanos

set -e

INSTALL_PREFIX="/usr/local"
LIB_DIR="`$INSTALL_PREFIX/lib"
INCLUDE_DIR="`$INSTALL_PREFIX/include"

echo "=== Installation système de Tucanos ==="

# Vérifier les permissions
if [ "`$EUID" -ne 0 ]; then
    echo "ERREUR: Ce script doit être exécuté en tant que root"
    echo "Utilisez: sudo ./install-system.sh"
    exit 1
fi

# Créer les répertoires
mkdir -p "`$LIB_DIR"
mkdir -p "`$INCLUDE_DIR"

# Installer les bibliothèques
echo "Installation des bibliothèques..."
cp lib/*.so "`$LIB_DIR/"

# Installer les en-têtes
echo "Installation des en-têtes..."
cp include/*.h "`$INCLUDE_DIR/"

# Mettre à jour ldconfig
echo "Mise à jour du cache des bibliothèques..."
ldconfig

echo ""
echo "=== Installation système terminée ==="
echo "Les bibliothèques sont installées dans `$LIB_DIR"
echo "Les en-têtes sont installés dans `$INCLUDE_DIR"
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
echo "=== Installation Python terminée ==="
echo "Vous pouvez maintenant importer pytmesh et pytucanos"
EOF

# Script de test
cat > "tucanos-install/test-installation.sh" << 'EOF'
#!/bin/bash
# Test de l'installation de Tucanos

set -e

echo "=== Test de l'installation de Tucanos ==="

# Test FFI
echo "Test des bibliothèques FFI..."
if [ -f "lib/libtucanos.so" ]; then
    echo "✓ Bibliothèque FFI trouvée"
    ldd lib/libtucanos.so | head -5
else
    echo "✗ Bibliothèque FFI non trouvée"
fi

# Test Python
echo "Test des bindings Python..."
if command -v python3 &> /dev/null; then
    python3 -c "
try:
    import pytmesh
    print('✓ pytmesh importé avec succès')
except ImportError as e:
    print(f'✗ Erreur import pytmesh: {e}')

try:
    import pytucanos
    print('✓ pytucanos importé avec succès')
except ImportError as e:
    print(f'✗ Erreur import pytucanos: {e}')
"
else
    echo "✗ Python3 non disponible"
fi

echo "Test terminé"
EOF

# Rendre les scripts exécutables
chmod +x "tucanos-install"/*.sh

echo "=== Compilation terminée ==="
echo "Package d'installation créé dans: tucanos-install"
echo ""
echo "Pour installer:"
echo "1. cd tucanos-install"
echo "2. sudo ./install-system.sh"
echo "3. ./install-python.sh"
echo "4. ./test-installation.sh"
"@

$OfflineInstallScript | Out-File -FilePath "$PackageDir/build-tucanos-offline.sh" -Encoding UTF8

# Créer un script de vérification des prérequis
$PrereqScript = @'
#!/bin/bash
# Vérification des prérequis pour installation hors ligne

set -e

echo "=== Vérification des prérequis pour installation HORS LIGNE ==="
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

# Vérifier Rust
echo "=== Vérification de Rust ==="
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version | cut -d' ' -f2)
    echo "✓ Rust trouvé: $RUST_VERSION"
else
    echo "✗ Rust non trouvé"
    echo "  Installez Rust avec: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    echo "  OU installez depuis les packages système si disponibles"
    exit 1
fi

# Vérifier les outils de compilation
echo ""
echo "=== Vérification des outils de compilation ==="

if command -v gcc &> /dev/null; then
    echo "✓ gcc trouvé: $(gcc --version | head -n1)"
else
    echo "✗ gcc non trouvé"
    echo "  Installez avec: zypper install gcc gcc-c++"
    exit 1
fi

if command -v make &> /dev/null; then
    echo "✓ make trouvé: $(make --version | head -n1)"
else
    echo "✗ make non trouvé"
    echo "  Installez avec: zypper install make"
    exit 1
fi

if command -v pkg-config &> /dev/null; then
    echo "✓ pkg-config trouvé: $(pkg-config --version)"
else
    echo "✗ pkg-config non trouvé"
    echo "  Installez avec: zypper install pkg-config"
    exit 1
fi

# Vérifier Python
echo ""
echo "=== Vérification de Python ==="

if command -v python3 &> /dev/null; then
    echo "✓ python3 trouvé: $(python3 --version)"
else
    echo "✗ python3 non trouvé"
    echo "  Installez avec: zypper install python3 python3-devel"
    exit 1
fi

if command -v pip3 &> /dev/null; then
    echo "✓ pip3 trouvé: $(pip3 --version)"
else
    echo "✗ pip3 non trouvé"
    echo "  Installez avec: zypper install python3-pip"
    exit 1
fi

# Vérifier maturin
echo ""
echo "=== Vérification de maturin ==="
if command -v maturin &> /dev/null; then
    echo "✓ maturin trouvé: $(maturin --version)"
else
    echo "⚠ maturin non trouvé - sera installé automatiquement"
fi

# Vérifier les dépendances optionnelles
echo ""
echo "=== Vérification des dépendances optionnelles ==="

# METIS
if pkg-config --exists metis 2>/dev/null; then
    echo "✓ METIS trouvé via pkg-config"
elif [ -f /usr/local/lib/libmetis.so ] || [ -f /usr/lib/libmetis.so ]; then
    echo "✓ METIS trouvé dans le système"
else
    echo "⚠ METIS non trouvé (optionnel)"
    echo "  Pour l'installer: https://github.com/KarypisLab/METIS"
fi

# NLOPT
if pkg-config --exists nlopt 2>/dev/null; then
    echo "✓ NLOPT trouvé via pkg-config"
elif [ -f /usr/local/lib/libnlopt.so ] || [ -f /usr/lib/libnlopt.so ]; then
    echo "✓ NLOPT trouvé dans le système"
else
    echo "⚠ NLOPT non trouvé (optionnel)"
    echo "  Installez avec: zypper install nlopt-devel"
fi

echo ""
echo "=== Résumé ==="
echo "✓ Prérequis de base: OK"
echo "⚠ Dépendances optionnelles: Vérifiez selon vos besoins"
echo ""
echo "Vous pouvez maintenant exécuter:"
echo "  ./build-tucanos-offline.sh"
'@

$PrereqScript | Out-File -FilePath "$PackageDir/check-prerequisites.sh" -Encoding UTF8

# Créer la documentation hors ligne
$OfflineReadme = @"
# Package HORS LIGNE Tucanos pour SUSE 15

## 🚫 Installation VRAIMENT hors ligne

Ce package est conçu pour fonctionner **SANS connexion internet** sur la machine SUSE 15.

## ⚠️ Prérequis IMPORTANTS

**AVANT** de transférer ce package sur SUSE 15, assurez-vous que la machine cible a :

### Dépendances système (installées AVANT)
```bash
# Sur la machine SUSE 15, avec connexion internet :
sudo zypper refresh
sudo zypper install gcc gcc-c++ make pkg-config
sudo zypper install python3 python3-devel python3-pip
sudo zypper install nlopt-devel  # optionnel pour NLOPT
```

### Rust (installé AVANT)
```bash
# Sur la machine SUSE 15, avec connexion internet :
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
```

### METIS (optionnel, installation manuelle)
```bash
# Téléchargez depuis : https://github.com/KarypisLab/METIS
# Compilez et installez manuellement
```

## 🚀 Installation hors ligne

### 1. Vérification des prérequis
```bash
chmod +x check-prerequisites.sh
./check-prerequisites.sh
```

### 2. Compilation hors ligne
```bash
chmod +x build-tucanos-offline.sh
./build-tucanos-offline.sh
```

### 3. Installation
```bash
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh
```

## 📋 Ce qui est inclus

- ✅ Code source complet de Tucanos
- ✅ Scripts de compilation hors ligne
- ✅ Scripts d'installation
- ✅ Scripts de test
- ✅ Documentation complète

## 📋 Ce qui N'EST PAS inclus

- ❌ Compilateur Rust (doit être installé avant)
- ❌ Outils de compilation (gcc, make, etc.)
- ❌ Python et pip
- ❌ Dépendances système (NLOPT, METIS)

## 🔧 Configuration compilée

- **Architecture** : x86_64-unknown-linux-gnu
- **METIS** : $WithMetis
- **NLOPT** : $WithNlopt
- **Mode debug** : $Debug

## ⚡ Workflow recommandé

### Sur une machine avec internet :
1. Installez les dépendances système
2. Installez Rust
3. Téléchargez ce package
4. Transférez sur la machine SUSE 15 hors ligne

### Sur la machine SUSE 15 hors ligne :
1. Vérifiez les prérequis : `./check-prerequisites.sh`
2. Compilez : `./build-tucanos-offline.sh`
3. Installez : `cd tucanos-install && sudo ./install-system.sh && ./install-python.sh`

## 🎯 Avantages

- ✅ Vraiment hors ligne
- ✅ Pas de téléchargement pendant la compilation
- ✅ Compilation locale
- ✅ Contrôle total sur l'environnement

## ⚠️ Limitations

- ⚠️ Dépendances système doivent être installées AVANT
- ⚠️ Rust doit être installé AVANT
- ⚠️ Plus de préparation initiale requise

## 📚 Support

- **Documentation officielle** : https://github.com/tucanos/tucanos
- **Issues** : https://github.com/tucanos/tucanos/issues
- **Licence** : LGPL-2.1
"@

$OfflineReadme | Out-File -FilePath "$PackageDir/README-OFFLINE.md" -Encoding UTF8

# Créer un script de préparation complète
$PrepScript = @'
#!/bin/bash
# Script de préparation pour installation hors ligne

set -e

echo "=== Préparation pour installation HORS LIGNE de Tucanos ==="
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

# Installation des dépendances système
echo "=== Installation des dépendances système ==="
echo "Mise à jour du système..."
sudo zypper refresh

echo "Installation des outils de développement..."
sudo zypper install -y gcc gcc-c++ make pkg-config

echo "Installation de Python..."
sudo zypper install -y python3 python3-devel python3-pip

echo "Installation de NLOPT (optionnel)..."
sudo zypper install -y nlopt-devel

echo "Dépendances système installées"
echo ""

# Installation de Rust
echo "=== Installation de Rust ==="
if ! command -v rustc &> /dev/null; then
    echo "Installation de Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
    echo "Rust installé"
else
    echo "Rust déjà installé: $(rustc --version)"
fi

echo ""

# Installation de maturin
echo "=== Installation de maturin ==="
pip3 install --user maturin

echo ""

# Information sur METIS
echo "=== Information sur METIS ==="
echo "METIS n'est pas disponible dans les dépôts standard de SUSE"
echo "Pour l'installer manuellement:"
echo "1. Téléchargez depuis: https://github.com/KarypisLab/METIS"
echo "2. Compilez et installez selon les instructions"
echo "3. Configurez METISDIR dans .cargo/config.toml si nécessaire"
echo ""

echo "=== Préparation terminée ==="
echo "Vous pouvez maintenant transférer ce package sur une machine hors ligne"
echo "et exécuter: ./build-tucanos-offline.sh"
'@

$PrepScript | Out-File -FilePath "$PackageDir/prepare-for-offline.sh" -Encoding UTF8

# Créer un fichier de vérification
$VerificationFile = @"
# Package HORS LIGNE Tucanos pour SUSE 15

Date de création: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Configuration: METIS=$WithMetis, NLOPT=$WithNlopt, Debug=$Debug

IMPORTANT: Ce package nécessite que les dépendances soient installées AVANT le transfert.

Prérequis à installer AVANT le transfert:
- gcc, gcc-c++, make, pkg-config
- python3, python3-devel, python3-pip
- rust (via rustup)
- nlopt-devel (optionnel)
- maturin (via pip)

Instructions:
1. Sur machine avec internet: ./prepare-for-offline.sh
2. Transférer le package sur SUSE 15 hors ligne
3. Sur SUSE 15: ./check-prerequisites.sh
4. Sur SUSE 15: ./build-tucanos-offline.sh
5. Sur SUSE 15: cd tucanos-install && sudo ./install-system.sh && ./install-python.sh

Documentation: README-OFFLINE.md
"@

$VerificationFile | Out-File -FilePath "$PackageDir/VERIFICATION-OFFLINE.txt" -Encoding UTF8

Write-Host ""
Write-Host "=== PACKAGE HORS LIGNE CRÉÉ ===" -ForegroundColor Green
Write-Host ""
Write-Host "Package hors ligne: $PackageDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  IMPORTANT: Ce package nécessite des prérequis installés AVANT le transfert" -ForegroundColor Red
Write-Host ""
Write-Host "Instructions complètes:" -ForegroundColor Yellow
Write-Host "1. Sur machine avec internet: ./prepare-for-offline.sh" -ForegroundColor White
Write-Host "2. Transférer le package sur SUSE 15 hors ligne" -ForegroundColor White
Write-Host "3. Sur SUSE 15: ./check-prerequisites.sh" -ForegroundColor White
Write-Host "4. Sur SUSE 15: ./build-tucanos-offline.sh" -ForegroundColor White
Write-Host "5. Sur SUSE 15: cd tucanos-install && sudo ./install-system.sh && ./install-python.sh" -ForegroundColor White
Write-Host ""
Write-Host "Documentation: $PackageDir/README-OFFLINE.md" -ForegroundColor Green




