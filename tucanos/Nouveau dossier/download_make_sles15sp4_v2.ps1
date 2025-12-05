# Version améliorée pour télécharger les RPMs make pour SLES 15 SP4
$Base = "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64"
$Out = "suse-packages\RPMS"
New-Item -Force -ItemType Directory -Path $Out | Out-Null

# URLs spécifiques pour SLES 15 SP4 / Leap 15.4
$SpecificUrls = @{
    "make" = @(
        "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/make-4.2.1-lp154.2.3.1.x86_64.rpm"
    )
    "gcc" = @(
        "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/gcc-7-7.5.0+git20181009.0a0c9e9-lp154.2.6.1.x86_64.rpm"
    )
    "gcc-c++" = @(
        "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/gcc-c++-7-7.5.0+git20181009.0a0c9e9-lp154.2.6.1.x86_64.rpm"
    )
    "glibc-devel" = @(
        "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/glibc-devel-2.26-lp154.2.3.1.x86_64.rpm"
    )
    "libstdc++-devel" = @(
        "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/libstdc++-devel-7-7.5.0+git20181009.0a0c9e9-lp154.2.6.1.x86_64.rpm"
    )
    "binutils" = @(
        "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/binutils-2.30-lp154.2.3.1.x86_64.rpm"
    )
    "tar" = @(
        "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/tar-1.30-lp154.2.3.1.x86_64.rpm"
    )
    "pkg-config" = @(
        "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64/pkg-config-0.29.2-lp154.2.3.1.x86_64.rpm"
    )
}

function Download-Package {
    param($PackageName, $Urls)
    
    foreach ($url in $Urls) {
        try {
            $fileName = Split-Path $url -Leaf
            $dst = Join-Path $Out $fileName
            Write-Host "Tentative: $url" -ForegroundColor Yellow
            
            Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing -ErrorAction Stop
            
            if ((Get-Item $dst).Length -gt 0) {
                Write-Host "OK  $PackageName -> $fileName" -ForegroundColor Green
                return $dst
            }
        } catch {
            Write-Host "Échec: $url" -ForegroundColor Red
            continue
        }
    }
    return $null
}

$Downloaded = @()
foreach ($package in $SpecificUrls.Keys) {
    $rpm = Download-Package -PackageName $package -Urls $SpecificUrls[$package]
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






