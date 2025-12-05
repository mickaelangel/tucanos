# Script pour compresser le package Tucanos complet
# Utilise 7-Zip ou PowerShell Compress-Archive

Write-Host "=== Compression du package Tucanos offline ===" -ForegroundColor Cyan
Write-Host ""

$PackageDir = "tucanos-complete-offline-final"
$OutputZip = "tucanos-complete-offline-final.zip"
$OutputTar = "tucanos-complete-offline-final.tar.gz"

# Vérifier que le package existe
if (!(Test-Path $PackageDir)) {
    Write-Host "✗ Erreur : Le package $PackageDir n'existe pas" -ForegroundColor Red
    Write-Host "Exécutez d'abord : creer_package_complet_tucanos.ps1" -ForegroundColor Yellow
    exit 1
}

# Calculer la taille du package
$totalSize = (Get-ChildItem $PackageDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Taille du package non compressé : $([math]::Round($totalSize, 1)) MB" -ForegroundColor Cyan
Write-Host ""

# Méthode 1 : Essayer avec 7-Zip (meilleure compression)
$7zipPaths = @(
    "C:\Program Files\7-Zip\7z.exe",
    "C:\Program Files (x86)\7-Zip\7z.exe",
    "$env:ProgramFiles\7-Zip\7z.exe",
    "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
)

$7zipFound = $false
$7zipPath = $null

foreach ($path in $7zipPaths) {
    if (Test-Path $path) {
        $7zipPath = $path
        $7zipFound = $true
        break
    }
}

if ($7zipFound) {
    Write-Host "✓ 7-Zip trouvé : $7zipPath" -ForegroundColor Green
    Write-Host "Compression avec 7-Zip (tar.gz)..." -ForegroundColor Yellow
    Write-Host ""
    
    # Créer tar
    $tarFile = "$PackageDir.tar"
    if (Test-Path $tarFile) {
        Remove-Item $tarFile -Force
    }
    
    & $7zipPath a -ttar $tarFile $PackageDir
    
    # Compresser en gzip
    if (Test-Path $OutputTar) {
        Remove-Item $OutputTar -Force
    }
    
    & $7zipPath a -tgzip $OutputTar $tarFile
    
    # Supprimer le fichier tar intermédiaire
    if (Test-Path $tarFile) {
        Remove-Item $tarFile -Force
    }
    
    if (Test-Path $OutputTar) {
        $compressedSize = (Get-Item $OutputTar).Length / 1MB
        $compressionRatio = [math]::Round(($compressedSize / $totalSize) * 100, 1)
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "✓ Archive créée avec succès !" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Fichier : $OutputTar" -ForegroundColor Cyan
        Write-Host "Taille compressée : $([math]::Round($compressedSize, 1)) MB" -ForegroundColor Cyan
        Write-Host "Taux de compression : $compressionRatio%" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host "✗ Erreur lors de la compression" -ForegroundColor Red
    }
    
} else {
    Write-Host "⚠ 7-Zip non trouvé, utilisation de Compress-Archive (PowerShell)" -ForegroundColor Yellow
    Write-Host "Note : 7-Zip offre une meilleure compression pour tar.gz" -ForegroundColor DarkGray
    Write-Host ""
    
    # Méthode 2 : PowerShell Compress-Archive (ZIP seulement)
    Write-Host "Compression avec PowerShell (ZIP)..." -ForegroundColor Yellow
    
    if (Test-Path $OutputZip) {
        Remove-Item $OutputZip -Force
    }
    
    try {
        Compress-Archive -Path $PackageDir -DestinationPath $OutputZip -CompressionLevel Optimal
        
        $compressedSize = (Get-Item $OutputZip).Length / 1MB
        $compressionRatio = [math]::Round(($compressedSize / $totalSize) * 100, 1)
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "✓ Archive créée avec succès !" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Fichier : $OutputZip" -ForegroundColor Cyan
        Write-Host "Taille compressée : $([math]::Round($compressedSize, 1)) MB" -ForegroundColor Cyan
        Write-Host "Taux de compression : $compressionRatio%" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Note : Format ZIP (pour tar.gz, installez 7-Zip)" -ForegroundColor Yellow
        Write-Host ""
    } catch {
        Write-Host "✗ Erreur lors de la compression : $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Prochaines étapes :" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Transférer sur SUSE 15 SP4 :" -ForegroundColor White

if (Test-Path $OutputTar) {
    Write-Host "   scp $OutputTar user@server:/home/user/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Sur le serveur, extraire :" -ForegroundColor White
    Write-Host "   tar xzf $OutputTar" -ForegroundColor Gray
} else {
    Write-Host "   scp $OutputZip user@server:/home/user/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Sur le serveur, extraire :" -ForegroundColor White
    Write-Host "   unzip $OutputZip" -ForegroundColor Gray
}

Write-Host ""
Write-Host "3. Installer :" -ForegroundColor White
Write-Host "   cd $PackageDir" -ForegroundColor Gray
Write-Host "   chmod +x install_tucanos_suse15_offline.sh" -ForegroundColor Gray
Write-Host "   ./install_tucanos_suse15_offline.sh" -ForegroundColor Gray
Write-Host ""

Write-Host "Pour installer 7-Zip (meilleure compression) :" -ForegroundColor DarkGray
Write-Host "  Téléchargez depuis https://www.7-zip.org/" -ForegroundColor DarkGray
Write-Host ""







