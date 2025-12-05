# Version 3 - Recherche des paquets disponibles sur les miroirs
$Mirrors = @(
    "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/",
    "https://download.opensuse.org/distribution/leap/15.5/repo/oss/x86_64/",
    "https://download.opensuse.org/distribution/leap/15.6/repo/oss/x86_64/"
)

$Out = "suse-packages\RPMS"
New-Item -Force -ItemType Directory -Path $Out | Out-Null

# Paquets essentiels avec différentes variantes
$PackageVariants = @{
    "make" = @("make", "make-4.2", "make-4.3")
    "gcc" = @("gcc", "gcc-7", "gcc-8", "gcc-9")
    "gcc-c++" = @("gcc-c++", "gcc-c++-7", "gcc-c++-8", "gcc-c++-9")
    "glibc-devel" = @("glibc-devel", "glibc-devel-2.26", "glibc-devel-2.31")
    "libstdc++-devel" = @("libstdc++-devel", "libstdc++-devel-7", "libstdc++-devel-8")
    "binutils" = @("binutils", "binutils-2.30", "binutils-2.35")
    "tar" = @("tar", "tar-1.30", "tar-1.34")
    "pkg-config" = @("pkg-config", "pkg-config-0.29")
}

function Test-Url {
    param($url)
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

function Download-Package {
    param($PackageName, $Variants)
    
    foreach ($mirror in $Mirrors) {
        foreach ($variant in $Variants) {
            $urls = @(
                "$mirror$variant-*.x86_64.rpm",
                "$mirror$variant-*.noarch.rpm",
                "$mirror$variant-*-lp*.x86_64.rpm"
            )
            
            foreach ($url in $urls) {
                try {
                    Write-Host "Test: $url" -ForegroundColor Yellow
                    if (Test-Url -url $url) {
                        $fileName = Split-Path $url -Leaf
                        $dst = Join-Path $Out $fileName
                        Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing -ErrorAction Stop
                        
                        if ((Get-Item $dst).Length -gt 0) {
                            Write-Host "OK  $PackageName -> $fileName" -ForegroundColor Green
                            return $dst
                        }
                    }
                } catch {
                    continue
                }
            }
        }
    }
    return $null
}

$Downloaded = @()
foreach ($package in $PackageVariants.Keys) {
    Write-Host "Recherche de $package..." -ForegroundColor Cyan
    $rpm = Download-Package -PackageName $package -Variants $PackageVariants[$package]
    if ($rpm) { 
        $Downloaded += $rpm 
    } else { 
        Write-Warning "ÉCHEC téléchargement pour: $package" 
    }
}

# Récapitulatif
Write-Host ""
Write-Host "Fichiers RPM récupérés:" -ForegroundColor Green
Get-ChildItem $Out -Filter *.rpm | Select-Object Name,Length | Format-Table

# Génère un README pour l'installation offline côté SUSE
$readme = @"
Installation offline sur SLES 15 SP4:
  sudo rpm -Uvh --force --nodeps *.rpm
Ordre conseillé si erreurs de dépendances:
  sudo rpm -Uvh binutils-*.rpm libstdc++-devel-*.rpm glibc-devel-*.rpm gcc-*.rpm gcc-c++-*.rpm tar-*.rpm pkg-config-*.rpm make-*.rpm
Vérification:
  make --version
"@
$readme | Set-Content (Join-Path $Out "README_OFFLINE.txt") -Encoding UTF8

Write-Host ""
Write-Host "Transférez le dossier '$Out' sur la machine SUSE 15 SP4 (scp/USB)."






