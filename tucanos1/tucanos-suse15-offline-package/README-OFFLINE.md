# Package HORS LIGNE Tucanos pour SUSE 15

## ðŸš« Installation VRAIMENT hors ligne

Ce package est conÃ§u pour fonctionner **SANS connexion internet** sur la machine SUSE 15.

## âš ï¸ PrÃ©requis IMPORTANTS

**AVANT** de transfÃ©rer ce package sur SUSE 15, assurez-vous que la machine cible a :

### DÃ©pendances systÃ¨me (installÃ©es AVANT)
`ash
# Sur la machine SUSE 15, avec connexion internet :
sudo zypper refresh
sudo zypper install gcc gcc-c++ make pkg-config
sudo zypper install python3 python3-devel python3-pip
sudo zypper install nlopt-devel  # optionnel pour NLOPT
`

### Rust (installÃ© AVANT)
`ash
# Sur la machine SUSE 15, avec connexion internet :
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
`

### METIS (optionnel, installation manuelle)
`ash
# TÃ©lÃ©chargez depuis : https://github.com/KarypisLab/METIS
# Compilez et installez manuellement
`

## ðŸš€ Installation hors ligne

### 1. VÃ©rification des prÃ©requis
`ash
chmod +x check-prerequisites.sh
./check-prerequisites.sh
`

### 2. Compilation hors ligne
`ash
chmod +x build-tucanos-offline.sh
./build-tucanos-offline.sh
`

### 3. Installation
`ash
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh
`

## ðŸ“‹ Ce qui est inclus

- âœ… Code source complet de Tucanos
- âœ… Scripts de compilation hors ligne
- âœ… Scripts d'installation
- âœ… Scripts de test
- âœ… Documentation complÃ¨te

## ðŸ“‹ Ce qui N'EST PAS inclus

- âŒ Compilateur Rust (doit Ãªtre installÃ© avant)
- âŒ Outils de compilation (gcc, make, etc.)
- âŒ Python et pip
- âŒ DÃ©pendances systÃ¨me (NLOPT, METIS)

## ðŸ”§ Configuration compilÃ©e

- **Architecture** : x86_64-unknown-linux-gnu
- **METIS** : True
- **NLOPT** : True
- **Mode debug** : False

## âš¡ Workflow recommandÃ©

### Sur une machine avec internet :
1. Installez les dÃ©pendances systÃ¨me
2. Installez Rust
3. TÃ©lÃ©chargez ce package
4. TransfÃ©rez sur la machine SUSE 15 hors ligne

### Sur la machine SUSE 15 hors ligne :
1. VÃ©rifiez les prÃ©requis : ./check-prerequisites.sh
2. Compilez : ./build-tucanos-offline.sh
3. Installez : cd tucanos-install && sudo ./install-system.sh && ./install-python.sh

## ðŸŽ¯ Avantages

- âœ… Vraiment hors ligne
- âœ… Pas de tÃ©lÃ©chargement pendant la compilation
- âœ… Compilation locale
- âœ… ContrÃ´le total sur l'environnement

## âš ï¸ Limitations

- âš ï¸ DÃ©pendances systÃ¨me doivent Ãªtre installÃ©es AVANT
- âš ï¸ Rust doit Ãªtre installÃ© AVANT
- âš ï¸ Plus de prÃ©paration initiale requise

## ðŸ“š Support

- **Documentation officielle** : https://github.com/tucanos/tucanos
- **Issues** : https://github.com/tucanos/tucanos/issues
- **Licence** : LGPL-2.1
