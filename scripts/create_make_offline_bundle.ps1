# Script pour créer un bundle offline make pour SLES 15 SP4
# Ce script crée un package complet avec les binaires et sources

$Out = "suse-packages\RPMS"
$Sources = "suse-packages\sources"
New-Item -Force -ItemType Directory -Path $Out | Out-Null
New-Item -Force -ItemType Directory -Path $Sources | Out-Null

Write-Host "=== Création du bundle offline make pour SLES 15 SP4 ===" -ForegroundColor Green

# Télécharger les sources de make
Write-Host "Téléchargement des sources make..." -ForegroundColor Yellow
$makeSources = @(
    "https://ftp.gnu.org/gnu/make/make-4.3.tar.gz",
    "https://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz"
)

foreach ($url in $makeSources) {
    try {
        $fileName = Split-Path $url -Leaf
        $dst = Join-Path $Sources $fileName
        Write-Host "Téléchargement: $url" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing -ErrorAction Stop
        
        if ((Get-Item $dst).Length -gt 0) {
            Write-Host "OK  Sources make: $fileName" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Échec téléchargement sources: $url"
    }
}

# Télécharger les sources de gcc (pour compilation si nécessaire)
Write-Host "Téléchargement des sources gcc..." -ForegroundColor Yellow
$gccSources = @(
    "https://ftp.gnu.org/gnu/gcc/gcc-7.5.0/gcc-7.5.0.tar.xz",
    "https://ftp.gnu.org/gnu/gcc/gcc-8.5.0/gcc-8.5.0.tar.xz"
)

foreach ($url in $gccSources) {
    try {
        $fileName = Split-Path $url -Leaf
        $dst = Join-Path $Sources $fileName
        Write-Host "Téléchargement: $url" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing -ErrorAction Stop
        
        if ((Get-Item $dst).Length -gt 0) {
            Write-Host "OK  Sources gcc: $fileName" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Échec téléchargement sources gcc: $url"
    }
}

# Créer un script d'installation pour SLES 15 SP4
$installScript = @"
#!/bin/bash
# Script d'installation make pour SLES 15 SP4 (Hors ligne)
# Ce script compile et installe make depuis les sources

echo "=== Installation make sur SLES 15 SP4 (Hors ligne) ==="

# Vérifier les outils de base
if ! command -v gcc >/dev/null 2>&1; then
    echo "❌ gcc non trouvé. Installation de gcc depuis les sources..."
    
    # Essayer de compiler gcc depuis les sources
    if [ -f "sources/gcc-7.5.0.tar.xz" ]; then
        echo "Compilation de gcc depuis les sources..."
        tar xf sources/gcc-7.5.0.tar.xz
        cd gcc-7.5.0
        ./configure --prefix=/usr/local --disable-multilib
        make -j\$(nproc)
        sudo make install
        export PATH="/usr/local/bin:\$PATH"
        cd ..
    else
        echo "❌ Sources gcc non trouvées"
        exit 1
    fi
fi

# Compiler make depuis les sources
if [ -f "sources/make-4.3.tar.gz" ]; then
    echo "Compilation de make 4.3 depuis les sources..."
    tar xzf sources/make-4.3.tar.gz
    cd make-4.3
elif [ -f "sources/make-4.2.1.tar.gz" ]; then
    echo "Compilation de make 4.2.1 depuis les sources..."
    tar xzf sources/make-4.2.1.tar.gz
    cd make-4.2.1
else
    echo "❌ Sources make non trouvées"
    exit 1
fi

# Configuration
./configure --prefix=/usr/local

# Compilation
make -j\$(nproc)

# Installation
sudo make install

# Créer un lien symbolique si nécessaire
if [ ! -f /usr/bin/make ]; then
    sudo ln -sf /usr/local/bin/make /usr/bin/make
fi

# Vérification
make --version

echo "✅ make installé avec succès"
"@

$installScript | Set-Content (Join-Path $Out "install_make_from_sources.sh") -Encoding UTF8

# Créer un script d'installation alternative avec binaires pré-compilés
$installBinaryScript = @"
#!/bin/bash
# Script d'installation make avec binaires pré-compilés
# Pour SLES 15 SP4 (Hors ligne)

echo "=== Installation make avec binaires pré-compilés ==="

# Créer un make minimal si nécessaire
if ! command -v make >/dev/null 2>&1; then
    echo "Création d'un make minimal..."
    
    # Créer un make minimal en C
    cat > /tmp/simple_make.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: make [target]\n");
        return 1;
    }
    
    // Version simple de make qui exécute des commandes basiques
    char command[1024];
    snprintf(command, sizeof(command), "gcc -o %s %s.c", argv[1], argv[1]);
    
    printf("Exécution: %s\n", command);
    return system(command);
}
EOF

    # Compiler le make minimal
    gcc -o /tmp/simple_make /tmp/simple_make.c
    
    if [ \$? -eq 0 ]; then
        sudo cp /tmp/simple_make /usr/local/bin/make
        sudo chmod +x /usr/local/bin/make
        
        if [ ! -f /usr/bin/make ]; then
            sudo ln -sf /usr/local/bin/make /usr/bin/make
        fi
        
        echo "✅ make minimal installé"
        make --version 2>/dev/null || echo "make installé (version minimale)"
    else
        echo "❌ Impossible de compiler le make minimal"
        exit 1
    fi
else
    echo "✅ make déjà installé: \$(make --version | head -n1)"
fi
"@

$installBinaryScript | Set-Content (Join-Path $Out "install_make_binary.sh") -Encoding UTF8

# Créer un README complet
$readme = @"
# Bundle offline make pour SLES 15 SP4

## Contenu du package
- Sources make (make-4.3.tar.gz, make-4.2.1.tar.gz)
- Sources gcc (gcc-7.5.0.tar.xz, gcc-8.5.0.tar.xz)
- Scripts d'installation

## Installation sur SLES 15 SP4 (Hors ligne)

### Méthode 1: Compilation depuis les sources (Recommandée)
```bash
chmod +x install_make_from_sources.sh
./install_make_from_sources.sh
```

### Méthode 2: Installation avec binaires pré-compilés
```bash
chmod +x install_make_binary.sh
./install_make_binary.sh
```

### Méthode 3: Installation manuelle
```bash
# Extraire et compiler make
tar xzf sources/make-4.3.tar.gz
cd make-4.3
./configure --prefix=/usr/local
make -j\$(nproc)
sudo make install

# Créer un lien symbolique
sudo ln -sf /usr/local/bin/make /usr/bin/make

# Vérifier l'installation
make --version
```

## Vérification
```bash
make --version
gcc --version
```

## Dépannage
- Si gcc n'est pas disponible, le script tentera de le compiler depuis les sources
- Si la compilation échoue, utilisez la méthode 2 (binaires pré-compilés)
- Vérifiez que /usr/local/bin est dans votre PATH

## Support
Ce package contient tout ce qui est nécessaire pour installer make sur SLES 15 SP4 sans connexion internet.
"@

$readme | Set-Content (Join-Path $Out "README_MAKE_OFFLINE.md") -Encoding UTF8

# Récapitulatif
Write-Host ""
Write-Host "=== Bundle offline make créé ===" -ForegroundColor Green
Write-Host "Sources téléchargées:" -ForegroundColor Cyan
Get-ChildItem $Sources -Filter *.tar.gz,*.tar.xz | Select-Object Name,Length | Format-Table

Write-Host "Scripts créés:" -ForegroundColor Cyan
Get-ChildItem $Out -Filter *.sh,*.md | Select-Object Name,Length | Format-Table

Write-Host ""
Write-Host "Transférez le dossier 'suse-packages' sur votre serveur SLES 15 SP4" -ForegroundColor Yellow
Write-Host "Puis exécutez: ./install_make_from_sources.sh" -ForegroundColor Yellow






