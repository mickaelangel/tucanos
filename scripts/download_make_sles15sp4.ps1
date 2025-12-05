# SLES 15 SP4 / Leap 15.4 équivalents
$Base = "https://download.opensuse.org/distribution/leap/15.4/repo/oss/x86_64"
$Out  = "suse-packages\RPMS"
New-Item -Force -ItemType Directory -Path $Out | Out-Null

$Packages = @(
  "make", "gcc", "gcc-c++", "glibc-devel", "libstdc++-devel", "binutils", "tar", "pkg-config"
)

function Get-RpmPattern {
  param($Name)
  # large pattern to catch variants; the server handles globbing poorly, so we try multiple common prefixes
  @(
    "$Base/$Name-*.x86_64.rpm",
    "$Base/$Name-*.noarch.rpm",
    "$Base/lib$Name-*.x86_64.rpm",
    "$Base/$Name-*-lp*.x86_64.rpm"
  )
}

# simple downloader that tries patterns until one works
function Download-FirstMatch {
  param($Patterns)
  foreach ($u in $Patterns) {
    try {
      $fileName = Split-Path $u -Leaf
      $dst = Join-Path $Out $fileName
      Invoke-WebRequest -Uri $u -OutFile $dst -UseBasicParsing -ErrorAction Stop
      if ((Get-Item $dst).Length -gt 0) { return $dst }
    } catch { continue }
  }
  return $null
}

$Downloaded = @()
foreach ($p in $Packages) {
  $rpm = Download-FirstMatch (Get-RpmPattern -Name $p)
  if ($rpm) { Write-Host "OK  $p -> $(Split-Path $rpm -Leaf)"; $Downloaded += $rpm }
  else { Write-Warning "ÉCHEC téléchargement pour: $p (vérifier manuellement)" }
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






