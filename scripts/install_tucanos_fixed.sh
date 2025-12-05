#!/bin/bash
# Script d'installation de Tucanos pour SUSE 15 (Version corrigée)
# Ce script corrige les problèmes de dépendances manquantes

echo "=== Installation de Tucanos sur SUSE 15 (Version corrigée) ==="

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fonction pour installer les dépendances manquantes
install_dependencies() {
    echo "Vérification et installation des dépendances..."
    
    local missing_deps=()
    
    # Vérifier les dépendances essentielles
    if ! command_exists gcc; then
        missing_deps+=("gcc")
    fi
    
    if ! command_exists g++; then
        missing_deps+=("gcc-c++")
    fi
    
    if ! command_exists make; then
        missing_deps+=("make")
    fi
    
    if ! command_exists cmake; then
        missing_deps+=("cmake")
    fi
    
    if ! command_exists pkg-config; then
        missing_deps+=("pkg-config")
    fi
    
    # Installer les dépendances manquantes
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Dépendances manquantes: ${missing_deps[*]}"
        echo "Installation des dépendances..."
        
        if command_exists zypper; then
            sudo zypper install -y "${missing_deps[@]}"
        elif command_exists apt-get; then
            sudo apt-get update && sudo apt-get install -y "${missing_deps[@]}"
        elif command_exists yum; then
            sudo yum install -y "${missing_deps[@]}"
        else
            echo "❌ Gestionnaire de paquets non reconnu"
            echo "Veuillez installer manuellement: ${missing_deps[*]}"
            exit 1
        fi
        
        # Vérifier l'installation
        for dep in "${missing_deps[@]}"; do
            if ! command_exists "$dep"; then
                echo "❌ $dep n'est toujours pas disponible après installation"
                exit 1
            fi
        done
        
        echo "✅ Toutes les dépendances sont installées"
    else
        echo "✅ Toutes les dépendances sont déjà installées"
    fi
}

# Fonction pour installer Rust si nécessaire
install_rust() {
    if ! command_exists rustc; then
        echo "Rust n'est pas installé. Installation de Rust..."
        
        # Vérifier si rustup-init existe
        if [ ! -f "rustup-init" ]; then
            echo "❌ Fichier rustup-init non trouvé"
            echo "Veuillez télécharger rustup-init depuis https://rustup.rs/"
            exit 1
        fi
        
        chmod +x rustup-init
        ./rustup-init -y --default-toolchain stable-x86_64-unknown-linux-gnu
        source ~/.cargo/env
        
        if command_exists rustc; then
            echo "✅ Rust installé avec succès: $(rustc --version)"
        else
            echo "❌ Erreur lors de l'installation de Rust"
            exit 1
        fi
    else
        echo "✅ Rust déjà installé: $(rustc --version)"
    fi
}

# Fonction pour installer NLOPT si nécessaire
install_nlopt() {
    if ! pkg-config --exists nlopt; then
        echo "NLOPT non trouvé. Tentative d'installation..."
        
        # Essayer d'abord le gestionnaire de paquets
        if command_exists zypper; then
            echo "Installation de NLOPT via zypper..."
            sudo zypper install -y nlopt-devel
        elif command_exists apt-get; then
            echo "Installation de NLOPT via apt-get..."
            sudo apt-get update && sudo apt-get install -y libnlopt-dev
        elif command_exists yum; then
            echo "Installation de NLOPT via yum..."
            sudo yum install -y nlopt-devel
        fi
        
        # Vérifier l'installation
        if pkg-config --exists nlopt; then
            echo "✅ NLOPT installé: $(pkg-config --modversion nlopt)"
        else
            echo "⚠️  NLOPT non installé (optionnel)"
        fi
    else
        echo "✅ NLOPT déjà installé: $(pkg-config --modversion nlopt)"
    fi
}

# Fonction pour installer Metis si nécessaire
install_metis() {
    if ! pkg-config --exists metis; then
        echo "Metis non trouvé. Tentative d'installation..."
        
        # Essayer d'abord le gestionnaire de paquets
        if command_exists zypper; then
            echo "Installation de Metis via zypper..."
            sudo zypper install -y metis-devel
        elif command_exists apt-get; then
            echo "Installation de Metis via apt-get..."
            sudo apt-get update && sudo apt-get install -y libmetis-dev
        elif command_exists yum; then
            echo "Installation de Metis via yum..."
            sudo yum install -y metis-devel
        fi
        
        # Vérifier l'installation
        if pkg-config --exists metis; then
            echo "✅ Metis installé: $(pkg-config --modversion metis)"
        else
            echo "⚠️  Metis non installé (optionnel)"
        fi
    else
        echo "✅ Metis déjà installé: $(pkg-config --modversion metis)"
    fi
}

# Fonction pour compiler Tucanos
compile_tucanos() {
    if [ ! -d "tucanos" ]; then
        echo "❌ Répertoire 'tucanos' non trouvé"
        exit 1
    fi
    
    echo "Compilation de Tucanos..."
    cd tucanos
    
    # Vérifier les fonctionnalités disponibles
    local features=""
    
    if pkg-config --exists metis; then
        features="$features metis"
        echo "✅ Support Metis activé"
    fi
    
    if pkg-config --exists nlopt; then
        features="$features nlopt"
        echo "✅ Support NLOPT activé"
    fi
    
    # Compilation
    if [ -n "$features" ]; then
        echo "Compilation avec les fonctionnalités: $features"
        cargo build --workspace --release --features "$features"
    else
        echo "Compilation sans fonctionnalités optionnelles"
        cargo build --workspace --release
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Compilation réussie !"
        
        # Afficher les fichiers générés
        echo "Fichiers générés:"
        find target/release -name "*.so" -o -name "*.a" -o -name "*.h" 2>/dev/null | while read file; do
            echo "  - $file"
        done
        
        return 0
    else
        echo "❌ Erreur lors de la compilation"
        echo "Tentative avec les fonctionnalités minimales..."
        cargo build --workspace --release --no-default-features
        
        if [ $? -eq 0 ]; then
            echo "✅ Compilation réussie (version minimale) !"
            return 0
        else
            echo "❌ Échec de la compilation"
            return 1
        fi
    fi
}

# Fonction pour installer Tucanos globalement
install_globally() {
    read -p "Installer Tucanos globalement pour tous les utilisateurs ? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation globale..."
        
        # Créer les répertoires
        sudo mkdir -p /usr/local/lib
        sudo mkdir -p /usr/local/include
        
        # Copier les bibliothèques
        if [ -f "target/release/libtucanos.so" ]; then
            sudo cp target/release/libtucanos.so /usr/local/lib/
            sudo ldconfig
            echo "✅ Bibliothèque installée dans /usr/local/lib/"
        fi
        
        # Copier les headers
        if [ -f "target/release/tucanos.h" ]; then
            sudo cp target/release/tucanos.h /usr/local/include/
            echo "✅ Headers installés dans /usr/local/include/"
        fi
        
        echo "✅ Installation globale terminée"
    else
        echo "Installation locale uniquement"
    fi
}

# Fonction principale
main() {
    echo "Début de l'installation de Tucanos..."
    
    # Étape 1: Installer les dépendances
    install_dependencies
    
    # Étape 2: Installer Rust
    install_rust
    
    # Étape 3: Installer les dépendances optionnelles
    install_nlopt
    install_metis
    
    # Étape 4: Compiler Tucanos
    if compile_tucanos; then
        echo "✅ Compilation de Tucanos réussie"
        
        # Étape 5: Installation globale (optionnelle)
        install_globally
        
        echo ""
        echo "=== Installation terminée avec succès ! ==="
        echo "Tucanos est prêt à être utilisé !"
        echo ""
        echo "Pour utiliser Tucanos:"
        echo "  - API C: #include <tucanos.h>"
        echo "  - Compilation: gcc -I/usr/local/include -L/usr/local/lib -ltucanos votre_programme.c -o votre_programme"
        echo ""
        echo "Fichiers disponibles dans: $(pwd)/target/release/"
    else
        echo "❌ Échec de l'installation de Tucanos"
        exit 1
    fi
}

# Exécuter la fonction principale
main






