# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Unreleased]

### Ajouté
- Installation personnalisée avec choix du répertoire (variable PREFIX)
- Script `install_tucanos_custom.sh` pour installation flexible
- Documentation complète `INSTALLATION_DEPUIS_GIT.md`
- Guide de contribution `CONTRIBUTING.md`
- Tests de validation du package

### Modifié
- Réorganisation de la structure du dépôt (docs/, scripts/, sources/, config/)
- README amélioré avec deux méthodes d'installation
- .gitignore optimisé pour exclure les gros fichiers

## [1.0.0] - 2025-12-05

### Ajouté
- Package d'installation offline complet pour SUSE 15 SP4
- Scripts d'installation automatisés
- Documentation en français
- Support de Rust 1.89.0 offline
- Support de METIS et NLOPT (optionnels)
- Dépendances Rust vendorisées (231 packages)
- Installation sans sudo dans ~/.local/
- Guide d'installation détaillé
- Description complète de Tucanos

### Fonctionnalités
- Installation 100% offline
- Compilation de Tucanos depuis sources
- Installation de make, Rust, METIS, NLOPT
- Configuration automatique de l'environnement
- Détection des dépendances optionnelles

---

[Unreleased]: https://github.com/mickaelangel/tucanos/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/mickaelangel/tucanos/releases/tag/v1.0.0

