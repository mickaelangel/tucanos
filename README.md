# 🦏 Tucanos - Package d'Installation Offline pour SUSE 15 SP4

Package complet d'installation offline de **Tucanos** pour SUSE Linux Enterprise Server 15 SP4.

## 🎯 Qu'est-ce que Tucanos ?

**Tucanos** est une bibliothèque Rust moderne et performante pour l'adaptation de maillage anisotrope en 2D et 3D, spécialement conçue pour les simulations numériques spatio-temporelles. Elle fournit des outils avancés pour :

- ✅ **Adaptation de maillage anisotrope** basée sur des métriques (feature-based, geometry-based, mesh-implied)
- ✅ **Remaillage adaptatif** pour optimiser la qualité et la résolution
- ✅ **Opérations sur maillages** : création, partitionnement, manipulation 2D/3D
- ✅ **APIs multi-langages** : Rust (natif), Python (`pytucanos`, `pytmesh`), C (FFI)

Tucanos est particulièrement adapté pour les simulations CFD, éléments finis, et toute application nécessitant une adaptation dynamique du maillage.

📖 **Voir [DESCRIPTION_TUCANOS.md](DESCRIPTION_TUCANOS.md) pour une description complète.**

## 📋 Description

Ce projet contient tous les outils et scripts nécessaires pour installer Tucanos sur un système SUSE 15 SP4 **sans connexion internet**. Le package inclut :

- ✅ **Tucanos** (sources complètes)
- ✅ **Rust 1.89.0** (toolchain complet offline)
- ✅ **Dépendances Rust vendorisées** (231 packages)
- ✅ **Dépendances GitHub** (coupe, metis-rs, minimeshb)
- ✅ **Sources make et gcc** (pour compilation)
- ✅ **METIS et NLOPT** (optionnels, nécessitent g++)

## 🚀 Installation Rapide

### Sur le serveur SUSE 15 SP4

```bash
# 1. Extraire le package
unzip tucanos-complete-offline-final.zip
cd tucanos-complete-offline-final

# 2. Lancer l'installation (1 seule commande)
bash install_tucanos_offline.sh
```

Le script installe automatiquement :
- make (si nécessaire)
- Rust (si nécessaire)
- Tucanos (compilation 100% offline)
- METIS et NLOPT (si g++ disponible)

## 📁 Structure du Projet

```
tucanos/
├── README.md                          # Ce fichier
├── .gitignore                         # Exclusions Git
│
├── Nouveau dossier/                   # Dossier principal de travail
│   ├── install_tucanos_offline.sh    # Script d'installation principal
│   ├── LIRE_MOI_INSTALLATION.md      # Guide d'installation détaillé
│   ├── RECAPITULATIF_FINAL.md        # Récapitulatif du package
│   │
│   ├── tucanos-main/                 # Sources Tucanos
│   ├── cargo-vendor/                 # Dépendances Rust (.crate)
│   ├── rust-offline-package/         # Toolchain Rust offline
│   ├── suse-packages/                # Sources make et gcc
│   └── suse-packages-optional/       # METIS et NLOPT
│
└── [scripts PowerShell]              # Scripts de création du package
```

## 📦 Création du Package Offline

### Prérequis (sur machine Windows avec internet)

- PowerShell
- Git
- ~2 GB d'espace disque

### Étapes

1. **Télécharger les dépendances Rust** :
   ```powershell
   cd "Nouveau dossier"
   .\creer_package_complet_tucanos.ps1
   ```

2. **Créer l'archive finale** :
   ```powershell
   .\comprimer_package.ps1
   ```

3. **Transférer sur le serveur SUSE 15 SP4** :
   - Via SCP : `scp tucanos-complete-offline-final.zip user@server:/home/user/`
   - Via clé USB

## 📚 Documentation

- **[LIRE_MOI_INSTALLATION.md](Nouveau%20dossier/LIRE_MOI_INSTALLATION.md)** - Guide d'installation complet
- **[RECAPITULATIF_FINAL.md](Nouveau%20dossier/RECAPITULATIF_FINAL.md)** - Récapitulatif technique
- **[COMMENT_CA_MARCHE_VRAIMENT.md](Nouveau%20dossier/COMMENT_CA_MARCHE_VRAIMENT.md)** - Explication du système

## ⚙️ Prérequis Système (SUSE 15 SP4)

### Obligatoires
- ✅ **gcc** (normalement préinstallé)
- ✅ **tar**, **gzip**, **unzip**

### Optionnels (pour METIS/NLOPT)
- ⚠️ **g++** (gcc-c++) : `sudo zypper install gcc-c++`

## ✅ Vérification de l'Installation

```bash
# Vérifier Tucanos
ls -lh ~/.local/lib/libtucanos.so

# Vérifier METIS
gpmetis --help

# Vérifier NLOPT
pkg-config --modversion nlopt

# Activer l'environnement
source ~/.bashrc
```

## 🔧 Fonctionnalités

- ✅ **Installation 100% offline** - Aucune connexion internet requise
- ✅ **Installation sans sudo** - Tout installé dans `~/.local/`
- ✅ **Détection automatique** - Détecte g++ pour METIS/NLOPT
- ✅ **Scripts automatisés** - Installation en une seule commande

## 📊 Taille du Package

- **Archive compressée** : ~679-717 MB (ZIP)
- **Package décompressé** : ~734 MB
- **Contenu** : Sources + Toolchain + Dépendances + Scripts

## 🛠️ Dépannage

### Erreur : "g++ not found"
**Solution** : C'est normal si g++ n'est pas installé. Tucanos fonctionne sans METIS/NLOPT.

### Erreur : "cargo build failed"
**Causes possibles** :
1. Espace disque insuffisant : `df -h`
2. cargo-vendor incomplet : Vérifiez `ls -la cargo-vendor/`

### Erreur : "Permission denied"
**Solution** : N'utilisez PAS sudo avec le script d'installation.

## 📝 Notes Importantes

- Le package **exclut** les gros fichiers (ZIP, vendor packages) du dépôt Git
- Seuls les **scripts et la documentation** sont versionnés
- Les packages complets doivent être créés localement avec les scripts PowerShell

## 🔗 Liens Utiles

- **Tucanos GitHub** : https://github.com/tucanos/tucanos
- **Documentation officielle** : Voir les fichiers .md dans `Nouveau dossier/`

## 📄 Licence

Voir les licences respectives de chaque composant (Tucanos, Rust, METIS, NLOPT).

---

**Package généré pour installation offline complète sur SUSE 15 SP4** 🚀


