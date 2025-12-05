# Package de compilation Tucanos pour SUSE 15

## Description

Ce package contient tout le nÃ©cessaire pour compiler et installer Tucanos sur SUSE 15.

## Contenu

- **Code source** : DÃ©pÃ´t complet de Tucanos
- **Scripts de compilation** : Automatisation de la compilation
- **Scripts d'installation** : Installation des dÃ©pendances et du logiciel
- **Documentation** : Instructions complÃ¨tes

## Installation rapide

### 1. Installation des dÃ©pendances

`ash
chmod +x install-dependencies.sh
./install-dependencies.sh
`

### 2. Compilation

`ash
chmod +x build-tucanos.sh
./build-tucanos.sh
`

### 3. Installation

`ash
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh
`

## Installation manuelle

### PrÃ©requis systÃ¨me

`ash
# Mise Ã  jour du systÃ¨me
sudo zypper refresh

# DÃ©pendances de base
sudo zypper install gcc gcc-c++ make pkg-config

# Python
sudo zypper install python3 python3-devel python3-pip

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
`

### DÃ©pendances optionnelles

`ash
# NLOPT (pour l'optimisation)
sudo zypper install nlopt-devel

# METIS (pour le partitionnement - installation manuelle requise)
# TÃ©lÃ©chargez depuis: https://github.com/KarypisLab/METIS
`

### Compilation

`ash
# Compilation standard
./build-tucanos.sh

# Avec METIS
./build-tucanos.sh --with-metis

# Avec NLOPT
./build-tucanos.sh --with-nlopt

# Mode debug
./build-tucanos.sh --debug

# Toutes les options
./build-tucanos.sh --with-metis --with-nlopt --debug
`

## Configuration compilÃ©e

- **Architecture** : x86_64-unknown-linux-gnu
- **METIS** : True
- **NLOPT** : True
- **Mode debug** : False

## Utilisation aprÃ¨s installation

### En C/C++

`c
#include <tucanos.h>

int main() {
    tucanos_init_log();
    // Votre code ici
    return 0;
}
`

Compilation :
`ash
gcc -I/usr/local/include -L/usr/local/lib -ltucanos votre_programme.c -o votre_programme
`

### En Python

`python
import pytmesh
import pytucanos

# Votre code Python ici
`

## Structure du package

`
tucanos-suse15-build-package/
â”œâ”€â”€ build-tucanos.sh           # Script de compilation principal
â”œâ”€â”€ install-dependencies.sh    # Installation des dÃ©pendances
â”œâ”€â”€ tucanos/                   # Code source principal
â”œâ”€â”€ tmesh/                     # Code source tmesh
â”œâ”€â”€ pytmesh/                   # Bindings Python pytmesh
â”œâ”€â”€ pytucanos/                 # Bindings Python pytucanos
â”œâ”€â”€ tucanos-ffi/              # Interface FFI
â””â”€â”€ README-INSTALL.md          # Cette documentation
`

## DÃ©pannage

### Erreur de compilation Rust

`ash
# VÃ©rifier la version de Rust
rustc --version

# Mettre Ã  jour Rust
rustup update
`

### Erreur de dÃ©pendances systÃ¨me

`ash
# VÃ©rifier les dÃ©pendances
pkg-config --list-all | grep -E "(metis|nlopt)"

# Installer les dÃ©pendances manquantes
sudo zypper install gcc gcc-c++ make pkg-config
`

### Erreur Python

`ash
# VÃ©rifier Python
python3 --version
pip3 --version

# RÃ©installer les bindings
pip3 install --user --force-reinstall tucanos-install/python/*.whl
`

## Support

- **Documentation officielle** : https://github.com/tucanos/tucanos
- **Issues** : https://github.com/tucanos/tucanos/issues
- **Licence** : LGPL-2.1

## Notes techniques

- CompilÃ© avec Rust 1.90.0
- OptimisÃ© pour SUSE 15 (x86_64)
- Compatible avec SUSE Linux Enterprise Server 15 et openSUSE Leap 15.x
- Support des fonctionnalitÃ©s optionnelles selon la configuration
