# 📦 Installation Hors Ligne - Tucanos pour SUSE 15 SP4

## 🎯 Guide d'installation rapide

Ce package contient **TOUT** ce dont vous avez besoin pour installer Tucanos sur un serveur SUSE 15 SP4 **sans connexion internet**.

---

## 📋 Contenu du package

✅ **Code source complet** de Tucanos  
✅ **45 packages RPM** système (gcc, python3, make, etc.)  
✅ **Toolchain Rust complète** (558 MB)  
✅ **67 crates cargo** (dépendances Rust)  
✅ **4 wheels Python** (maturin, numpy, setuptools, wheel)  
✅ **Sources externes** (cmake, METIS, NLOPT)  
✅ **Scripts d'installation automatisés**  
✅ **Documentation complète**

**Taille totale** : ~1-1.5 GB (compressé)

---

## 🚀 Installation en 3 étapes

### Étape 1️⃣ : Transférer l'archive sur le serveur SUSE 15 SP4

```bash
# Sur la machine source (Windows/Linux)
# L'archive se trouve dans: C:\Users\mickaelangel\Desktop\Nouveau dossier\

# Transférer via USB, SCP, ou réseau interne
scp tucanos-suse15-offline-complete.tar.gz user@serveur-suse:/tmp/
```

### Étape 2️⃣ : Décompresser et lancer l'installation

```bash
# Sur le serveur SUSE 15 SP4 (hors ligne)
cd /tmp
tar xzf tucanos-suse15-offline-complete.tar.gz
cd tucanos-suse15-ultimate-complete

# Rendre le script exécutable
chmod +x install-offline-suse15.sh

# Lancer l'installation complète (20-40 minutes)
./install-offline-suse15.sh
```

Le script va automatiquement :
- ✅ Installer les 45 packages RPM système
- ✅ Installer Rust (toolchain complète)
- ✅ Configurer cargo en mode offline
- ✅ Installer les packages Python
- ✅ Compiler METIS et NLOPT
- ✅ Compiler Tucanos (bibliothèque Rust)
- ✅ Compiler pytmesh et pytucanos (bindings Python)
- ✅ Créer le package d'installation final

### Étape 3️⃣ : Finaliser l'installation

```bash
# Aller dans le dossier d'installation final
cd tucanos-install

# Installation système (nécessite sudo)
sudo ./install-system.sh

# Installation Python (utilisateur)
./install-python.sh

# Tester l'installation
./test-installation.sh
```

---

## ✅ Vérification de l'installation

```bash
# Test rapide Python
python3 -c "import pytmesh, pytucanos; print('✓ Tucanos installé avec succès !')"

# Vérifier la bibliothèque système
ldconfig -p | grep tucanos

# Test détaillé
cd tucanos-install
./test-installation.sh
```

---

## 📁 Structure du package

```
tucanos-suse15-ultimate-complete/
├── install-offline-suse15.sh          ⭐ SCRIPT PRINCIPAL
├── INSTALLATION-HORS-LIGNE.md         📖 Ce fichier
│
├── dependencies/
│   ├── system/                        📦 6 RPM de base
│   ├── repo-sle-update/               📦 38 RPM supplémentaires
│   │   ├── x86_64/                    (32 RPM)
│   │   └── noarch/                    (6 RPM)
│   ├── python/python/                 🐍 4 wheels Python
│   ├── rust/                          🦀 Rust complet
│   │   ├── rust-1.89.0-*.tar.gz       (363 MB)
│   │   ├── rustc-1.89.0-*.tar.gz      (130 MB)
│   │   ├── rust-std-1.89.0-*.tar.gz   (51 MB)
│   │   ├── cargo-1.89.0-*.tar.gz      (14 MB)
│   │   ├── rustup-init                (28 KB)
│   │   ├── cargo-dependencies/        📚 67 fichiers .crate
│   │   └── install_rust_offline.sh
│   └── sources/                       📚 Sources externes
│       ├── cmake-3.28.1-*.tar.gz      (52 MB)
│       ├── metis-master.tar.gz        (4.8 MB)
│       └── nlopt-2.7.1.tar.gz         (2 MB)
│
├── tucanos/                           💎 Code source Tucanos
├── tmesh/                             💎 Code source tmesh
├── pytmesh/                           🐍 Bindings Python tmesh
├── pytucanos/                         🐍 Bindings Python tucanos
├── tucanos-ffi/                       🔧 Interface FFI C
│
└── [Documentation complète]
    ├── GUIDE-DEMARRAGE-RAPIDE.md
    ├── README-INSTALLATION-COMPLETE.md
    ├── SOMMAIRE-PACKAGE.txt
    └── ...
```

---

## ⏱️ Temps d'installation estimés

| Étape | Durée |
|-------|-------|
| Transfert de l'archive | 5-30 min (selon méthode) |
| Décompression | 2-5 min |
| Installation automatique | 20-40 min |
| Installation finale | 2-5 min |
| **TOTAL** | **30-80 minutes** |

---

## 🔧 Que fait le script d'installation ?

Le script `install-offline-suse15.sh` effectue les étapes suivantes :

### Phase 1 : Préparation
- ✅ Vérification du dossier et des fichiers
- ✅ Création des dossiers temporaires

### Phase 2 : Dépendances système
- ✅ Installation de 45 packages RPM (gcc, python3, make, etc.)
- ✅ Installation depuis `dependencies/system/` et `dependencies/repo-sle-update/`

### Phase 3 : Rust
- ✅ Installation de la toolchain Rust complète (1.89.0)
- ✅ Configuration de `$CARGO_HOME` et `$RUSTUP_HOME`
- ✅ Copie des 67 fichiers .crate dans le registre cargo local
- ✅ Configuration cargo pour mode offline

### Phase 4 : Python
- ✅ Installation des 4 wheels (maturin, numpy, setuptools, wheel)
- ✅ Vérification de maturin dans `~/.local/bin`

### Phase 5 : Bibliothèques externes
- ✅ Compilation et installation de METIS (si sources disponibles)
- ✅ Compilation et installation de NLOPT (si sources disponibles)
- ✅ Extraction de cmake si nécessaire

### Phase 6 : Compilation Tucanos
- ✅ Compilation de la bibliothèque Rust avec features (metis, nlopt)
- ✅ Génération de `libtucanos_ffi.so`

### Phase 7 : Bindings Python
- ✅ Compilation de pytmesh avec maturin
- ✅ Compilation de pytucanos avec maturin
- ✅ Génération des wheels Python

### Phase 8 : Package final
- ✅ Création de `tucanos-install/`
- ✅ Copie des bibliothèques, headers, et wheels
- ✅ Génération des scripts d'installation finaux
- ✅ Nettoyage des fichiers temporaires

---

## 📊 Espace disque requis

- Archive compressée : **~1-1.5 GB**
- Archive décompressée : **~2-3 GB**
- Pendant la compilation : **~5-6 GB** (temporaire)
- Après installation : **~3-4 GB**
- Installation finale : **~100-200 MB** (dans /usr/local et ~/.local)

**Recommandation** : Au moins **10 GB d'espace libre** sur le serveur

---

## ❓ Dépannage

### Problème : "rpm command not found"
**Solution** : Le serveur n'est pas SUSE/RHEL. Ce package est spécifique à SUSE 15 SP4.

### Problème : "Permission denied" lors de l'installation RPM
**Solution** : Certaines étapes nécessitent sudo. Assurez-vous d'avoir les droits sudo.

### Problème : "cargo failed to fetch crate"
**Solution** : Le script essaie d'abord en mode offline, puis en mode normal. Si vous voyez cet avertissement, c'est normal.

### Problème : "maturin: command not found"
**Solution** : 
```bash
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc
```

### Problème : Compilation échoue avec "gcc not found"
**Solution** : Vérifiez que les RPM sont installés :
```bash
rpm -qa | grep gcc
```

### Problème : "python3: No module named pip"
**Solution** : Installez depuis les RPM :
```bash
sudo rpm -ivh dependencies/system/python3*.rpm
```

### Problème : Test Python échoue "ImportError: cannot import pytmesh"
**Solution** : Réinstallez les wheels :
```bash
cd tucanos-install
./install-python.sh
```

---

## 📞 Support

- **Documentation locale** : Consultez les fichiers README*.md dans ce dossier
- **Logs** : En cas d'erreur, consultez :
  - `build.log` (compilation Tucanos)
  - `pytmesh-build.log` (compilation pytmesh)
  - `pytucanos-build.log` (compilation pytucanos)

---

## 🎉 Après l'installation

### Utilisation Python

```python
import pytmesh
import pytucanos

# Charger un maillage
mesh = pytmesh.Mesh()

# Utiliser Tucanos
# ... votre code ...
```

### Utilisation C/C++

```c
#include <tucanos.h>

// Votre code C/C++
// Compiler avec: gcc -o mon_programme mon_programme.c -ltucanos_ffi
```

### Configuration PATH (optionnel)

Ajoutez à votre `~/.bashrc` :

```bash
export PATH="$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
```

---

## 📝 Résumé des commandes

```bash
# Sur le serveur SUSE 15 SP4 (hors ligne)

# 1. Décompresser
tar xzf tucanos-suse15-offline-complete.tar.gz
cd tucanos-suse15-ultimate-complete

# 2. Installation complète
chmod +x install-offline-suse15.sh
./install-offline-suse15.sh

# 3. Installation finale
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh

# 4. Test
python3 -c "import pytmesh, pytucanos; print('✓ OK')"
```

---

## 📅 Informations

- **Version** : SUSE 15 SP4 Complete Offline Package
- **Date** : 2025-10-09
- **Rust** : 1.89.0
- **Python** : 3.x (fourni par SUSE 15)
- **Licence** : LGPL-2.1

---

## ✨ Fonctionnalités incluses

- ✅ Support METIS (partitionnement de maillage)
- ✅ Support NLOPT (optimisation)
- ✅ Interface FFI C
- ✅ Bindings Python complets
- ✅ Installation 100% hors ligne
- ✅ Scripts automatisés

---

**Bonne installation ! 🚀**

Pour toute question, consultez la documentation complète dans les fichiers README*.md



