# 🤝 Contribuer à Tucanos

Merci de votre intérêt pour contribuer à ce projet d'installation offline de Tucanos !

## 📋 Table des Matières

- [Code de Conduite](#code-de-conduite)
- [Comment Contribuer](#comment-contribuer)
- [Structure du Projet](#structure-du-projet)
- [Développement](#développement)
- [Tests](#tests)
- [Pull Requests](#pull-requests)

## 📜 Code de Conduite

Ce projet adhère à un code de conduite. En participant, vous acceptez de respecter ce code.

- Soyez respectueux et inclusif
- Acceptez les critiques constructives
- Concentrez-vous sur ce qui est le mieux pour la communauté

## 🚀 Comment Contribuer

### Signaler des Bugs

Si vous trouvez un bug, ouvrez une [issue](https://github.com/mickaelangel/tucanos/issues) avec :

- **Titre clair** : Décrivez le problème en une phrase
- **Description** : Expliquez ce qui s'est passé
- **Étapes pour reproduire** : Comment recréer le bug
- **Environnement** : OS, version, etc.
- **Logs** : Copiez les messages d'erreur

### Proposer des Améliorations

Pour suggérer une amélioration :

1. Vérifiez que l'amélioration n'existe pas déjà dans les [issues](https://github.com/mickaelangel/tucanos/issues)
2. Ouvrez une issue avec le tag `enhancement`
3. Décrivez clairement le problème et la solution proposée

### Ajouter de la Documentation

La documentation est toujours bienvenue ! Vous pouvez :

- Corriger des fautes de frappe
- Clarifier des instructions
- Ajouter des exemples
- Traduire en d'autres langues

## 📁 Structure du Projet

```
tucanos/
├── README.md              # Documentation principale
├── CHANGELOG.md           # Historique des versions
├── CONTRIBUTING.md        # Ce fichier
│
├── docs/                  # Documentation détaillée
│   ├── LIRE_MOI_INSTALLATION.md
│   ├── INSTALLATION_DEPUIS_GIT.md
│   └── ...
│
├── scripts/               # Scripts d'installation
│   ├── install_tucanos_custom.sh
│   ├── install_tucanos_offline.sh
│   └── ...
│
├── sources/               # Code source Tucanos
│   └── tucanos-main/
│
├── config/                # Fichiers de configuration
└── tests/                 # Tests de validation
```

## 💻 Développement

### Prérequis

- Git
- PowerShell (pour création du package sur Windows)
- Bash (pour scripts d'installation Linux)
- Rust (pour compiler Tucanos)

### Configuration

```bash
# Cloner le dépôt
git clone https://github.com/mickaelangel/tucanos.git
cd tucanos

# Créer une branche pour vos modifications
git checkout -b feature/ma-fonctionnalite
```

### Conventions de Code

#### Scripts Bash

```bash
#!/bin/bash
# Description claire du script

set -e  # Arrêter en cas d'erreur

# Variables en MAJUSCULES
INSTALL_PREFIX="${PREFIX:-$HOME/.local}"

# Fonctions avec commentaires
function install_component() {
    local component_name="$1"
    echo "Installation de $component_name..."
}
```

#### Scripts PowerShell

```powershell
# Description claire du script

# Variables en PascalCase
$InstallPrefix = $env:PREFIX ?? "$env:USERPROFILE\.local"

# Fonctions avec commentaires
function Install-Component {
    param([string]$ComponentName)
    Write-Host "Installation de $ComponentName..."
}
```

#### Documentation (Markdown)

- Utilisez des titres clairs (# ## ###)
- Ajoutez des exemples de code
- Utilisez des emojis pour la lisibilité (📦 🚀 ✅ ❌ ⚠️)
- Vérifiez les liens

### Tests

Avant de soumettre une PR, testez vos modifications :

```bash
# Tester le script d'installation
bash scripts/install_tucanos_custom.sh

# Vérifier la syntaxe bash
shellcheck scripts/*.sh

# Vérifier les liens dans la doc
# (utilisez un outil comme markdown-link-check)
```

## 🔄 Pull Requests

### Processus

1. **Fork** le projet
2. **Créez** une branche (`git checkout -b feature/AmazingFeature`)
3. **Committez** vos changements (`git commit -m 'Add some AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrez** une Pull Request

### Conventions de Commit

Utilisez des messages de commit clairs :

```
✨ feat: Ajouter support pour installation dans /opt
🐛 fix: Corriger erreur de chemin dans install script
📚 docs: Améliorer documentation d'installation
♻️ refactor: Réorganiser structure des scripts
✅ test: Ajouter tests pour validation du package
🎨 style: Corriger formatage du code
```

Préfixes recommandés :
- ✨ `feat`: Nouvelle fonctionnalité
- 🐛 `fix`: Correction de bug
- 📚 `docs`: Documentation
- ♻️ `refactor`: Refactoring
- ✅ `test`: Tests
- 🎨 `style`: Style/formatage
- 🧹 `chore`: Maintenance

### Checklist PR

Avant de soumettre, vérifiez :

- [ ] Le code fonctionne sur SUSE 15 SP4
- [ ] Les scripts bash ont `set -e`
- [ ] La documentation est à jour
- [ ] Les exemples fonctionnent
- [ ] Les liens sont valides
- [ ] Le CHANGELOG.md est mis à jour
- [ ] Les messages de commit sont clairs

## 📝 Types de Contributions

### Scripts

- Améliorer les scripts d'installation
- Ajouter support pour d'autres distributions Linux
- Optimiser les téléchargements
- Gérer plus de cas d'erreur

### Documentation

- Ajouter des guides pour cas d'usage spécifiques
- Créer des tutoriels vidéo
- Traduire en d'autres langues
- Améliorer les exemples

### Tests

- Ajouter des tests automatisés
- Créer des scripts de validation
- Tester sur différentes configurations
- Documenter les résultats de tests

### Package

- Optimiser la taille du package
- Ajouter plus de dépendances offline
- Améliorer la compression
- Créer des variantes du package

## ❓ Questions

Si vous avez des questions, n'hésitez pas à :

- Ouvrir une [issue](https://github.com/mickaelangel/tucanos/issues)
- Consulter la [documentation](docs/)
- Contacter les mainteneurs

## 🙏 Remerciements

Merci à tous les contributeurs qui aident à améliorer ce projet !

---

**Ensemble, rendons l'installation de Tucanos plus facile pour tous !** 🚀

