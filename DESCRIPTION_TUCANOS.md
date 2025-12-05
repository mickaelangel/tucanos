# 🦏 Tucanos - Description Complète

## Qu'est-ce que Tucanos ?

**Tucanos** est une bibliothèque Rust moderne et performante pour l'**adaptation de maillage anisotrope** en 2D et 3D. Elle est spécialement conçue pour les simulations numériques spatio-temporelles haute performance.

Développée avec un focus sur la performance et la flexibilité, Tucanos fournit des outils avancés pour manipuler, adapter et optimiser des maillages computationnels.

## 🎯 Objectifs Principaux

Tucanos répond aux besoins des ingénieurs et chercheurs en simulation numérique :

- **Adaptation de maillage anisotrope** : Raffiner les maillages selon des métriques spécifiques
- **Remaillage adaptatif** : Optimiser la qualité et la résolution du maillage dynamiquement
- **Opérations sur maillages** : Création, partitionnement, manipulation 2D et 3D
- **Performance** : Écrit en Rust pour une vitesse maximale et une sécurité mémoire
- **Multi-plateforme** : APIs pour Rust, Python et C

## ⚡ Fonctionnalités Principales

### Adaptation de Maillage Anisotrope

Tucanos permet d'adapter les maillages selon trois approches :

1. **Feature-based** : Adaptation basée sur les caractéristiques de la solution (gradients, Hessien)
2. **Geometry-based** : Adaptation basée sur la géométrie (courbure, discontinuités)
3. **Mesh-implied** : Adaptation basée sur les métriques implicites du maillage existant

### Remaillage Adaptatif

Le remailleur de Tucanos optimise automatiquement :
- La qualité des éléments (évite les éléments dégénérés)
- La taille des éléments selon les métriques fournies
- L'orientation des éléments (anisotropie)
- La résolution locale selon les besoins de la simulation

### Opérations sur Maillages (tmesh)

La bibliothèque `tmesh` fournit :
- Création de maillages 2D et 3D
- Partitionnement pour calcul parallèle
- Opérations de dualité (mesh dual)
- Extrusion de maillages 2D vers 3D
- Import/Export de formats standards (GMSH, VTK, CGNS)

### APIs Multi-Langages

Tucanos est accessible depuis plusieurs langages :

**Rust (natif)** :
```rust
use tucanos::mesh::Mesh;
use tucanos::metric::Metric;
use tucanos::remesher::Remesher;
```

**Python (pytucanos)** :
```python
from pytucanos import Mesh, Metric, remesh
```

**C (FFI)** :
```c
#include "tucanos_ffi.h"
```

## 🏗️ Architecture

Tucanos est organisé en plusieurs crates :

- **`tucanos`** : Bibliothèque principale (adaptation, remaillage, métriques)
- **`tmesh`** : Opérations sur maillages (création, manipulation, I/O)
- **`pytucanos`** : Bindings Python pour Tucanos
- **`pytmesh`** : Bindings Python pour tmesh
- **`tucanos-ffi`** : Interface C pour intégration avec codes legacy

## 🔬 Cas d'Usage

### Mécanique des Fluides Numérique (CFD)

- Simulation d'écoulements aérodynamiques
- Adaptation près des couches limites
- Capture de chocs et discontinuités
- Optimisation de forme

### Éléments Finis

- Mécanique des structures
- Thermique
- Électromagnétisme
- Problèmes multi-physiques

### Simulations Spatio-Temporelles

- Problèmes instationnaires
- Adaptation dynamique du maillage
- Suivi d'interfaces
- Simulations adaptatives en temps

## 🚀 Performance

Écrit en Rust, Tucanos bénéficie de :

- **Vitesse** : Performance proche du C/C++
- **Sécurité mémoire** : Pas de segfaults
- **Parallélisme** : Threading safe par défaut
- **Optimisations** : Compilateur LLVM moderne

Benchmarks typiques :
- Remaillage 2D (100K triangles) : ~2-5 secondes
- Remaillage 3D (1M tétraèdres) : ~30-60 secondes
- Calcul de métriques : ~0.5-2 secondes

## 📦 Installation

### Depuis Git (avec internet)

```bash
git clone https://github.com/mickaelangel/tucanos.git
cd tucanos
bash scripts/install_tucanos_custom.sh
```

### Installation Offline (sans internet)

```bash
# 1. Créer package offline (sur machine avec internet)
cd tucanos/scripts
./creer_package_complet_tucanos.ps1

# 2. Transférer et installer (sur machine sans internet)
bash install_tucanos_offline.sh
```

Voir [docs/INSTALLATION_100_POURCENT_OFFLINE.md](docs/INSTALLATION_100_POURCENT_OFFLINE.md)

## 🔧 Dépendances

### Dépendances Rust (automatiques)

Tucanos utilise ~230 crates Rust gérées automatiquement par Cargo :
- `nalgebra` : Algèbre linéaire
- `petgraph` : Structures de graphes
- `rayon` : Parallélisme
- `ndarray` : Tableaux N-dimensionnels
- `scotch` : Partitionnement (optionnel)

### Dépendances Système (optionnelles)

- **METIS** : Partitionnement de graphes (nécessite g++)
- **NLOPT** : Optimisation non-linéaire (nécessite g++)
- **g++** : Compilateur C++ (optionnel)

## 📖 Documentation

- **Guide d'installation** : [docs/LIRE_MOI_INSTALLATION.md](docs/LIRE_MOI_INSTALLATION.md)
- **Installation offline** : [docs/INSTALLATION_100_POURCENT_OFFLINE.md](docs/INSTALLATION_100_POURCENT_OFFLINE.md)
- **Guide final** : [docs/GUIDE_FINAL_INSTALLATION_TUCANOS_SUSE15.md](docs/GUIDE_FINAL_INSTALLATION_TUCANOS_SUSE15.md)

## 🌐 Liens

- **Dépôt officiel Tucanos** : https://github.com/tucanos/tucanos
- **Ce package** : https://github.com/mickaelangel/tucanos
- **Documentation Rust** : https://www.rust-lang.org/

## 📄 Licence

Tucanos est sous licence selon les termes du projet officiel.

---

**Package créé par Mickael Angel pour faciliter le déploiement offline sur SUSE 15 SP4**

*Décembre 2025*

