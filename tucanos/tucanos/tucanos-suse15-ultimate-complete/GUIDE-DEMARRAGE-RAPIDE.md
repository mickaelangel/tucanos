
# 🚀 Guide de Démarrage Rapide - Installation Hors Ligne SUSE 15 SP4

## ⚡ Installation en 5 minutes (si le package est déjà préparé)

### Sur la machine HORS LIGNE (SUSE 15 SP4):

```bash
# 1. Décompresser le package
tar xzf tucanos-offline.tar.gz
cd tucanos-suse15-ultimate-complete

# 2. Installer
chmod +x install-complete-offline-improved.sh
./install-complete-offline-improved.sh

# 3. Finaliser
cd tucanos-install
sudo ./install-system.sh
./install-python.sh
./test-installation.sh

# 4. Tester
python3 -c "import pytmesh, pytucanos; print('✓ Installation réussie!')"
```

---

## 📋 Préparation du package (machine AVEC internet)

### Option A: Tout automatique (RECOMMANDÉ)

```bash
cd tucanos-suse15-ultimate-complete
./prepare-complete-offline-package.sh
```

**Note**: Doit être exécuté sur SUSE 15 avec zypper

### Option B: Étape par étape

```bash
# 1. Packages RPM (sur SUSE 15 uniquement)
./download-rpm-dependencies.sh

# 2. Rust + Vendor (sur n'importe quel Linux)
./download-rust-complete.sh
```

---

## ✅ Liste de vérification

### Avant de transférer, vérifiez:

- [ ] `dependencies/system/*.rpm` existe (50-100 fichiers)
- [ ] `dependencies/rust/rustup-init` existe
- [ ] `vendor/` existe et contient des dossiers
- [ ] `dependencies/python/python/*.whl` (4 fichiers)
- [ ] `PACKAGE-READY.txt` créé

### Commandes de vérification:

```bash
# Compter les RPM
ls dependencies/system/*.rpm | wc -l

# Compter les crates vendor
ls -d vendor/*/ | wc -l

# Vérifier les wheels Python
ls dependencies/python/python/*.whl

# Consulter le résumé
cat PACKAGE-READY.txt
```

---

## 🎯 Que faire en cas de problème?

### Erreur: "zypper command not found"

➜ Vous devez exécuter `download-rpm-dependencies.sh` sur SUSE 15, pas sur Ubuntu/Debian

### Erreur: "cargo download failed"

➜ Le vendor n'est pas configuré. Exécutez `./download-rust-complete.sh`

### Erreur: "gcc not found"

➜ Les packages RPM ne sont pas installés. Vérifiez `dependencies/system/`

### Erreur: "maturin not found"

➜ Ajoutez au PATH: `export PATH="$HOME/.local/bin:$PATH"`

---

## 📊 Résumé des scripts

| Script | Où l'exécuter | Nécessite | Durée |
|--------|---------------|-----------|-------|
| `prepare-complete-offline-package.sh` | SUSE 15 + Internet | sudo | 20-30 min |
| `download-rpm-dependencies.sh` | SUSE 15 + Internet | sudo | 10-15 min |
| `download-rust-complete.sh` | Linux + Internet | - | 10-15 min |
| `install-complete-offline-improved.sh` | SUSE 15 HORS LIGNE | sudo | 20-40 min |

---

## 💡 Conseils

### Pour gagner du temps:

1. **Utilisez le script master**: `prepare-complete-offline-package.sh`
2. **Préparez sur SUSE 15**: Les RPM seront compatibles
3. **Vérifiez avant de transférer**: Utilisez `PACKAGE-READY.txt`
4. **Compressez pour le transfert**: `tar czf` réduit la taille de 50%

### Pour économiser de l'espace:

- Après installation réussie, supprimez `vendor/` (~1-2 GB)
- Gardez les RPM pour d'autres installations
- Les wheels Python sont petits, gardez-les

---

## 📞 Besoin d'aide?

1. **Consultez**: `README-INSTALLATION-COMPLETE.md` (guide complet)
2. **Vérifiez**: Section Dépannage du README
3. **Cherchez**: Dans les fichiers `*-INFO.txt` et `*-LIST.txt`

---

**Temps total estimé**:
- Préparation: 30 min
- Transfert: 10-60 min (selon méthode)
- Installation: 30 min
- **Total: 1-2 heures**

Bonne installation! 🎉

