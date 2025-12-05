#!/bin/bash
# Script pour créer un dépôt local SUSE 15
# À exécuter sur le serveur SUSE 15

echo "=== Création d'un dépôt local SUSE 15 ==="

# Vérifier que nous sommes sur SUSE 15
if [ ! -f /etc/os-release ]; then
    echo "Erreur: Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
if [[ "$ID" != "opensuse-leap" && "$VERSION_ID" != "15"* ]]; then
    echo "Attention: Ce script est conçu pour SUSE 15. Version détectée: $PRETTY_NAME"
    read -p "Continuer quand même ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Système détecté: $PRETTY_NAME"

# Vérifier que le répertoire RPMS existe
if [ ! -d "RPMS" ]; then
    echo "❌ Répertoire RPMS non trouvé"
    echo "Assurez-vous d'être dans le répertoire contenant les paquets RPM"
    exit 1
fi

# Vérifier que zypper est disponible
if ! command -v zypper >/dev/null 2>&1; then
    echo "❌ zypper non trouvé"
    echo "Ce script nécessite zypper pour fonctionner"
    exit 1
fi

echo "✅ zypper trouvé"

# Créer le répertoire du dépôt local
REPO_DIR="/tmp/local-repo"
echo "Création du dépôt local dans: $REPO_DIR"

# Créer le répertoire
mkdir -p "$REPO_DIR"

# Copier les paquets RPM
echo "Copie des paquets RPM..."
cp RPMS/*.rpm "$REPO_DIR/"

# Créer les métadonnées du dépôt
echo "Création des métadonnées du dépôt..."

# Installer createrepo si nécessaire
if ! command -v createrepo >/dev/null 2>&1; then
    echo "Installation de createrepo..."
    if command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y createrepo
    else
        echo "❌ Impossible d'installer createrepo sans zypper"
        exit 1
    fi
fi

# Créer les métadonnées
createrepo "$REPO_DIR"

# Ajouter le dépôt local à zypper
echo "Ajout du dépôt local à zypper..."
sudo zypper addrepo "file://$REPO_DIR" local-repo

# Actualiser les dépôts
echo "Actualisation des dépôts..."
sudo zypper refresh

# Installer les paquets nécessaires
echo "Installation des paquets nécessaires..."
sudo zypper install -y gcc gcc-c++ make cmake tar pkg-config

echo ""
echo "=== Installation terminée ==="
echo "Paquets installés:"
echo "  - gcc: $(gcc --version | head -n1)"
echo "  - g++: $(g++ --version | head -n1)"
echo "  - make: $(make --version | head -n1)"
echo "  - cmake: $(cmake --version | head -n1)"

echo ""
echo "Vous pouvez maintenant compiler Tucanos !"


