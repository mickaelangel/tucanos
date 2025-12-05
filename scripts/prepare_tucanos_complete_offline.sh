#!/bin/bash
# Script pour préparer le package complet offline de Tucanos avec make
# Ce script doit être exécuté sur une machine connectée

echo "=== Préparation du package complet Tucanos offline ==="

# Créer le répertoire du package
PACKAGE_DIR="tucanos-complete-offline"
mkdir -p "$PACKAGE_DIR"

echo "Copie des composants..."

# 1. Copier les sources Tucanos
if [ -d "tucanos-main" ]; then
    echo "✓ Copie des sources Tucanos..."
    cp -r tucanos-main "$PACKAGE_DIR/"
else
    echo "✗ Sources Tucanos non trouvées dans tucanos-main/"
    exit 1
fi

# 2. Copier le package Rust offline
if [ -d "rust-offline-package" ]; then
    echo "✓ Copie du package Rust offline..."
    cp -r rust-offline-package "$PACKAGE_DIR/"
else
    echo "⚠ Package Rust offline non trouvé (optionnel si Rust est déjà installé)"
fi

# 3. Copier le bundle make
if [ -d "suse-packages" ]; then
    echo "✓ Copie du bundle make..."
    cp -r suse-packages "$PACKAGE_DIR/"
else
    echo "✗ Bundle make non trouvé dans suse-packages/"
    exit 1
fi

# 4. Copier le script d'installation
echo "✓ Copie du script d'installation..."
cp install_tucanos_suse15_offline.sh "$PACKAGE_DIR/"
chmod +x "$PACKAGE_DIR/install_tucanos_suse15_offline.sh"

# 5. Créer un README
cat > "$PACKAGE_DIR/README_INSTALLATION_COMPLETE.md" << 'EOF'
# Installation complète de Tucanos sur SUSE 15 SP4 (Hors ligne)

Ce package contient tout le nécessaire pour installer Tucanos sur SUSE 15 SP4 sans connexion internet.

## Contenu du package

- `tucanos-main/` - Sources de Tucanos
- `rust-offline-package/` - Package Rust offline (toolchain complet)
- `suse-packages/` - Bundle make et dépendances
- `install_tucanos_suse15_offline.sh` - Script d'installation automatique

## Prérequis sur le serveur SUSE 15 SP4

Le serveur doit avoir au minimum :
- `gcc` et `g++` installés (pour compiler make et les dépendances natives)
- `tar` et `gzip` (normalement présents par défaut)
- Accès sudo pour l'installation globale

Si gcc n'est pas disponible, installez-le d'abord :
```bash
sudo zypper install gcc gcc-c++
```

## Installation

1. Transférez ce dossier complet sur votre serveur SUSE 15 SP4 :
   ```bash
   scp -r tucanos-complete-offline user@server:/path/to/destination/
   ```
   
   Ou utilisez une clé USB pour le transfert.

2. Sur le serveur, accédez au dossier :
   ```bash
   cd /path/to/destination/tucanos-complete-offline
   ```

3. Rendez le script exécutable (si ce n'est pas déjà fait) :
   ```bash
   chmod +x install_tucanos_suse15_offline.sh
   ```

4. Lancez l'installation :
   ```bash
   ./install_tucanos_suse15_offline.sh
   ```

Le script va automatiquement :
1. ✓ Vérifier et installer `make` si nécessaire (depuis les sources)
2. ✓ Vérifier et installer Rust si nécessaire
3. ✓ Compiler Tucanos avec les fonctionnalités disponibles
4. ✓ Proposer l'installation globale (optionnel)

## Dépendances optionnelles

Pour activer toutes les fonctionnalités de Tucanos, vous pouvez installer :

- **NLOPT** (pour le lissage de maillage) :
  ```bash
  sudo zypper install nlopt-devel
  ```

- **METIS** (pour le partitionnement de maillage) :
  ```bash
  sudo zypper install metis-devel
  ```

Ces dépendances sont optionnelles. Tucanos se compilera sans elles, mais avec des fonctionnalités réduites.

## Vérification

Après l'installation, vérifiez que tout fonctionne :

```bash
# Vérifier make
make --version

# Vérifier Rust
rustc --version
cargo --version

# Vérifier Tucanos
cd tucanos-main
cargo test --release
```

## Structure après installation

```
/usr/local/bin/make          # make installé
~/.cargo/                    # Rust toolchain
~/.rustup/                   # Rustup
/usr/local/lib/libtucanos.so # Bibliothèque Tucanos (si installation globale)
/usr/local/include/tucanos.h # Headers Tucanos (si installation globale)
```

## Dépannage

### make : command not found
- Vérifiez que gcc est installé : `gcc --version`
- Relancez le script d'installation

### Erreur de compilation Rust
- Vérifiez l'espace disque disponible : `df -h`
- Vérifiez la mémoire : `free -h`
- Compilez avec moins de parallélisme : `cargo build --release -j 2`

### Erreur NLOPT ou METIS
- Ces dépendances sont optionnelles
- Le script compilera Tucanos sans ces fonctionnalités
- Pour les activer, installez-les avec zypper (nécessite connexion internet)

## Support

Pour plus d'informations :
- Documentation Tucanos : https://github.com/tucanos/tucanos
- Documentation Rust : https://www.rust-lang.org/
EOF

# 6. Créer un fichier de vérification
cat > "$PACKAGE_DIR/VERIFIER_PACKAGE.sh" << 'EOF'
#!/bin/bash
# Script de vérification du package offline

echo "=== Vérification du package Tucanos offline ==="

errors=0

# Vérifier les composants
echo "Vérification des composants..."

if [ -d "tucanos-main" ]; then
    echo "✓ Sources Tucanos présentes"
else
    echo "✗ Sources Tucanos manquantes"
    ((errors++))
fi

if [ -d "suse-packages/sources" ]; then
    if [ -f "suse-packages/sources/make-4.3.tar.gz" ] || [ -f "suse-packages/sources/make-4.2.1.tar.gz" ]; then
        echo "✓ Sources make présentes"
    else
        echo "✗ Sources make manquantes"
        ((errors++))
    fi
else
    echo "✗ Dossier suse-packages/sources manquant"
    ((errors++))
fi

if [ -f "install_tucanos_suse15_offline.sh" ]; then
    echo "✓ Script d'installation présent"
    if [ -x "install_tucanos_suse15_offline.sh" ]; then
        echo "✓ Script d'installation exécutable"
    else
        echo "⚠ Script d'installation non exécutable (sera corrigé)"
        chmod +x install_tucanos_suse15_offline.sh
    fi
else
    echo "✗ Script d'installation manquant"
    ((errors++))
fi

if [ -d "rust-offline-package" ]; then
    echo "✓ Package Rust présent"
else
    echo "⚠ Package Rust manquant (Rust doit être déjà installé)"
fi

echo ""
if [ $errors -eq 0 ]; then
    echo "✓ Package complet et prêt pour le transfert !"
    echo ""
    echo "Prochaines étapes :"
    echo "1. Compresser le package : tar czf tucanos-complete-offline.tar.gz tucanos-complete-offline/"
    echo "2. Transférer sur le serveur SUSE 15 SP4"
    echo "3. Extraire : tar xzf tucanos-complete-offline.tar.gz"
    echo "4. Installer : cd tucanos-complete-offline && ./install_tucanos_suse15_offline.sh"
else
    echo "✗ $errors erreur(s) détectée(s)"
    exit 1
fi
EOF

chmod +x "$PACKAGE_DIR/VERIFIER_PACKAGE.sh"

echo ""
echo "✓ Package préparé avec succès dans : $PACKAGE_DIR/"
echo ""
echo "Contenu du package :"
du -sh "$PACKAGE_DIR"
ls -lh "$PACKAGE_DIR"

echo ""
echo "Prochaines étapes :"
echo "1. Vérifier le package : cd $PACKAGE_DIR && ./VERIFIER_PACKAGE.sh"
echo "2. Compresser : tar czf tucanos-complete-offline.tar.gz $PACKAGE_DIR/"
echo "3. Transférer sur SUSE 15 SP4 : scp tucanos-complete-offline.tar.gz user@server:/path/"
echo "4. Sur le serveur : tar xzf tucanos-complete-offline.tar.gz && cd $PACKAGE_DIR"
echo "5. Installer : ./install_tucanos_suse15_offline.sh"







