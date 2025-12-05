# Script pour telecharger les packages SUSE depuis les depots officiels

Write-Host "=== Telechargement des packages SUSE ===" -ForegroundColor Green

# Creer le repertoire
New-Item -ItemType Directory -Path "dependencies" -Force | Out-Null
New-Item -ItemType Directory -Path "dependencies/system" -Force | Out-Null

# URLs des depots SUSE
$repos = @{
    "opensuse-leap-15.5" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/"
    "opensuse-leap-15.4" = "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/"
    "opensuse-leap-15.3" = "https://download.opensuse.org/distribution/leap/15.3/repo/oss/x86_64/"
}

# Packages necessaires
$packages = @(
    "gcc",
    "gcc-c++",
    "make", 
    "pkg-config",
    "python3",
    "python3-devel",
    "python3-pip",
    "nlopt-devel"
)

Write-Host "Packages a telecharger:" -ForegroundColor Yellow
foreach ($pkg in $packages) {
    Write-Host "  - $pkg" -ForegroundColor White
}
Write-Host ""

$downloaded = 0
$total = $packages.Count

foreach ($package in $packages) {
    $found = $false
    
    foreach ($repoName in $repos.Keys) {
        if (-not $found) {
            $repoUrl = $repos[$repoName]
            
            try {
                Write-Host "Recherche de $package dans $repoName..." -ForegroundColor Yellow
                
                # Construire l'URL de recherche
                $searchUrl = $repoUrl + "?search=" + $package
                
                # Telecharger la page de recherche
                $searchPage = Invoke-WebRequest -Uri $searchUrl -UseBasicParsing -TimeoutSec 30
                
                # Extraire les liens RPM
                $rpmLinks = $searchPage.Links | Where-Object { 
                    $_.href -like "*.rpm" -and 
                    $_.href -like "*$package*" -and
                    $_.href -notlike "*debug*" -and
                    $_.href -notlike "*src*"
                }
                
                if ($rpmLinks.Count -gt 0) {
                    # Prendre le premier lien
                    $rpmUrl = $repoUrl + $rpmLinks[0].href
                    $filename = Split-Path $rpmUrl -Leaf
                    
                    Write-Host "  Telechargement depuis $rpmUrl..." -ForegroundColor Green
                    Invoke-WebRequest -Uri $rpmUrl -OutFile "dependencies/system/$filename" -TimeoutSec 60
                    
                    if (Test-Path "dependencies/system/$filename") {
                        $size = [math]::Round((Get-Item "dependencies/system/$filename").Length / 1MB, 2)
                        Write-Host "  OK - $filename ($size MB)" -ForegroundColor Green
                        $downloaded++
                        $found = $true
                    }
                }
            } catch {
                Write-Host "  ERREUR dans $repoName : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    if (-not $found) {
        Write-Host "  ERREUR - $package non trouve dans tous les depots" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "=== Resume ===" -ForegroundColor Green
Write-Host "Packages telecharges: $downloaded/$total" -ForegroundColor White

if ($downloaded -eq $total) {
    Write-Host "Tous les packages ont ete telecharges!" -ForegroundColor Green
} else {
    Write-Host "Certains packages n'ont pas pu etre telecharges" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Instructions pour telecharger manuellement:" -ForegroundColor Yellow
    Write-Host "1. Visitez https://software.opensuse.org/" -ForegroundColor White
    Write-Host "2. Recherchez chaque package manquant" -ForegroundColor White
    Write-Host "3. Telechargez les fichiers .rpm" -ForegroundColor White
    Write-Host "4. Placez-les dans dependencies/system/" -ForegroundColor White
}

Write-Host ""
Write-Host "Fichiers telecharges dans dependencies/system/:" -ForegroundColor Cyan
Get-ChildItem "dependencies/system/*.rpm" -ErrorAction SilentlyContinue | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  - $($_.Name) ($size MB)" -ForegroundColor White
}

Write-Host ""
Write-Host "Telechargement termine!" -ForegroundColor Green




