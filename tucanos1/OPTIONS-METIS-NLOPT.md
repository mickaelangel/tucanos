# Options METIS et NLOPT pour Tucanos

## 📦 Packages disponibles

### 1. Package standard (sans METIS/NLOPT)
- **Fichier :** `tucanos-suse15-build-package.zip`
- **METIS :** ❌ Non activé
- **NLOPT :** ❌ Non activé
- **Taille :** Plus petit
- **Dépendances :** Minimales

### 2. Package complet (avec METIS/NLOPT)
- **Fichier :** `tucanos-suse15-build-package-with-metis-nlopt.zip`
- **METIS :** ✅ Activé
- **NLOPT :** ✅ Activé
- **Taille :** Plus grand
- **Dépendances :** Plus nombreuses

## 🔧 À quoi servent METIS et NLOPT ?

### METIS
- **Fonction :** Partitionnement de maillage de haute qualité
- **Avantage :** Meilleure performance pour les maillages complexes
- **Utilisation :** Automatique quand activé
- **Dépendance :** METIS doit être installé sur le système

### NLOPT
- **Fonction :** Optimisation non-linéaire pour le lissage
- **Avantage :** Amélioration de la qualité des maillages
- **Utilisation :** Automatique quand activé
- **Dépendance :** NLOPT doit être installé sur le système

## 🚀 Installation sur SUSE 15

### Package standard
```bash
# Décompression
unzip tucanos-suse15-build-package.zip
cd tucanos-suse15-build-package

# Installation automatique
chmod +x *.sh
./deploy-complete.sh
```

### Package avec METIS/NLOPT
```bash
# Décompression
unzip tucanos-suse15-build-package-with-metis-nlopt.zip
cd tucanos-suse15-build-package

# Installation automatique (inclut METIS et NLOPT)
chmod +x *.sh
./deploy-complete.sh
```

## 📋 Dépendances supplémentaires pour METIS/NLOPT

Le script `install-dependencies.sh` installera automatiquement :

### NLOPT (disponible dans les dépôts SUSE)
```bash
sudo zypper install nlopt-devel
```

### METIS (installation manuelle requise)
```bash
# METIS n'est pas dans les dépôts standard de SUSE
# Installation manuelle depuis : https://github.com/KarypisLab/METIS
```

## ⚙️ Configuration de compilation

### Sans METIS/NLOPT (par défaut)
```bash
./build-tucanos.sh
```

### Avec METIS seulement
```bash
./build-tucanos.sh --with-metis
```

### Avec NLOPT seulement
```bash
./build-tucanos.sh --with-nlopt
```

### Avec les deux
```bash
./build-tucanos.sh --with-metis --with-nlopt
```

## 🎯 Recommandations

### Utilise le package standard si :
- Tu n'as pas besoin de partitionnement avancé
- Tu veux une installation simple et rapide
- Tu travailles avec des maillages simples

### Utilise le package avec METIS/NLOPT si :
- Tu travailles avec des maillages complexes
- Tu as besoin de la meilleure qualité de maillage
- Tu peux installer les dépendances supplémentaires

## 🔍 Vérification après installation

```bash
# Vérifier que les fonctionnalités sont activées
cd tucanos-install
./test-installation.sh

# Vérifier les dépendances
ldd lib/libtucanos.so | grep -E "(metis|nlopt)"
```

## 📚 Documentation

- **METIS :** https://github.com/KarypisLab/METIS
- **NLOPT :** https://github.com/stevengj/nlopt
- **Tucanos :** https://github.com/tucanos/tucanos

## ✨ Résumé

Tu as maintenant **deux options** :

1. **`tucanos-suse15-build-package.zip`** - Version standard (recommandée pour commencer)
2. **`tucanos-suse15-build-package-with-metis-nlopt.zip`** - Version complète avec toutes les fonctionnalités

Choisis selon tes besoins ! 🚀




