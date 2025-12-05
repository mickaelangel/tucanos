# Package COMPLET HORS LIGNE Tucanos pour SUSE 15

## ðŸš« Installation VRAIMENT hors ligne avec TOUTES les dÃ©pendances

Ce package inclut TOUTES les dÃ©pendances nÃ©cessaires pour une installation complÃ¨tement hors ligne.

## ðŸ“¦ Contenu du package

- âœ… **Code source complet** de Tucanos
- âœ… **Rust portable** (rustup-init)
- âœ… **Packages Python** (maturin, setuptools, etc.)
- âœ… **Scripts d'installation** complets
- âœ… **Documentation** dÃ©taillÃ©e

## ðŸ”„ Workflow d'installation

### Ã‰tape 1 : PrÃ©paration (sur machine avec internet)
`ash
# TÃ©lÃ©charger les dÃ©pendances
chmod +x download-dependencies.sh
./download-dependencies.sh

# TÃ©lÃ©charger manuellement les packages RPM depuis SUSE
# et les placer dans dependencies/system/
`

### Ã‰tape 2 : Transfert
`ash
# TransfÃ©rer le dossier complet sur SUSE 15
`

### Ã‰tape 3 : Installation (sur SUSE 15 SANS internet)
`ash
# Installation complÃ¨te hors ligne
chmod +x install-complete-offline.sh
./install-complete-offline.sh

# Installation des bibliothÃ¨ques
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh
`

## ðŸ“‹ DÃ©pendances incluses

### Rust
- âœ… rustup-init tÃ©lÃ©chargÃ©
- âœ… Installation locale possible

### Python
- âœ… maturin
- âœ… setuptools
- âœ… wheel
- âœ… pyo3
- âœ… numpy

### SystÃ¨me (Ã  tÃ©lÃ©charger manuellement)
- âš ï¸ gcc, gcc-c++, make, pkg-config
- âš ï¸ python3, python3-devel, python3-pip
- âš ï¸ nlopt-devel

## ðŸ”§ Configuration compilÃ©e

- **Architecture** : x86_64-unknown-linux-gnu
- **METIS** : True
- **NLOPT** : True
- **Mode debug** : False

## âš¡ Installation rapide

### Avec dÃ©pendances incluses
`ash
# 1. PrÃ©parer les dÃ©pendances (sur machine avec internet)
./download-dependencies.sh

# 2. TransfÃ©rer sur SUSE 15

# 3. Installation complÃ¨te (sur SUSE 15 hors ligne)
./install-complete-offline.sh
cd tucanos-install && sudo ./install-system.sh && ./install-python.sh
`

## ðŸŽ¯ Avantages

- âœ… **Vraiment hors ligne** aprÃ¨s prÃ©paration
- âœ… **Toutes les dÃ©pendances** incluses
- âœ… **Installation automatique** de tout
- âœ… **ContrÃ´le total** sur l'environnement
- âœ… **METIS et NLOPT** supportÃ©s

## âš ï¸ Limitations

- âš ï¸ **PrÃ©paration initiale** requise (tÃ©lÃ©chargement des dÃ©pendances)
- âš ï¸ **Packages RPM** Ã  tÃ©lÃ©charger manuellement
- âš ï¸ **Taille du package** plus importante

## ðŸ“š Support

- **Documentation officielle** : https://github.com/tucanos/tucanos
- **Issues** : https://github.com/tucanos/tucanos/issues
- **Licence** : LGPL-2.1

## ðŸŽ‰ RÃ©sultat

Tu as maintenant un package COMPLET qui inclut TOUTES les dÃ©pendances pour une installation vraiment hors ligne sur SUSE 15 !
