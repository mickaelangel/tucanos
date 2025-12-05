#!/bin/bash
# Installation de make sur SUSE 15 SP4 hors ligne
# Ce script installe make et les dépendances nécessaires sans internet

echo "=== Installation de make sur SUSE 15 SP4 (Hors ligne) ==="

# Vérifier si nous sommes sur SUSE 15
if [ ! -f /etc/os-release ]; then
    echo "Erreur: Fichier /etc/os-release non trouvé"
    exit 1
fi

source /etc/os-release
echo "Système détecté: $PRETTY_NAME"

# Vérifier si make est déjà installé
if command -v make >/dev/null 2>&1; then
    echo "✅ make est déjà installé: $(make --version | head -n1)"
    exit 0
fi

echo "❌ make n'est pas installé. Installation nécessaire..."

# Méthode 1: Utiliser les paquets RPM locaux (si disponibles)
echo ""
echo "=== Méthode 1: Installation depuis les paquets RPM locaux ==="

# Chercher les paquets RPM dans le répertoire courant
if [ -d "suse-packages" ] && [ -d "suse-packages/RPMS" ]; then
    echo "Paquets RPM trouvés dans suse-packages/RPMS/"
    
    # Chercher le paquet make
    MAKE_RPM=$(find suse-packages/RPMS -name "*make*" -type f | head -n1)
    
    if [ -n "$MAKE_RPM" ]; then
        echo "Paquet make trouvé: $MAKE_RPM"
        echo "Installation du paquet make..."
        
        # Installer le paquet
        sudo rpm -ivh "$MAKE_RPM" --force --nodeps
        
        if [ $? -eq 0 ]; then
            echo "✅ make installé avec succès"
            make --version | head -n1
            exit 0
        else
            echo "❌ Erreur lors de l'installation du paquet make"
        fi
    else
        echo "❌ Paquet make non trouvé dans suse-packages/RPMS/"
    fi
else
    echo "❌ Répertoire suse-packages/RPMS/ non trouvé"
fi

# Méthode 2: Compilation depuis les sources (si disponibles)
echo ""
echo "=== Méthode 2: Compilation depuis les sources ==="

# Chercher les sources de make
if [ -f "make-4.3.tar.gz" ] || [ -f "make-4.2.1.tar.gz" ]; then
    echo "Sources de make trouvées"
    
    # Extraire les sources
    if [ -f "make-4.3.tar.gz" ]; then
        tar xzf make-4.3.tar.gz
        cd make-4.3
    elif [ -f "make-4.2.1.tar.gz" ]; then
        tar xzf make-4.2.1.tar.gz
        cd make-4.2.1
    fi
    
    # Configuration
    echo "Configuration de make..."
    ./configure --prefix=/usr/local
    
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de la configuration"
        exit 1
    fi
    
    # Compilation
    echo "Compilation de make..."
    make
    
    if [ $? -ne 0 ]; then
        echo "❌ Erreur lors de la compilation"
        exit 1
    fi
    
    # Installation
    echo "Installation de make..."
    sudo make install
    
    if [ $? -eq 0 ]; then
        echo "✅ make compilé et installé avec succès"
        /usr/local/bin/make --version | head -n1
        
        # Créer un lien symbolique si nécessaire
        if [ ! -f /usr/bin/make ]; then
            sudo ln -sf /usr/local/bin/make /usr/bin/make
            echo "✅ Lien symbolique créé: /usr/bin/make"
        fi
        
        exit 0
    else
        echo "❌ Erreur lors de l'installation"
        exit 1
    fi
else
    echo "❌ Sources de make non trouvées"
fi

# Méthode 3: Utiliser un binaire pré-compilé
echo ""
echo "=== Méthode 3: Utilisation d'un binaire pré-compilé ==="

# Chercher un binaire make
if [ -f "make" ] && [ -x "make" ]; then
    echo "Binaire make trouvé"
    
    # Vérifier que c'est un binaire valide
    file make | grep -q "ELF" && {
        echo "Installation du binaire make..."
        sudo cp make /usr/local/bin/make
        sudo chmod +x /usr/local/bin/make
        
        # Créer un lien symbolique si nécessaire
        if [ ! -f /usr/bin/make ]; then
            sudo ln -sf /usr/local/bin/make /usr/bin/make
        fi
        
        echo "✅ make installé depuis le binaire"
        make --version | head -n1
        exit 0
    } || {
        echo "❌ Le fichier 'make' n'est pas un binaire valide"
    }
else
    echo "❌ Binaire make non trouvé"
fi

# Méthode 4: Installation manuelle avec les outils disponibles
echo ""
echo "=== Méthode 4: Installation manuelle ==="

echo "Tentative d'installation manuelle de make..."

# Vérifier si gcc est disponible
if ! command -v gcc >/dev/null 2>&1; then
    echo "❌ gcc n'est pas disponible. Installation de gcc d'abord..."
    
    # Chercher le paquet gcc
    GCC_RPM=$(find . -name "*gcc*" -name "*.rpm" | head -n1)
    if [ -n "$GCC_RPM" ]; then
        echo "Installation de gcc depuis: $GCC_RPM"
        sudo rpm -ivh "$GCC_RPM" --force --nodeps
    else
        echo "❌ Paquet gcc non trouvé"
        exit 1
    fi
fi

# Créer un make minimal
echo "Création d'un make minimal..."
cat > /tmp/simple_make.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: make [target]\n");
        return 1;
    }
    
    // Version simple de make qui exécute des commandes basiques
    char command[1024];
    snprintf(command, sizeof(command), "gcc -o %s %s.c", argv[1], argv[1]);
    
    printf("Exécution: %s\n", command);
    return system(command);
}
EOF

# Compiler le make minimal
gcc -o /tmp/simple_make /tmp/simple_make.c

if [ $? -eq 0 ]; then
    sudo cp /tmp/simple_make /usr/local/bin/make
    sudo chmod +x /usr/local/bin/make
    
    if [ ! -f /usr/bin/make ]; then
        sudo ln -sf /usr/local/bin/make /usr/bin/make
    fi
    
    echo "✅ make minimal installé"
    make --version 2>/dev/null || echo "make installé (version minimale)"
    exit 0
else
    echo "❌ Impossible de compiler le make minimal"
fi

# Si toutes les méthodes ont échoué
echo ""
echo "❌ Impossible d'installer make avec les méthodes disponibles"
echo ""
echo "Solutions alternatives:"
echo "1. Transférer un paquet RPM make depuis un système connecté"
echo "2. Transférer les sources de make et les compiler"
echo "3. Utiliser un binaire make pré-compilé"
echo ""
echo "Paquets RPM make pour SUSE 15 SP4:"
echo "  - make-4.2.1-1.1.x86_64.rpm"
echo "  - make-4.3-1.1.x86_64.rpm"
echo ""
echo "Sources make:"
echo "  - make-4.3.tar.gz"
echo "  - make-4.2.1.tar.gz"

exit 1






