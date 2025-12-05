# Installation de g++ (gcc-c++) en mode offline

## ⚠️ IMPORTANT : Lisez ceci d'abord !

### Solution RECOMMANDÉE : Demander à l'admin

La manière la plus simple et rapide d'installer g++ :

```bash
sudo zypper install gcc-c++
```

**C'est tout !** Installation en 30 secondes.

---

## 🔧 Installation depuis les sources (si vraiment nécessaire)

### Prérequis
- gcc déjà installé
- make installé
- **1-2 heures de temps** ⏰
- **~3-5 Go d'espace disque libre** 💾
- Patience ! ☕

### Étapes

1. **Sur Windows (avec Internet) : Télécharger les sources**
   ```powershell
   pwsh -File download_gcc_sources.ps1
   ```
   
   Télécharge :
   - GCC 7.5.0 (~110 MB)
   - GMP, MPFR, MPC, ISL (dépendances)

2. **Copier dans le package**
   ```powershell
   Copy-Item gcc-sources-offline tucanos-complete-offline-final\ -Recurse -Force
   Copy-Item install_gcc_cpp_offline_from_sources.sh tucanos-complete-offline-final\
   ```

3. **Sur SUSE 15 SP4 (hors ligne)**
   ```bash
   cd tucanos-complete-offline-final
   bash install_gcc_cpp_offline_from_sources.sh
   ```

   Le script va :
   - Extraire les sources GCC
   - Configurer GCC pour C et C++
   - Compiler pendant 1-2 heures
   - Installer dans `~/.local/`

---

## 📊 Comparaison des méthodes

| Méthode | Temps | Espace disque | Complexité |
|---------|-------|---------------|------------|
| **sudo zypper** | 30 sec | ~50 MB | ✅ Facile |
| **Compilation sources** | 1-2h | ~3-5 Go | ⚠️ Complexe |

---

## 💡 Recommandation Finale

### Si vous AVEZ accès sudo (même temporaire)
```bash
sudo zypper install gcc-c++
```
**C'est la meilleure option !**

### Si vous N'AVEZ PAS g++
**Option 1** : Utilisez Tucanos sans METIS/NLOPT (ils sont optionnels)

**Option 2** : Compilez g++ depuis les sources (très long)

**Option 3** : Demandez à l'admin de faire `sudo zypper install gcc-c++`

---

## ❓ FAQ

**Q : Tucanos fonctionne sans g++ ?**
R : ✅ OUI ! Seuls METIS et NLOPT nécessitent g++ (optionnels)

**Q : METIS et NLOPT sont importants ?**
R : Ils ajoutent des fonctionnalités (partitionnement, optimisation) mais ne sont pas obligatoires.

**Q : Combien de temps la compilation de GCC prend-elle ?**
R : 1-2 heures sur une machine standard, parfois plus si CPU lent.

**Q : Puis-je arrêter la compilation ?**
R : Oui, mais il faudra tout recommencer.

---

## 🎯 Résumé

1. **Meilleure solution** : `sudo zypper install gcc-c++`
2. **Pas de sudo** : Utilisez Tucanos sans METIS/NLOPT
3. **Vraiment besoin** : Compilez depuis les sources (1-2h)



