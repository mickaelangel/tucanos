# Package Rust hors ligne pour SUSE 15

## 📦 Contenu du package

Ce package contient **TOUS** les composants Rust nécessaires pour une installation complète hors ligne :

| Fichier | Taille | Description |
|---------|--------|-------------|
| `rust-1.89.0-x86_64-unknown-linux-gnu.tar.gz` | 346 MB | ✅ Rust complet (compilateur + outils) |
| `rustc-1.89.0-x86_64-unknown-linux-gnu.tar.gz` | 124 MB | ✅ Compilateur Rust |
| `rust-std-1.89.0-x86_64-unknown-linux-gnu.tar.gz` | 48.6 MB | ✅ Bibliothèque standard |
| `cargo-1.89.0-x86_64-unknown-linux-gnu.tar.gz` | 13.6 MB | ✅ Gestionnaire de paquets |
| `install_rust_offline.sh` | - | ✅ Script d'installation |
| `README_RUST_OFFLINE.md` | - | ✅ Ce guide |

**Total : ~532 MB** - Installation complète de Rust hors ligne !

## 🚀 Installation sur votre serveur SUSE 15

### 1. Transférer le package
```bash
# Copiez tout le répertoire rust-offline-package/ sur votre serveur SUSE 15
scp -r rust-offline-package/ user@votre-serveur-suse15:/home/user/
```

### 2. Se connecter au serveur
```bash
ssh user@votre-serveur-suse15
cd rust-offline-package
```

### 3. Installer Rust
```bash
# Rendre le script exécutable
chmod +x install_rust_offline.sh

# Lancer l'installation
./install_rust_offline.sh
```

### 4. Activer Rust
```bash
# Charger l'environnement Rust
source /etc/profile.d/rust.sh

# Vérifier l'installation
rustc --version
cargo --version
```

## ✅ Avantages de cette solution

- ✅ **100% hors ligne** - Aucune connexion internet requise
- ✅ **Installation complète** - Tous les composants Rust inclus
- ✅ **Installation globale** - Accessible à tous les utilisateurs
- ✅ **Version stable** - Rust 1.89.0 (même version que Tucanos)
- ✅ **Compatible SUSE 15** - Optimisé pour x86_64-unknown-linux-gnu

## 🔧 Prérequis SUSE 15

Le script vérifiera et installera automatiquement :
- ✅ `tar` (pour extraire les archives)
- ✅ `gcc` et `gcc-c++` (compilateurs C/C++)
- ✅ `make` (outils de build)

Si manquants, installez avec :
```bash
sudo zypper install tar gcc gcc-c++ make
```

## 📋 Après installation de Rust

Une fois Rust installé, vous pouvez compiler Tucanos :

```bash
# Retourner au package Tucanos
cd ../tucanos-suse15-package

# Utiliser le script d'installation Tucanos
chmod +x install_offline_complete.sh
./install_offline_complete.sh
```

## 🎯 Réponse à votre question principale

**Vous n'avez toujours PAS besoin de configurer l'environnement pour chaque utilisateur !**

Avec cette installation :
- ✅ **Rust** sera installé globalement dans `/usr/local/rust`
- ✅ **Tucanos** sera compilé et installé globalement
- ✅ **Tous les utilisateurs** pourront utiliser Rust et Tucanos

## 🛠️ Dépannage

### Erreur de permissions
```bash
sudo chown -R $USER:$USER rust-offline-package
```

### Erreur "command not found" après installation
```bash
# Recharger l'environnement
source /etc/profile.d/rust.sh

# Ou redémarrer votre session
logout
# puis se reconnecter
```

### Vérifier l'installation
```bash
# Vérifier Rust
which rustc
which cargo
rustc --version
cargo --version

# Vérifier les liens symboliques
ls -la /usr/local/bin/rust*
```

## 📞 Support

- **Documentation Rust** : https://doc.rust-lang.org/
- **Guide d'installation** : https://forge.rust-lang.org/infra/channel-layout.html
- **Version** : Rust 1.89.0 (compatible avec Tucanos)

---

## 🎉 Félicitations !

Vous avez maintenant un **package Rust complet** pour installation hors ligne sur SUSE 15 !

**Étapes suivantes :**
1. Transférez ce package sur votre serveur SUSE 15
2. Installez Rust avec `./install_rust_offline.sh`
3. Compilez Tucanos avec le package tucanos-suse15-package

**Tout sera installé globalement** - accessible à tous les utilisateurs du serveur !



