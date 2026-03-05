#!/bin/bash

# ==============================
# Configuration
# ==============================

# Directory to back up
SOURCE_DIR="/path/to/source_directory"

# Directory where backups will be stored
DEST_BASE="/path/to/backup_directory"

# Log file location
LOG_FILE="$HOME/backup.log"

# ==============================
# Backup Creation
# ==============================

DATE=$(date +"%d%b%Y")
DEST_DIR="$DEST_BASE/${DATE} Backup"

# Ensure backup directory exists
mkdir -p "$DEST_BASE"

# Create backup only if today's backup does not already exist
if [ ! -d "$DEST_DIR" ]; then

    # Find existing backups
    mapfile -t EXISTING < <(
        find "$DEST_BASE" -maxdepth 1 -mindepth 1 -type d -name "* Backup"
    )

    if [ ${#EXISTING[@]} -gt 0 ]; then

        # Determine newest backup by parsing date from folder name
        NEWEST=""
        NEWEST_EPOCH=0

        for FOLDER in "${EXISTING[@]}"; do
            NAME=$(basename "$FOLDER")
            DATE_PART="${NAME% Backup}"

            EPOCH=$(date -d "$DATE_PART" +%s 2>/dev/null)

            if [ "$EPOCH" -gt "$NEWEST_EPOCH" ]; then
                NEWEST_EPOCH=$EPOCH
                NEWEST="$FOLDER"
            fi
        done

        echo "$(date): Creating incremental backup using $NEWEST" >> "$LOG_FILE"

        rsync -a \
            --link-dest="$NEWEST" \
            "$SOURCE_DIR/" "$DEST_DIR/" >> "$LOG_FILE" 2>&1

    else

        echo "$(date): No previous backup found. Creating full backup." >> "$LOG_FILE"

        rsync -a \
            "$SOURCE_DIR/" "$DEST_DIR/" >> "$LOG_FILE" 2>&1

    fi

    echo "$(date): Backup completed to $DEST_DIR" >> "$LOG_FILE"

else
    echo "$(date): Backup already exists. Skipping creation." >> "$LOG_FILE"
fi


# ==============================
# Retention Policy
# Keep only 7 newest backups
# ==============================

mapfile -t BACKUPS < <(
    find "$DEST_BASE" -maxdepth 1 -mindepth 1 -type d -name "* Backup"
)

if [ ${#BACKUPS[@]} -gt 7 ]; then

    echo "$(date): More than 7 backups found. Cleaning up..." >> "$LOG_FILE"

    TEMP_LIST=()

    for FOLDER in "${BACKUPS[@]}"; do
        NAME=$(basename "$FOLDER")
        DATE_PART="${NAME% Backup}"
        EPOCH=$(date -d "$DATE_PART" +%s 2>/dev/null)

        TEMP_LIST+=("$EPOCH|$FOLDER")
    done

    # Sort backups by date (oldest first)
    IFS=$'\n' SORTED=($(sort <<<"${TEMP_LIST[*]}"))
    unset IFS

    REMOVE_COUNT=$((${#SORTED[@]} - 7))

    for (( i=0; i<REMOVE_COUNT; i++ )); do
        OLD_FOLDER="${SORTED[$i]#*|}"
        echo "$(date): Deleting old backup $OLD_FOLDER" >> "$LOG_FILE"
        rm -rf "$OLD_FOLDER"
    done

fi
