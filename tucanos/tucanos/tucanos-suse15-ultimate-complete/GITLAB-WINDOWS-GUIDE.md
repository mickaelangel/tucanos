# 🚀 Guide GitLab sur Windows 11

## 📋 Étapes pour mettre votre projet sur GitLab

### ÉTAPE 1 : Créer un dépôt sur GitLab (via navigateur)

1. **Ouvrez votre GitLab** dans le navigateur (votre URL GitLab)
   - Exemple : `https://gitlab.exemple.com` ou `https://gitlab.com`

2. **Connectez-vous** à votre compte

3. **Cliquez sur "New project"** (Nouveau projet)
   - Bouton en haut à droite ou au centre de la page

4. **Choisissez "Create blank project"** (Créer un projet vide)

5. **Remplissez les informations** :
   - **Project name** : `tucanos-suse15-offline`
   - **Project slug** : (se remplit automatiquement)
   - **Visibility Level** : 
     - `Private` (recommandé pour un projet interne)
     - `Internal` (visible par les utilisateurs connectés)
     - `Public` (visible par tous)
   - **Initialize repository** : ❌ NE COCHEZ PAS "Initialize with README"

6. **Cliquez sur "Create project"**

7. **Copiez l'URL du dépôt** qui s'affiche :
   - URL HTTPS : `https://gitlab.exemple.com/votre-nom/tucanos-suse15-offline.git`
   - URL SSH : `git@gitlab.exemple.com:votre-nom/tucanos-suse15-offline.git`

---

### ÉTAPE 2 : Préparer Git sur Windows 11

#### A. Vérifier si Git est installé

Ouvrez **PowerShell** ou **Git Bash** et tapez :

```powershell
git --version
```

#### B. Si Git n'est pas installé

1. Téléchargez Git : https://git-scm.com/download/win
2. Installez avec les options par défaut
3. Redémarrez PowerShell

---

### ÉTAPE 3 : Initialiser Git localement (Windows)

#### Option A : Avec le script automatique (RECOMMANDÉ)

1. **Ouvrez Git Bash** (clic droit dans le dossier → "Git Bash Here")

2. **Naviguez vers votre dossier** :
```bash
cd /c/Users/mickaelangel/Desktop/tucanos/tucanos/tucanos-suse15-ultimate-complete
```

3. **Exécutez le script** :
```bash
chmod +x init-git.sh
./init-git.sh
```

4. **Suivez les instructions** :
   - Entrez votre nom
   - Entrez votre email
   - Quand demandé "URL du dépôt distant", collez l'URL GitLab copiée à l'étape 1

#### Option B : Manuellement avec PowerShell

1. **Ouvrez PowerShell**

2. **Naviguez vers votre dossier** :
```powershell
cd C:\Users\mickaelangel\Desktop\tucanos\tucanos\tucanos-suse15-ultimate-complete
```

3. **Initialisez Git** :
```powershell
git init
```

4. **Configurez votre identité** :
```powershell
git config user.name "Votre Nom"
git config user.email "votre.email@example.com"
```

5. **Ajoutez tous les fichiers** :
```powershell
git add .
```

6. **Créez le premier commit** :
```powershell
git commit -m "Initial commit: Package Tucanos SUSE 15 SP4"
```

7. **Renommez la branche en main** :
```powershell
git branch -M main
```

8. **Ajoutez le dépôt GitLab distant** (remplacez par votre URL) :
```powershell
git remote add origin https://gitlab.exemple.com/votre-nom/tucanos-suse15-offline.git
```

9. **Poussez vers GitLab** :
```powershell
git push -u origin main
```

---

### ÉTAPE 4 : Authentification GitLab

Lors du premier `git push`, GitLab vous demandera de vous authentifier :

#### Méthode 1 : Token d'accès personnel (RECOMMANDÉ)

1. **Sur GitLab** (dans le navigateur) :
   - Cliquez sur votre avatar (en haut à droite)
   - **Settings** → **Access Tokens**
   - **Add new token**
   - Nom : `git-windows`
   - Scopes : cochez `read_repository` et `write_repository`
   - Cliquez **Create personal access token**
   - **COPIEZ LE TOKEN** (vous ne pourrez plus le voir après !)

2. **Dans PowerShell/Git Bash** :
   - Quand demandé "Username" : votre nom d'utilisateur GitLab
   - Quand demandé "Password" : **COLLEZ LE TOKEN** (pas votre mot de passe)

#### Méthode 2 : Username/Password

- Username : votre nom d'utilisateur GitLab
- Password : votre mot de passe GitLab

---

### ÉTAPE 5 : Vérifier sur GitLab

1. **Retournez sur GitLab** dans votre navigateur
2. **Rafraîchissez la page** de votre projet
3. Vous devriez voir tous vos fichiers !

---

## 🔧 Commandes PowerShell Complètes (copier-coller)

Voici la séquence complète à exécuter dans PowerShell :

```powershell
# 1. Aller dans le dossier
cd C:\Users\mickaelangel\Desktop\tucanos\tucanos\tucanos-suse15-ultimate-complete

# 2. Initialiser Git
git init

# 3. Configurer votre identité (MODIFIEZ avec vos infos)
git config user.name "Votre Nom"
git config user.email "votre.email@example.com"

# 4. Ajouter tous les fichiers
git add .

# 5. Premier commit
git commit -m "Initial commit: Package Tucanos SUSE 15 SP4"

# 6. Renommer la branche
git branch -M main

# 7. Ajouter GitLab (REMPLACEZ par votre URL GitLab)
git remote add origin https://gitlab.exemple.com/votre-nom/tucanos-suse15-offline.git

# 8. Pousser vers GitLab
git push -u origin main
```

---

## 📊 Gestion des Fichiers Volumineux

Votre projet peut être volumineux (~2-3 GB). Voici les options :

### Option 1 : Exclure les gros fichiers (RECOMMANDÉ pour GitLab)

**Avant le `git add .`**, éditez `.gitignore` :

```powershell
notepad .gitignore
```

Ajoutez à la fin :
```
# Exclure les fichiers volumineux (à régénérer)
vendor/
dependencies/system/*.rpm
dependencies/rust/*.tar.gz
```

Ensuite faites :
```powershell
git add .
git commit -m "Initial commit (sans vendor et RPM)"
git push -u origin main
```

**Ajoutez un README pour régénérer** :
```powershell
echo "# Pour régénérer les dépendances : ./prepare-complete-offline-package.sh" > REGENERATE.md
git add REGENERATE.md
git commit -m "Instructions de régénération"
git push
```

### Option 2 : Utiliser Git LFS (si GitLab le supporte)

```powershell
# Installer Git LFS
git lfs install

# Tracker les gros fichiers
git lfs track "*.rpm"
git lfs track "*.tar.gz"
git lfs track "vendor/**"

# Ajouter et commiter
git add .gitattributes
git commit -m "Configuration Git LFS"
git add .
git commit -m "Initial commit avec LFS"
git push -u origin main
```

---

## 🔄 Workflow Quotidien

### Modifier des fichiers et pousser

```powershell
# 1. Modifier vos fichiers...

# 2. Voir ce qui a changé
git status

# 3. Ajouter les modifications
git add .

# 4. Créer un commit
git commit -m "Description de vos modifications"

# 5. Pousser vers GitLab
git push
```

### Récupérer sur une autre machine

```powershell
# Cloner le projet
git clone https://gitlab.exemple.com/votre-nom/tucanos-suse15-offline.git

# Entrer dans le dossier
cd tucanos-suse15-offline

# Si vous avez exclu vendor/, régénérez
./prepare-complete-offline-package.sh
```

---

## ❓ Résolution de Problèmes

### Erreur : "fatal: not a git repository"

Vous n'êtes pas dans le bon dossier. Vérifiez avec :
```powershell
Get-Location
```

### Erreur : "Permission denied"

Utilisez un **token d'accès personnel** au lieu du mot de passe.

### Erreur : "The file will have its original line endings"

C'est juste un avertissement, ignorez-le ou configurez :
```powershell
git config core.autocrlf true
```

### Le push est très lent

Votre projet est probablement trop volumineux. Utilisez l'Option 1 (exclure vendor/ et .rpm).

### Erreur : "repository not found"

Vérifiez que :
1. L'URL est correcte
2. Le projet existe bien sur GitLab
3. Vous avez les permissions

---

## 🎯 Vérification Rapide

Après avoir tout configuré, vérifiez :

```powershell
# Git est initialisé ?
git status

# Dépôt distant configuré ?
git remote -v
# Devrait afficher : origin https://gitlab.exemple.com/...

# Commits présents ?
git log --oneline

# Tout est poussé ?
git status
# Devrait afficher : "nothing to commit, working tree clean"
```

---

## 📱 Interface Graphique (Alternative)

Si vous préférez une interface graphique :

### GitHub Desktop (fonctionne aussi avec GitLab)
1. Téléchargez : https://desktop.github.com/
2. Installez
3. "Add Existing Repository" → choisissez votre dossier
4. Configurez le remote vers GitLab manuellement

### GitKraken
1. Téléchargez : https://www.gitkraken.com/
2. Installez
3. "Open" → choisissez votre dossier
4. Ajoutez le remote GitLab

---

## 🆘 Aide Supplémentaire

- **Git sur Windows** : https://git-scm.com/book/fr/v2
- **Documentation GitLab** : https://docs.gitlab.com/
- **Commandes rapides** : Consultez `GIT-COMMANDES-RAPIDES.txt`

---

## ✅ Checklist Complète

- [ ] Git installé sur Windows 11
- [ ] Projet créé sur GitLab (via navigateur)
- [ ] URL du projet GitLab copiée
- [ ] Git initialisé localement (`git init`)
- [ ] Identité configurée (`git config user.name/email`)
- [ ] Fichiers ajoutés (`git add .`)
- [ ] Premier commit créé
- [ ] Remote GitLab ajouté (`git remote add origin`)
- [ ] Poussé vers GitLab (`git push -u origin main`)
- [ ] Vérifié sur GitLab dans le navigateur

---

**Vous êtes prêt à utiliser GitLab depuis Windows 11 !** 🚀

Pour toute question, consultez les autres guides :
- `GIT-SETUP.md` - Configuration générale Git
- `GIT-COMMANDES-RAPIDES.txt` - Aide-mémoire

