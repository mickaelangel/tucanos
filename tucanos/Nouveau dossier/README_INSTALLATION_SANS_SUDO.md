# Installation Tucanos SANS SUDO sur SUSE 15 SP4

## 🎯 Pour qui ?

Ce guide est pour les utilisateurs qui **N'ONT PAS les droits sudo/root** sur leur machine SUSE 15 SP4.

Toutes les installations se feront dans votre répertoire utilisateur `~/.local/`

---

## 📦 Contenu du Package

Le package inclut des scripts **sans sudo** :

```
tucanos-complete-offline-final/
├── install_tucanos_no_sudo.sh      ⭐ Installation complète sans sudo
├── install_make_no_sudo.sh         ⭐ Installer make uniquement
├── install_gcc_no_sudo.sh          ⭐ Installer gcc uniquement (long)
├── install_tucanos_suse15_offline.sh  (nécessite sudo)
└── ... (autres fichiers)
```

---

## 🚀 Installation Rapide (Méthode Recommandée)

### Prérequis

Votre système doit **déjà avoir** :
- ✅ **gcc** et **g++** (demander à l'administrateur si absent)
- ✅ **tar**, **gzip**, **xz** (normalement présents)

### Étape 1 : Vérifier gcc

```bash
gcc --version
g++ --version
```

Si gcc n'est pas disponible, demandez à votre administrateur système :
```bash
# L'admin doit exécuter :
sudo zypper install gcc gcc-c++
```

### Étape 2 : Lancer l'installation complète

```bash
cd tucanos-complete-offline-final

# Rendre le script exécutable
chmod +x install_tucanos_no_sudo.sh

# Lancer l'installation
./install_tucanos_no_sudo.sh
```

Le script va automatiquement :
1. ✅ Installer make dans `~/.local/bin/` (si absent)
2. ✅ Installer Rust dans `~/.cargo/`
3. ✅ Compiler Tucanos
4. ✅ Installer Tucanos dans `~/.local/`
5. ✅ Configurer votre `.bashrc`

### Étape 3 : Activer les changements

```bash
source ~/.bashrc
```

C'est tout ! ✨

---

## 🛠️ Installation Composant par Composant

Si vous préférez installer composant par composant :

### 1. Installer make (si absent)

```bash
chmod +x install_make_no_sudo.sh
./install_make_no_sudo.sh
source ~/.bashrc
```

### 2. Installer Rust (si absent)

```bash
# Rust est inclus dans install_tucanos_no_sudo.sh
# Ou utiliser directement :
cd rust-offline-package
./install_rust_offline.sh
```

### 3. Installer Tucanos

```bash
./install_tucanos_no_sudo.sh
```

---

## 📂 Structure après Installation

Tout sera installé dans votre répertoire utilisateur :

```
$HOME/
├── .local/
│   ├── bin/
│   │   ├── make                    # Make 4.3
│   │   └── tucanos                 # Binaires Tucanos
│   ├── lib/
│   │   └── libtucanos.so          # Bibliothèque Tucanos
│   └── include/
│       └── tucanos.h              # Headers Tucanos
├── .cargo/
│   ├── bin/
│   │   ├── rustc                   # Compilateur Rust
│   │   └── cargo                   # Gestionnaire de paquets
│   └── env                         # Variables d'environnement
└── .bashrc                         # Mis à jour automatiquement
```

---

## 🔍 Variables d'Environnement

Le script configure automatiquement `.bashrc` avec :

```bash
# PATH pour les binaires
export PATH="$HOME/.local/bin:$PATH"

# LD_LIBRARY_PATH pour les bibliothèques
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

# PKG_CONFIG_PATH
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Rust
source "$HOME/.cargo/env"
```

---

## ✅ Vérification après Installation

### 1. Vérifier make
```bash
make --version
# Attendu : GNU Make 4.3
```

### 2. Vérifier Rust
```bash
rustc --version
cargo --version
# Attendu : rustc 1.89.0, cargo 1.89.0
```

### 3. Vérifier Tucanos
```bash
ls -lh ~/.local/lib/libtucanos.so
ls -lh ~/.local/include/tucanos.h
```

### 4. Test de compilation
```bash
cd tucanos-main
cargo test --release
```

---

## 📝 Utilisation de Tucanos

### Compiler un programme C avec Tucanos

```bash
# Créer un fichier test.c
cat > test.c << 'EOF'
#include <tucanos.h>
#include <stdio.h>

int main() {
    printf("Tucanos fonctionne!\n");
    return 0;
}
EOF

# Compiler
gcc test.c -I$HOME/.local/include -L$HOME/.local/lib -ltucanos -o test

# Exécuter
./test
```

### Utiliser dans un Makefile

```makefile
CC = gcc
CFLAGS = -I$(HOME)/.local/include
LDFLAGS = -L$(HOME)/.local/lib -ltucanos

myprogram: myprogram.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@
```

---

## 🛠️ Cas Spécial : gcc n'est pas disponible

Si gcc n'est pas installé sur le système, vous avez deux options :

### Option 1 : Demander à l'administrateur (Recommandé)

C'est la méthode la plus simple :

```bash
# L'admin exécute :
sudo zypper install gcc gcc-c++ gmp-devel mpfr-devel mpc-devel
```

### Option 2 : Compiler gcc sans sudo (TRÈS LONG)

⚠️ **ATTENTION** : Cela peut prendre **1-3 heures** et nécessite **~15 GB d'espace disque**.

```bash
# Vérifier l'espace disponible
df -h $HOME

# Lancer la compilation de gcc
chmod +x install_gcc_no_sudo.sh
./install_gcc_no_sudo.sh

# Cela va compiler et installer gcc dans ~/.local/
# Puis relancer l'installation de Tucanos
./install_tucanos_no_sudo.sh
```

**Prérequis pour compiler gcc** :
- **GMP**, **MPFR**, **MPC** doivent être disponibles sur le système
- Si manquants, demander à l'admin de les installer :
  ```bash
  sudo zypper install gmp-devel mpfr-devel mpc-devel
  ```

---

## 🐛 Dépannage

### Erreur : `command not found` après installation

**Solution :**
```bash
# Recharger .bashrc
source ~/.bashrc

# Vérifier le PATH
echo $PATH
# Doit contenir: /home/VOTRE_USER/.local/bin
```

---

### Erreur : `cannot open shared object file: libtucanos.so`

**Solution :**
```bash
# Ajouter à LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"

# Ou recharger .bashrc
source ~/.bashrc
```

---

### Erreur : `Permission denied` dans `.cargo`

**Solution :**
```bash
# Vérifier les permissions
ls -la ~/.cargo

# Corriger si nécessaire
chmod -R u+w ~/.cargo
```

---

### Erreur : Compilation Tucanos nécessite internet

Le package contient **certaines** dépendances Cargo mais pas toutes.

**Solutions :**

**Option A** : Autoriser téléchargement temporaire (le script demande)
```bash
# Le script demandera :
# "Continuer avec téléchargement internet ? (y/N):"
# Répondre : y
```

**Option B** : Package offline complet (préparer en avance)
```bash
# Sur une machine avec internet, avant de créer le package :
cd tucanos-main
cargo vendor

# Copier le dossier vendor/ complet dans le package
```

---

## 📊 Comparaison avec / sans sudo

| Fonctionnalité | Avec sudo | Sans sudo |
|----------------|-----------|-----------|
| **Installation make** | Dans `/usr/local/` | Dans `~/.local/` |
| **Installation gcc** | Dans `/usr/local/` | Dans `~/.local/` |
| **Installation Rust** | Dans `~/.cargo/` | Dans `~/.cargo/` ✅ |
| **Installation Tucanos** | Dans `/usr/local/` OU `~/.local/` | Dans `~/.local/` ✅ |
| **Droits requis** | sudo/root | Aucun ✅ |
| **Disponible pour autres users** | Oui | Non (seulement vous) |
| **Modification système** | Oui | Non ✅ |

---

## 💡 Avantages de l'installation sans sudo

✅ **Aucun droit admin requis**
✅ **Pas de modification du système**
✅ **Installation isolée dans votre home**
✅ **Facile à désinstaller** (supprimer `~/.local/`)
✅ **Pas de conflit avec installations système**

---

## 🗑️ Désinstallation

Pour supprimer complètement Tucanos :

```bash
# Supprimer les binaires et bibliothèques
rm -rf ~/.local/bin/tucanos
rm -rf ~/.local/lib/libtucanos*
rm -rf ~/.local/include/tucanos.h

# Supprimer Rust (optionnel)
rm -rf ~/.cargo
rm -rf ~/.rustup

# Supprimer make (si installé localement)
rm -f ~/.local/bin/make

# Nettoyer .bashrc (enlever les lignes ajoutées)
# Éditer manuellement ~/.bashrc
```

---

## 📚 Ressources

- **Script principal** : `install_tucanos_no_sudo.sh`
- **Documentation Tucanos** : https://github.com/tucanos/tucanos
- **Documentation Rust** : https://www.rust-lang.org/

---

## ✨ Résumé

**Installation simple en 3 commandes :**

```bash
cd tucanos-complete-offline-final
chmod +x install_tucanos_no_sudo.sh
./install_tucanos_no_sudo.sh
source ~/.bashrc
```

**Tout sera installé dans votre répertoire utilisateur - Aucun sudo requis ! 🎉**





