#!/bin/bash
# Script de correction pour l'installation NLOPT
# Ce script corrige l'erreur "make: Command not found" lors de l'installation de NLOPT

echo "=== Correction de l'installation NLOPT ==="

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Vérifier et installer make si nécessaire
if ! command_exists make; then
    echo "❌ make n'est pas trouvé. Installation de make..."
    
    # Essayer d'installer make via le gestionnaire de paquets
    if command_exists zypper; then
        echo "Installation de make via zypper..."
        sudo zypper install -y make
    elif command_exists apt-get; then
        echo "Installation de make via apt-get..."
        sudo apt-get update && sudo apt-get install -y make
    elif command_exists yum; then
        echo "Installation de make via yum..."
        sudo yum install -y make
    else
        echo "❌ Impossible d'installer make automatiquement"
        echo "Veuillez installer make manuellement:"
        echo "  - Sur SUSE: sudo zypper install make"
        echo "  - Sur Ubuntu/Debian: sudo apt-get install make"
        echo "  - Sur CentOS/RHEL: sudo yum install make"
        exit 1
    fi
else
    echo "✅ make est déjà installé: $(make --version | head -n1)"
fi

# Vérifier que make fonctionne
if command_exists make; then
    echo "✅ make est maintenant disponible"
else
    echo "❌ make n'est toujours pas disponible après installation"
    exit 1
fi

# Fonction pour installer NLOPT depuis les sources
install_nlopt_from_source() {
    local nlopt_dir="$1"
    local build_dir="$2"
    
    echo "Installation de NLOPT depuis les sources..."
    
    # Se déplacer dans le répertoire de build
    cd "$build_dir"
    
    # Extraire NLOPT si nécessaire
    if [ ! -d "nlopt-2.7.1" ]; then
        if [ -f "$nlopt_dir/nlopt-2.7.1.tar.gz" ]; then
            echo "Extraction de NLOPT..."
            tar xzf "$nlopt_dir/nlopt-2.7.1.tar.gz"
        else
            echo "❌ Fichier nlopt-2.7.1.tar.gz non trouvé dans $nlopt_dir"
            return 1
        fi
    fi
    
    cd nlopt-2.7.1
    
    # Créer le répertoire de build
    mkdir -p build
    cd build
    
    # Configuration avec cmake
    echo "Configuration de NLOPT avec cmake..."
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
    
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de la configuration cmake"
        return 1
    fi
    
    # Compilation
    echo "Compilation de NLOPT..."
    make -j$(nproc)
    
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de la compilation"
        return 1
    fi
    
    # Installation
    echo "Installation de NLOPT..."
    sudo make install
    
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de l'installation"
        return 1
    fi
    
    # Mettre à jour le cache des bibliothèques
    sudo ldconfig
    
    echo "✅ NLOPT installé avec succès"
    return 0
}

# Fonction pour installer NLOPT via le gestionnaire de paquets
install_nlopt_via_package_manager() {
    echo "Tentative d'installation de NLOPT via le gestionnaire de paquets..."
    
    if command_exists zypper; then
        echo "Installation via zypper..."
        sudo zypper install -y nlopt-devel
    elif command_exists apt-get; then
        echo "Installation via apt-get..."
        sudo apt-get update && sudo apt-get install -y libnlopt-dev
    elif command_exists yum; then
        echo "Installation via yum..."
        sudo yum install -y nlopt-devel
    else
        echo "❌ Gestionnaire de paquets non reconnu"
        return 1
    fi
    
    # Vérifier l'installation
    if pkg-config --exists nlopt; then
        echo "✅ NLOPT installé via le gestionnaire de paquets"
        return 0
    else
        echo "❌ NLOPT non trouvé après installation via le gestionnaire de paquets"
        return 1
    fi
}

# Fonction principale
main() {
    echo "Vérification de NLOPT..."
    
    # Vérifier si NLOPT est déjà installé
    if pkg-config --exists nlopt; then
        echo "✅ NLOPT est déjà installé: $(pkg-config --modversion nlopt)"
        return 0
    fi
    
    echo "NLOPT non trouvé. Tentative d'installation..."
    
    # Essayer d'abord le gestionnaire de paquets
    if install_nlopt_via_package_manager; then
        echo "✅ NLOPT installé via le gestionnaire de paquets"
        return 0
    fi
    
    echo "Installation via le gestionnaire de paquets échouée. Tentative depuis les sources..."
    
    # Essayer depuis les sources
    local current_dir=$(pwd)
    local build_dir="/tmp/nlopt-build-$$"
    
    mkdir -p "$build_dir"
    
    if install_nlopt_from_source "$current_dir" "$build_dir"; then
        echo "✅ NLOPT installé depuis les sources"
        rm -rf "$build_dir"
        return 0
    else
        echo "❌ Échec de l'installation de NLOPT depuis les sources"
        rm -rf "$build_dir"
        return 1
    fi
}

# Exécuter la fonction principale
main

echo ""
echo "=== Instructions pour continuer l'installation Tucanos ==="
echo "Maintenant que make et NLOPT sont installés, vous pouvez:"
echo "1. Relancer le script d'installation Tucanos"
echo "2. Ou continuer manuellement avec:"
echo "   cd tucanos"
echo "   cargo build --workspace --release --features nlopt"
echo ""
echo "✅ Correction terminée !"






