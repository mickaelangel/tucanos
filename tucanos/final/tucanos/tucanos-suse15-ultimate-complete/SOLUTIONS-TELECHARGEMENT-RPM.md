# 🔧 Solutions pour le Téléchargement des Packages RPM et NLOPT

## 🚨 Problème

Vous n'arrivez pas à télécharger les packages RPM et nlopt avec le script `download-rpm-dependencies.sh`.

---

## 📋 Diagnostic

### Pourquoi ça ne fonctionne pas ?

Vérifiez d'abord ces points :

```bash
# 1. Êtes-vous sur SUSE/openSUSE ?
cat /etc/os-release

# 2. zypper est-il disponible ?
which zypper

# 3. Les dépôts sont-ils configurés ?
sudo zypper lr

# 4. Avez-vous accès internet ?
ping -c 3 download.opensuse.org
```

**Causes fréquentes** :
- ❌ Vous n'êtes pas sur SUSE/openSUSE (Ubuntu, Debian, etc.)
- ❌ Les dépôts SUSE ne sont pas configurés
- ❌ nlopt n'existe pas dans les dépôts officiels
- ❌ Problème de réseau/proxy

---

## ✅ Solutions

### Solution 1 : Script Alternatif (RECOMMANDÉ)

J'ai créé un script avec 4 méthodes différentes :

```bash
chmod +x download-rpm-alternative.sh
./download-rpm-alternative.sh
```

**Méthodes disponibles** :
1. **zypper download** (si vous êtes sur SUSE)
2. **wget depuis les dépôts** en ligne
3. **Liste manuelle** des URLs à télécharger
4. **Installation minimale** (packages déjà présents sur la cible)

---

### Solution 2 : Téléchargement Manuel des RPM

#### Étape 1 : Visitez les dépôts OpenSUSE

Ouvrez dans votre navigateur :
```
https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/
```

#### Étape 2 : Téléchargez les packages essentiels

Utilisez Ctrl+F pour chercher et télécharger :

**OBLIGATOIRES** :
- [ ] `gcc-7-*.x86_64.rpm`
- [ ] `gcc7-c++-*.x86_64.rpm`
- [ ] `libstdc++6-devel-gcc7-*.x86_64.rpm`
- [ ] `make-*.x86_64.rpm`
- [ ] `python3-3.*.x86_64.rpm`
- [ ] `python3-devel-3.*.x86_64.rpm`
- [ ] `python3-pip-*.noarch.rpm`
- [ ] `pkg-config-*.x86_64.rpm`
- [ ] `glibc-devel-*.x86_64.rpm`

**RECOMMANDÉS** :
- [ ] `cmake-*.x86_64.rpm`
- [ ] `zlib-devel-*.x86_64.rpm`
- [ ] `libopenssl-devel-*.x86_64.rpm`

#### Étape 3 : Placez les fichiers

```bash
# Créez le dossier
mkdir -p dependencies/system

# Déplacez tous les .rpm téléchargés
mv ~/Downloads/*.rpm dependencies/system/

# Vérifiez
ls dependencies/system/*.rpm
```

---

### Solution 3 : Utiliser software.opensuse.org

Site plus convivial pour télécharger des packages individuels :

1. **Visitez** : https://software.opensuse.org
2. **Cherchez** le package (ex: "gcc")
3. **Sélectionnez** "openSUSE Leap 15.4"
4. **Téléchargez** le fichier .rpm
5. **Répétez** pour chaque package

**Exemple pour gcc** :
```
https://software.opensuse.org/package/gcc
→ Cliquez sur "Show other versions"
→ Sélectionnez "openSUSE Leap 15.4"
→ Téléchargez le .rpm
```

---

### Solution 4 : Installation Minimale (Si échec total)

Si vous ne pouvez vraiment pas télécharger les RPM :

#### Option A : Système avec packages pré-installés

Si votre SUSE 15 SP4 cible a déjà les outils de base installés :

```bash
# Sur la machine cible, vérifiez :
gcc --version
python3 --version
make --version

# Si ces commandes fonctionnent, vous avez déjà l'essentiel !
```

**Notre package fournira** :
- ✅ Rust complet
- ✅ Packages Python (maturin, numpy)
- ✅ Code source Tucanos

Vous pouvez installer avec ces seuls éléments.

#### Option B : Demandez à l'admin système

Sur la machine cible (SUSE 15 SP4), l'administrateur peut installer :

```bash
sudo zypper install gcc gcc-c++ make python3 python3-devel \
    python3-pip glibc-devel libstdc++-devel zlib-devel \
    libopenssl-devel pkg-config cmake
```

---

## 🔬 Solution pour NLOPT

NLOPT n'est **généralement PAS disponible** dans les dépôts SUSE standard.

### Option 1 : Compiler depuis les sources (RECOMMANDÉ)

J'ai créé un script pour ça :

```bash
chmod +x compile-nlopt-from-source.sh
./compile-nlopt-from-source.sh
```

**Ce script** :
- ✅ Utilise l'archive `nlopt-2.7.1.tar.gz` déjà présente
- ✅ Compile avec cmake (fourni dans le package)
- ✅ Installe localement (pas besoin de sudo)
- ✅ Crée le fichier pkg-config

**Prérequis** : gcc, g++, make (fournis par les RPM de base)

### Option 2 : Compiler manuellement

Si le script ne fonctionne pas :

```bash
# Extraire
cd dependencies/sources
tar xzf nlopt-2.7.1.tar.gz
cd nlopt-2.7.1

# Créer le build
mkdir build && cd build

# Configurer (installation locale)
cmake -DCMAKE_INSTALL_PREFIX=$HOME/.local \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      ..

# Compiler
make -j$(nproc)

# Installer
make install

# Configurer l'environnement
echo 'export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"' >> ~/.bashrc
echo 'export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:$PKG_CONFIG_PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Option 3 : Compiler sans NLOPT

Si vous ne parvenez pas à compiler NLOPT, vous pouvez compiler Tucanos **sans** NLOPT :

**Éditez** `install-complete-offline-improved.sh` :

Trouvez la ligne (vers ligne 200) :
```bash
if [ "$USE_NLOPT" = true ]; then
    FEATURES="$FEATURES --features nlopt"
```

Et remplacez par :
```bash
# Désactiver NLOPT
USE_NLOPT=false
# if [ "$USE_NLOPT" = true ]; then
#     FEATURES="$FEATURES --features nlopt"
```

**Note** : NLOPT est optionnel. Tucanos fonctionnera sans, mais certaines optimisations ne seront pas disponibles.

---

## 🎯 Stratégie Recommandée (Étape par étape)

### 1️⃣ Pour les packages RPM :

**Si vous êtes sur SUSE 15** :
```bash
./download-rpm-alternative.sh
# Choisissez option 1 (zypper)
```

**Si vous êtes sur autre Linux** :
```bash
./download-rpm-alternative.sh
# Choisissez option 3 (liste manuelle)
# Puis téléchargez manuellement depuis votre navigateur
```

**Si échec complet** :
```bash
# Utilisez l'approche minimale
# Le système cible aura les packages pré-installés
```

### 2️⃣ Pour NLOPT :

```bash
# Après avoir transféré sur SUSE 15 SP4, compilez localement:
./compile-nlopt-from-source.sh
```

**OU**

```bash
# Désactivez NLOPT dans le script d'installation
# Éditez install-complete-offline-improved.sh comme indiqué ci-dessus
```

---

## 📊 Tableau Récapitulatif

| Situation | Solution RPM | Solution NLOPT |
|-----------|--------------|----------------|
| Sur SUSE 15 avec internet | `download-rpm-alternative.sh` option 1 | `compile-nlopt-from-source.sh` |
| Sur autre Linux avec internet | Téléchargement manuel via navigateur | `compile-nlopt-from-source.sh` |
| Impossible de télécharger | Approche minimale | Compiler sur la cible |
| Échec total | Pré-installer sur la cible | Désactiver NLOPT |

---

## 🆘 Cas d'Usage Pratiques

### Cas 1 : "Je suis sur Ubuntu, pas SUSE"

```bash
# 1. Exécutez le script alternatif
./download-rpm-alternative.sh
# Choisissez option 3

# 2. Ouvrez votre navigateur
firefox "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/"

# 3. Téléchargez manuellement les packages de la liste
cat dependencies/system/PACKAGES-TO-DOWNLOAD.txt

# 4. Pour NLOPT, copiez juste l'archive (déjà présente)
# Vous compilerez sur la machine SUSE cible
```

### Cas 2 : "zypper ne trouve pas certains packages"

```bash
# Cherchez les packages sur software.opensuse.org
# Exemple pour nlopt-devel :
firefox "https://software.opensuse.org/package/nlopt-devel"

# Si introuvable, utilisez compile-nlopt-from-source.sh
```

### Cas 3 : "Je n'arrive à télécharger aucun RPM"

```bash
# Solution : Installation minimale

# 1. Sur la machine SUSE 15 SP4 cible, installez manuellement :
sudo zypper install gcc gcc-c++ make python3 python3-devel python3-pip cmake

# 2. Transférez uniquement :
#    - Code source Tucanos
#    - Rust (dependencies/rust/)
#    - Vendor cargo (vendor/)
#    - Packages Python (dependencies/python/)
#    - Sources NLOPT (dependencies/sources/)

# 3. Installez normalement avec install-complete-offline-improved.sh
```

---

## ✅ Vérification

Après avoir appliqué une solution, vérifiez :

```bash
# Compter les RPM
ls dependencies/system/*.rpm 2>/dev/null | wc -l
# Au minimum 10-15 packages

# Vérifier NLOPT (si compilé)
ls -l ~/.local/lib/libnlopt.so 2>/dev/null
# ou
pkg-config --exists nlopt && echo "NLOPT OK"

# Vérifier les autres dépendances
ls dependencies/rust/rustup-init
ls dependencies/python/python/*.whl
ls vendor/ | head
```

---

## 📞 Besoin d'Aide Supplémentaire ?

Si aucune solution ne fonctionne :

1. **Décrivez votre situation** :
   - Système d'exploitation actuel ?
   - Erreurs exactes rencontrées ?
   - Que montre `cat /etc/os-release` ?

2. **Alternatives** :
   - Utilisez Docker avec une image SUSE 15
   - Demandez l'accès à une VM SUSE 15
   - Utilisez l'approche installation minimale

3. **Documentation** :
   - Consultez `README-INSTALLATION-COMPLETE.md`
   - Section Dépannage complète

---

## 🎉 Résumé

**Pour les RPM** :
1. Essayez `download-rpm-alternative.sh`
2. Si échec : téléchargement manuel via navigateur
3. Si échec total : approche minimale (packages pré-installés)

**Pour NLOPT** :
1. Utilisez `compile-nlopt-from-source.sh` (sur la machine cible)
2. Si échec : compilation manuelle
3. Si échec total : désactivez NLOPT

**L'essentiel** : Vous pouvez installer Tucanos même sans tous les RPM, tant que gcc, python3 et make sont disponibles sur la machine cible !

Bonne chance ! 🚀
