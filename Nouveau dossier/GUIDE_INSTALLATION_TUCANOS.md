# Guide d'installation de Tucanos sur Windows

## Résumé
Tucanos est une bibliothèque d'adaptation de maillage anisotrope 2D et 3D écrite en Rust. Cette bibliothèque peut être installée de manière **globale** et sera accessible à tous les utilisateurs du système.

## Réponse à votre question principale
**Vous n'avez PAS besoin de configurer l'environnement pour chaque utilisateur.** Tucanos peut être installé de manière globale et sera accessible à tous via ses API C ou Python.

## Prérequis pour l'installation

### 1. Rust (Déjà installé ✅)
- Rust 1.89.0 ou plus récent
- Cargo (gestionnaire de paquets Rust)

### 2. Outils de compilation Visual Studio
Vous devez installer les Build Tools for Visual Studio 2022 :

1. Téléchargez depuis : https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
2. Exécutez l'installateur
3. Sélectionnez "C++ build tools" avec les composants suivants :
   - MSVC v143 - VS 2022 C++ x64/x86 build tools
   - Windows 10/11 SDK
   - CMake tools for Visual Studio

### 3. Git (optionnel mais recommandé)
- Téléchargez depuis : https://git-scm.com/download/win

## Installation de Tucanos

### Méthode 1 : Installation depuis les sources (Recommandée)

```powershell
# 1. Cloner le dépôt
git clone https://github.com/tucanos/tucanos.git
cd tucanos

# 2. Compiler la bibliothèque
cargo build --workspace --release

# 3. Les fichiers seront générés dans :
# target/release/tucanos.h (header C)
# target/release/libtucanos.dll (bibliothèque dynamique)
```

### Méthode 2 : Installation Python (si vous utilisez Python)

```powershell
# Installation des bindings Python
pip install 'git+https://github.com/tucanos/tucanos.git#subdirectory=pytmesh'
pip install 'git+https://github.com/tucanos/tucanos.git#subdirectory=pytucanos'
```

## Fonctionnalités optionnelles

### Avec support Metis (pour le partitionnement de maillage)
```powershell
cargo build --workspace --release --features metis
```

### Avec support NLOPT (pour le lissage)
```powershell
cargo build --workspace --release --features nlopt
```

### Avec toutes les fonctionnalités
```powershell
cargo build --workspace --release --features "metis nlopt"
```

## Utilisation

### API C
```c
#include <tucanos.h>

// Exemple d'utilisation
tucanos_init_log();
// ... votre code ...
```

### API Python
```python
import pytucanos
import pytmesh

# Exemple d'utilisation
# ... votre code ...
```

## Fichiers générés

Après compilation, vous trouverez :
- `target/release/tucanos.h` - Header C pour l'API FFI
- `target/release/libtucanos.dll` - Bibliothèque dynamique Windows
- `target/release/tucanos.exe` - Exécutable (si applicable)

## Installation globale

Pour rendre Tucanos accessible à tous les utilisateurs :

1. Copiez `libtucanos.dll` dans `C:\Windows\System32\`
2. Copiez `tucanos.h` dans un répertoire d'en-têtes système
3. Ajoutez le chemin aux bibliothèques dans les variables d'environnement système

## Test de l'installation

```powershell
# Tester la compilation
cargo test --workspace

# Tester les exemples
cargo run --example basic_usage
```

## Dépannage

### Erreur "link.exe not found"
- Installez les Build Tools for Visual Studio 2022
- Redémarrez votre terminal après installation

### Erreur "dlltool.exe not found"
- Utilisez le toolchain MSVC au lieu de GNU
- Ou installez MinGW-w64

### Problèmes de dépendances
- Vérifiez que toutes les dépendances système sont installées
- Utilisez `--no-default-features` pour une compilation minimale

## Support

- Documentation : https://github.com/tucanos/tucanos
- Issues : https://github.com/tucanos/tucanos/issues
- Licence : LGPL-2.1

---

**Note importante** : Cette installation sera accessible à tous les utilisateurs du système une fois compilée et installée correctement. Aucune configuration par utilisateur n'est nécessaire.








