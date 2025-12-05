# Script PowerShell pour initialiser Git et pousser vers GitLab
# Pour Windows 11

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  Initialisation Git pour GitLab - Windows 11" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier que Git est installé
try {
    $gitVersion = git --version
    Write-Host "✓ Git installé: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ ERREUR: Git n'est pas installé" -ForegroundColor Red
    Write-Host ""
    Write-Host "Téléchargez Git depuis: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host "Puis relancez ce script." -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}

Write-Host ""

# Vérifier si .git existe déjà
if (Test-Path ".git") {
    Write-Host "⚠ Un dépôt Git existe déjà dans ce dossier" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Voulez-vous le réinitialiser? (o/N)"
    
    if ($response -eq "o" -or $response -eq "O" -or $response -eq "y" -or $response -eq "Y") {
        Write-Host "Réinitialisation du dépôt..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force .git
    } else {
        Write-Host "Annulé. Utilisez les commandes git normalement." -ForegroundColor Yellow
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 0
    }
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  Configuration" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

# Demander les informations utilisateur
$gitName = Read-Host "Nom d'utilisateur Git (ex: Jean Dupont)"
$gitEmail = Read-Host "Email Git (ex: jean.dupont@example.com)"

# Initialiser Git
Write-Host ""
Write-Host "Initialisation du dépôt Git..." -ForegroundColor Yellow
git init

# Configurer l'utilisateur
git config user.name "$gitName"
git config user.email "$gitEmail"

# Configurer pour Windows
git config core.autocrlf true

Write-Host "✓ Dépôt Git initialisé" -ForegroundColor Green
Write-Host "✓ Utilisateur: $gitName <$gitEmail>" -ForegroundColor Green
Write-Host ""

# GitLab
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  Configuration GitLab" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Avez-vous créé un projet sur GitLab?" -ForegroundColor Yellow
Write-Host ""
Write-Host "Si NON:" -ForegroundColor White
Write-Host "  1. Ouvrez GitLab dans votre navigateur" -ForegroundColor White
Write-Host "  2. Cliquez sur 'New project' → 'Create blank project'" -ForegroundColor White
Write-Host "  3. Nom du projet: tucanos-suse15-offline" -ForegroundColor White
Write-Host "  4. NE COCHEZ PAS 'Initialize with README'" -ForegroundColor White
Write-Host "  5. Cliquez 'Create project'" -ForegroundColor White
Write-Host "  6. Copiez l'URL du dépôt" -ForegroundColor White
Write-Host ""

$response = Read-Host "Voulez-vous configurer GitLab maintenant? (o/N)"

if ($response -eq "o" -or $response -eq "O" -or $response -eq "y" -or $response -eq "Y") {
    Write-Host ""
    Write-Host "Exemples d'URLs GitLab:" -ForegroundColor Cyan
    Write-Host "  - https://gitlab.com/votre-nom/tucanos-suse15-offline.git" -ForegroundColor Gray
    Write-Host "  - https://gitlab.exemple.com/votre-nom/tucanos.git" -ForegroundColor Gray
    Write-Host ""
    
    $gitlabUrl = Read-Host "URL de votre dépôt GitLab"
    
    if ($gitlabUrl) {
        git remote add origin $gitlabUrl
        Write-Host "✓ Dépôt GitLab configuré: $gitlabUrl" -ForegroundColor Green
        $hasGitlab = $true
    }
} else {
    $hasGitlab = $false
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  Gestion des fichiers volumineux" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier vendor/
if (Test-Path "vendor") {
    $vendorSize = (Get-ChildItem vendor -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Taille du dossier vendor/: $([math]::Round($vendorSize, 2)) MB" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Le dossier vendor/ contient les crates Cargo (peut être volumineux)" -ForegroundColor Yellow
    Write-Host ""
    
    $response = Read-Host "Voulez-vous EXCLURE vendor/ du dépôt? (O/n)"
    
    if ($response -eq "" -or $response -eq "o" -or $response -eq "O" -or $response -eq "y" -or $response -eq "Y") {
        Add-Content -Path .gitignore -Value "`n# Vendor exclus (à régénérer)"
        Add-Content -Path .gitignore -Value "vendor/"
        Write-Host "✓ vendor/ ajouté à .gitignore" -ForegroundColor Green
    } else {
        Write-Host "✓ vendor/ sera inclus dans le dépôt" -ForegroundColor Green
    }
} else {
    Write-Host "ℹ vendor/ n'existe pas encore (normal avant préparation)" -ForegroundColor Gray
}

Write-Host ""

# Vérifier les RPM
$rpmCount = (Get-ChildItem "dependencies\system\*.rpm" -ErrorAction SilentlyContinue | Measure-Object).Count
if ($rpmCount -gt 0) {
    $rpmSize = (Get-ChildItem "dependencies\system\*.rpm" -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Packages RPM: $rpmCount fichiers ($([math]::Round($rpmSize, 2)) MB)" -ForegroundColor Yellow
    Write-Host ""
    
    $response = Read-Host "Voulez-vous EXCLURE les .rpm du dépôt? (O/n)"
    
    if ($response -eq "" -or $response -eq "o" -or $response -eq "O" -or $response -eq "y" -or $response -eq "Y") {
        Add-Content -Path .gitignore -Value "`n# RPM exclus (à re-télécharger)"
        Add-Content -Path .gitignore -Value "dependencies/system/*.rpm"
        Write-Host "✓ .rpm ajoutés à .gitignore" -ForegroundColor Green
    } else {
        Write-Host "✓ Les .rpm seront inclus" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  Premier commit" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

# Ajouter tous les fichiers
Write-Host "Ajout des fichiers au staging..." -ForegroundColor Yellow
git add .

# Afficher un résumé
$stagedFiles = git diff --cached --name-only | Measure-Object
Write-Host ""
Write-Host "Fichiers à committer: $($stagedFiles.Count)" -ForegroundColor Cyan
Write-Host ""

# Créer le commit
Write-Host "Création du commit initial..." -ForegroundColor Yellow
git commit -m "Initial commit: Package complet Tucanos pour SUSE 15 SP4

- Code source complet (tmesh, tucanos, pytmesh, pytucanos)
- Scripts de préparation et d'installation
- Documentation complète
- Dépendances Python
- Sources externes (cmake, METIS, NLOPT)
- Configuration Git
"

Write-Host "✓ Commit initial créé" -ForegroundColor Green

# Renommer la branche
git branch -M main
Write-Host "✓ Branche renommée en 'main'" -ForegroundColor Green

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  Push vers GitLab" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

if ($hasGitlab) {
    Write-Host "Prêt à pousser vers GitLab!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "IMPORTANT - Authentification:" -ForegroundColor Yellow
    Write-Host "  - Username: votre nom d'utilisateur GitLab" -ForegroundColor White
    Write-Host "  - Password: utilisez un TOKEN d'accès personnel (pas votre mot de passe!)" -ForegroundColor White
    Write-Host ""
    Write-Host "Pour créer un token:" -ForegroundColor Cyan
    Write-Host "  1. GitLab → Avatar → Settings → Access Tokens" -ForegroundColor White
    Write-Host "  2. Add new token" -ForegroundColor White
    Write-Host "  3. Scopes: read_repository + write_repository" -ForegroundColor White
    Write-Host "  4. Create et COPIEZ le token" -ForegroundColor White
    Write-Host ""
    
    $response = Read-Host "Pousser vers GitLab maintenant? (o/N)"
    
    if ($response -eq "o" -or $response -eq "O" -or $response -eq "y" -or $response -eq "Y") {
        Write-Host ""
        Write-Host "Push en cours (peut prendre du temps selon la taille)..." -ForegroundColor Yellow
        git push -u origin main
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓ Push réussi!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Vérifiez sur GitLab dans votre navigateur!" -ForegroundColor Cyan
        } else {
            Write-Host ""
            Write-Host "❌ Erreur lors du push" -ForegroundColor Red
            Write-Host "Vous pouvez réessayer avec: git push -u origin main" -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Write-Host "Push annulé. Vous pouvez le faire plus tard avec:" -ForegroundColor Yellow
        Write-Host "  git push -u origin main" -ForegroundColor Cyan
    }
} else {
    Write-Host "Aucun dépôt distant configuré." -ForegroundColor Gray
    Write-Host ""
    Write-Host "Pour ajouter GitLab plus tard:" -ForegroundColor Yellow
    Write-Host "  git remote add origin <URL_GITLAB>" -ForegroundColor Cyan
    Write-Host "  git push -u origin main" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  Configuration terminée!" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

# Résumé
Write-Host "📊 Résumé:" -ForegroundColor Green
git log --oneline -1

Write-Host ""
if (git remote get-url origin 2>$null) {
    $remoteUrl = git remote get-url origin
    Write-Host "📡 Dépôt distant: $remoteUrl" -ForegroundColor Green
} else {
    Write-Host "ℹ Aucun dépôt distant configuré" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Write-Host "  - GITLAB-WINDOWS-GUIDE.md   (guide complet GitLab + Windows)" -ForegroundColor White
Write-Host "  - GIT-SETUP.md              (configuration Git générale)" -ForegroundColor White
Write-Host "  - GIT-COMMANDES-RAPIDES.txt (aide-mémoire)" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "  1. Vérifiez sur GitLab dans votre navigateur" -ForegroundColor White
Write-Host "  2. Pour ajouter des modifications:" -ForegroundColor White
Write-Host "     git add ." -ForegroundColor Gray
Write-Host "     git commit -m 'Description'" -ForegroundColor Gray
Write-Host "     git push" -ForegroundColor Gray

Write-Host ""
Write-Host "✅ Git configuré avec succès!" -ForegroundColor Green
Write-Host ""

Read-Host "Appuyez sur Entrée pour quitter"

