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



Ce README est structuré pour être clair et professionnel tout en détaillant les aspects importants de ton projet. Ajoute ton **pseudo GitHub** ou ton **nom** pour personnaliser davantage !
