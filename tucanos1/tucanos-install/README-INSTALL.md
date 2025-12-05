# Installation de Tucanos pour SUSE 15

## Contenu du package

- lib/: BibliothÃ¨ques partagÃ©es (.so)
- include/: En-tÃªtes C/C++ (.h)
- python/: Packages Python (.whl)
- install-system.sh: Script d'installation systÃ¨me
- install-python.sh: Script d'installation Python
- 	est-installation.sh: Script de test

## Installation

### 1. Installation systÃ¨me (requiert root)

`ash
sudo ./install-system.sh
`

### 2. Installation Python

`ash
./install-python.sh
`

### 3. Test de l'installation

`ash
./test-installation.sh
`

## Utilisation

### En C/C++

`c
#include <tucanos.h>
// Compiler avec: gcc -ltucanos
`

### En Python

`python
import pytmesh
import pytucanos
`

## Configuration compilÃ©e

- Architecture: x86_64-unknown-linux-gnu
- METIS: False
- NLOPT: False
- Mode debug: False
- Build Python: True
- Build FFI: True

## DÃ©pendances systÃ¨me requises

- gcc/g++
- make
- pkg-config
- python3 (si bindings Python installÃ©s)
- pip3 (si bindings Python installÃ©s)

## DÃ©pendances optionnelles

- METIS (pour le partitionnement de maillage)
- NLOPT (pour le lissage)

## Instructions de dÃ©ploiement

1. Copiez le dossier $InstallDir sur la machine SUSE 15
2. Sur la machine SUSE 15, exÃ©cutez:
   `ash
   cd tucanos-install
   sudo ./install-system.sh
   ./install-python.sh  # si nÃ©cessaire
   ./test-installation.sh
   `

## Compilation sur la machine cible

Si vous prÃ©fÃ©rez compiler directement sur la machine SUSE 15:

1. Copiez le dossier $BuildDir sur la machine cible
2. Sur la machine SUSE 15, exÃ©cutez:
   `ash
   cd tucanos-build
   chmod +x build-tucanos.sh
   ./build-tucanos.sh
   `
