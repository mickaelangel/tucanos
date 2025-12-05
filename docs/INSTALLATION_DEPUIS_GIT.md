# 🚀 Installation de Tucanos depuis GitHub

Ce guide explique comment installer Tucanos directement depuis le dépôt GitHub.

## 📦 Méthode 1 : Installation Complète (Recommandée)

### Étape 1 : Créer le package offline complet

Sur une **machine avec internet** (Windows/Linux) :

```bash
# Cloner le dépôt
git clone https://github.com/mickaelangel/tucanos.git
cd tucanos

# Créer le package complet avec toutes les dépendances
cd scripts
./creer_package_complet_tucanos.ps1  # Windows PowerShell
```

Cela télécharge et crée `tucanos-complete-offline-final.zip` (~700 MB) contenant :
- Sources Tucanos
- Rust 1.89.0 (toolchain offline)
- Dépendances vendorisées (231 packages)
- METIS et NLOPT

### Étape 2 : Transférer sur SUSE 15 SP4

```bash
# Via SCP
scp tucanos-complete-offline-final.zip user@suse-server:/home/user/

# Ou via clé USB
# Copiez le ZIP sur USB, puis transférez sur le serveur
```

### Étape 3 : Installer sur SUSE 15 SP4

#### Option A : Installation par défaut (dans ~/.local/)

```bash
unzip tucanos-complete-offline-final.zip
cd tucanos-complete-offline-final
bash install_tucanos_offline.sh
```

#### Option B : Installation personnalisée (choisir le dossier)

```bash
# Installer dans un répertoire personnalisé
PREFIX=/opt/tucanos bash install_tucanos_custom.sh

# Ou dans votre home avec un nom spécifique
PREFIX=$HOME/logiciels/tucanos bash install_tucanos_custom.sh

# Ou dans un espace partagé (nécessite les permissions)
PREFIX=/usr/local bash install_tucanos_custom.sh
```

## 📦 Méthode 2 : Installation Minimale (Sources seulement)

Si vous avez déjà Rust et les outils de compilation :

```bash
# 1. Cloner le dépôt
git clone https://github.com/mickaelangel/tucanos.git
cd tucanos

# 2. Compiler depuis les sources (nécessite internet)
cd sources/tucanos-main
cargo build --release

# 3. Installer manuellement
sudo cp target/release/libtucanos.so /usr/local/lib/
sudo cp target/release/tucanos.h /usr/local/include/
sudo ldconfig
```

## ⚙️ Options d'Installation Personnalisée

### Choisir le répertoire d'installation

Le script `install_tucanos_custom.sh` accepte la variable d'environnement `PREFIX` :

```bash
# Exemples d'installation
PREFIX=/opt/tucanos bash install_tucanos_custom.sh              # Système
PREFIX=$HOME/apps/tucanos bash install_tucanos_custom.sh        # Utilisateur
PREFIX=/shared/tools/tucanos bash install_tucanos_custom.sh     # Partagé
PREFIX=/mnt/data/tucanos bash install_tucanos_custom.sh         # Disque externe
```

### Structure du répertoire d'installation

Quel que soit le `PREFIX` choisi, Tucanos sera installé ainsi :

```
$PREFIX/
├── bin/           # Exécutables (make, rust si installés)
├── lib/           # Bibliothèques (libtucanos.so, libnlopt.so, etc.)
└── include/       # Headers (tucanos.h)
```

## 🔧 Configuration de l'Environnement

Après l'installation, ajoutez à votre `~/.bashrc` :

```bash
# Pour installation par défaut (~/.local)
export PATH="$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

# Pour installation personnalisée
export PATH="/votre/prefix/bin:$PATH"
export LD_LIBRARY_PATH="/votre/prefix/lib:$LD_LIBRARY_PATH"
```

Puis rechargez :

```bash
source ~/.bashrc
```

## ✅ Vérification de l'Installation

```bash
# Vérifier la bibliothèque
ls -lh $PREFIX/lib/libtucanos.so

# Vérifier les headers
ls -lh $PREFIX/include/tucanos.h

# Tester un programme C
gcc -I$PREFIX/include -L$PREFIX/lib -ltucanos test.c -o test
```

## 📊 Comparaison des Méthodes

| Méthode | Avantages | Inconvénients | Internet requis |
|---------|-----------|---------------|-----------------|
| **Package complet** | ✅ 100% offline<br>✅ Inclut tout<br>✅ Reproductible | ❌ ~700 MB à télécharger | Oui (création)<br>Non (installation) |
| **Sources Git** | ✅ Léger (~50 MB)<br>✅ Rapide à cloner | ❌ Nécessite Rust<br>❌ Télécharge deps | Oui (compilation) |
| **Installation minimale** | ✅ Très rapide<br>✅ Contrôle total | ❌ Configuration manuelle | Oui (dépendances) |

## 🎯 Cas d'Usage Recommandés

### Environnement Offline (serveur sans internet)
→ **Méthode 1** (package complet)

### Développement avec internet
→ **Méthode 2** (sources Git)

### Installation système (pour tous les utilisateurs)
→ **Méthode 1** avec `PREFIX=/usr/local`

### Installation utilisateur (sans sudo)
→ **Méthode 1** avec `PREFIX=$HOME/.local` (défaut)

### Installation pour tests
→ **Méthode 2** (compilation rapide)

## 🛠️ Dépannage

### Erreur : "cargo-vendor non trouvé"

Le dépôt Git ne contient pas les gros fichiers. Utilisez la **Méthode 1** pour créer le package complet.

### Erreur : "Permission denied" pour PREFIX=/usr/local

```bash
# Solution 1 : Utiliser sudo (si autorisé)
sudo PREFIX=/usr/local bash install_tucanos_custom.sh

# Solution 2 : Choisir un autre répertoire
PREFIX=$HOME/.local bash install_tucanos_custom.sh
```

### Erreur : "Rust not found"

```bash
# Installer Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

## 📚 Ressources

- **Dépôt GitHub** : https://github.com/mickaelangel/tucanos
- **Documentation complète** : Voir `docs/`
- **Tucanos officiel** : https://github.com/tucanos/tucanos

---

**Choisissez la méthode adaptée à votre environnement !** 🚀

