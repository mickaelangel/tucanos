# Script simple pour telecharger les packages RPM SUSE

Write-Host "=== Telechargement des packages RPM SUSE ===" -ForegroundColor Green

# Creer le repertoire
New-Item -ItemType Directory -Path "dependencies" -Force | Out-Null
New-Item -ItemType Directory -Path "dependencies/system" -Force | Out-Null

# Packages avec URLs
$packages = @{
    "gcc" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/gcc-11.2.1+git123-1.1.x86_64.rpm"
    "gcc-c++" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/gcc11-c++-11.2.1+git123-1.1.x86_64.rpm"
    "make" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/make-4.3-1.1.x86_64.rpm"
    "pkg-config" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/pkg-config-0.29.2-1.1.x86_64.rpm"
    "python3" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/python3-3.6.15-1.1.x86_64.rpm"
    "python3-devel" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/python3-devel-3.6.15-1.1.x86_64.rpm"
    "python3-pip" = "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/python3-pip-21.3.1-1.1.noarch.rpm"
    "nlopt-devel" = "https://download.opensuse.org/repositories/science/openSUSE_Leap_15.5/x86_64/nlopt-devel-2.7.1-1.1.x86_64.rpm"
}

$downloaded = 0
$total = $packages.Count

foreach ($package in $packages.Keys) {
    $url = $packages[$package]
    $filename = Split-Path $url -Leaf
    
    try {
        Write-Host "Telechargement de $package..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $url -OutFile "dependencies/system/$filename" -TimeoutSec 30
        
        if (Test-Path "dependencies/system/$filename") {
            Write-Host "  OK - $filename" -ForegroundColor Green
            $downloaded++
        } else {
            Write-Host "  ERREUR - Fichier non trouve" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Resume ===" -ForegroundColor Green
Write-Host "Packages telecharges: $downloaded/$total" -ForegroundColor White

if ($downloaded -eq $total) {
    Write-Host "Tous les packages ont ete telecharges!" -ForegroundColor Green
} else {
    Write-Host "Certains packages n'ont pas pu etre telecharges" -ForegroundColor Yellow
    Write-Host "Visitez https://software.opensuse.org/ pour les telecharger manuellement" -ForegroundColor White
}

Write-Host ""
Write-Host "Fichiers dans dependencies/system/:" -ForegroundColor Cyan
Get-ChildItem "dependencies/system/*.rpm" -ErrorAction SilentlyContinue | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  - $($_.Name) ($size MB)" -ForegroundColor White
}

Write-Host ""
Write-Host "Telechargement termine!" -ForegroundColor Green




