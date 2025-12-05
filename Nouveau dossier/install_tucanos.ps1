# Script d'installation de Tucanos pour Windows
# Ce script configure l'environnement et installe Tucanos

Write-Host "=== Installation de Tucanos ===" -ForegroundColor Green

# Vérifier si Rust est installé
if (-not (Get-Command rustc -ErrorAction SilentlyContinue)) {
    Write-Host "Installation de Rust..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://win.rustup.rs/" -OutFile "rustup-init.exe"
    .\rustup-init.exe -y
    Remove-Item "rustup-init.exe" -Force
    $env:PATH += ";$env:USERPROFILE\.cargo\bin"
}

# Vérifier si Git est installé
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git n'est pas installé. Installation de Git..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest/download/Git-2.45.1-64-bit.exe" -OutFile "git-installer.exe"
    Start-Process -FilePath "git-installer.exe" -ArgumentList "/SILENT" -Wait
    Remove-Item "git-installer.exe" -Force
    $env:PATH += ";C:\Program Files\Git\bin"
}

# Cloner le dépôt Tucanos
if (-not (Test-Path "tucanos")) {
    Write-Host "Téléchargement des sources de Tucanos..." -ForegroundColor Yellow
    git clone https://github.com/tucanos/tucanos.git
}

# Se déplacer dans le répertoire
Set-Location "tucanos"

# Modifier le fichier rust-toolchain.toml pour utiliser GNU
$rustToolchainContent = @"
[toolchain]
channel = "1.89.0"
targets = ["x86_64-pc-windows-gnu"]
"@
Set-Content -Path "rust-toolchain.toml" -Value $rustToolchainContent

# Installer le toolchain GNU
Write-Host "Installation du toolchain Rust GNU..." -ForegroundColor Yellow
rustup toolchain install 1.89.0-x86_64-pc-windows-gnu

# Essayer de compiler avec les fonctionnalités de base
Write-Host "Compilation de Tucanos (version de base)..." -ForegroundColor Yellow
try {
    cargo build --workspace --release --target x86_64-pc-windows-gnu
    Write-Host "Compilation réussie !" -ForegroundColor Green
} catch {
    Write-Host "Erreur lors de la compilation. Tentative avec les fonctionnalités minimales..." -ForegroundColor Red
    cargo build --workspace --release --target x86_64-pc-windows-gnu --no-default-features
}

# Vérifier les fichiers générés
if (Test-Path "target\x86_64-pc-windows-gnu\release") {
    Write-Host "Fichiers générés dans target\x86_64-pc-windows-gnu\release\" -ForegroundColor Green
    Get-ChildItem "target\x86_64-pc-windows-gnu\release" -Name "*.dll", "*.exe" | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Cyan
    }
}

Write-Host "=== Installation terminée ===" -ForegroundColor Green
Write-Host "Tucanos est maintenant installé et prêt à être utilisé !" -ForegroundColor Green









