# 📚 Wiki Tucanos - Package d'Installation Offline

Bienvenue sur le wiki du projet Tucanos Package Offline ! Cette page centrale regroupe toute la documentation.

## 📋 Table des Matières

### 🚀 Démarrage Rapide
- [Installation depuis Git](INSTALLATION_DEPUIS_GIT.md)
- [Guide d'installation complet](LIRE_MOI_INSTALLATION.md)
- [Installation 100% offline](INSTALLATION_100_POURCENT_OFFLINE.md)

### 📖 Guides Détaillés
- [Guide final d'installation pour SUSE 15](GUIDE_FINAL_INSTALLATION_TUCANOS_SUSE15.md)
- [Comment ça marche vraiment](COMMENT_CA_MARCHE_VRAIMENT.md)
- [Récapitulatif technique](RECAPITULATIF_FINAL.md)

### 🛠️ Utilisation

#### Installation Standard
```bash
# Cloner le dépôt
git clone https://github.com/mickaelangel/tucanos.git
cd tucanos

# Installation par défaut (dans ~/.local/)
bash scripts/install_tucanos_custom.sh
```

#### Installation Personnalisée
```bash
# Choisir le répertoire d'installation
PREFIX=/opt/tucanos bash scripts/install_tucanos_custom.sh
PREFIX=$HOME/apps/tucanos bash scripts/install_tucanos_custom.sh
```

#### Création du Package Offline
```powershell
# Sur machine Windows avec internet
cd scripts
.\creer_package_complet_tucanos.ps1
```

### 🎯 Cas d'Usage

#### Cas 1 : Serveur Sans Internet
**Objectif** : Installer Tucanos sur un serveur SUSE 15 SP4 isolé

**Solution** :
1. Créer le package offline sur machine avec internet
2. Transférer le ZIP via clé USB ou SCP
3. Extraire et exécuter `install_tucanos_offline.sh`

**Lien** : [Installation 100% Offline](INSTALLATION_100_POURCENT_OFFLINE.md)

---

#### Cas 2 : Installation Multi-Utilisateurs
**Objectif** : Installer Tucanos pour tous les utilisateurs d'un système

**Solution** :
```bash
sudo PREFIX=/usr/local bash scripts/install_tucanos_custom.sh
```

**Lien** : [Installation depuis Git](INSTALLATION_DEPUIS_GIT.md#installation-système-pour-tous)

---

#### Cas 3 : Installation Développeur
**Objectif** : Installer rapidement pour tester Tucanos

**Solution** :
```bash
git clone https://github.com/mickaelangel/tucanos.git
cd tucanos
bash scripts/install_tucanos_custom.sh
```

**Lien** : [Installation depuis Git](INSTALLATION_DEPUIS_GIT.md)

---

#### Cas 4 : Installation dans Espace Partagé
**Objectif** : Installer dans `/shared/tools` pour équipe

**Solution** :
```bash
PREFIX=/shared/tools/tucanos bash scripts/install_tucanos_custom.sh
# Ajouter au PATH de l'équipe
echo 'export PATH="/shared/tools/tucanos/bin:$PATH"' >> /etc/profile.d/tucanos.sh
```

---

### 📦 Composants du Package

| Composant | Taille | Description | Obligatoire |
|-----------|--------|-------------|-------------|
| **Tucanos** | ~77 MB | Sources Tucanos | ✅ Oui |
| **Rust 1.89.0** | ~532 MB | Toolchain Rust offline | ✅ Oui |
| **cargo-vendor** | ~302 MB | 231 packages Rust | ✅ Oui |
| **github-deps** | ~200 KB | coupe, metis-rs, minimeshb | ✅ Oui |
| **make sources** | ~2-125 MB | Sources make/gcc | ⚠️ Si make absent |
| **METIS** | ~4.7 MB | Partitionnement maillage | ❌ Optionnel |
| **NLOPT** | ~1.9 MB | Optimisation | ❌ Optionnel |

**Total package complet** : ~679-717 MB (compressé)

---

### 🔧 Prérequis Système

#### SUSE 15 SP4 (Cible)

**Obligatoires** :
- ✅ gcc (normalement préinstallé)
- ✅ tar, gzip, unzip
- ✅ ~1 GB d'espace disque
- ✅ ~2 GB de RAM pour compilation

**Optionnels** :
- ⚠️ g++ (gcc-c++) : Pour METIS/NLOPT
- ⚠️ cmake : Pour METIS/NLOPT

**Installation g++** :
```bash
sudo zypper install gcc-c++
```

---

### ⚙️ Variables d'Environnement

#### PREFIX
Définit le répertoire d'installation

```bash
# Par défaut
PREFIX=$HOME/.local

# Personnalisé
PREFIX=/opt/tucanos bash scripts/install_tucanos_custom.sh
```

#### PATH et LD_LIBRARY_PATH
Configurés automatiquement dans `~/.bashrc`

```bash
export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
```

---

### 🧪 Tests et Validation

#### Valider le Package
```bash
# Dans le dossier du package décompressé
bash tests/validate_package.sh
```

#### Vérifier l'Installation
```bash
# Vérifier Tucanos
ls -lh $PREFIX/lib/libtucanos.so
ls -lh $PREFIX/include/tucanos.h

# Vérifier METIS (optionnel)
command -v gpmetis

# Vérifier NLOPT (optionnel)
pkg-config --modversion nlopt
```

#### Tester avec un Programme C
```c
#include <tucanos.h>
#include <stdio.h>

int main() {
    tucanos_init_log();
    printf("Tucanos initialisé avec succès!\n");
    return 0;
}
```

Compiler :
```bash
gcc -I$PREFIX/include -L$PREFIX/lib -ltucanos test.c -o test
./test
```

---

### 🐛 Dépannage

#### Erreur : "gcc not found"
**Cause** : gcc n'est pas installé

**Solution** :
```bash
sudo zypper install gcc gcc-c++
```

---

#### Erreur : "cargo build failed"
**Causes possibles** :
1. Espace disque insuffisant
2. cargo-vendor incomplet
3. Mémoire RAM insuffisante

**Solutions** :
```bash
# Vérifier l'espace disque
df -h

# Vérifier la mémoire
free -h

# Compiler avec moins de parallélisme
export CARGO_BUILD_JOBS=2
cargo build --release
```

---

#### Erreur : "g++ not found" pour METIS/NLOPT
**Cause** : g++ n'est pas installé (METIS/NLOPT nécessitent g++)

**Solution** :
```bash
# g++ est optionnel, Tucanos fonctionne sans
# Si vous voulez METIS/NLOPT :
sudo zypper install gcc-c++
```

---

#### Erreur : "Permission denied" pour PREFIX=/usr/local
**Cause** : Permissions insuffisantes pour écrire dans /usr/local

**Solutions** :
```bash
# Solution 1 : Utiliser sudo
sudo PREFIX=/usr/local bash scripts/install_tucanos_custom.sh

# Solution 2 : Choisir un autre répertoire
PREFIX=$HOME/.local bash scripts/install_tucanos_custom.sh
```

---

### 📊 Structure du Dépôt

```
tucanos/
├── README.md                   # Documentation principale
├── DESCRIPTION_TUCANOS.md      # Description de Tucanos
├── CHANGELOG.md                # Historique des versions
├── CONTRIBUTING.md             # Guide de contribution
├── .gitignore                  # Exclusions Git
│
├── docs/                       # 📚 Documentation
│   ├── WIKI.md                 # Ce fichier
│   ├── LIRE_MOI_INSTALLATION.md
│   ├── INSTALLATION_DEPUIS_GIT.md
│   ├── INSTALLATION_100_POURCENT_OFFLINE.md
│   ├── GUIDE_FINAL_INSTALLATION_TUCANOS_SUSE15.md
│   ├── COMMENT_CA_MARCHE_VRAIMENT.md
│   └── RECAPITULATIF_FINAL.md
│
├── scripts/                    # 🔧 Scripts d'installation
│   ├── install_tucanos_custom.sh
│   ├── install_tucanos_offline.sh
│   ├── creer_package_complet_tucanos.ps1
│   └── ... (28 scripts)
│
├── sources/                    # 💻 Sources Tucanos
│   └── tucanos-main/
│       ├── tucanos/            # Lib principale
│       ├── tmesh/              # Opérations maillages
│       ├── pytucanos/          # Bindings Python
│       └── pytmesh/            # Bindings Python
│
├── config/                     # ⚙️ Configuration
│   └── rust-toolchain.toml
│
└── tests/                      # ✅ Tests de validation
    └── validate_package.sh
```

---

### 🔗 Liens Utiles

#### Documentation
- [README Principal](../README.md)
- [Description Tucanos](../DESCRIPTION_TUCANOS.md)
- [Guide de Contribution](../CONTRIBUTING.md)
- [Changelog](../CHANGELOG.md)

#### Externes
- [Tucanos GitHub Officiel](https://github.com/tucanos/tucanos)
- [Rust Lang](https://www.rust-lang.org/)
- [SUSE Documentation](https://documentation.suse.com/)

---

### 📝 FAQ

#### Q : Puis-je installer Tucanos sans sudo ?
**R** : Oui ! Par défaut, l'installation se fait dans `~/.local/` sans sudo.

#### Q : Quelle est la différence entre les deux scripts d'installation ?
**R** : 
- `install_tucanos_offline.sh` : Installation fixe dans ~/.local/
- `install_tucanos_custom.sh` : Installation personnalisée avec PREFIX

#### Q : Puis-je installer plusieurs versions de Tucanos ?
**R** : Oui, utilisez des PREFIX différents :
```bash
PREFIX=$HOME/tucanos-v1 bash scripts/install_tucanos_custom.sh
PREFIX=$HOME/tucanos-v2 bash scripts/install_tucanos_custom.sh
```

#### Q : Le package fonctionne-t-il sur d'autres distributions ?
**R** : Principalement testé sur SUSE 15 SP4, mais devrait fonctionner sur :
- openSUSE Leap 15.x
- RHEL/CentOS 7/8
- Ubuntu 20.04+
- Debian 10+

#### Q : Combien de temps prend la compilation ?
**R** : 
- Avec 4 CPUs : ~10-15 minutes
- Avec 8 CPUs : ~5-10 minutes
- Dépend aussi de la RAM disponible

#### Q : Puis-je utiliser Tucanos depuis Python ?
**R** : Oui ! Tucanos inclut des bindings Python (`pytucanos` et `pytmesh`).
Voir les exemples dans `sources/tucanos-main/pytucanos/examples/`

---

### 🤝 Contribuer

Ce projet est ouvert aux contributions ! Consultez [CONTRIBUTING.md](../CONTRIBUTING.md) pour :
- Signaler des bugs
- Proposer des améliorations
- Ajouter de la documentation
- Soumettre des pull requests

---

### 📜 Licence

Voir les licences respectives de chaque composant :
- Tucanos : Voir [sources/tucanos-main/LICENSE](../sources/tucanos-main/LICENSE)
- Rust : MIT/Apache 2.0
- METIS : Apache 2.0
- NLOPT : LGPL

---

**Bienvenue dans la communauté Tucanos !** 🦏🚀

