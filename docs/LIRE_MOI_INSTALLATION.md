# 📦 Installation Tucanos SUSE 15 SP4 - 100% Offline

## 🚀 Installation Rapide (1 seule commande)

```bash
bash install_tucanos_offline.sh
```

C'est tout ! Le script installe automatiquement **tout** :
- ✅ make (si nécessaire)
- ✅ Rust (si nécessaire)
- ✅ **Tucanos** (compilation 100% offline)
- ✅ METIS (si g++ disponible)
- ✅ NLOPT (si g++ disponible)

## 📋 Prérequis Système

### Obligatoires (déjà sur SUSE 15 SP4)
- ✅ **gcc** : Normalement préinstallé

### Optionnels (pour METIS et NLOPT)
- ⚠️ **g++** (gcc-c++) : Pour compiler METIS et NLOPT

### Vérifier g++
```bash
g++ --version
```

**Si g++ n'est pas trouvé** :
```bash
# Demander à l'administrateur système
sudo zypper install gcc-c++
```

## 🎯 Que se passe-t-il ?

### Si g++ est disponible ✅
Le script installe automatiquement :
1. Tucanos
2. METIS (partitionnement de maillage)
3. NLOPT (optimisation)

### Si g++ n'est PAS disponible ⚠️
Le script installe :
1. Tucanos ✅ (fonctionne parfaitement)
2. METIS ❌ (optionnel, non critique)
3. NLOPT ❌ (optionnel, non critique)

**Tucanos fonctionne sans METIS et NLOPT !**

## 📁 Structure du Package

```
tucanos-complete-offline-final/
├── install_tucanos_offline.sh        ← LANCEZ CE SCRIPT
├── tucanos-main/                      ← Sources Tucanos
├── cargo-vendor/                      ← 231 packages Rust (302 MB)
├── rust-offline-package/              ← Rust 1.89.0
├── suse-packages/                     ← make sources
├── suse-packages-optional/            ← METIS et NLOPT
│   ├── install_metis.sh
│   ├── install_nlopt.sh
│   └── sources/
│       ├── metis-5.2.1.tar.gz
│       └── nlopt-2.7.1.tar.gz
└── README et documentation
```

## ⚙️ Installation Manuelle (si besoin)

### 1. Installer Tucanos seulement
```bash
bash install_tucanos_offline.sh
# Arrêtez quand Tucanos est compilé
```

### 2. Installer METIS/NLOPT plus tard
```bash
# Après avoir obtenu g++ de l'admin
cd suse-packages-optional
bash install_metis.sh
bash install_nlopt.sh
```

## ✅ Vérification de l'Installation

```bash
# Vérifier Tucanos
ls -lh ~/.local/lib/libtucanos.so

# Vérifier METIS
gpmetis --help

# Vérifier NLOPT
pkg-config --modversion nlopt
ls -lh ~/.local/lib/libnlopt.so

# Activer l'environnement
source ~/.bashrc
```

## 🔍 Résolution de Problèmes

### Erreur : "g++ not found" lors de METIS/NLOPT
**Solution** : C'est normal si g++ n'est pas installé.
- Tucanos fonctionne quand même
- Installez g++ avec l'admin : `sudo zypper install gcc-c++`

### Erreur : "cargo build failed"
**Causes possibles** :
1. Espace disque insuffisant : `df -h`
2. cargo-vendor incomplet : Vérifiez `ls -la cargo-vendor/`

### Erreur : "Permission denied"
**Solution** : N'utilisez PAS sudo avec ce script.
```bash
# BON
bash install_tucanos_offline.sh

# MAUVAIS
sudo bash install_tucanos_offline.sh
```

## 📊 Résumé

| Composant | gcc | g++ | Obligatoire |
|-----------|-----|-----|-------------|
| **Tucanos** | ✅ | ❌ | OUI |
| **METIS** | ✅ | ✅ | NON (optionnel) |
| **NLOPT** | ✅ | ✅ | NON (optionnel) |

**Conclusion** : Vous pouvez utiliser Tucanos sans g++. METIS et NLOPT sont des bonus.

## 📞 Support

Si le script échoue, copiez **tout** le message d'erreur pour diagnostic.

**Bon courage ! 🚀**



