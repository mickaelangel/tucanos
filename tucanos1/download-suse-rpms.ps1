# Script PowerShell pour télécharger les packages RPM SUSE nécessaires
# À exécuter sur une machine avec internet AVANT le transfert

Write-Host "=== Téléchargement des packages RPM SUSE ===" -ForegroundColor Green

# Créer le répertoire des dépendances système
New-Item -ItemType Directory -Path "dependencies" -Force | Out-Null
New-Item -ItemType Directory -Path "dependencies/system" -Force | Out-Null

# Configuration des dépôts SUSE
$SuseRepos = @{
    "opensuse-leap-15.5" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/"
    "opensuse-leap-15.4" = "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/"
    "opensuse-leap-15.3" = "https://download.opensuse.org/distribution/leap/15.3/repo/oss/x86_64/"
    "sles-15" = "https://download.suse.com/ibs/SUSE:/SLE-15:/GA/standard/x86_64/"
}

# Packages nécessaires
$RequiredPackages = @(
    "gcc",
    "gcc-c++", 
    "make",
    "pkg-config",
    "python3",
    "python3-devel",
    "python3-pip",
    "nlopt-devel",
    "glibc-devel",
    "libstdc++-devel",
    "zlib-devel",
    "openssl-devel",
    "libffi-devel"
)

Write-Host "Packages à télécharger:" -ForegroundColor Yellow
foreach ($package in $RequiredPackages) {
    Write-Host "  - $package" -ForegroundColor White
}
Write-Host ""

# Fonction pour télécharger un package depuis un dépôt
function Download-Package {
    param(
        [string]$PackageName,
        [string]$RepoUrl,
        [string]$OutputDir
    )
    
    try {
        Write-Host "Recherche de $PackageName dans $RepoUrl..." -ForegroundColor Yellow
        
        # Construire l'URL de recherche
        $SearchUrl = "$RepoUrl" + "?search=$PackageName"
        
        # Télécharger la page de recherche
        $SearchPage = Invoke-WebRequest -Uri $SearchUrl -UseBasicParsing
        
        # Extraire les liens vers les packages RPM
        $RpmLinks = $SearchPage.Links | Where-Object { $_.href -like "*.rpm" -and $_.href -like "*$PackageName*" }
        
        if ($RpmLinks.Count -gt 0) {
            # Prendre le premier lien (généralement le plus récent)
            $RpmUrl = $RepoUrl + $RpmLinks[0].href
            $FileName = Split-Path $RpmUrl -Leaf
            
            Write-Host "Téléchargement de $FileName..." -ForegroundColor Green
            Invoke-WebRequest -Uri $RpmUrl -OutFile "$OutputDir\$FileName"
            return $true
        } else {
            Write-Host "Package $PackageName non trouvé dans $RepoUrl" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Erreur lors du téléchargement de $PackageName : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Télécharger les packages depuis différents dépôts
$DownloadedPackages = @()

foreach ($package in $RequiredPackages) {
    $Downloaded = $false
    
    foreach ($repoName in $SuseRepos.Keys) {
        if (-not $Downloaded) {
            Write-Host "Tentative de téléchargement de $package depuis $repoName..." -ForegroundColor Yellow
            $Downloaded = Download-Package -PackageName $package -RepoUrl $SuseRepos[$repoName] -OutputDir "dependencies/system"
            
            if ($Downloaded) {
                $DownloadedPackages += $package
                Write-Host "✓ $package téléchargé depuis $repoName" -ForegroundColor Green
                break
            }
        }
    }
    
    if (-not $Downloaded) {
        Write-Host "✗ Impossible de télécharger $package depuis tous les dépôts" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Résumé du téléchargement ===" -ForegroundColor Green
Write-Host "Packages téléchargés: $($DownloadedPackages.Count)/$($RequiredPackages.Count)" -ForegroundColor White

foreach ($package in $DownloadedPackages) {
    Write-Host "  ✓ $package" -ForegroundColor Green
}

$MissingPackages = $RequiredPackages | Where-Object { $_ -notin $DownloadedPackages }
if ($MissingPackages.Count -gt 0) {
    Write-Host ""
    Write-Host "Packages manquants:" -ForegroundColor Red
    foreach ($package in $MissingPackages) {
        Write-Host "  ✗ $package" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Instructions pour les packages manquants:" -ForegroundColor Yellow
    Write-Host "1. Visitez https://software.opensuse.org/" -ForegroundColor White
    Write-Host "2. Recherchez chaque package manquant" -ForegroundColor White
    Write-Host "3. Téléchargez les fichiers .rpm" -ForegroundColor White
    Write-Host "4. Placez-les dans dependencies/system/" -ForegroundColor White
}

Write-Host ""
Write-Host "=== Téléchargement terminé ===" -ForegroundColor Green
Write-Host "Packages RPM dans: dependencies/system/" -ForegroundColor White
Write-Host "Vous pouvez maintenant transférer le package complet sur SUSE 15" -ForegroundColor White




