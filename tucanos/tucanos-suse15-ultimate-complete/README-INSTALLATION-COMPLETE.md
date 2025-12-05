# 📦 Package COMPLET Hors Ligne - Tucanos pour SUSE 15 SP4

## 🎯 Vue d'ensemble

Ce package contient **TOUT** ce qui est nécessaire pour installer Tucanos sur SUSE Linux Enterprise Server 15 SP4 **sans connexion internet**.

## 📋 Table des matières

- [Contenu du package](#contenu-du-package)
- [Prérequis](#prérequis)
- [Workflow complet](#workflow-complet)
- [Installation détaillée](#installation-détaillée)
- [Dépannage](#dépannage)
- [FAQ](#faq)

---

## 📦 Contenu du package

### ✅ Code source
- Tucanos (bibliothèque de remaillage)
- tmesh (bibliothèque de maillage)
- pytmesh (bindings Python)
- pytucanos (bindings Python)
- tucanos-ffi (interface FFI C)

### ✅ Dépendances système
- Packages RPM SUSE (gcc, python3, make, etc.)
- À télécharger avec `download-rpm-dependencies.sh`

### ✅ Rust complet
- rustup-init
- Toolchain complète (optionnel)
- Vendor cargo (toutes les crates)

### ✅ Packages Python
- maturin 1.9.5
- numpy 2.3.3
- setuptools 80.9.0
- wheel 0.45.1

### ✅ Sources externes
- cmake 3.28.1
- METIS (master)
- NLOPT 2.7.1

### ✅ Scripts et documentation
- Scripts de téléchargement
- Scripts d'installation
- Documentation complète

---

## 🔧 Prérequis

### Sur la machine de préparation (avec internet)
- **OS**: SUSE Linux Enterprise Server 15 SP4 (recommandé)
- **Accès**: Internet
- **Espace disque**: ~5-10 GB
- **Droits**: sudo pour zypper

### Sur la machine cible (hors ligne)
- **OS**: SUSE Linux Enterprise Server 15 SP4
- **Accès**: Aucun (hors ligne total)
- **Espace disque**: ~5 GB pour installation
- **Droits**: sudo pour installer les packages RPM

---

## 🚀 Workflow complet

### Phase A: Préparation (machine avec internet)

```bash
# 1. Se placer dans le dossier du package
cd tucanos-suse15-ultimate-complete

# 2. Télécharger TOUTES les dépendances (recommandé)
chmod +x prepare-complete-offline-package.sh
./prepare-complete-offline-package.sh
```

**OU télécharger séparément:**

```bash
# Télécharger les packages RPM (sur SUSE 15 avec zypper)
chmod +x download-rpm-dependencies.sh
./download-rpm-dependencies.sh

# Télécharger Rust complet et vendor
chmod +x download-rust-complete.sh
./download-rust-complete.sh
```

### Phase B: Transfert

```bash
# 1. Créer une archive du package complet
cd ..
tar czf tucanos-suse15-offline-complete.tar.gz tucanos-suse15-ultimate-complete/

# 2. Transférer sur la machine cible
#    - USB
#    - Réseau interne
#    - DVD
#    - etc.
```

### Phase C: Installation (machine hors ligne)

```bash
# 1. Décompresser
tar xzf tucanos-suse15-offline-complete.tar.gz
cd tucanos-suse15-ultimate-complete

# 2. Installer (version améliorée recommandée)
chmod +x install-complete-offline-improved.sh
./install-complete-offline-improved.sh

# 3. Installer les bibliothèques système et Python
cd tucanos-install
sudo ./install-system.sh     # Installation système (nécessite sudo)
./install-python.sh          # Installation Python (utilisateur)

# 4. Tester
./test-installation.sh
```

---

## 📖 Installation détaillée

### Étape 1: Préparation des dépendances

#### Option 1: Tout en une fois (RECOMMANDÉ)

```bash
./prepare-complete-offline-package.sh
```

Ce script va:
1. Télécharger ~50-100 packages RPM système
2. Télécharger Rust complet
3. Créer le vendor cargo (toutes les crates)
4. Vérifier l'intégrité du package
5. Créer un fichier `PACKAGE-READY.txt`

**Durée estimée**: 15-30 minutes

#### Option 2: Étape par étape

##### A. Packages RPM système

```bash
./download-rpm-dependencies.sh
```

Télécharge:
- gcc, gcc-c++, make, cmake
- python3, python3-devel, python3-pip
- glibc-devel, libstdc++, zlib, openssl
- BLAS, LAPACK
- Et toutes leurs dépendances

**Note**: Ce script DOIT être exécuté sur SUSE 15 car il utilise `zypper`.

##### B. Rust complet avec vendor

```bash
./download-rust-complete.sh
```

Télécharge:
- rustup-init
- Toolchain Rust stable complète
- **Toutes les crates** nécessaires (vendor)
- cargo-binstall (optionnel)

**Important**: Le vendor contient toutes les dépendances Cargo. L'installation hors ligne ne nécessitera AUCUN téléchargement depuis crates.io.

### Étape 2: Vérification du package

Avant de transférer, vérifiez:

```bash
# Vérifier les RPM
ls -lh dependencies/system/*.rpm | wc -l
# Doit afficher ~50-100 packages

# Vérifier le vendor
ls -d vendor/*/ | wc -l
# Doit afficher plusieurs centaines de crates

# Vérifier les wheels Python
ls dependencies/python/python/*.whl
# Doit afficher 4 fichiers

# Consulter le résumé
cat PACKAGE-READY.txt
```

### Étape 3: Transfert

```bash
# Créer l'archive
tar czf tucanos-offline.tar.gz tucanos-suse15-ultimate-complete/

# Vérifier la taille
ls -lh tucanos-offline.tar.gz
# Attendu: 1-3 GB selon le contenu
```

Méthodes de transfert:
- **USB**: Copier directement
- **SCP**: `scp tucanos-offline.tar.gz user@target:/tmp/`
- **Réseau local**: Serveur HTTP/FTP temporaire
- **DVD**: Graver l'archive

### Étape 4: Installation hors ligne

Sur la machine cible (SUSE 15 SP4 hors ligne):

```bash
# Décompresser
tar xzf tucanos-offline.tar.gz
cd tucanos-suse15-ultimate-complete

# Lancer l'installation complète
chmod +x install-complete-offline-improved.sh
./install-complete-offline-improved.sh
```

Le script va:
1. ✅ Installer les packages RPM système
2. ✅ Vérifier les outils (gcc, make, python, etc.)
3. ✅ Installer Rust localement
4. ✅ Configurer cargo en mode vendor (offline)
5. ✅ Installer les packages Python
6. ✅ Compiler Tucanos avec cargo (mode offline)
7. ✅ Compiler pytmesh et pytucanos
8. ✅ Créer le package d'installation final

**Durée estimée**: 20-40 minutes

### Étape 5: Installation finale

```bash
cd tucanos-install

# Installation système (nécessite sudo)
sudo ./install-system.sh
# Installe libtucanos.so dans /usr/local/lib
# Installe tucanos.h dans /usr/local/include

# Installation Python (utilisateur)
./install-python.sh
# Installe pytmesh et pytucanos dans ~/.local

# Test
./test-installation.sh
```

### Étape 6: Vérification

```bash
# Test Python
python3 -c "import pytmesh, pytucanos; print('OK')"

# Test bibliothèque
ldconfig -p | grep tucanos

# Test FFI (si vous développez en C)
pkg-config --libs tucanos || echo "Créer tucanos.pc si nécessaire"
```

---

## 🔍 Dépannage

### Problème: "Package RPM xxx already installed"

**Solution**: Normal, ignorez ces messages. Les packages déjà présents ne sont pas réinstallés.

### Problème: "METIS non trouvé"

**Options**:
1. Compiler METIS manuellement:
```bash
cd dependencies/sources
tar xzf metis-master.tar.gz
cd metis-master
make config prefix=/usr/local
make
sudo make install
```

2. Compiler Tucanos sans METIS (non recommandé):
```bash
# Éditer le script et retirer --features metis
```

### Problème: "cargo failed to download crates"

**Cause**: Le vendor n'a pas été correctement préparé.

**Solution**:
1. Sur la machine de préparation, exécuter:
```bash
./download-rust-complete.sh
```

2. Vérifier que `vendor/` contient des dossiers

3. Vérifier que `.cargo/config.toml.vendor` existe

### Problème: "pip3 command not found"

**Solution**:
```bash
# Installer depuis les RPM
sudo rpm -ivh dependencies/system/python3*.rpm
```

### Problème: "maturin not found"

**Solution**:
```bash
# Ajouter ~/.local/bin au PATH
export PATH="$HOME/.local/bin:$PATH"

# Réinstaller maturin
pip3 install --user --force-reinstall dependencies/python/python/maturin*.whl
```

### Problème: Compilation Rust échoue avec "network error"

**Cause**: Le mode vendor n'est pas activé.

**Solution**:
```bash
# Vérifier la config cargo
cat .cargo/config.toml

# Doit contenir:
# [source.crates-io]
# replace-with = "vendored-sources"

# Si absent, copier:
cp .cargo/config.toml.vendor .cargo/config.toml
```

### Problème: "error: no override and no default toolchain set"

**Solution**:
```bash
# Réinstaller Rust
dependencies/rust/rustup-init -y
source ~/.cargo/env
```

---

## ❓ FAQ

### Q: Puis-je préparer le package sur Ubuntu/Debian au lieu de SUSE?

**R**: Pour les packages RPM, NON. Vous devez utiliser SUSE pour `zypper download`. Cependant, pour Rust et Python, vous pouvez préparer sur n'importe quel Linux.

### Q: Quelle est la taille totale du package?

**R**: 
- Sans vendor: ~500 MB
- Avec vendor: ~1.5-3 GB
- Après compilation: ~5 GB

### Q: Puis-je installer sans sudo?

**R**: 
- Les packages RPM nécessitent sudo
- Rust et Python peuvent s'installer en utilisateur normal
- L'installation système (`install-system.sh`) nécessite sudo

### Q: Le package fonctionne-t-il sur SUSE 15 SP3 ou SP5?

**R**: 
- SP3: Probablement oui
- SP5: Probablement oui
- Autres versions: Non garanti, testez d'abord

### Q: Combien de temps prend l'installation complète?

**R**:
- Préparation (avec internet): 15-30 min
- Transfert: Variable (USB ~10 min, réseau variable)
- Installation (hors ligne): 20-40 min
- **Total: 1-2 heures**

### Q: Que faire si un package RPM est corrompu?

**R**:
```bash
# Vérifier l'intégrité
rpm -K dependencies/system/*.rpm

# Retélécharger un package spécifique
zypper download --download-only nom_du_package
```

### Q: Puis-je mettre à jour Tucanos plus tard?

**R**: Oui, remplacez juste le code source et recompilez. Les dépendances système et Rust peuvent rester.

---

## 📚 Fichiers de référence

| Fichier | Description |
|---------|-------------|
| `prepare-complete-offline-package.sh` | Script master (préparation) |
| `download-rpm-dependencies.sh` | Télécharge les RPM SUSE |
| `download-rust-complete.sh` | Télécharge Rust + vendor |
| `install-complete-offline-improved.sh` | Installation complète (version améliorée) |
| `install-complete-offline.sh` | Installation complète (version originale) |
| `PACKAGE-READY.txt` | Vérification du package (généré) |
| `dependencies/system/PACKAGES-LIST.txt` | Liste des RPM (généré) |
| `dependencies/rust/RUST-INFO.txt` | Info Rust (généré) |

---

## 🎉 Résumé rapide

### Pour préparer (machine avec internet):

```bash
./prepare-complete-offline-package.sh
tar czf tucanos-offline.tar.gz .
```

### Pour installer (machine hors ligne):

```bash
tar xzf tucanos-offline.tar.gz
cd tucanos-suse15-ultimate-complete
./install-complete-offline-improved.sh
cd tucanos-install
sudo ./install-system.sh && ./install-python.sh
./test-installation.sh
```

---

## 📞 Support

- **Documentation**: Ce fichier
- **Issues GitHub**: https://github.com/tucanos/tucanos/issues
- **Licence**: LGPL-2.1

---

**Dernière mise à jour**: 2025-10-07

**Version du package**: SUSE 15 SP4 Complete Offline

