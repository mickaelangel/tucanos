# 🚀 Tucanos - Package Complet pour SUSE 15 SP4 (Installation Hors Ligne)

[![Licence](https://img.shields.io/badge/licence-LGPL--2.1-blue.svg)](LICENSE)
[![SUSE](https://img.shields.io/badge/SUSE-15%20SP4-green.svg)]()
[![Offline](https://img.shields.io/badge/Installation-100%25%20Hors%20Ligne-orange.svg)]()

Package complet pour installer **Tucanos** sur SUSE Linux Enterprise Server 15 SP4 sans connexion internet.

---

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Démarrage rapide](#démarrage-rapide)
- [Documentation](#documentation)
- [Résolution de problèmes](#résolution-de-problèmes)
- [Structure du projet](#structure-du-projet)
- [Contribution](#contribution)

---

## 🎯 Vue d'ensemble

Ce package contient **tout** ce qui est nécessaire pour installer Tucanos hors ligne :

- ✅ Code source complet (tmesh, tucanos, pytmesh, pytucanos)
- ✅ Scripts de préparation et d'installation
- ✅ Dépendances Python (maturin, numpy, setuptools, wheel)
- ✅ Sources externes (cmake, METIS, NLOPT)
- ✅ Documentation complète
- ⚠️ Packages RPM système (à télécharger)
- ⚠️ Rust complet + vendor (à télécharger)

---

## ⚡ Démarrage rapide

### 1️⃣ Préparation (sur machine avec internet)

```bash
# Télécharger toutes les dépendances
chmod +x prepare-complete-offline-package.sh
./prepare-complete-offline-package.sh
```

**Durée** : 20-30 minutes

### 2️⃣ Transfert

```bash
# Créer l'archive
cd ..
tar czf tucanos-offline.tar.gz tucanos-suse15-ultimate-complete/

# Transférer sur SUSE 15 SP4 (USB, réseau, etc.)
```

### 3️⃣ Installation (sur SUSE 15 SP4 hors ligne)

```bash
# Décompresser
tar xzf tucanos-offline.tar.gz
cd tucanos-suse15-ultimate-complete

# Installer
chmod +x install-complete-offline-improved.sh
./install-complete-offline-improved.sh

# Finaliser
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh
```

**Durée** : 30-40 minutes

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[GUIDE-DEMARRAGE-RAPIDE.md](GUIDE-DEMARRAGE-RAPIDE.md)** | ⭐ Commencer ici - Installation en 5 minutes |
| **[README-INSTALLATION-COMPLETE.md](README-INSTALLATION-COMPLETE.md)** | Guide complet avec FAQ et dépannage |
| **[SOLUTIONS-TELECHARGEMENT-RPM.md](SOLUTIONS-TELECHARGEMENT-RPM.md)** | Problèmes de téléchargement RPM/NLOPT |
| **[AIDE-RAPIDE-RPM-NLOPT.txt](AIDE-RAPIDE-RPM-NLOPT.txt)** | Aide rapide format texte |
| **[NOUVEAUX-SCRIPTS-CREES.md](NOUVEAUX-SCRIPTS-CREES.md)** | Description des scripts |
| **[GIT-SETUP.md](GIT-SETUP.md)** | Configuration Git local |

---

## 🔧 Résolution de problèmes

### Problème : "Je n'arrive pas à télécharger les packages RPM"

**Solution** : Utilisez le script alternatif

```bash
chmod +x download-rpm-alternative.sh
./download-rpm-alternative.sh
```

Consultez **[SOLUTIONS-TELECHARGEMENT-RPM.md](SOLUTIONS-TELECHARGEMENT-RPM.md)** pour plus de détails.

### Problème : "NLOPT introuvable"

**Solution** : Compilez depuis les sources (déjà incluses)

```bash
# Sur la machine cible
chmod +x compile-nlopt-from-source.sh
./compile-nlopt-from-source.sh
```

### Plus de solutions

Consultez la section **Dépannage** de **[README-INSTALLATION-COMPLETE.md](README-INSTALLATION-COMPLETE.md)**

---

## 📁 Structure du projet

```
tucanos-suse15-ultimate-complete/
├── 📜 Scripts de préparation
│   ├── prepare-complete-offline-package.sh    ⭐ Script master
│   ├── download-rpm-dependencies.sh           Télécharge RPM
│   ├── download-rpm-alternative.sh            Alternative RPM
│   ├── download-rust-complete.sh              Télécharge Rust+vendor
│   └── compile-nlopt-from-source.sh           Compile NLOPT
│
├── 🔧 Scripts d'installation
│   ├── install-complete-offline-improved.sh   ⭐ Installation (améliorée)
│   └── install-complete-offline.sh            Installation (originale)
│
├── 📚 Documentation
│   ├── README.md                              Ce fichier
│   ├── GUIDE-DEMARRAGE-RAPIDE.md             Démarrage rapide
│   ├── README-INSTALLATION-COMPLETE.md        Guide complet
│   ├── SOLUTIONS-TELECHARGEMENT-RPM.md        Solutions téléchargement
│   ├── AIDE-RAPIDE-RPM-NLOPT.txt             Aide rapide
│   ├── NOUVEAUX-SCRIPTS-CREES.md             Description scripts
│   ├── SOMMAIRE-PACKAGE.txt                   Vue d'ensemble
│   └── GIT-SETUP.md                           Configuration Git
│
├── 📦 Dépendances
│   ├── dependencies/
│   │   ├── python/python/                     4 wheels Python
│   │   ├── rust/                              rustup-init (+ à télécharger)
│   │   ├── sources/                           cmake, METIS, NLOPT
│   │   └── system/                            Packages RPM (à télécharger)
│   └── vendor/                                Crates Cargo (à générer)
│
├── 💻 Code source
│   ├── tmesh/                                 Bibliothèque de maillage
│   ├── tucanos/                               Bibliothèque principale
│   ├── tucanos-ffi/                           Interface FFI C
│   ├── pytmesh/                               Bindings Python
│   └── pytucanos/                             Bindings Python
│
└── ⚙️ Configuration
    ├── Cargo.toml                             Workspace Rust
    ├── rust-toolchain.toml                    Version Rust
    ├── .gitignore                             Configuration Git
    ├── .gitattributes                         Attributs Git
    └── LICENSE                                Licence LGPL-2.1
```

---

## 🎯 Scripts disponibles

| Script | Fonction | Où l'exécuter |
|--------|----------|---------------|
| `prepare-complete-offline-package.sh` | ⭐ Fait tout automatiquement | SUSE 15 + Internet |
| `download-rpm-dependencies.sh` | Télécharge les RPM | SUSE 15 + Internet |
| `download-rpm-alternative.sh` | Alternative RPM (4 méthodes) | N'importe où |
| `download-rust-complete.sh` | Télécharge Rust + vendor | Linux + Internet |
| `compile-nlopt-from-source.sh` | Compile NLOPT | Machine cible |
| `install-complete-offline-improved.sh` | ⭐ Installation complète | SUSE 15 hors ligne |

---

## 🔍 Vérification du package

```bash
# Compter les composants
ls dependencies/system/*.rpm 2>/dev/null | wc -l    # RPM
ls dependencies/python/python/*.whl                  # Python wheels
ls -d vendor/*/ 2>/dev/null | wc -l                 # Crates

# Taille totale
du -sh .

# Consulter le résumé (après préparation)
cat PACKAGE-READY.txt
```

---

## 🌐 Configuration Git

Ce projet est prêt pour Git. Consultez **[GIT-SETUP.md](GIT-SETUP.md)** pour :

- Initialiser un dépôt Git local
- Configurer un dépôt distant
- Gérer les fichiers volumineux
- Bonnes pratiques Git

**Commandes rapides** :

```bash
# Initialiser Git
git init
git add .
git commit -m "Initial commit: Package Tucanos SUSE 15 SP4"

# Avec dépôt distant
git remote add origin http://votre-git-local.com/tucanos.git
git push -u origin main
```

---

## 🤝 Contribution

### Améliorer le package

1. Clonez le dépôt
2. Créez une branche : `git checkout -b amelioration-xxx`
3. Faites vos modifications
4. Testez sur SUSE 15 SP4
5. Committez : `git commit -m "Amélioration: xxx"`
6. Poussez : `git push origin amelioration-xxx`

### Rapporter des bugs

Documentez :
- Système d'exploitation (version exacte)
- Commande exécutée
- Erreur complète
- Fichiers de log

---

## 📊 Statistiques

- **Lignes de code documentation** : ~3000+
- **Scripts shell** : 6
- **Guides** : 7
- **Taille package complet** : ~2-3 GB
- **Temps installation total** : 1-2 heures

---

## 📞 Support

- **Documentation locale** : Consultez les fichiers .md dans ce dépôt
- **Tucanos officiel** : https://github.com/tucanos/tucanos
- **Issues** : https://github.com/tucanos/tucanos/issues

---

## 📄 Licence

Ce package est distribué sous licence **LGPL-2.1** (même licence que Tucanos).

Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🎉 Remerciements

- **Tucanos** - https://github.com/tucanos/tucanos
- **METIS** - http://glaros.dtc.umn.edu/gkhome/metis/metis/overview
- **NLOPT** - https://github.com/stevengj/nlopt
- **Rust** - https://www.rust-lang.org/
- **Python Maturin** - https://github.com/PyO3/maturin

---

## 🚀 Version

**Package** : v2.0  
**Date** : 2025-10-07  
**Tucanos** : Compatible avec la version courante  
**SUSE** : 15 SP4 (compatible SP3, SP5)

---

**Prêt pour une installation hors ligne à 100% !** 🎯

Pour commencer : **[GUIDE-DEMARRAGE-RAPIDE.md](GUIDE-DEMARRAGE-RAPIDE.md)**