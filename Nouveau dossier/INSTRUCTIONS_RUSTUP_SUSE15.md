# Instructions pour rustup-init sur SUSE 15

## ❌ Erreur commune
**rustup-init pour SUSE 15 n'est PAS un fichier `.exe`** - les fichiers `.exe` sont uniquement pour Windows !

## ✅ Fichier correct pour SUSE 15
Pour SUSE 15 (Linux), rustup-init est un **script shell** (`.sh`)

## 📥 Téléchargement

### Sur un système connecté (Linux/Windows avec WSL) :
```bash
# Télécharger rustup-init pour Linux
wget https://sh.rustup.rs -O rustup-init
# OU
curl https://sh.rustup.rs -o rustup-init

# Rendre exécutable
chmod +x rustup-init
```

### Sur Windows (pour transfert vers SUSE 15) :
```powershell
# Télécharger avec PowerShell
Invoke-WebRequest -Uri "https://sh.rustup.rs" -OutFile "rustup-init"
```

## 📋 Fichiers à transférer sur SUSE 15

1. **`rustup-init`** - Script d'installation Rust (pas .exe !)
2. **`tucanos/`** - Répertoire complet des sources
3. **`install_tucanos_suse15_offline.sh`** - Script d'installation

## 🚀 Installation sur SUSE 15

```bash
# 1. Rendre rustup-init exécutable
chmod +x rustup-init

# 2. Installer Rust
./rustup-init -y --default-toolchain stable-x86_64-unknown-linux-gnu

# 3. Charger l'environnement Rust
source ~/.cargo/env

# 4. Vérifier l'installation
rustc --version
cargo --version
```

## 🔍 Différences entre systèmes

| Système | Fichier rustup-init | Extension |
|---------|-------------------|-----------|
| **Windows** | `rustup-init.exe` | `.exe` |
| **Linux (SUSE 15)** | `rustup-init` | Script shell |
| **macOS** | `rustup-init` | Script shell |

## ⚠️ Points importants

1. **Pas de .exe sur Linux** - SUSE 15 utilise des scripts shell
2. **Permissions** - N'oubliez pas `chmod +x rustup-init`
3. **Architecture** - Utilisez `x86_64-unknown-linux-gnu` pour SUSE 15
4. **Environnement** - Exécutez `source ~/.cargo/env` après installation

## 🛠️ Script automatisé

Utilisez le script `telecharger_rustup_suse15.sh` pour télécharger automatiquement le bon fichier :

```bash
chmod +x telecharger_rustup_suse15.sh
./telecharger_rustup_suse15.sh
```

## 📁 Structure finale sur SUSE 15

```
votre_repertoire/
├── rustup-init                    # Script d'installation Rust
├── tucanos/                       # Sources de Tucanos
│   ├── Cargo.toml
│   ├── src/
│   └── ...
└── install_tucanos_suse15_offline.sh  # Script d'installation
```

---

**Résumé** : Pour SUSE 15, utilisez `rustup-init` (script shell), pas `rustup-init.exe` !





