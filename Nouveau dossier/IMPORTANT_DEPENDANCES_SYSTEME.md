# ⚠️ DÉPENDANCES SYSTÈME REQUISES

## Installation de Tucanos : OK ✅
Le script `install_tucanos_offline.sh` fonctionne **100% hors ligne** sans g++.

## Installation de METIS et NLOPT : Nécessite g++ ⚠️

METIS et NLOPT sont des dépendances **optionnelles** écrites en C++.
Pour les compiler, vous avez besoin de **g++** (compilateur C++).

### Solution 1 : Demander à l'administrateur (RECOMMANDÉ)

```bash
sudo zypper install gcc-c++
```

### Solution 2 : Installation sans METIS/NLOPT

Si vous ne pouvez pas installer g++, **Tucanos fonctionnera quand même** !

- **METIS** : Utilisé pour le partitionnement de maillage (optionnel)
- **NLOPT** : Utilisé pour l'optimisation/lissage (optionnel)

### Que faire ?

1. **Installez Tucanos d'abord** (ne nécessite PAS g++) :
   ```bash
   bash install_tucanos_offline.sh
   ```

2. **Ensuite**, si vous avez accès à g++ :
   ```bash
   cd suse-packages-optional
   bash install_metis.sh
   bash install_nlopt.sh
   ```

### Vérifier si g++ est installé

```bash
g++ --version
```

Si vous voyez :
- `g++ (SUSE Linux) 7.5.0` → ✅ Vous pouvez installer METIS et NLOPT
- `command not found` → ⚠️ Demandez à l'admin d'installer `gcc-c++`

---

## Résumé

| Composant | gcc requis | g++ requis | 100% offline |
|-----------|------------|------------|--------------|
| **Tucanos** | ✅ Oui | ❌ Non | ✅ Oui |
| **METIS** | ✅ Oui | ⚠️ Oui | ✅ Oui |
| **NLOPT** | ✅ Oui | ⚠️ Oui | ✅ Oui |

**Conclusion** : Vous pouvez installer et utiliser Tucanos sans g++. 
METIS et NLOPT sont des bonus optionnels si vous avez g++.




