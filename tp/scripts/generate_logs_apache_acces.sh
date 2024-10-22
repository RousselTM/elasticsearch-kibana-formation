#!/bin/bash

# Fichier de sortie
OUTPUT_FILE="../logs/apache-access-tp.json"

# Liste des REQUEST_URI possibles
REQUEST_URIS=(
    "/home"
    "/about"
    "/contact"
    "/products"
    "/services"
    "/login"
    "/register"
    "/api/v1/resource"
    "/api/v1/resource/1"
    "/api/v1/resource/2"
    "/search"
    "/faq"
)

# Liste des REMOTE_ADDR possibles (adresses IP)
REMOTE_ADDRS=(
    "192.168.1.1"
    "192.168.1.2"
    "192.168.1.3"
    "192.168.1.4"
    "192.168.1.5"
    "192.168.1.10"
    "10.0.0.1"
    "10.0.0.2"
    "172.16.0.1"
    "172.16.0.2"
)

# Écrire l'en-tête JSON
echo "[" > $OUTPUT_FILE

# Générer 1000 lignes de logs
for i in $(seq 1 1000); do
    # Générer des données aléatoires
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" -d "$((RANDOM % 30)) days ago")
    REMOTE_ADDR=${REMOTE_ADDRS[$((RANDOM % ${#REMOTE_ADDRS[@]}))]}  # Sélectionner une IP aléatoire
    REQUEST_METHOD=$(shuf -n 1 -e GET POST PUT DELETE)
    REQUEST_URI=${REQUEST_URIS[$((RANDOM % ${#REQUEST_URIS[@]}))]}  # Sélectionner une URI aléatoire
    STATUS=$((200 + RANDOM % 5)) # Simuler des codes de statut 200 à 204
    BYTES=$((RANDOM % 10000 + 100)) # Taille aléatoire entre 100 et 10000 bytes

    # Écrire la ligne de log au format ECS
    if [ $i -lt 1000 ]; then
        echo "  {\"@timestamp\":\"$TIMESTAMP\", \"user\":{\"id\":\"$REMOTE_ADDR\"}, \"http\":{\"request\":{\"method\":\"$REQUEST_METHOD\", \"original\":\"$REQUEST_URI\"}, \"response\":{\"status_code\":$STATUS, \"body_bytes_sent\":$BYTES}}}," >> $OUTPUT_FILE
    else
        echo "  {\"@timestamp\":\"$TIMESTAMP\", \"user\":{\"id\":\"$REMOTE_ADDR\"}, \"http\":{\"request\":{\"method\":\"$REQUEST_METHOD\", \"original\":\"$REQUEST_URI\"}, \"response\":{\"status_code\":$STATUS, \"body_bytes_sent\":$BYTES}}}" >> $OUTPUT_FILE
    fi
done

# Écrire la fermeture du tableau JSON
echo "]" >> $OUTPUT_FILE

echo "Fichier de logs généré : $OUTPUT_FILE"