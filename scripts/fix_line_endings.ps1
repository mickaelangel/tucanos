# Script pour convertir les fins de ligne Windows (CRLF) vers Unix (LF)
# pour tous les fichiers .sh

Write-Host "=== Conversion des fins de ligne CRLF -> LF ===" -ForegroundColor Cyan
Write-Host ""

$scriptsToFix = Get-ChildItem -Path "." -Include "*.sh" -Recurse

$count = 0
foreach ($file in $scriptsToFix) {
    Write-Host "Traitement de : $($file.FullName)" -ForegroundColor Yellow
    
    # Lire le contenu
    $content = [System.IO.File]::ReadAllText($file.FullName)
    
    # Convertir CRLF en LF
    $content = $content -replace "`r`n", "`n"
    
    # Écrire avec UTF8 sans BOM et LF seulement
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
    
    Write-Host "  ✓ Converti" -ForegroundColor Green
    $count++
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ $count fichier(s) converti(s) !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Les fichiers .sh ont maintenant des fins de ligne Unix (LF)" -ForegroundColor Cyan
Write-Host "Ils peuvent être exécutés correctement sur Linux/SUSE" -ForegroundColor Cyan





