#!/bin/bash
# Installation de Rust hors ligne sur SUSE 15
# Ce script installe Rust sans connexion internet

echo "=== Installation Rust hors ligne sur SUSE 15 ==="

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "rust-1.89.0-x86_64-unknown-linux-gnu.tar.gz" ]; then
    echo "❌ Fichier rust-1.89.0-x86_64-unknown-linux-gnu.tar.gz non trouvé"
    echo "Assurez-vous d'être dans le répertoire rust-offline-package"
    exit 1
fi

# Vérifier les outils nécessaires
echo "Vérification des outils nécessaires..."

if ! command -v tar >/dev/null 2>&1; then
    echo "❌ tar non trouvé. Installation requise:"
    echo "sudo zypper install tar"
    exit 1
fi

if ! command -v gcc >/dev/null 2>&1; then
    echo "❌ gcc non trouvé. Installation requise:"
    echo "sudo zypper install gcc gcc-c++"
    exit 1
fi

echo "✅ Outils nécessaires trouvés"

# Créer le répertoire d'installation
INSTALL_DIR="/usr/local/rust"
echo "Installation dans: $INSTALL_DIR"

# Demander confirmation
read -p "Installer Rust dans $INSTALL_DIR ? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation annulée"
    exit 0
fi

# Créer le répertoire d'installation
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Extraire Rust
echo "Extraction de Rust..."
sudo tar -xzf "$OLDPWD/rust-1.89.0-x86_64-unknown-linux-gnu.tar.gz"

# Extraire les composants
echo "Extraction des composants Rust..."
sudo tar -xzf "$OLDPWD/rustc-1.89.0-x86_64-unknown-linux-gnu.tar.gz"
sudo tar -xzf "$OLDPWD/rust-std-1.89.0-x86_64-unknown-linux-gnu.tar.gz"
sudo tar -xzf "$OLDPWD/cargo-1.89.0-x86_64-unknown-linux-gnu.tar.gz"

# Installer Rust
echo "Installation de Rust..."
cd rust-1.89.0-x86_64-unknown-linux-gnu
sudo ./install.sh --prefix="$INSTALL_DIR" --disable-ldconfig

# Installer rustc
echo "Installation de rustc..."
cd ../rustc-1.89.0-x86_64-unknown-linux-gnu
sudo ./install.sh --prefix="$INSTALL_DIR" --disable-ldconfig

# Installer rust-std
echo "Installation de rust-std..."
cd ../rust-std-1.89.0-x86_64-unknown-linux-gnu
sudo ./install.sh --prefix="$INSTALL_DIR" --disable-ldconfig

# Installer cargo
echo "Installation de cargo..."
cd ../cargo-1.89.0-x86_64-unknown-linux-gnu
sudo ./install.sh --prefix="$INSTALL_DIR" --disable-ldconfig

# Créer les liens symboliques
echo "Création des liens symboliques..."
sudo ln -sf "$INSTALL_DIR/bin/rustc" /usr/local/bin/rustc
sudo ln -sf "$INSTALL_DIR/bin/cargo" /usr/local/bin/cargo
sudo ln -sf "$INSTALL_DIR/bin/rustup" /usr/local/bin/rustup

# Ajouter au PATH système
echo "Configuration du PATH..."
if ! grep -q "$INSTALL_DIR/bin" /etc/environment; then
    echo "PATH=\"$INSTALL_DIR/bin:\$PATH\"" | sudo tee -a /etc/environment
fi

# Créer le fichier de profil
sudo tee /etc/profile.d/rust.sh > /dev/null << EOF
#!/bin/bash
export PATH="$INSTALL_DIR/bin:\$PATH"
export RUSTUP_HOME="$INSTALL_DIR"
export CARGO_HOME="$INSTALL_DIR"
EOF

sudo chmod +x /etc/profile.d/rust.sh

# Vérifier l'installation
echo "Vérification de l'installation..."
export PATH="$INSTALL_DIR/bin:$PATH"

if command -v rustc >/dev/null 2>&1; then
    echo "✅ rustc installé: $(rustc --version)"
else
    echo "❌ rustc non trouvé"
    exit 1
fi

if command -v cargo >/dev/null 2>&1; then
    echo "✅ cargo installé: $(cargo --version)"
else
    echo "❌ cargo non trouvé"
    exit 1
fi

echo ""
echo "=== Installation Rust terminée avec succès ! ==="
echo ""
echo "Pour utiliser Rust dans une nouvelle session:"
echo "  source /etc/profile.d/rust.sh"
echo "  # ou redémarrer votre session"
echo ""
echo "Vérification:"
echo "  rustc --version"
echo "  cargo --version"
echo ""
echo "Vous pouvez maintenant compiler Tucanos !"



