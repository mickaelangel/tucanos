# Guide d'installation de Tucanos sur SUSE 15 (Hors ligne)

## Réponse à votre question principale
**Vous n'avez PAS besoin de configurer l'environnement pour chaque utilisateur.** Tucanos peut être installé de manière **globale** sur le serveur SUSE 15 et sera accessible à tous les utilisateurs.

## Préparation (sur un système connecté)

### 1. Télécharger Rust
```bash
# Télécharger rustup-init pour Linux
wget https://sh.rustup.rs -O rustup-init
chmod +x rustup-init
```

### 2. Télécharger les sources de Tucanos
```bash
# Cloner le dépôt
git clone https://github.com/tucanos/tucanos.git

# Ou télécharger l'archive ZIP
wget https://github.com/tucanos/tucanos/archive/refs/heads/main.zip
unzip main.zip
mv tucanos-main tucanos
```

### 3. Télécharger les dépendances optionnelles (si disponibles)

#### Metis (pour le partitionnement de maillage)
```bash
# Sur SUSE 15, installer via zypper
sudo zypper install metis-devel
```

#### NLOPT (pour le lissage)
```bash
# Sur SUSE 15
sudo zypper install nlopt-devel
```

## Installation sur le serveur SUSE 15 (Hors ligne)

### 1. Transférer les fichiers
Copiez sur votre serveur SUSE 15 :
- `rustup-init`
- `tucanos/` (répertoire complet)
- `install_tucanos_suse15_offline.sh`

### 2. Exécuter l'installation
```bash
# Rendre le script exécutable
chmod +x install_tucanos_suse15_offline.sh

# Exécuter l'installation
./install_tucanos_suse15_offline.sh
```

## Installation manuelle (alternative)

Si vous préférez une installation manuelle :

### 1. Installer Rust
```bash
chmod +x rustup-init
./rustup-init -y --default-toolchain stable-x86_64-unknown-linux-gnu
source ~/.cargo/env
```

### 2. Compiler Tucanos
```bash
cd tucanos

# Compilation de base
cargo build --workspace --release

# Avec Metis (si disponible)
cargo build --workspace --release --features metis

# Avec NLOPT (si disponible)
cargo build --workspace --release --features nlopt

# Avec toutes les fonctionnalités
cargo build --workspace --release --features "metis nlopt"
```

### 3. Installation globale (optionnelle)
```bash
# Copier les bibliothèques
sudo cp target/release/libtucanos.so /usr/local/lib/
sudo ldconfig

# Copier les headers
sudo cp target/release/tucanos.h /usr/local/include/
```

## Utilisation

### API C
```c
#include <tucanos.h>

int main() {
    tucanos_init_log();
    // Votre code ici
    return 0;
}
```

### Compilation d'un programme C
```bash
gcc -I/usr/local/include -L/usr/local/lib -ltucanos votre_programme.c -o votre_programme
```

### API Python (si bindings compilés)
```python
import pytucanos
import pytmesh

# Votre code Python ici
```

## Fichiers générés

Après compilation, vous trouverez dans `target/release/` :
- `libtucanos.so` - Bibliothèque dynamique
- `tucanos.h` - Header C
- `tucanos` - Exécutable (si applicable)

## Configuration pour tous les utilisateurs

### Variables d'environnement système
Ajoutez dans `/etc/environment` :
```bash
LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
```

### Configuration Cargo globale
Créez `/etc/cargo/config.toml` :
```toml
[env]
METISDIR="/usr/local"
```

## Test de l'installation

```bash
# Tester la compilation
cargo test --workspace --release

# Tester les exemples
cargo run --example basic_usage

# Vérifier les bibliothèques
ldconfig -p | grep tucanos
```

## Dépannage

### Erreur "ld: cannot find -ltucanos"
```bash
sudo ldconfig
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
```

### Erreur de dépendances manquantes
```bash
# Installer les dépendances de base SUSE 15
sudo zypper install gcc gcc-c++ make cmake
```

### Problèmes de permissions
```bash
# Vérifier les permissions
ls -la /usr/local/lib/libtucanos.so
ls -la /usr/local/include/tucanos.h
```

## Avantages de l'installation globale

1. **Accessible à tous les utilisateurs** - Pas de configuration individuelle
2. **Maintenance simplifiée** - Une seule installation à maintenir
3. **Performance optimisée** - Compilation optimisée pour le serveur
4. **Intégration système** - Bibliothèques dans les chemins système

## Support

- Documentation : https://github.com/tucanos/tucanos
- Issues : https://github.com/tucanos/tucanos/issues
- Licence : LGPL-2.1

---

**Note importante** : Cette installation sera accessible à tous les utilisateurs du serveur SUSE 15 une fois compilée et installée. Aucune configuration par utilisateur n'est nécessaire.





