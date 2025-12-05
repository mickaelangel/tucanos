# 📦 Configuration Git pour le Package Tucanos

## 🎯 Initialiser le dépôt Git local

### Méthode 1 : Git local simple

```bash
cd tucanos-suse15-ultimate-complete

# Initialiser le dépôt
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit: Package complet Tucanos pour SUSE 15 SP4"

# Créer une branche principale (optionnel)
git branch -M main
```

### Méthode 2 : Avec un dépôt distant (GitLab/GitHub interne)

```bash
cd tucanos-suse15-ultimate-complete

# Initialiser le dépôt
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit: Package complet Tucanos pour SUSE 15 SP4"

# Ajouter le dépôt distant (remplacez l'URL)
git remote add origin http://votre-git-local.com/tucanos-suse15.git

# Pousser vers le dépôt distant
git branch -M main
git push -u origin main
```

---

## 📋 Fichiers Git créés

### `.gitignore`
Exclut automatiquement :
- ✅ Fichiers de build (`target/`, `build/`)
- ✅ Fichiers temporaires Python (`__pycache__/`, `*.pyc`)
- ✅ Fichiers générés (`PACKAGE-READY.txt`, `tucanos-install/`)
- ✅ Logs et cache
- ⚠️ **Note** : `vendor/` est inclus par défaut (important pour offline)

### `.gitattributes`
Gère correctement :
- ✅ Line endings (LF pour les scripts shell)
- ✅ Détection des binaires (.rpm, .whl, .tar.gz)

---

## 🔧 Gestion des fichiers volumineux

### Option 1 : Garder vendor/ dans Git (RECOMMANDÉ pour offline)

**Avantage** : Package vraiment complet  
**Inconvénient** : Dépôt volumineux (~1-2 GB)

```bash
# Rien à faire, vendor/ est inclus par défaut
git add .
git commit -m "Ajout du vendor cargo complet"
```

### Option 2 : Exclure vendor/ (si trop volumineux)

**Avantage** : Dépôt plus léger  
**Inconvénient** : Il faudra régénérer vendor/ après clone

```bash
# Éditez .gitignore et décommentez la ligne :
# vendor/

# Ajoutez un script de régénération
echo "cargo vendor vendor --versioned-dirs" > regenerate-vendor.sh
chmod +x regenerate-vendor.sh

git add .gitignore regenerate-vendor.sh
git commit -m "Exclusion du vendor (à régénérer)"
```

### Option 3 : Git LFS pour les gros fichiers (si disponible)

Si votre serveur Git supporte Git LFS :

```bash
# Installer Git LFS
git lfs install

# Tracker les gros fichiers
git lfs track "*.rpm"
git lfs track "*.tar.gz"
git lfs track "vendor/**"

# Commit
git add .gitattributes
git commit -m "Configuration Git LFS"
```

---

## 📦 Exclure les dépendances téléchargées (optionnel)

Si vous ne voulez pas versionner les dépendances téléchargées :

Éditez `.gitignore` et ajoutez :

```
# Dépendances téléchargées (à régénérer)
dependencies/system/*.rpm
dependencies/rust/rust-toolchain-*.tar.gz
dependencies/rust/cargo-vendor.tar.gz
vendor/
```

Puis créez un README pour régénérer :

```bash
cat > REGENERATE-DEPENDENCIES.md << 'EOF'
# Régénération des dépendances

Après avoir cloné ce dépôt, régénérez les dépendances :

```bash
# Télécharger les dépendances
./prepare-complete-offline-package.sh
```

Cela téléchargera :
- Packages RPM
- Rust complet
- Vendor cargo
EOF

git add REGENERATE-DEPENDENCIES.md
git commit -m "Instructions de régénération"
```

---

## 🌳 Structure des branches recommandée

```bash
# Branche principale
git branch -M main

# Créer des branches pour différentes versions
git checkout -b suse15-sp3
git checkout -b suse15-sp4
git checkout -b suse15-sp5

# Retour à main
git checkout main
```

---

## 📊 Taille du dépôt

### Estimation des tailles

| Contenu | Taille approximative |
|---------|---------------------|
| Code source seul | ~50 MB |
| + Packages Python | ~75 MB |
| + Packages RPM | ~500 MB - 1 GB |
| + Vendor cargo | +1-2 GB |
| + Sources (cmake, METIS, NLOPT) | +60 MB |
| **Total complet** | **~2-3 GB** |

### Vérifier la taille

```bash
# Taille actuelle du dossier
du -sh .

# Taille par dossier
du -sh */ | sort -h

# Taille du dépôt Git (après commit)
git count-objects -vH
```

---

## 🔄 Workflow Git recommandé

### Ajouter des modifications

```bash
# Voir les fichiers modifiés
git status

# Ajouter des fichiers spécifiques
git add fichier1.sh fichier2.md

# Ou tout ajouter
git add .

# Commit avec message descriptif
git commit -m "Ajout de scripts alternatifs pour téléchargement RPM"
```

### Créer des tags pour les versions

```bash
# Créer un tag pour une version stable
git tag -a v1.0 -m "Version 1.0 - Package complet SUSE 15 SP4"

# Lister les tags
git tag

# Pousser les tags
git push origin --tags
```

### Voir l'historique

```bash
# Historique complet
git log

# Historique condensé
git log --oneline --graph

# Historique d'un fichier
git log -- README-INSTALLATION-COMPLETE.md
```

---

## 🚀 Cloner et utiliser le dépôt

### Sur une autre machine

```bash
# Cloner le dépôt
git clone http://votre-git-local.com/tucanos-suse15.git
cd tucanos-suse15

# Si vendor/ n'est pas inclus, régénérez
./download-rust-complete.sh

# Utiliser normalement
./prepare-complete-offline-package.sh
```

---

## 🔒 Fichiers sensibles (si applicable)

Si vous avez des informations sensibles à exclure :

```bash
# Créez un fichier .gitignore.local (non versionné)
echo ".gitignore.local" >> .gitignore

# Ajoutez vos exclusions locales
cat > .gitignore.local << 'EOF'
# Fichiers locaux sensibles
config.secret
*.key
*.pem
credentials/
EOF
```

---

## 📝 Bonnes pratiques

### 1. Messages de commit descriptifs

```bash
# ❌ Mauvais
git commit -m "fix"

# ✅ Bon
git commit -m "Fix: Correction du script download-rpm-alternative.sh pour SUSE 15 SP3"
```

### 2. Commits atomiques

```bash
# Un commit par fonctionnalité
git add download-rpm-alternative.sh
git commit -m "Ajout du script alternatif de téléchargement RPM"

git add compile-nlopt-from-source.sh
git commit -m "Ajout du script de compilation NLOPT"
```

### 3. Branches pour expérimentation

```bash
# Créer une branche pour tester
git checkout -b test-nouvelle-methode

# Faire vos modifications...

# Si ça marche, merger
git checkout main
git merge test-nouvelle-methode

# Si ça ne marche pas, supprimer
git branch -D test-nouvelle-methode
```

---

## 🎯 Commandes Git utiles

```bash
# Annuler les modifications non commitées
git checkout -- fichier.sh

# Annuler le dernier commit (garder les modifications)
git reset --soft HEAD~1

# Annuler le dernier commit (perdre les modifications)
git reset --hard HEAD~1

# Voir les différences
git diff

# Voir les différences d'un fichier
git diff README.md

# Stash (mettre de côté) des modifications
git stash
git stash pop

# Nettoyer les fichiers non trackés
git clean -fd
```

---

## 📦 Export sans Git

Si vous voulez exporter le projet sans l'historique Git :

```bash
# Créer une archive propre
git archive --format=tar.gz --output=tucanos-suse15-clean.tar.gz HEAD

# Ou sans git du tout
cd ..
tar czf tucanos-suse15-export.tar.gz \
    --exclude='.git' \
    --exclude='target' \
    --exclude='__pycache__' \
    tucanos-suse15-ultimate-complete/
```

---

## 🎉 Commandes rapides

```bash
# Setup initial complet
git init
git add .
git commit -m "Initial commit: Package Tucanos SUSE 15 SP4"
git branch -M main

# Avec dépôt distant
git remote add origin http://votre-git-local.com/tucanos.git
git push -u origin main

# Cloner ailleurs
git clone http://votre-git-local.com/tucanos.git
```

---

## 📞 Aide

- **Documentation Git** : https://git-scm.com/doc
- **Git en français** : https://git-scm.com/book/fr/v2
- **Aide locale** : `git help <commande>`

---

**Votre dépôt Git local est prêt à être utilisé !** 🚀


