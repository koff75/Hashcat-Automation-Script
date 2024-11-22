#!/bin/bash

# Variables de configuration
HASH_FILE=$1
OUTPUT_FILE="cracked_password.txt"
LOG_FILE="trace_follow.log"
POT_FILE="hashcat.potfile"
LOCK_FILE="/tmp/hashcat.lock"

# À modifier selon vos fichiers
DICT_FILES=(
    "/root/CRACKING-PASSWORD/SecLists-master/Passwords/WiFi-WPA/probable-v2-wpa-top4800.txt"
    "/root/CRACKING-PASSWORD/SecLists-master/Passwords/darkweb2017-top10000.txt"
    "/mnt/files/rockyou_25Go.txt"
)

RULES=(
    "/root/best64.rule"
    "/root/pantagrule/rules/hashesorg.v6/pantagrule.hashorg.v6.one.rule"
)
MASKS=(
    "?d?d?d?d?d?d?d?d"       # Ex. 12345678
    "?d?d?d?d?d?d?d?d?d?d"   # Ex. 1234567890
    "?u?u?u?u?u?u?u?u"       # Ex. 8 lettres majuscules
    "?u?u?u?u?d?d?d?d"       # Mélange commun dans certains Wi-Fi
    "?l?l?l?l?l?d?d?d"       # abcde123
)

# Fonction de log avec niveaux de gravité et couleurs
log_message() {
    local level="$1"
    local message="$2"
    local color

    case "$level" in
        "INFO") color="\033[1;32m" ;;    # Vert
        "WARNING") color="\033[1;33m" ;; # Jaune
        "ERROR") color="\033[1;31m" ;;   # Rouge
        *) color="\033[0m" ;;            # Défaut
    esac

    echo -e "${color}$(date '+%Y-%m-%d %H:%M:%S') [$level] : $message\033[0m" | tee -a "$LOG_FILE"
}

# Fonction de résumé final
log_summary() {
    log_message "INFO" "Résumé de l'exécution :"
    grep "Mot de passe trouvé" "$LOG_FILE" || log_message "INFO" "Aucun mot de passe trouvé."
}

# Vérification et attente du fichier de verrou
wait_for_lock() {
    while [ -f "$LOCK_FILE" ]; do
        log_message "WARNING" "Un processus Hashcat est en cours. Attente de 5 secondes..."
        sleep 5
    done
}

# Fonction pour tester un hash
run_hashcat() {
    local options="$1"
    wait_for_lock

    touch "$LOCK_FILE"
    log_message "INFO" "Lancement : hashcat $options"
    if ! hashcat -D 1,2 -w 4 -m 22000 "$HASH_FILE" $options --potfile-path "$POT_FILE" >> "$LOG_FILE" 2>&1; then
        log_message "ERROR" "Échec de hashcat avec les options : $options"
        rm -f "$LOCK_FILE"
        return 1
    fi
    rm -f "$LOCK_FILE"
    return 0
}

# Fonction pour vérifier si un mot de passe a été trouvé
check_cracked() {
    hashcat -m 22000 "$HASH_FILE" --show --potfile-path "$POT_FILE" | grep -q .
    return $?
}

# Vérification du fichier de hash
if [ ! -f "$HASH_FILE" ]; then
    log_message "ERROR" "Le fichier $HASH_FILE n'existe pas."
    exit 1
elif [ ! -s "$HASH_FILE" ]; then
    log_message "ERROR" "Le fichier $HASH_FILE est vide."
    exit 1
fi

log_message "INFO" "Début de l'attaque Hashcat."

#############################################
# Étape 1 : Test avec des dictionnaires bruts
#############################################
log_message "INFO" "Étape 1 : Dictionnaires bruts"
for dict in "${DICT_FILES[@]}"; do
    if [ ! -f "$dict" ]; then
        log_message "ERROR" "Le fichier de dictionnaire $dict n'existe pas."
        continue
    fi
    run_hashcat "-a 0 $dict"
    if check_cracked; then
        log_message "INFO" "Mot de passe trouvé avec $dict !"
        hashcat -m 22000 "$HASH_FILE" --show --potfile-path "$POT_FILE" > "$OUTPUT_FILE"
        log_message "INFO" "Mot de passe sauvegardé dans $OUTPUT_FILE."
        log_summary
        exit 0
    fi
done

#############################################
# Étape 2 : Test avec des règles
#############################################
# Ajout de chiffres à la fin (password123)
# Substitutions (e → 3, o → 0)
# Mise en majuscule de la première lettre (password → Password)
log_message "INFO" "Étape 2 : Dictionnaires + Règles"
for dict in "${DICT_FILES[@]}"; do
    for rule in "${RULES[@]}"; do
        if [ ! -f "$rule" ]; then
            log_message "ERROR" "Le fichier de règle $rule n'existe pas."
            continue
        fi
        run_hashcat "-a 0 $dict -r $rule"
        if check_cracked; then
            log_message "INFO" "Mot de passe trouvé avec $dict et $rule !"
            hashcat -m 22000 "$HASH_FILE" --show --potfile-path "$POT_FILE" > "$OUTPUT_FILE"
            log_message "INFO" "Mot de passe sauvegardé dans $OUTPUT_FILE."
            log_summary
            exit 0
        fi
    done
done

#############################################
# Étape 3 : Attaques par masque
#############################################
log_message "INFO" "Étape 3 : Brute force avec masques"
for mask in "${MASKS[@]}"; do
    run_hashcat "-a 3 $mask"
    if check_cracked; then
        log_message "INFO" "Mot de passe trouvé avec le masque $mask !"
        hashcat -m 22000 "$HASH_FILE" --show --potfile-path "$POT_FILE" > "$OUTPUT_FILE"
        log_message "INFO" "Mot de passe sauvegardé dans $OUTPUT_FILE."
        log_summary
        exit 0
    fi
done

log_message "INFO" "Aucun mot de passe trouvé après toutes les tentatives."
log_summary
exit 1
