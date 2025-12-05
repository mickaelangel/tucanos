#!/bin/bash
# Installation g++ pour SUSE 15 SP4 (mode hors ligne avec RPMs)

echo "=== Installation g++ pour SUSE 15 SP4 ==="

# Vérifier si g++ est déjà installé
if command -v g++ >/dev/null 2>&1; then
    echo "✓ g++ déjà installé : $(g++ --version | head -n1)"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RPM_DIR="$SCRIPT_DIR/suse15-gcc-cpp-rpms"

# Vérifier la présence des RPMs
if [ ! -d "$RPM_DIR" ]; then
    echo "✗ Dossier RPMs non trouvé : $RPM_DIR"
    echo "Exécutez download_gcc_cpp_suse15sp4.ps1 sur Windows d'abord."
    exit 1
fi

rpm_count=$(ls -1 "$RPM_DIR"/*.rpm 2>/dev/null | wc -l)
if [ $rpm_count -eq 0 ]; then
    echo "✗ Aucun RPM trouvé dans $RPM_DIR"
    exit 1
fi

echo "✓ Trouvé $rpm_count RPM(s)"

# Vérifier si on a les droits sudo
if ! sudo -n true 2>/dev/null; then
    echo "✗ Installation de g++ nécessite sudo"
    echo "Demandez à votre administrateur d'exécuter :"
    echo "  cd $RPM_DIR"
    echo "  sudo rpm -ivh --nodeps *.rpm"
    exit 1
fi

echo "Installation des RPMs g++..."
cd "$RPM_DIR"

# Installer avec rpm
sudo rpm -ivh --nodeps *.rpm

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ g++ installé avec succès !"
    echo "Version : $(g++ --version | head -n1)"
    echo ""
    echo "Vous pouvez maintenant installer METIS et NLOPT :"
    echo "  cd ../suse-packages-optional"
    echo "  bash install_metis.sh"
    echo "  bash install_nlopt.sh"
else
    echo "✗ Erreur lors de l'installation des RPMs"
    echo ""
    echo "Si les RPMs ont des dépendances, essayez :"
    echo "  sudo zypper install gcc-c++"
    exit 1
fi




