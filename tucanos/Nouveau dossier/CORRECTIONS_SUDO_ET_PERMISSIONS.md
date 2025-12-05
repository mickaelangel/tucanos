# Corrections - Support Sudo et Gestion des Permissions

## 🐛 Problèmes Identifiés et Corrigés

### Problème 1 : `chmod: command not found` avec sudo

**Symptôme :**
```bash
sudo bash install_tucanos_suse15_offline.sh
# chmod: command not found
```

**Cause :** Avec `sudo bash`, le PATH n'est pas configuré correctement

**Solution :** Utiliser le chemin absolu de chmod
```bash
/bin/chmod +x script.sh  # ou /usr/bin/chmod
```

---

### Problème 2 : Permission denied sur `/usr/local/rust/git/db/`

**Symptôme :**
```bash
error: failed to create directory `/usr/local/rust/git/db/coupe-bf27dbab74f7e10c`
Caused by: Permission denied (os error 13)
```

**Cause :** Cargo essaie d'écrire dans `/usr/local/rust/` au lieu de `~/.cargo/`

**Solution :** Configurer `CARGO_HOME` et `RUSTUP_HOME` vers le répertoire utilisateur
```bash
# Déterminer le vrai utilisateur même avec sudo
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo ~$REAL_USER)

export CARGO_HOME="$REAL_HOME/.cargo"
export RUSTUP_HOME="$REAL_HOME/.rustup"
```

---

### Problème 3 : Compilation avec sudo en tant que root

**Symptôme :**
Quand le script est exécuté avec `sudo`, cargo compile en tant que root, créant des fichiers avec mauvaises permissions

**Solution :** Exécuter cargo en tant qu'utilisateur réel
```bash
run_cargo() {
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        sudo -u "$SUDO_USER" env CARGO_HOME="$CARGO_HOME" RUSTUP_HOME="$RUSTUP_HOME" "$@"
    else
        "$@"
    fi
}

run_cargo cargo build --workspace --release
```

---

### Problème 4 : Connexion internet requise (mode offline non activé)

**Symptôme :**
```bash
Updating git repository `https://github.com/LIHPC-Computational-Geometry/coupe.git`
```

**Cause :** Configuration offline de Cargo pas appliquée correctement

**Solution :** Créer `.cargo/config.toml` avec configuration offline
```toml
[net]
offline = true

[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "../cargo-vendor"
```

---

## ✅ Corrections Appliquées au Script

### 1. Utilisation de chemins absolus
```bash
# Avant
chmod +x install_gcc_offline.sh

# Après
/bin/chmod +x install_gcc_offline.sh 2>/dev/null || /usr/bin/chmod +x install_gcc_offline.sh
/bin/bash install_gcc_offline.sh
```

### 2. Configuration CARGO_HOME avec support sudo
```bash
# Déterminer le vrai utilisateur (même si exécuté avec sudo)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo ~$REAL_USER)

export CARGO_HOME="$REAL_HOME/.cargo"
export RUSTUP_HOME="$REAL_HOME/.rustup"

# Corriger les permissions si nécessaire
if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER:$(id -gn $SUDO_USER)" "$CARGO_HOME" 2>/dev/null
    chown -R "$SUDO_USER:$(id -gn $SUDO_USER)" "$RUSTUP_HOME" 2>/dev/null
fi
```

### 3. Fonction run_cargo pour compilation en tant qu'utilisateur réel
```bash
run_cargo() {
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        # Exécuté avec sudo, compiler en tant qu'utilisateur réel
        echo "Compilation en tant que $SUDO_USER (pas root)..."
        sudo -u "$SUDO_USER" env CARGO_HOME="$CARGO_HOME" RUSTUP_HOME="$RUSTUP_HOME" "$@"
    else
        # Exécution normale
        "$@"
    fi
}

# Utilisation
run_cargo cargo build --workspace --release
```

### 4. Configuration mode offline de Cargo
```bash
mkdir -p .cargo
cat > .cargo/config.toml << 'EOF'
[net]
offline = true

[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "../cargo-vendor"
EOF
```

---

## 🚀 Utilisation Recommandée

### Option 1 : Sans sudo (Recommandé si possible)
```bash
./install_tucanos_no_sudo.sh
```
- ✅ Pas de problèmes de permissions
- ✅ Installation dans ~/.local/
- ✅ Pas besoin de droits admin

### Option 2 : Avec sudo (si nécessaire pour installation système)
```bash
sudo bash install_tucanos_suse15_offline.sh
```
- ✅ Maintenant corrigé pour gérer les permissions
- ✅ Compile en tant qu'utilisateur réel
- ✅ CARGO_HOME configuré correctement

### Option 3 : En tant qu'utilisateur normal (si gcc/make déjà installés)
```bash
bash install_tucanos_suse15_offline.sh
```
- ✅ Le plus simple
- ✅ Pas de complications avec sudo

---

## 📋 Checklist de Dépannage

### Si `chmod: command not found`
- ✅ **Corrigé** : Le script utilise maintenant `/bin/chmod` ou `/usr/bin/chmod`

### Si `Permission denied` sur `/usr/local/rust/`
- ✅ **Corrigé** : CARGO_HOME pointe vers `~/.cargo/` de l'utilisateur réel

### Si compilation en tant que root
- ✅ **Corrigé** : Utilise `run_cargo()` pour compiler en tant qu'utilisateur

### Si tentative de connexion internet
- ✅ **Corrigé** : Mode offline activé via `.cargo/config.toml`

### Si dépendances cargo-vendor manquantes
- ⚠️ **Partiel** : Le package contient certaines dépendances
- 💡 **Solution** : Le script demande confirmation pour téléchargement internet

---

## 📊 Comparaison Avant/Après

| Problème | Avant | Après |
|----------|-------|-------|
| **chmod avec sudo** | ❌ Erreur "command not found" | ✅ Chemin absolu utilisé |
| **CARGO_HOME** | ❌ Pointe vers `/usr/local/rust/` | ✅ Pointe vers `~/.cargo/` |
| **Compilation root** | ❌ Fichiers owned par root | ✅ Compilation en tant qu'utilisateur |
| **Mode offline** | ❌ Tentative connexion internet | ✅ Mode offline activé |
| **Permissions** | ❌ Permission denied errors | ✅ Permissions corrigées |

---

## ✨ Résultat

Le script fonctionne maintenant correctement :

- ✅ **Sans sudo** : `./install_tucanos_no_sudo.sh`
- ✅ **Avec sudo** : `sudo bash install_tucanos_suse15_offline.sh`
- ✅ **Normal** : `bash install_tucanos_suse15_offline.sh`

Tous les cas sont gérés correctement avec les permissions appropriées ! 🎉

---

## 📚 Fichiers Mis à Jour

- ✅ `install_tucanos_suse15_offline.sh` - Script principal corrigé
- ✅ `install_tucanos_no_sudo.sh` - Version sans sudo
- ✅ `install_gcc_offline.sh` - Installation gcc
- ✅ `install_make_no_sudo.sh` - Installation make sans sudo
- ✅ `README_INSTALLATION_SANS_SUDO.md` - Documentation sans sudo

---

**Package final : `tucanos-complete-offline-final.zip` (711.1 MB)**

**Chemin : `C:\Users\mickaelangel\Desktop\Nouveau dossier\tucanos-complete-offline-final.zip`**





