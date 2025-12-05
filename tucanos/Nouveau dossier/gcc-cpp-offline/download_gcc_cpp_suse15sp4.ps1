# Script PowerShell pour télécharger g++ et ses dépendances pour SUSE 15 SP4
# À exécuter sur une machine Windows avec Internet

$ErrorActionPreference = "Continue"

Write-Host "=== Téléchargement g++ pour SUSE 15 SP4 ===" -ForegroundColor Cyan

# Créer le dossier de destination
$targetDir = "suse15-gcc-cpp-rpms"
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

# URLs des RPMs pour SUSE 15 SP4 (OpenSUSE Leap 15.4)
$baseUrl = "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64"

# Liste des packages nécessaires pour g++
$packages = @(
    "gcc7-c++-7.5.0+r278197-150000.1.10.x86_64.rpm",
    "libstdc++6-devel-gcc7-7.5.0+r278197-150000.1.10.x86_64.rpm",
    "libstdc++6-7.5.0+r278197-150000.1.10.x86_64.rpm"
)

$successCount = 0
$failCount = 0

foreach ($pkg in $packages) {
    $url = "$baseUrl/$pkg"
    $output = Join-Path $targetDir $pkg
    
    Write-Host "`nTéléchargement: $pkg" -ForegroundColor Yellow
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $output -TimeoutSec 60
        
        if (Test-Path $output) {
            $size = (Get-Item $output).Length / 1MB
            Write-Host "  ✓ Téléchargé: $([math]::Round($size, 2)) MB" -ForegroundColor Green
            $successCount++
        }
    }
    catch {
        Write-Host "  ✗ ÉCHEC: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host "`n=== Résumé ===" -ForegroundColor Cyan
Write-Host "Succès: $successCount" -ForegroundColor Green
Write-Host "Échecs: $failCount" -ForegroundColor Red

if ($successCount -gt 0) {
    Write-Host "`nRPMs téléchargés dans: $targetDir" -ForegroundColor Green
    Write-Host "Copiez ce dossier dans votre archive offline." -ForegroundColor Yellow
}




