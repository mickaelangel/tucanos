#!/bin/bash
# Script d'installation make pour SUSE 15 SP4 (Sans sudo)
# Ce script compile et installe make dans ~/.local/

set -e  # Arrêter en cas d'erreur

echo "=== Installation make sur SUSE 15 SP4 (Sans sudo) ==="

# Vérifier si make est déjà installé
if command -v make >/dev/null 2>&1; then
    echo "✓ make est déjà installé: $(make --version | head -n1)"
    exit 0
fi

echo "make n'est pas installé. Installation dans ~/.local/..."

# Créer les répertoires locaux
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/lib"
mkdir -p "$HOME/.local/share/man/man1"

# Vérifier si gcc est disponible
if ! command -v gcc >/dev/null 2>&1; then
    echo "✗ ERREUR: gcc n'est pas disponible"
    echo "gcc est requis pour compiler make"
    echo ""
    echo "Solutions:"
    echo "  1. Demander à l'administrateur d'installer gcc:"
    echo "     sudo zypper install gcc"
    echo "  2. Compiler gcc avec install_gcc_no_sudo.sh (long)"
    exit 1
fi

echo "✓ gcc trouvé: $(gcc --version | head -n1)"

# Chercher les sources make
MAKE_SOURCE=""
MAKE_VERSION=""

for loc in "." "sources" "../suse-packages/sources" "suse-packages/sources"; do
    if [ -f "$loc/make-4.3.tar.gz" ]; then
        MAKE_SOURCE="$loc/make-4.3.tar.gz"
        MAKE_VERSION="4.3"
        echo "✓ Sources make trouvées: $MAKE_SOURCE"
        break
    elif [ -f "$loc/make-4.2.1.tar.gz" ]; then
        MAKE_SOURCE="$loc/make-4.2.1.tar.gz"
        MAKE_VERSION="4.2.1"
        echo "✓ Sources make trouvées: $MAKE_SOURCE"
        break
    fi
done

if [ -z "$MAKE_SOURCE" ]; then
    echo "✗ Sources make non trouvées"
    echo "Cherché: make-4.3.tar.gz ou make-4.2.1.tar.gz"
    exit 1
fi

# Créer un répertoire de build temporaire
TEMP_DIR=$(mktemp -d)
echo "Extraction de make $MAKE_VERSION dans $TEMP_DIR..."
tar xzf "$MAKE_SOURCE" -C "$TEMP_DIR"

cd "$TEMP_DIR/make-$MAKE_VERSION"

# Configuration pour installation dans ~/.local
echo "Configuration de make pour installation dans ~/.local/..."
./configure --prefix="$HOME/.local"

if [ $? -ne 0 ]; then
    echo "✗ Erreur lors de la configuration"
    cd "$HOME"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Compilation
echo "Compilation de make..."
# Utiliser 'gcc' directement car 'make' n'est pas encore installé
# Le Makefile généré par configure peut être exécuté avec sh
sh ./build.sh || {
    # Si build.sh échoue, essayer une compilation manuelle basique
    echo "build.sh a échoué, tentative de compilation manuelle..."
    
    # Compiler les fichiers source principaux
    gcc -O2 -o make *.c glob/*.c -I. -Iglob -DHAVE_CONFIG_H || {
        echo "✗ Erreur lors de la compilation"
        cd "$HOME"
        rm -rf "$TEMP_DIR"
        exit 1
    }
}

# Installation
echo "Installation de make dans ~/.local/bin/..."
cp make "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/make"

# Copier la documentation si disponible
if [ -f "make.1" ]; then
    cp make.1 "$HOME/.local/share/man/man1/"
fi

# Nettoyer
cd "$HOME"
rm -rf "$TEMP_DIR"

# Ajouter ~/.local/bin au PATH si nécessaire
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
    echo "✓ ~/.local/bin ajouté au PATH"
    echo "  Exécutez: source ~/.bashrc"
fi

# Vérification
export PATH="$HOME/.local/bin:$PATH"
if command -v make >/dev/null 2>&1; then
    echo "✓ make installé avec succès !"
    make --version | head -n1
else
    echo "✗ make n'est pas disponible après installation"
    echo "Vérifiez que ~/.local/bin est dans votre PATH"
    echo "Exécutez: source ~/.bashrc"
    exit 1
fi

echo ""
echo "Installation terminée !"
echo "make est installé dans: ~/.local/bin/make"
echo ""
echo "Pour utiliser make immédiatement:"
echo "  source ~/.bashrc"
echo "ou:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""





