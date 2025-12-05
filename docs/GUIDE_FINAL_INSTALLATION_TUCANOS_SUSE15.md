# Guide Complet d'Installation de Tucanos sur SUSE 15 SP4 (Hors Ligne)

## 📦 Package Créé avec Succès !

Vous disposez maintenant d'un **package complet offline** pour installer Tucanos sur SUSE 15 SP4 sans connexion internet.

### Contenu du Package

Le package `tucanos-complete-offline-final.zip` (679.3 MB compressé, 734.4 MB décompressé) contient :

```
tucanos-complete-offline-final/
├── tucanos-main/                      # Sources Tucanos (77.4 MB)
├── rust-offline-package/              # Toolchain Rust complet (532.2 MB)
├── suse-packages/                     # Bundle make + GCC sources (124.9 MB)
│   └── sources/
│       ├── make-4.3.tar.gz
│       ├── make-4.2.1.tar.gz
│       ├── gcc-8.5.0.tar.xz
│       └── gcc-7.5.0.tar.xz
├── install_tucanos_suse15_offline.sh  # Script d'installation automatique
├── README_INSTALLATION_COMPLETE.md    # Documentation complète
├── RESUME_PACKAGE.txt                 # Résumé du package
└── VERIFIER_PACKAGE.sh                # Script de vérification
```

---

## 🚀 Installation Rapide (3 étapes)

### Étape 1 : Transférer le Package sur SUSE 15 SP4

**Option A - Via SCP (si réseau disponible) :**
```bash
scp tucanos-complete-offline-final.zip user@server:/home/user/
```

**Option B - Via Clé USB :**
1. Copiez `tucanos-complete-offline-final.zip` sur une clé USB
2. Montez la clé sur le serveur SUSE 15 SP4
3. Copiez le fichier vers `/home/user/`

### Étape 2 : Extraire le Package

```bash
# Se connecter au serveur SUSE 15 SP4
ssh user@server

# Extraire l'archive
unzip tucanos-complete-offline-final.zip

# Accéder au dossier
cd tucanos-complete-offline-final
```

### Étape 3 : Lancer l'Installation

```bash
# Rendre le script exécutable
chmod +x install_tucanos_suse15_offline.sh

# Lancer l'installation automatique
./install_tucanos_suse15_offline.sh
```

Le script va automatiquement :
1. ✅ Vérifier le système (SUSE 15 SP4)
2. ✅ Installer **make** (compilation depuis les sources si absent)
3. ✅ Installer **Rust** (depuis le package offline si absent)
4. ✅ Compiler **Tucanos** avec les fonctionnalités disponibles
5. ✅ Proposer l'installation globale (optionnel)
6. ✅ Exécuter les tests de validation

---

## ⚙️ Prérequis sur le Serveur SUSE 15 SP4

Le serveur doit avoir **au minimum** :

- ✅ **gcc** et **g++** (pour compiler make et les dépendances natives)
- ✅ **tar** et **gzip** (normalement présents par défaut)
- ✅ Accès **sudo** (pour l'installation globale)
- ✅ **~1 GB d'espace disque** libre
- ✅ **~2 GB de RAM** recommandés pour la compilation

### Installer GCC si nécessaire

Si gcc n'est pas disponible sur le serveur :

```bash
# Vérifier si gcc est installé
gcc --version

# Si absent, installer gcc (nécessite connexion internet temporaire)
sudo zypper install gcc gcc-c++
```

**Note :** Si le serveur est complètement hors ligne et gcc n'est pas installé, vous devrez installer gcc via RPM ou depuis les sources.

---

## 📝 Processus d'Installation Détaillé

### Ce que fait le script automatiquement

#### 1. Vérification du Système
```bash
# Le script vérifie :
- Distribution : SUSE Linux Enterprise 15 SP4
- Architecture : x86_64
- Présence de make, gcc, rust
```

#### 2. Installation de make
```bash
# Si make est absent :
- Extraction de make-4.3.tar.gz
- ./configure --prefix=/usr/local
- make && sudo make install
- Création du lien symbolique /usr/bin/make
```

#### 3. Installation de Rust
```bash
# Si Rust est absent :
- Extraction des composants Rust offline
- Installation de rustc, cargo, rust-std
- Configuration de l'environnement (~/.cargo/env)
```

#### 4. Compilation de Tucanos
```bash
# Le script compile Tucanos avec :
- Détection automatique des dépendances (NLOPT, METIS)
- Activation des fonctionnalités disponibles
- Compilation optimisée (--release)
- Tests de validation
```

#### 5. Installation Globale (Optionnel)
```bash
# Si vous choisissez l'installation globale :
sudo cp target/release/libtucanos.so /usr/local/lib/
sudo cp target/release/tucanos.h /usr/local/include/
sudo ldconfig
```

---

## 🔧 Dépendances Optionnelles

Pour activer **toutes les fonctionnalités** de Tucanos :

### NLOPT (pour le lissage de maillage)
```bash
sudo zypper install nlopt-devel
```

### METIS (pour le partitionnement de maillage)
```bash
sudo zypper install metis-devel
```

**📌 Important :** Ces dépendances sont **optionnelles**. Tucanos se compilera sans elles, mais avec des fonctionnalités réduites.

---

## ✅ Vérification Après Installation

### 1. Vérifier make
```bash
make --version
# Attendu : GNU Make 4.3 ou 4.2.1
```

### 2. Vérifier Rust
```bash
rustc --version
# Attendu : rustc 1.89.0 (x86_64-unknown-linux-gnu)

cargo --version
# Attendu : cargo 1.89.0
```

### 3. Vérifier Tucanos
```bash
cd tucanos-main

# Exécuter les tests
cargo test --release

# Vérifier les binaires compilés
ls -lh target/release/
```

### 4. Vérifier l'installation globale (si effectuée)
```bash
ls -lh /usr/local/lib/libtucanos.so
ls -lh /usr/local/include/tucanos.h

# Vérifier que la bibliothèque est bien linkée
ldconfig -p | grep tucanos
```

---

## 📂 Structure Après Installation

```
/usr/local/bin/make                    # make installé
~/.cargo/                              # Rust toolchain
  ├── bin/
  │   ├── rustc
  │   ├── cargo
  │   └── ...
  └── env                              # Variables d'environnement Rust
~/.rustup/                             # Rustup (si installé via rustup)
/usr/local/lib/libtucanos.so          # Bibliothèque Tucanos (si install globale)
/usr/local/include/tucanos.h          # Headers Tucanos (si install globale)
```

---

## 🛠️ Dépannage

### Problème : `make: command not found`

**Solution :**
```bash
# Vérifier que gcc est installé
gcc --version

# Si gcc est absent
sudo zypper install gcc gcc-c++

# Relancer le script d'installation
./install_tucanos_suse15_offline.sh
```

---

### Problème : Erreur de compilation Rust

**Causes possibles :**
- Espace disque insuffisant
- Mémoire insuffisante
- Dépendances manquantes

**Solutions :**
```bash
# Vérifier l'espace disque (minimum 5 GB recommandé)
df -h

# Vérifier la mémoire (minimum 2 GB recommandé)
free -h

# Compiler avec moins de parallélisme
cd tucanos-main
cargo build --release -j 2
```

---

### Problème : Erreur NLOPT ou METIS

**Explication :** Ces dépendances sont optionnelles.

**Solutions :**
1. **Sans connexion internet :** Tucanos se compile sans ces fonctionnalités
2. **Avec connexion internet :** Installer via zypper :
   ```bash
   sudo zypper install nlopt-devel metis-devel
   ```

---

### Problème : Erreur de permissions

**Solution :**
```bash
# Vérifier les permissions
ls -la

# S'assurer d'avoir les droits sudo
sudo -v

# Corriger les permissions du script
chmod +x install_tucanos_suse15_offline.sh
```

---

### Problème : `gcc: error: unrecognized command line option`

**Solution :**
```bash
# Vérifier la version de gcc
gcc --version

# Si gcc est trop ancien (< 5.0), mettre à jour
sudo zypper update gcc gcc-c++
```

---

## 📚 Utilisation de Tucanos

### API C

```c
#include <tucanos.h>

int main() {
    // Votre code ici
    return 0;
}
```

**Compilation :**
```bash
gcc mon_programme.c -ltucanos -o mon_programme
./mon_programme
```

---

### API Python (si bindings compilés)

```python
import pytucanos

# Votre code ici
```

---

### Bibliothèque Partagée

```bash
# Linker avec -ltucanos
gcc mon_code.c -I/usr/local/include -L/usr/local/lib -ltucanos -o mon_app

# Si erreur de chargement
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

---

## 📊 Résumé du Package

| Composant | Taille | Description |
|-----------|--------|-------------|
| **Tucanos sources** | 77.4 MB | Code source complet de Tucanos |
| **Rust offline** | 532.2 MB | Toolchain Rust 1.89.0 |
| **make + GCC sources** | 124.9 MB | Sources pour compilation de make |
| **Scripts** | < 1 MB | Scripts d'installation et documentation |
| **Total (non compressé)** | **734.4 MB** | Package complet |
| **Total (compressé ZIP)** | **679.3 MB** | Archive finale |

---

## 🔗 Ressources et Support

- **Tucanos GitHub :** https://github.com/tucanos/tucanos
- **Documentation Rust :** https://www.rust-lang.org/learn
- **SUSE 15 Docs :** https://documentation.suse.com/
- **Make Manual :** https://www.gnu.org/software/make/manual/

---

## 📋 Checklist d'Installation

- [ ] Package transféré sur SUSE 15 SP4
- [ ] Archive extraite
- [ ] gcc installé (vérifier : `gcc --version`)
- [ ] Script exécutable (`chmod +x install_tucanos_suse15_offline.sh`)
- [ ] Installation lancée (`./install_tucanos_suse15_offline.sh`)
- [ ] make installé (vérifier : `make --version`)
- [ ] Rust installé (vérifier : `rustc --version`)
- [ ] Tucanos compilé (vérifier : `ls tucanos-main/target/release/`)
- [ ] Tests passés (vérifier : `cargo test --release`)
- [ ] Installation globale effectuée (optionnel)

---

## 🎯 Version et Informations

- **Tucanos :** Version main (dernière version)
- **Rust :** 1.89.0
- **Make :** 4.3 / 4.2.1
- **GCC :** 7.5.0 / 8.5.0 (sources pour compilation)
- **Système cible :** SUSE Linux Enterprise Server 15 SP4
- **Architecture :** x86_64

---

## ✨ Félicitations !

Si l'installation s'est bien déroulée, vous disposez maintenant de Tucanos compilé et prêt à l'emploi sur votre serveur SUSE 15 SP4 hors ligne ! 🎉

Pour toute question ou problème, consultez la documentation ou les issues GitHub de Tucanos.

---

**Package créé automatiquement - Installation offline complète pour SUSE 15 SP4**







