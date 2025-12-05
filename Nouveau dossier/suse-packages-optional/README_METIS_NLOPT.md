# Installation METIS et NLOPT pour Tucanos

## Contenu

- `metis-5.1.0.tar.gz` - Sources METIS 5.1.0
- `nlopt-2.7.1.tar.gz` - Sources NLOPT 2.7.1
- `install_metis.sh` - Script d'installation METIS
- `install_nlopt.sh` - Script d'installation NLOPT

## Installation

### Sur SUSE 15 SP4 (avec les sources)

```bash
# Installer METIS
chmod +x install_metis.sh
./install_metis.sh

# Installer NLOPT
chmod +x install_nlopt.sh
./install_nlopt.sh
```

### Avec zypper (si connexion internet)

```bash
# METIS
sudo zypper install metis-devel

# NLOPT
sudo zypper install nlopt-devel
```

## Prérequis

- cmake
- make
- gcc/g++

## Note

Ces dépendances sont **optionnelles** pour Tucanos.

- **METIS** : Utilisé pour le partitionnement de maillage
- **NLOPT** : Utilisé pour le lissage de maillage

Tucanos peut compiler et fonctionner sans elles, mais avec des fonctionnalités réduites.
