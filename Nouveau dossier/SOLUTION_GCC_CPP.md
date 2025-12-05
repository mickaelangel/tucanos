# Solution pour g++ (gcc-c++)

## Le Problème
METIS et NLOPT nécessitent g++ (compilateur C++) pour compiler.

## La Solution Simple
**g++ fait partie de gcc**, il est probablement déjà installé sur le système SUSE 15 SP4.

### Vérification sur votre machine SUSE
```bash
# Vérifier si g++ est disponible
g++ --version

# Si g++ n'est pas trouvé, demander à l'admin :
sudo zypper install gcc-c++
```

### Installation hors ligne de gcc-c++ (avec RPM)

Sur SUSE, `gcc-c++` est un package RPM standard. Voici comment le bundler :

1. **Sur une machine SUSE avec Internet** (ou machine de l'admin) :
```bash
# Télécharger le RPM et ses dépendances
sudo zypper download gcc-c++

# Les RPMs sont dans /var/cache/zypp/packages/
```

2. **Sur votre machine Windows** (pour créer le bundle) :
- Télécharger depuis OpenSUSE Leap 15.4 repos
- Les URLs exactes varient, il faut les chercher

3. **Sur la machine SUSE hors ligne** :
```bash
sudo rpm -ivh gcc*.rpm
```

## Alternative : Détection Intelligente

Je vais modifier les scripts `install_metis.sh` et `install_nlopt.sh` pour :
1. Détecter si g++ est disponible
2. Si OUI → installer normalement
3. Si NON → afficher un message clair et sauter l'installation

Tucanos fonctionnera sans METIS/NLOPT (ce sont des features optionnelles).



