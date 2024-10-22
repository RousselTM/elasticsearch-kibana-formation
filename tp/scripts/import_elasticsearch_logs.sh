#!/bin/bash

# Variables de configuration
LOG_DIR="./../logs"  # Dossier contenant vos fichiers de logs ECS au format .json ou .log
ELASTICSEARCH_URL="http://localhost:9200"  # URL de votre instance Elasticsearch

# Vérifier l'existence du dossier de logs
if [ ! -d "$LOG_DIR" ]; then
    echo "Dossier de logs non trouvé : $LOG_DIR"
    exit 1
fi

# Préparation du fichier de chargement en masse (_bulk)
BULK_FILE="bulk_data.json"

# Parcourir chaque fichier se terminant par .log ou .json dans le dossier de logs
for LOG_FILE in "$LOG_DIR"/*.{log,json}; do
    if [ -f "$LOG_FILE" ]; then  # Vérifier que c'est bien un fichier
        # Extraire le nom de fichier sans extension pour utiliser comme nom d'index
        FILE_NAME=$(basename "$LOG_FILE")
        INDEX_NAME="${FILE_NAME%.*}"  # Enlever l'extension pour le nom de l'index

        echo "Traitement du fichier : $LOG_FILE, import dans l'index : $INDEX_NAME"

        # Créer ou réinitialiser l'index Elasticsearch
        curl -X DELETE "$ELASTICSEARCH_URL/$INDEX_NAME" > /dev/null 2>&1
        curl -X PUT "$ELASTICSEARCH_URL/$INDEX_NAME" > /dev/null 2>&1

        # Vider ou créer le fichier temporaire pour le bulk
        > $BULK_FILE

        # Lecture du fichier ECS et préparation du fichier _bulk
        while read -r line; do
            # Créer l'action d'indexation pour chaque document ECS
            echo "{ \"index\": { \"_index\": \"$INDEX_NAME\" } }" >> $BULK_FILE
            echo "$line" >> $BULK_FILE
        done < "$LOG_FILE"

        # Importer les logs dans Elasticsearch avec l'API _bulk
        curl -X POST "$ELASTICSEARCH_URL/_bulk" -H "Content-Type: application/json" --data-binary "@$BULK_FILE"

        echo "Importation terminée pour : $LOG_FILE"
    fi
done

# Supprimer le fichier temporaire
rm $BULK_FILE

echo "Importation terminée pour tous les fichiers dans : $LOG_DIR"