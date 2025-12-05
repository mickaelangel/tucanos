# Structure du dépôt Git Tucanos - Version Propre

## Structure proposée

```
tucanos/
├── README.md                           # Documentation principale
├── DESCRIPTION_TUCANOS.md              # Description détaillée
├── .gitignore                          # Exclusions Git
│
├── docs/                               # Documentation
│   ├── LIRE_MOI_INSTALLATION.md       # Guide installation
│   ├── RECAPITULATIF_FINAL.md         # Récapitulatif technique
│   ├── COMMENT_CA_MARCHE_VRAIMENT.md  # Explications détaillées
│   ├── GUIDE_FINAL_INSTALLATION_TUCANOS_SUSE15.md
│   ├── INSTALLATION_100_POURCENT_OFFLINE.md
│   └── autres guides...
│
├── scripts/                            # Scripts d'installation
│   ├── install_tucanos_offline.sh     # Script principal
│   ├── install_metis.sh
│   ├── install_nlopt.sh
│   └── autres scripts .sh et .ps1...
│
├── sources/                            # Sources Tucanos (léger)
│   └── tucanos-main/                  # Code source de Tucanos
│       ├── Cargo.toml
│       ├── README.md
│       ├── tucanos/
│       ├── tmesh/
│       ├── pytucanos/
│       └── pytmesh/
│
└── config/                             # Fichiers de configuration
    ├── rust-toolchain.toml
    └── cargo-config-examples/
```

## Fichiers à EXCLURE du Git (dans .gitignore)

- ❌ Archives: *.zip, *.tar.gz (sauf petites archives)
- ❌ Dossiers vendor: cargo-vendor/, tucanos-vendor-*/
- ❌ Packages offline: rust-offline-package/*.tar.gz
- ❌ Duplications: tucanos/, tucanos1/, Nouveau dossier/tucanos-complete-*
- ❌ Binaires: *.exe, *.so, target/
- ❌ Documents Word: *.docx
- ❌ RPMs lourds: *.rpm > 50MB

## Fichiers à GARDER

- ✅ Scripts .sh et .ps1
- ✅ Documentation .md
- ✅ Sources Tucanos (code Rust)
- ✅ README et guides
- ✅ Fichiers de configuration

