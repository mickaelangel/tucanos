# Script PowerShell simplifié pour télécharger les packages RPM SUSE
# Version simplifiée et robuste

Write-Host "=== Téléchargement des packages RPM SUSE ===" -ForegroundColor Green

# Créer le répertoire des dépendances système
New-Item -ItemType Directory -Path "dependencies" -Force | Out-Null
New-Item -ItemType Directory -Path "dependencies/system" -Force | Out-Null

# Packages nécessaires avec leurs URLs directes
$Packages = @{
    "gcc" = "https://download.opensuse.org/repositories/devel:/gcc/openSUSE_Leap_15.5/x86_64/gcc-11.2.1+git123-1.1.x86_64.rpm"
    "gcc-c++" = "https://download.opensuse.org/repositories/devel:/gcc/openSUSE_Leap_15.5/x86_64/gcc11-c++-11.2.1+git123-1.1.x86_64.rpm"
    "make" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/make-4.3-1.1.x86_64.rpm"
    "pkg-config" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/pkg-config-0.29.2-1.1.x86_64.rpm"
    "python3" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/python3-3.6.15-1.1.x86_64.rpm"
    "python3-devel" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/python3-devel-3.6.15-1.1.x86_64.rpm"
    "python3-pip" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/python3-pip-21.3.1-1.1.noarch.rpm"
    "nlopt-devel" = "https://download.opensuse.org/repositories/science/openSUSE_Leap_15.5/x86_64/nlopt-devel-2.7.1-1.1.x86_64.rpm"
    "glibc-devel" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/glibc-devel-2.31-1.1.x86_64.rpm"
    "libstdc++-devel" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/libstdc++6-devel-11.2.1+git123-1.1.x86_64.rpm"
    "zlib-devel" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/zlib-devel-1.2.11-1.1.x86_64.rpm"
    "openssl-devel" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/libopenssl-devel-1.1.1l-1.1.x86_64.rpm"
    "libffi-devel" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/libffi-devel-3.3-1.1.x86_64.rpm"
}

Write-Host "Packages à télécharger:" -ForegroundColor Yellow
foreach ($package in $Packages.Keys) {
    Write-Host "  - $package" -ForegroundColor White
}
Write-Host ""

$DownloadedCount = 0
$TotalCount = $Packages.Count

foreach ($package in $Packages.Keys) {
    $url = $Packages[$package]
    $fileName = Split-Path $url -Leaf
    
    try {
        Write-Host "Téléchargement de $package..." -ForegroundColor Yellow
        Write-Host "  URL: $url" -ForegroundColor Gray
        Write-Host "  Fichier: $fileName" -ForegroundColor Gray
        
        Invoke-WebRequest -Uri $url -OutFile "dependencies/system/$fileName" -TimeoutSec 30
        
        if (Test-Path "dependencies/system/$fileName") {
            $fileSize = (Get-Item "dependencies/system/$fileName").Length
            Write-Host "  ✓ Téléchargé ($([math]::Round($fileSize/1MB, 2)) MB)" -ForegroundColor Green
            $DownloadedCount++
        } else {
            Write-Host "  ✗ Fichier non trouvé après téléchargement" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ✗ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "=== Résumé du téléchargement ===" -ForegroundColor Green
Write-Host "Packages téléchargés: $DownloadedCount/$TotalCount" -ForegroundColor White

if ($DownloadedCount -eq $TotalCount) {
    Write-Host "✓ Tous les packages ont été téléchargés avec succès!" -ForegroundColor Green
} else {
    Write-Host "⚠ Certains packages n'ont pas pu être téléchargés" -ForegroundColor Yellow
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

# Lister les fichiers téléchargés
$DownloadedFiles = Get-ChildItem "dependencies/system/*.rpm" -ErrorAction SilentlyContinue
if ($DownloadedFiles) {
    Write-Host ""
    Write-Host "Fichiers téléchargés:" -ForegroundColor Cyan
    foreach ($file in $DownloadedFiles) {
        $size = [math]::Round($file.Length / 1MB, 2)
        Write-Host "  - $($file.Name) ($size MB)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Vous pouvez maintenant transférer le package complet sur SUSE 15" -ForegroundColor Green




