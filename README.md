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

## 📋 Contenu du Dépôt

Ce dépôt contient tous les **scripts, documentation et sources** nécessaires pour installer Tucanos sur SUSE 15 SP4 **sans connexion internet**.

```
tucanos/
├── README.md                      # Ce fichier
├── DESCRIPTION_TUCANOS.md         # Description détaillée de Tucanos
├── .gitignore                     # Exclusions Git
│
├── docs/                          # 📚 Documentation complète
│   ├── LIRE_MOI_INSTALLATION.md
│   ├── RECAPITULATIF_FINAL.md
│   ├── COMMENT_CA_MARCHE_VRAIMENT.md
│   ├── GUIDE_FINAL_INSTALLATION_TUCANOS_SUSE15.md
│   └── INSTALLATION_100_POURCENT_OFFLINE.md
│
├── scripts/                       # 🔧 Scripts d'installation
│   ├── install_tucanos_offline.sh      # Script principal
│   ├── install_metis.sh
│   ├── install_nlopt.sh
│   ├── creer_package_complet_tucanos.ps1
│   └── autres scripts...
│
├── sources/                       # 💻 Code source Tucanos
│   └── tucanos-main/
│       ├── tucanos/              # Bibliothèque principale
│       ├── tmesh/                # Opérations sur maillages
│       ├── pytucanos/            # Bindings Python
│       └── pytmesh/              # Bindings Python
│
└── config/                        # ⚙️ Configuration
    └── rust-toolchain.toml
```

## 🚀 Installation Rapide

### Étape 1 : Créer le package offline (sur machine avec internet)

Sur une machine Windows/Linux **avec internet**, exécutez :

```powershell
# Windows PowerShell
cd scripts
.\creer_package_complet_tucanos.ps1
```

Cela télécharge et crée le package complet `tucanos-complete-offline-final.zip` (~700 MB).

### Étape 2 : Installer sur SUSE 15 SP4 (sans internet)

Transférez le package ZIP sur votre serveur SUSE 15 SP4, puis :

```bash
# Extraire le package
unzip tucanos-complete-offline-final.zip
cd tucanos-complete-offline-final

# Lancer l'installation (1 seule commande)
bash install_tucanos_offline.sh
```

Le script installe automatiquement :
- ✅ make (si nécessaire)
- ✅ Rust 1.89.0 (si nécessaire)
- ✅ Tucanos (compilation 100% offline)
- ✅ METIS et NLOPT (si g++ disponible)

## 📦 Package Complet Inclut

Le package offline (non versionné dans Git) contient :

- ✅ **Tucanos** (sources complètes)
- ✅ **Rust 1.89.0** (toolchain complet offline)
- ✅ **Dépendances Rust vendorisées** (231 packages, ~302 MB)
- ✅ **Dépendances GitHub** (coupe, metis-rs, minimeshb)
- ✅ **Sources make et gcc** (pour compilation)
- ✅ **METIS et NLOPT** (optionnels, nécessitent g++)

## ⚙️ Prérequis Système (SUSE 15 SP4)

### Obligatoires
- ✅ **gcc** (normalement préinstallé)
- ✅ **tar**, **gzip**, **unzip**
- ✅ ~1 GB d'espace disque libre
- ✅ ~2 GB de RAM pour la compilation

### Optionnels (pour METIS/NLOPT)
- ⚠️ **g++** (gcc-c++) : `sudo zypper install gcc-c++`

## ✅ Vérification de l'Installation

```bash
# Vérifier Tucanos
ls -lh ~/.local/lib/libtucanos.so

# Vérifier METIS (optionnel)
gpmetis --help

# Vérifier NLOPT (optionnel)
pkg-config --modversion nlopt

# Activer l'environnement
source ~/.bashrc
```

## 🔧 Fonctionnalités

- ✅ **Installation 100% offline** - Aucune connexion internet requise sur SUSE
- ✅ **Installation sans sudo** - Tout installé dans `~/.local/`
- ✅ **Détection automatique** - Détecte g++ pour METIS/NLOPT
- ✅ **Scripts automatisés** - Installation en une seule commande
- ✅ **Documentation complète** - Guides en français

## 📚 Documentation

- **[docs/LIRE_MOI_INSTALLATION.md](docs/LIRE_MOI_INSTALLATION.md)** - Guide d'installation complet
- **[docs/RECAPITULATIF_FINAL.md](docs/RECAPITULATIF_FINAL.md)** - Récapitulatif technique
- **[docs/COMMENT_CA_MARCHE_VRAIMENT.md](docs/COMMENT_CA_MARCHE_VRAIMENT.md)** - Explication du système
- **[DESCRIPTION_TUCANOS.md](DESCRIPTION_TUCANOS.md)** - Description détaillée de Tucanos

## 🛠️ Dépannage

### Erreur : "g++ not found"
**Solution** : C'est normal si g++ n'est pas installé. Tucanos fonctionne sans METIS/NLOPT.

### Erreur : "cargo build failed"
**Causes possibles** :
1. Espace disque insuffisant : `df -h`
2. cargo-vendor incomplet : Vérifiez le package téléchargé

### Erreur : "Permission denied"
**Solution** : N'utilisez PAS sudo avec le script d'installation.

## 📝 Notes Importantes

- ⚠️ Les **gros fichiers** (archives ZIP, vendor packages, binaires) sont **exclus du dépôt Git**
- ✅ Seuls les **scripts et la documentation** sont versionnés
- ✅ Le **package complet** doit être créé avec `creer_package_complet_tucanos.ps1`
- ✅ Le dépôt Git reste **léger** (~50-100 MB) pour faciliter le clonage

## 📊 Tailles

- **Dépôt Git** : ~50-100 MB (scripts + docs + sources)
- **Package offline complet** : ~679-717 MB (ZIP)
- **Package décompressé** : ~734 MB

## 🔗 Liens Utiles

- **Tucanos GitHub officiel** : https://github.com/tucanos/tucanos
- **Ce dépôt** : https://github.com/mickaelangel/tucanos

## 📄 Licence

Voir les licences respectives de chaque composant (Tucanos, Rust, METIS, NLOPT).

---

**Package d'installation offline pour Tucanos sur SUSE 15 SP4** 🚀

*Créé pour faciliter le déploiement de Tucanos sur des systèmes sans connexion internet.*
