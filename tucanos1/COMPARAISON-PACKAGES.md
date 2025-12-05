# Comparaison des packages Tucanos pour SUSE 15

## 📦 Trois options disponibles

### 1. Package standard (avec internet)
- **Fichier :** `tucanos-suse15-build-package.zip`
- **Internet requis :** ✅ OUI (pour installer les dépendances)
- **METIS/NLOPT :** ❌ Non activé
- **Utilisation :** Machine SUSE 15 avec connexion internet

### 2. Package complet (avec internet)
- **Fichier :** `tucanos-suse15-build-package-with-metis-nlopt.zip`
- **Internet requis :** ✅ OUI (pour installer les dépendances)
- **METIS/NLOPT :** ✅ Activé
- **Utilisation :** Machine SUSE 15 avec connexion internet

### 3. Package hors ligne (VRAIMENT hors ligne)
- **Fichier :** `tucanos-suse15-offline-package.zip`
- **Internet requis :** ❌ NON (après préparation)
- **METIS/NLOPT :** ✅ Activé
- **Utilisation :** Machine SUSE 15 SANS connexion internet

## 🔄 Workflow pour chaque option

### Option 1 & 2 : Avec internet
```bash
# Sur SUSE 15 avec internet
unzip tucanos-suse15-build-package.zip
cd tucanos-suse15-build-package
chmod +x *.sh
./deploy-complete.sh  # Installe tout automatiquement
```

### Option 3 : Vraiment hors ligne

#### Étape 1 : Préparation (sur machine avec internet)
```bash
# Sur une machine avec internet (peut être Windows, Linux, etc.)
unzip tucanos-suse15-offline-package.zip
cd tucanos-suse15-offline-package
chmod +x *.sh
./prepare-for-offline.sh  # Installe les prérequis
```

#### Étape 2 : Transfert
```bash
# Transférer le dossier complet sur SUSE 15 hors ligne
```

#### Étape 3 : Installation (sur SUSE 15 hors ligne)
```bash
# Sur SUSE 15 SANS internet
cd tucanos-suse15-offline-package
chmod +x *.sh
./check-prerequisites.sh  # Vérifier que tout est prêt
./build-tucanos-offline.sh  # Compiler (sans internet)
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh
```

## 📋 Dépendances par option

### Options 1 & 2 (avec internet)
- ✅ Installation automatique des dépendances
- ✅ Téléchargement de Rust
- ✅ Installation de Python, gcc, etc.
- ✅ Installation de NLOPT
- ⚠️ METIS : Installation manuelle requise

### Option 3 (hors ligne)
- ❌ Dépendances installées AVANT le transfert
- ❌ Rust installé AVANT le transfert
- ❌ Python, gcc, etc. installés AVANT
- ❌ NLOPT installé AVANT
- ⚠️ METIS : Installation manuelle AVANT

## 🎯 Recommandations

### Choisis l'option 1 si :
- Tu as une connexion internet sur SUSE 15
- Tu veux une installation simple
- Tu n'as pas besoin de METIS/NLOPT

### Choisis l'option 2 si :
- Tu as une connexion internet sur SUSE 15
- Tu veux toutes les fonctionnalités (METIS/NLOPT)
- Tu peux installer METIS manuellement

### Choisis l'option 3 si :
- Tu n'as PAS de connexion internet sur SUSE 15
- Tu veux toutes les fonctionnalités
- Tu peux préparer les dépendances sur une autre machine

## ⚡ Installation rapide

### Avec internet (recommandé)
```bash
# Télécharge et installe tout automatiquement
wget [URL-du-package]
unzip tucanos-suse15-build-package.zip
cd tucanos-suse15-build-package
chmod +x *.sh
./deploy-complete.sh
```

### Sans internet
```bash
# 1. Sur machine avec internet
./prepare-for-offline.sh

# 2. Transférer sur SUSE 15

# 3. Sur SUSE 15 hors ligne
./build-tucanos-offline.sh
cd tucanos-install && sudo ./install-system.sh && ./install-python.sh
```

## 🔍 Vérification après installation

```bash
# Test des bibliothèques
ldd /usr/local/lib/libtucanos.so

# Test Python
python3 -c "import pytmesh, pytucanos; print('Import réussi!')"

# Test de compilation C
gcc -I/usr/local/include -L/usr/local/lib -ltucanos test.c -o test
```

## 📚 Documentation

- **Option 1 & 2 :** `README-INSTALL.md`
- **Option 3 :** `README-OFFLINE.md`
- **Comparaison :** Ce fichier

## ✨ Résumé

| Option | Internet requis | METIS/NLOPT | Complexité | Recommandé pour |
|--------|----------------|--------------|------------|-----------------|
| 1 | ✅ Oui | ❌ Non | Simple | Débutants |
| 2 | ✅ Oui | ✅ Oui | Moyenne | Utilisateurs avancés |
| 3 | ❌ Non | ✅ Oui | Élevée | Environnements isolés |

**Choisis selon tes besoins !** 🚀




