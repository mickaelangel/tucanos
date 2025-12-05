#!/bin/bash
# VÃ©rification des prÃ©requis pour installation hors ligne

set -e

echo "=== VÃ©rification des prÃ©requis pour installation HORS LIGNE ==="
echo ""

# VÃ©rifier la distribution
if [ ! -f /etc/os-release ]; then
    echo "ERREUR: Fichier /etc/os-release non trouvÃ©"
    exit 1
fi

source /etc/os-release
echo "Distribution: $PRETTY_NAME"

if [[ "$ID" != "opensuse" && "$ID" != "sles" ]]; then
    echo "ATTENTION: Ce script est conÃ§u pour SUSE Linux"
    echo "Distribution dÃ©tectÃ©e: $PRETTY_NAME"
    read -p "Continuer quand mÃªme? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# VÃ©rifier Rust
echo "=== VÃ©rification de Rust ==="
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version | cut -d' ' -f2)
    echo "âœ“ Rust trouvÃ©: $RUST_VERSION"
else
    echo "âœ— Rust non trouvÃ©"
    echo "  Installez Rust avec: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    echo "  OU installez depuis les packages systÃ¨me si disponibles"
    exit 1
fi

# VÃ©rifier les outils de compilation
echo ""
echo "=== VÃ©rification des outils de compilation ==="

if command -v gcc &> /dev/null; then
    echo "âœ“ gcc trouvÃ©: $(gcc --version | head -n1)"
else
    echo "âœ— gcc non trouvÃ©"
    echo "  Installez avec: zypper install gcc gcc-c++"
    exit 1
fi

if command -v make &> /dev/null; then
    echo "âœ“ make trouvÃ©: $(make --version | head -n1)"
else
    echo "âœ— make non trouvÃ©"
    echo "  Installez avec: zypper install make"
    exit 1
fi

if command -v pkg-config &> /dev/null; then
    echo "âœ“ pkg-config trouvÃ©: $(pkg-config --version)"
else
    echo "âœ— pkg-config non trouvÃ©"
    echo "  Installez avec: zypper install pkg-config"
    exit 1
fi

# VÃ©rifier Python
echo ""
echo "=== VÃ©rification de Python ==="

if command -v python3 &> /dev/null; then
    echo "âœ“ python3 trouvÃ©: $(python3 --version)"
else
    echo "âœ— python3 non trouvÃ©"
    echo "  Installez avec: zypper install python3 python3-devel"
    exit 1
fi

if command -v pip3 &> /dev/null; then
    echo "âœ“ pip3 trouvÃ©: $(pip3 --version)"
else
    echo "âœ— pip3 non trouvÃ©"
    echo "  Installez avec: zypper install python3-pip"
    exit 1
fi

# VÃ©rifier maturin
echo ""
echo "=== VÃ©rification de maturin ==="
if command -v maturin &> /dev/null; then
    echo "âœ“ maturin trouvÃ©: $(maturin --version)"
else
    echo "âš  maturin non trouvÃ© - sera installÃ© automatiquement"
fi

# VÃ©rifier les dÃ©pendances optionnelles
echo ""
echo "=== VÃ©rification des dÃ©pendances optionnelles ==="

# METIS
if pkg-config --exists metis 2>/dev/null; then
    echo "âœ“ METIS trouvÃ© via pkg-config"
elif [ -f /usr/local/lib/libmetis.so ] || [ -f /usr/lib/libmetis.so ]; then
    echo "âœ“ METIS trouvÃ© dans le systÃ¨me"
else
    echo "âš  METIS non trouvÃ© (optionnel)"
    echo "  Pour l'installer: https://github.com/KarypisLab/METIS"
fi

# NLOPT
if pkg-config --exists nlopt 2>/dev/null; then
    echo "âœ“ NLOPT trouvÃ© via pkg-config"
elif [ -f /usr/local/lib/libnlopt.so ] || [ -f /usr/lib/libnlopt.so ]; then
    echo "âœ“ NLOPT trouvÃ© dans le systÃ¨me"
else
    echo "âš  NLOPT non trouvÃ© (optionnel)"
    echo "  Installez avec: zypper install nlopt-devel"
fi

echo ""
echo "=== RÃ©sumÃ© ==="
echo "âœ“ PrÃ©requis de base: OK"
echo "âš  DÃ©pendances optionnelles: VÃ©rifiez selon vos besoins"
echo ""
echo "Vous pouvez maintenant exÃ©cuter:"
echo "  ./build-tucanos-offline.sh"
