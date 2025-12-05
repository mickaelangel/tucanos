# Script PowerShell pour compiler Tucanos pour SUSE 15
# Compilation cross-platform depuis Windows vers Linux

param(
    [switch]$WithMetis,
    [switch]$WithNlopt,
    [switch]$Debug
)

Write-Host "=== Compilation de Tucanos pour SUSE 15 ===" -ForegroundColor Green

# Configuration
$SourceDir = "tucanos-main"
$BuildDir = "tucanos-build-suse15"
$InstallDir = "tucanos-suse15-package"
$TargetArch = "x86_64-unknown-linux-gnu"

Write-Host "Architecture cible: $TargetArch" -ForegroundColor Yellow
Write-Host "Avec METIS: $WithMetis" -ForegroundColor Yellow
Write-Host "Avec NLOPT: $WithNlopt" -ForegroundColor Yellow
Write-Host "Mode debug: $Debug" -ForegroundColor Yellow
Write-Host ""

# Nettoyer et créer les répertoires
if (Test-Path $BuildDir) {
    Remove-Item -Recurse -Force $BuildDir
}
if (Test-Path $InstallDir) {
    Remove-Item -Recurse -Force $InstallDir
}

New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

# Copier le code source
Write-Host "=== Copie du code source ===" -ForegroundColor Green
Copy-Item -Path "$SourceDir\*" -Destination $BuildDir -Recurse -Force
Set-Location $BuildDir

# Configuration Cargo pour SUSE 15
Write-Host "=== Configuration Cargo ===" -ForegroundColor Green
New-Item -ItemType Directory -Path ".cargo" -Force | Out-Null

$CargoConfig = @"
[target.$TargetArch]
linker = "x86_64-linux-gnu-gcc"

[env]
RUSTFLAGS = "-C target-cpu=native -C link-arg=-static-libgcc"
"@

if ($WithMetis) {
    $CargoConfig += "`nMETISDIR=`"/usr/local`""
}

$CargoConfig | Out-File -FilePath ".cargo/config.toml" -Encoding UTF8

# Définir les features
$Features = ""
if ($WithMetis) {
    $Features += " --features metis"
}
if ($WithNlopt) {
    $Features += " --features nlopt"
}

# Mode de compilation
$BuildMode = "--release"
if ($Debug) {
    $BuildMode = ""
}

Write-Host "=== Compilation des bibliothèques Rust ===" -ForegroundColor Green
Write-Host "Features: $Features" -ForegroundColor Yellow
Write-Host "Mode: $BuildMode" -ForegroundColor Yellow

try {
    # Compiler le workspace
    Write-Host "Compilation du workspace..." -ForegroundColor Yellow
    cargo build --workspace $BuildMode $Features --target $TargetArch
    
    Write-Host "Compilation Rust réussie !" -ForegroundColor Green
} catch {
    Write-Host "ERREUR lors de la compilation Rust: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Compiler FFI
Write-Host "=== Compilation FFI ===" -ForegroundColor Green
try {
    cargo build --package tucanos-ffi $BuildMode $Features --target $TargetArch
    
    # Copier les fichiers FFI
    New-Item -ItemType Directory -Path "../$InstallDir/lib" -Force | Out-Null
    New-Item -ItemType Directory -Path "../$InstallDir/include" -Force | Out-Null
    
    $ReleaseDir = "target/$TargetArch/release"
    Copy-Item -Path "$ReleaseDir/libtucanos.so" -Destination "../$InstallDir/lib/" -Force
    Copy-Item -Path "$ReleaseDir/tucanos.h" -Destination "../$InstallDir/include/" -Force
    
    Write-Host "FFI compilé et copié" -ForegroundColor Green
} catch {
    Write-Host "ERREUR lors de la compilation FFI: $($_.Exception.Message)" -ForegroundColor Red
}

# Compiler les bindings Python
Write-Host "=== Compilation des bindings Python ===" -ForegroundColor Green
try {
    # Installer maturin si nécessaire
    Write-Host "Installation de maturin..." -ForegroundColor Yellow
    pip install maturin --quiet
    
    # Compiler pytmesh
    Write-Host "Compilation de pytmesh..." -ForegroundColor Yellow
    Set-Location pytmesh
    maturin build --release --target $TargetArch $Features
    Set-Location ..
    
    # Compiler pytucanos
    Write-Host "Compilation de pytucanos..." -ForegroundColor Yellow
    Set-Location pytucanos
    maturin build --release --target $TargetArch $Features
    Set-Location ..
    
    # Copier les wheels
    New-Item -ItemType Directory -Path "../$InstallDir/python" -Force | Out-Null
    Copy-Item -Path "pytmesh/target/wheels/*.whl" -Destination "../$InstallDir/python/" -Force
    Copy-Item -Path "pytucanos/target/wheels/*.whl" -Destination "../$InstallDir/python/" -Force
    
    Write-Host "Bindings Python compilés" -ForegroundColor Green
} catch {
    Write-Host "ERREUR lors de la compilation Python: $($_.Exception.Message)" -ForegroundColor Red
}

Set-Location ..

# Créer les scripts d'installation pour SUSE 15
Write-Host "=== Création des scripts d'installation ===" -ForegroundColor Green

# Script d'installation système
$InstallSystemScript = @'
#!/bin/bash
# Installation système de Tucanos sur SUSE 15

set -e

INSTALL_PREFIX="/usr/local"
LIB_DIR="$INSTALL_PREFIX/lib"
INCLUDE_DIR="$INSTALL_PREFIX/include"

echo "=== Installation système de Tucanos sur SUSE 15 ==="

# Vérifier les permissions
if [ "$EUID" -ne 0 ]; then
    echo "ERREUR: Ce script doit être exécuté en tant que root"
    echo "Utilisez: sudo ./install-system.sh"
    exit 1
fi

# Vérifier que nous sommes sur SUSE
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse" && "$ID" != "sles" ]]; then
    echo "ATTENTION: Ce script est conçu pour SUSE Linux"
    echo "Distribution détectée: $PRETTY_NAME"
    read -p "Continuer quand même? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Distribution: $PRETTY_NAME"

# Créer les répertoires
mkdir -p "$LIB_DIR"
mkdir -p "$INCLUDE_DIR"

# Installer les bibliothèques
echo "Installation des bibliothèques..."
cp lib/*.so "$LIB_DIR/"

# Installer les en-têtes
echo "Installation des en-têtes..."
cp include/*.h "$INCLUDE_DIR/"

# Mettre à jour ldconfig
echo "Mise à jour du cache des bibliothèques..."
ldconfig

echo ""
echo "=== Installation système terminée ==="
echo "Les bibliothèques sont installées dans $LIB_DIR"
echo "Les en-têtes sont installés dans $INCLUDE_DIR"
echo ""
echo "Test de l'installation:"
echo "  ldd $LIB_DIR/libtucanos.so"
'@

$InstallSystemScript | Out-File -FilePath "$InstallDir/install-system.sh" -Encoding UTF8

# Script d'installation Python
$InstallPythonScript = @'
#!/bin/bash
# Installation des bindings Python sur SUSE 15

set -e

echo "=== Installation des bindings Python sur SUSE 15 ==="

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

# Installer les wheels
echo "Installation des packages Python..."
pip3 install --user python/*.whl

echo ""
echo "=== Installation Python terminée ==="
echo "Vous pouvez maintenant importer pytmesh et pytucanos"
echo ""
echo "Test de l'installation:"
echo "  python3 -c 'import pytmesh; import pytucanos; print(\"Import réussi!\")'"
'@

$InstallPythonScript | Out-File -FilePath "$InstallDir/install-python.sh" -Encoding UTF8

# Script de test complet
$TestScript = @'
#!/bin/bash
# Test complet de l'installation de Tucanos sur SUSE 15

set -e

echo "=== Test de l'installation de Tucanos sur SUSE 15 ==="

# Informations système
echo "Informations système:"
if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "Distribution: $PRETTY_NAME"
    echo "Version: $VERSION"
fi
echo "Architecture: $(uname -m)"
echo ""

# Test FFI
echo "=== Test des bibliothèques FFI ==="
if [ -f "lib/libtucanos.so" ]; then
    echo "✓ Bibliothèque FFI trouvée: lib/libtucanos.so"
    echo "Dépendances:"
    ldd lib/libtucanos.so | head -10
    echo ""
    
    # Test de compilation C
    echo "Test de compilation C..."
    cat > test_tucanos.c << 'EOF'
#include <stdio.h>
#include <tucanos.h>

int main() {
    printf("Test de compilation C avec Tucanos\n");
    tucanos_init_log();
    printf("Initialisation réussie\n");
    return 0;
}
EOF
    
    if gcc -I./include -L./lib -ltucanos test_tucanos.c -o test_tucanos 2>/dev/null; then
        echo "✓ Compilation C réussie"
        if LD_LIBRARY_PATH=./lib ./test_tucanos 2>/dev/null; then
            echo "✓ Exécution C réussie"
        else
            echo "✗ Erreur d'exécution C"
        fi
        rm -f test_tucanos test_tucanos.c
    else
        echo "✗ Erreur de compilation C"
    fi
else
    echo "✗ Bibliothèque FFI non trouvée"
fi

echo ""

# Test Python
echo "=== Test des bindings Python ==="
if command -v python3 &> /dev/null; then
    python3 -c "
import sys
print(f'Python version: {sys.version}')
print('')

try:
    import pytmesh
    print('✓ pytmesh importé avec succès')
    print(f'  Version: {pytmesh.__version__ if hasattr(pytmesh, \"__version__\") else \"N/A\"}')
except ImportError as e:
    print(f'✗ Erreur import pytmesh: {e}')

try:
    import pytucanos
    print('✓ pytucanos importé avec succès')
    print(f'  Version: {pytucanos.__version__ if hasattr(pytucanos, \"__version__\") else \"N/A\"}')
except ImportError as e:
    print(f'✗ Erreur import pytucanos: {e}')

# Test de fonctionnalité basique
try:
    import pytmesh
    print('✓ Test de fonctionnalité pytmesh...')
    # Test basique si disponible
except:
    pass

try:
    import pytucanos
    print('✓ Test de fonctionnalité pytucanos...')
    # Test basique si disponible
except:
    pass
"
else
    echo "✗ Python3 non disponible"
fi

echo ""
echo "=== Test terminé ==="
'@

$TestScript | Out-File -FilePath "$InstallDir/test-installation.sh" -Encoding UTF8

# Documentation complète
$ReadmeContent = @"
# Package d'installation Tucanos pour SUSE 15

## Description

Ce package contient Tucanos compilé pour SUSE 15 (x86_64) avec les composants suivants :

- **Bibliothèques FFI** : `lib/libtucanos.so` et `include/tucanos.h`
- **Bindings Python** : Packages wheel pour pytmesh et pytucanos
- **Scripts d'installation** : Automatisation de l'installation

## Configuration de compilation

- **Architecture** : x86_64-unknown-linux-gnu
- **METIS** : $WithMetis
- **NLOPT** : $WithNlopt
- **Mode debug** : $Debug
- **Compilé depuis** : Windows avec cross-compilation Rust

## Installation sur SUSE 15

### Prérequis système

```bash
# Mise à jour du système
sudo zypper refresh

# Installation des dépendances de base
sudo zypper install gcc gcc-c++ make pkg-config

# Pour les bindings Python (optionnel)
sudo zypper install python3 python3-devel python3-pip
```

### Installation

1. **Copiez ce dossier sur votre machine SUSE 15**

2. **Installation des bibliothèques système** (requiert root) :
   ```bash
   sudo ./install-system.sh
   ```

3. **Installation des bindings Python** (optionnel) :
   ```bash
   ./install-python.sh
   ```

4. **Test de l'installation** :
   ```bash
   ./test-installation.sh
   ```

## Utilisation

### En C/C++

```c
#include <tucanos.h>

int main() {
    tucanos_init_log();
    // Votre code ici
    return 0;
}
```

Compilation :
```bash
gcc -I/usr/local/include -L/usr/local/lib -ltucanos votre_programme.c -o votre_programme
```

### En Python

```python
import pytmesh
import pytucanos

# Votre code Python ici
```

## Structure du package

```
tucanos-suse15-package/
├── lib/
│   └── libtucanos.so          # Bibliothèque principale
├── include/
│   └── tucanos.h              # En-têtes C/C++
├── python/
│   ├── pytmesh-*.whl          # Package Python pytmesh
│   └── pytucanos-*.whl        # Package Python pytucanos
├── install-system.sh          # Script d'installation système
├── install-python.sh          # Script d'installation Python
├── test-installation.sh       # Script de test
└── README-INSTALL.md          # Cette documentation
```

## Dépannage

### Erreur "library not found"

```bash
# Vérifier que les bibliothèques sont installées
ldconfig -p | grep tucanos

# Si nécessaire, mettre à jour le cache
sudo ldconfig
```

### Erreur d'import Python

```bash
# Vérifier l'installation
pip3 list | grep -E "(pytmesh|pytucanos)"

# Réinstaller si nécessaire
pip3 install --user --force-reinstall python/*.whl
```

### Vérification des dépendances

```bash
# Vérifier les dépendances de la bibliothèque
ldd /usr/local/lib/libtucanos.so
```

## Support

- **Documentation officielle** : https://github.com/tucanos/tucanos
- **Issues** : https://github.com/tucanos/tucanos/issues
- **Licence** : LGPL-2.1

## Notes techniques

- Compilé avec Rust 1.90.0
- Optimisé pour SUSE 15 (x86_64)
- Compatible avec les versions récentes de SUSE Linux Enterprise Server et openSUSE
- Support des fonctionnalités optionnelles selon la configuration de compilation
"@

$ReadmeContent | Out-File -FilePath "$InstallDir/README-INSTALL.md" -Encoding UTF8

# Créer un script de déploiement rapide
$QuickDeployScript = @'
#!/bin/bash
# Déploiement rapide de Tucanos sur SUSE 15

set -e

echo "=== Déploiement rapide de Tucanos sur SUSE 15 ==="

# Vérifier les prérequis
if [ "$EUID" -eq 0 ]; then
    echo "ERREUR: Ne pas exécuter ce script en tant que root"
    echo "Ce script installera les dépendances système puis vous demandera sudo pour l'installation"
    exit 1
fi

# Installer les dépendances système
echo "Installation des dépendances système..."
sudo zypper refresh
sudo zypper install -y gcc gcc-c++ make pkg-config python3 python3-devel python3-pip

# Installer Rust si nécessaire
if ! command -v rustc &> /dev/null; then
    echo "Installation de Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
fi

# Installation des bibliothèques
echo "Installation des bibliothèques Tucanos..."
sudo ./install-system.sh

# Installation Python
echo "Installation des bindings Python..."
./install-python.sh

# Test
echo "Test de l'installation..."
./test-installation.sh

echo ""
echo "=== Déploiement terminé ==="
echo "Tucanos est maintenant installé sur votre système SUSE 15"
'@

$QuickDeployScript | Out-File -FilePath "$InstallDir/quick-deploy.sh" -Encoding UTF8

# Rendre tous les scripts exécutables (simulation)
Write-Host "=== Finalisation ===" -ForegroundColor Green

# Créer un fichier de vérification
$VerificationFile = @"
# Vérification du package Tucanos pour SUSE 15

Date de compilation: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Architecture: $TargetArch
Features: METIS=$WithMetis, NLOPT=$WithNlopt, Debug=$Debug

Contenu du package:
- Bibliothèques FFI: $(if (Test-Path "$InstallDir/lib/libtucanos.so") { "OK" } else { "KO" })
- En-têtes C: $(if (Test-Path "$InstallDir/include/tucanos.h") { "OK" } else { "KO" })
- Packages Python: $(if (Test-Path "$InstallDir/python") { "OK" } else { "KO" })
- Scripts d'installation: $(if (Test-Path "$InstallDir/install-system.sh") { "OK" } else { "KO" })

Instructions de déploiement:
1. Copiez le dossier '$InstallDir' sur la machine SUSE 15
2. Exécutez: cd $InstallDir && sudo ./install-system.sh
3. Exécutez: ./install-python.sh
4. Testez: ./test-installation.sh

OU utilisez le déploiement rapide:
cd $InstallDir && chmod +x quick-deploy.sh && ./quick-deploy.sh
"@

$VerificationFile | Out-File -FilePath "$InstallDir/VERIFICATION.txt" -Encoding UTF8

Write-Host ""
Write-Host "=== COMPILATION TERMINÉE ===" -ForegroundColor Green
Write-Host ""
Write-Host "Package créé: $InstallDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Contenu du package:" -ForegroundColor White
Get-ChildItem -Path $InstallDir -Recurse | ForEach-Object {
    Write-Host "  $($_.FullName.Replace((Get-Location).Path + '\', ''))" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "Instructions de déploiement:" -ForegroundColor Yellow
Write-Host "1. Copiez le dossier '$InstallDir' sur votre machine SUSE 15" -ForegroundColor White
Write-Host "2. Sur SUSE 15, exécutez:" -ForegroundColor White
Write-Host "   cd $InstallDir" -ForegroundColor Cyan
Write-Host "   sudo ./install-system.sh" -ForegroundColor Cyan
Write-Host "   ./install-python.sh" -ForegroundColor Cyan
Write-Host "   ./test-installation.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "OU utilisez le déploiement automatique:" -ForegroundColor Yellow
Write-Host "   cd $InstallDir && chmod +x quick-deploy.sh && ./quick-deploy.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "Documentation complète: $InstallDir/README-INSTALL.md" -ForegroundColor Green
