#!/bin/bash
# Script pour initialiser Git pour ce projet

set -e

echo "==================================================================="
echo "  Initialisation Git pour Tucanos SUSE 15 SP4"
echo "==================================================================="
echo ""

# Vérifier que git est installé
if ! command -v git &> /dev/null; then
    echo "❌ ERREUR: git n'est pas installé"
    echo ""
    echo "Installez git avec:"
    echo "  - Windows: https://git-scm.com/download/win"
    echo "  - Linux: sudo apt install git  ou  sudo zypper install git"
    echo "  - macOS: brew install git"
    exit 1
fi

echo "✓ Git installé: $(git --version)"
echo ""

# Vérifier si .git existe déjà
if [ -d ".git" ]; then
    echo "⚠ Un dépôt Git existe déjà dans ce dossier"
    echo ""
    read -p "Voulez-vous le réinitialiser? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Réinitialisation du dépôt..."
        rm -rf .git
    else
        echo "Annulé. Utilisez les commandes git normalement."
        exit 0
    fi
fi

echo "==================================================================="
echo "  Configuration"
echo "==================================================================="
echo ""

# Demander le nom d'utilisateur
read -p "Nom d'utilisateur Git (ex: Jean Dupont): " git_name
read -p "Email Git (ex: jean.dupont@example.com): " git_email

# Configurer Git localement pour ce projet
git init
git config user.name "$git_name"
git config user.email "$git_email"

echo ""
echo "✓ Dépôt Git initialisé"
echo "✓ Utilisateur: $git_name <$git_email>"
echo ""

# Demander si on veut configurer un dépôt distant
read -p "Voulez-vous configurer un dépôt distant? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Exemples d'URLs de dépôt distant:"
    echo "  - GitLab: http://gitlab.example.com/user/tucanos-suse15.git"
    echo "  - GitHub: https://github.com/user/tucanos-suse15.git"
    echo "  - Local: /chemin/vers/depot.git"
    echo ""
    read -p "URL du dépôt distant: " remote_url
    
    if [ -n "$remote_url" ]; then
        git remote add origin "$remote_url"
        echo "✓ Dépôt distant configuré: $remote_url"
    fi
fi

echo ""
echo "==================================================================="
echo "  Vérification des fichiers"
echo "==================================================================="
echo ""

# Vérifier les fichiers Git
if [ -f ".gitignore" ]; then
    echo "✓ .gitignore présent"
else
    echo "⚠ .gitignore manquant"
fi

if [ -f ".gitattributes" ]; then
    echo "✓ .gitattributes présent"
else
    echo "⚠ .gitattributes manquant"
fi

echo ""
echo "==================================================================="
echo "  Gestion des gros fichiers"
echo "==================================================================="
echo ""

# Vérifier la taille du dossier vendor
if [ -d "vendor" ]; then
    vendor_size=$(du -sh vendor 2>/dev/null | cut -f1)
    echo "Taille du dossier vendor/: $vendor_size"
    echo ""
    echo "Le dossier vendor/ contient les crates Cargo (peut être volumineux)"
    echo ""
    read -p "Voulez-vous EXCLURE vendor/ du dépôt? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> .gitignore
        echo "# Vendor exclus (à régénérer avec download-rust-complete.sh)" >> .gitignore
        echo "vendor/" >> .gitignore
        echo "✓ vendor/ ajouté à .gitignore"
    else
        echo "✓ vendor/ sera inclus dans le dépôt"
    fi
else
    echo "ℹ vendor/ n'existe pas encore (normal avant préparation)"
fi

echo ""

# Vérifier les RPM
rpm_count=$(find dependencies/system -name "*.rpm" 2>/dev/null | wc -l)
if [ $rpm_count -gt 0 ]; then
    rpm_size=$(du -sh dependencies/system 2>/dev/null | cut -f1)
    echo "Packages RPM: $rpm_count fichiers ($rpm_size)"
    echo ""
    read -p "Voulez-vous EXCLURE les .rpm du dépôt? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> .gitignore
        echo "# RPM exclus (à re-télécharger)" >> .gitignore
        echo "dependencies/system/*.rpm" >> .gitignore
        echo "✓ .rpm ajoutés à .gitignore"
    else
        echo "✓ Les .rpm seront inclus"
    fi
fi

echo ""
echo "==================================================================="
echo "  Premier commit"
echo "==================================================================="
echo ""

# Ajouter tous les fichiers
echo "Ajout des fichiers au staging..."
git add .

# Afficher le statut
echo ""
echo "Fichiers à committer:"
git status --short | head -20
total_files=$(git status --short | wc -l)
echo "... ($total_files fichiers au total)"
echo ""

# Demander confirmation pour le commit
read -p "Créer le commit initial? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    git commit -m "Initial commit: Package complet Tucanos pour SUSE 15 SP4

- Code source complet (tmesh, tucanos, pytmesh, pytucanos)
- Scripts de préparation et d'installation
- Documentation complète
- Dépendances Python
- Sources externes (cmake, METIS, NLOPT)
- Configuration Git
"
    
    echo ""
    echo "✓ Commit initial créé"
    
    # Créer la branche main
    git branch -M main
    echo "✓ Branche renommée en 'main'"
else
    echo "Commit annulé. Vous pouvez le faire manuellement avec:"
    echo "  git commit -m \"Initial commit\""
fi

echo ""
echo "==================================================================="
echo "  Configuration terminée!"
echo "==================================================================="
echo ""

echo "📊 Résumé:"
git log --oneline 2>/dev/null || echo "Aucun commit encore"
echo ""

if git remote get-url origin &> /dev/null; then
    remote_url=$(git remote get-url origin)
    echo "📡 Dépôt distant: $remote_url"
    echo ""
    echo "Pour pousser vos commits:"
    echo "  git push -u origin main"
    echo ""
else
    echo "ℹ Aucun dépôt distant configuré"
    echo ""
    echo "Pour ajouter un dépôt distant plus tard:"
    echo "  git remote add origin <URL>"
    echo "  git push -u origin main"
    echo ""
fi

echo "📚 Documentation Git:"
echo "  - Consultez: GIT-SETUP.md"
echo "  - Guide complet avec exemples et bonnes pratiques"
echo ""

echo "🎯 Prochaines étapes:"
echo "  1. Préparez le package: ./prepare-complete-offline-package.sh"
echo "  2. Committez les changements: git add . && git commit -m \"Ajout des dépendances\""
echo "  3. Poussez vers le distant: git push -u origin main"
echo ""

echo "✅ Git configuré avec succès!"


