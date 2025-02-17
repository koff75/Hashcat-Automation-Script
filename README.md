# Table des Matières  

- [Description](#description)  
- [Fonctionnalités](#fonctionnalités)  
- [Prérequis](#prérequis)  
- [Installation](#installation)  
- [Usage](#usage)  
  - [Exemple](#exemple)  
  - [Suivi en temps réel](#suivi-en-temps-réel)  
- [Organisation du code](#organisation-du-code)  
  - [Structure du script](#structure-du-script)  
  - [Fichiers générés](#fichiers-générés)  
- [Personnalisation](#personnalisation)  
  - [Ajouter de nouveaux dictionnaires](#ajouter-de-nouveaux-dictionnaires)  
  - [Ajouter de nouvelles règles](#ajouter-de-nouvelles-règles)  
  - [Modifier les masques](#modifier-les-masques)  
- [Résolution des problèmes](#résolution-des-problèmes)  
- [Stratégie à adopter](#stratégie-à-adopter)  
  - [Wordlist générale (rockyou)](#1-wordlist-générale-rockyou)  
  - [Chiffres simples (PIN ou clés par défaut)](#2-chiffres-simples-pin-ou-clés-par-défaut)  
  - [Wordlist française spécifique (Wi-Fi)](#3-wordlist-française-spécifique-wi-fi)  
  - [Optimisation matérielle](#4-optimisation-matérielle)  
  - [Attaques avancées avec règles (Pantagrule)](#5-attaques-avancées-avec-règles-pantagrule)  
  - [Tests exhaustifs (Brute force ciblée)](#6-tests-exhaustifs-brute-force-ciblée)  
  - [Résumé](#résumé)  
- [Wordlists intéressantes dans SecLists](#wordlists-intéressants-dans-seclists)  
  - [Wordlists générales](#wordlists-générales)  
  - [Wordlists spécifiques Wi-Fi](#wordlists-spécifiques-wi-fi)  
- [Différence entre Pantagrule et Best64](#différence-entre-pantagrule-et-best64)  
  - [Comparaison des utilisations](#comparaison-des-utilisations)  


# Hashcat Automation Script  

## Description  
Ce script bash automatise le processus de craquage de mots de passe avec **Hashcat**, en combinant différentes approches :  
1. **Dictionnaires bruts**  
2. **Dictionnaires avec des règles**  
3. **Attaques par masques personnalisés**  

Le script inclut des fonctionnalités avancées telles que la gestion des logs avec des niveaux de gravité, un suivi en temps réel, et un système de verrouillage pour éviter les conflits entre les processus.  

## Fonctionnalités  
- Automatisation des attaques Hashcat en trois étapes : dictionnaires, règles, et masques.  
- Vérification automatique si un mot de passe a été trouvé après chaque attaque.  
- Génération de logs détaillés avec horodatage et niveaux de gravité (INFO, WARNING, ERROR).  
- Gestion des conflits avec un système de verrouillage (`/tmp/hashcat.lock`).  
- Résumé final des résultats après toutes les tentatives.  
- Sauvegarde automatique des mots de passe trouvés dans un fichier dédié.  

## Prérequis  
Avant d'utiliser ce script, assurez-vous d'avoir :  
1. **Hashcat** installé sur votre machine.  
   - Vous pouvez installer Hashcat via votre gestionnaire de paquets ou en téléchargeant la version officielle depuis [hashcat.net](https://hashcat.net/hashcat/).  
2. Les droits d'exécution sur le script (`chmod +x script.sh`).  
3. Les fichiers de dictionnaires et de règles mentionnés dans le script.  
   - Par exemple : `rockyou.txt`, `darkweb2017.txt`, `best64.rule`.  
4. Un fichier de hash compatible avec l'algorithme 22000 (Wi-Fi WPA/WPA2).  

## Installation  
1. Clonez ce dépôt sur votre machine :  
   ```bash  
   git clone https://github.com/<votre-utilisateur>/<votre-projet>.git  
   cd <votre-projet>  
   ```  
2. Modifiez les chemins des fichiers de dictionnaires et des règles dans le script pour correspondre à votre environnement.  

## Usage  
Exécutez le script avec un fichier de hash en argument :  
```bash  
./script.sh <fichier_de_hash>  
```  

### Exemple  
```bash  
./script.sh hashes.hc22000  
```  

Le script :  
- Suivra trois étapes pour tenter de craquer les mots de passe.  
- Sauvegardera les mots de passe trouvés dans le fichier `cracked_password.txt`.  
- Enregistrera tous les événements dans un fichier de log (`trace_follow.log`).  

### Suivi en temps réel  
Pour suivre l'avancement en direct, utilisez la commande :  
```bash  
tail -f trace_follow.log  
```  

## Organisation du code  
### Structure du script  
| Étape                | Description                                                                                   |  
|----------------------|-----------------------------------------------------------------------------------------------|  
| **Vérifications**    | Vérifie la présence et la validité des fichiers nécessaires.                                  |  
| **Étape 1**          | Teste les dictionnaires bruts fournis.                                                        |  
| **Étape 2**          | Combine les dictionnaires avec des règles pour générer des variations de mots de passe.       |  
| **Étape 3**          | Utilise des masques pour effectuer des attaques par force brute ciblées.                      |  
| **Résumé final**     | Affiche un récapitulatif des résultats.                                                       |  

### Fichiers générés  
- `cracked_password.txt` : Contient les mots de passe trouvés.  
- `trace_follow.log` : Fichier de log détaillant chaque étape.  

## Personnalisation  
### Ajouter de nouveaux dictionnaires  
Ajoutez vos fichiers de dictionnaires dans la section suivante :  
```bash  
DICT_FILES=(  
    "/chemin/vers/votre_dictionnaire.txt"  
    "/autre/chemin/dictionnaire2.txt"  
)  
```  

### Ajouter de nouvelles règles  
Ajoutez vos fichiers de règles dans la section suivante :  
```bash  
RULES=(  
    "/chemin/vers/votre_regle.rule"  
)  
```  

### Modifier les masques  
Ajoutez ou modifiez les masques personnalisés dans la section suivante :  
```bash  
MASKS=(  
    "?d?d?d?d?d?d?d?d"  # Exemple : 12345678  
    "?u?l?d?l?l?d?u?u"  # Exemple complexe  
)  
```  

## Résolution des problèmes  
- **Hashcat affiche une erreur ou s'arrête :**  
  Vérifiez que votre matériel supporte les paramètres utilisés (GPU, CPU). Vous pouvez ajuster les options dans la commande Hashcat (`-D`, `-w`, etc.).  
- **Le fichier de verrouillage bloque l'exécution :**  
  Supprimez manuellement le fichier `/tmp/hashcat.lock` si nécessaire.

# Stratégie à adopter
### **1\. Wordlist générale (rockyou)**

Utilise d'abord un dictionnaire simple pour tester les mots de passe les plus probables.

```
hashcat -m 22000 -a 0 hash.22000 rockyou.txt --status --status-timer=60
```

*Exemple :* Teste `password123` et variantes communes.

---

### **2\. Chiffres simples (PIN ou clés par défaut)**

Teste les mots de passe composés uniquement de chiffres sur 8 caractères (standards de box).

```
hashcat -m 22000 -a 3 hash.22000 ?d?d?d?d?d?d?d?d --increment
```

*Exemple :* Teste `12345678`, `87654321`.

---

### **3\. Wordlist française spécifique (Wi-Fi)**

Prépare une wordlist combinant noms courants en France, box internet (Free, SFR, etc.), et chiffres.

```
hashcat -m 22000 -a 1 hash.22000 noms_box_fr.txt num_4_digits.txt
```

*Exemple :* Teste `Freebox2021`, `Livebox1234`.

Fichier `noms_box_fr.txt` (exemple) :

```
Freebox
Livebox
Bbox
Waya
```

---

### **4\. Optimisation matérielle**

Ajoute systématiquement les options d’optimisation pour gagner en performance.

```
hashcat -w 4 -O -m 22000 hash.22000 rockyou.txt
```

*Exemple :* Priorise la vitesse sur les GPU modernes en désactivant certaines limites.

**Astuce :** À appliquer pour toutes les commandes sauf en cas de crash ou limitation matérielle.

---

### **5\. Attaques avancées avec règles (Pantagrule)**

Utilise des règles puissantes pour des mutations complexes après les tests simples.

```
hashcat -m 22000 -a 0 hash.22000 wordlist_fr.txt -r /path/to/pantagrule/pantagrule.rule
```

*Exemple :* Transforme `password` en `P@ssw0rd123`.

---

### **6\. Tests exhaustifs (Brute force ciblée)**

Teste les structures spécifiques comme une clé générée automatiquement :

```
hashcat -m 22000 -a 3 hash.22000 ?u?l?l?d?d?d?d
```

*Exemple :* `Abc12345`.

---

### **Résumé**

6. **Toujours commencer simple** : wordlists générales, chiffres.  
7. **Progressivement augmenter la complexité** : hybrides et règles.  
8. **Optimisation matérielle essentielle à chaque étape** pour des performances maximales.

---

### **Wordlists intéressants dans SecLists**

Voici quelques wordlists spécifiques de [SecLists](https://github.com/danielmiessler/SecLists) qui peuvent être utiles pour WPA/WPA2 :

#### **Wordlists générales :**

1. **Passwords/common.txt**

   - Les mots de passe les plus courants, très efficace pour tester rapidement.  
   - *Exemple* : `123456`, `password`, `admin`.  
2. **Passwords/xato-net-10-million-passwords.txt**

   - 10 millions de mots de passe basés sur des fuites réelles.  
   - *Exemple* : `qwerty123`, `sunshine2022`.

#### **Wordlists spécifiques Wi-Fi :**

3. **Passwords/Wi-Fi/Common-WiFi-WPA2-Passphrases.txt**

   - Ciblé pour les SSID de box et mots de passe par défaut.  
   - *Exemple* : `freebox1234`, `livebox5678`.  
4. **Passwords/darkweb2017-top10000.txt**

   - Basé sur les leaks des bases de données du dark web.  
   - *Exemple* : `hunter2`, `iloveyou`.  
5. **Usernames/top-usernames-shortlist.txt \+ Numéros**

   - Combinez cette liste avec des chiffres (hybride `-a1`).  
   - *Exemple* : `admin1234`, `user2023`.

---

### **Différence entre Pantagrule et Best64**

#### **Pantagrule :**

- Une des règles les plus complexes pour *hashcat*, issue de transformations des attaques les plus efficaces.  
- Utilise des mutations avancées comme :  
  - Substitutions (`a` → `@`, `o` → `0`).  
  - Ajouts (`123`, `!`).  
  - Combinaisons dynamiques.  
- **Objectif** : Tester un grand nombre de permutations en peu de temps.  
- *Exemple transformation* :  
  - Entrée : `password`  
  - Sortie : `P@ssw0rd!123`

#### **Best64 :**

- Une règle plus légère et rapide, orientée vers les transformations les plus communes.  
- Adaptée pour des ressources limitées ou un premier passage rapide.  
- **Objectif** : Moins de transformations mais haut taux de réussite sur des mots de passe simples.  
- *Exemple transformation* :  
  - Entrée : `admin`  
  - Sortie : `admin123`

---

### **Comparaison des utilisations**

| Critère | Pantagrule | Best64 |
| :---- | :---- | :---- |
| **Complexité** | Élevée | Faible |
| **Nombre de règles** | \~1 million | \~64 |
| **Performance** | Nécessite un GPU performant | Rapide sur tout système |
| **Cas d’usage** | Longues attaques avancées | Tests rapides |

---

**Recommandation** :

- **Pantagrule** : Utiliser après avoir testé avec des règles simples comme Best64 ou dans une attaque finale.  
- **Best64** : Toujours commencer par celle-ci pour identifier rapidement les mots de passe faibles.
