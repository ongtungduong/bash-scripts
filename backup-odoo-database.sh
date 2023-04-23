#!/bin/bash

# Set the script to stop on any errors
set -e

# Environment variables: ODOO_HOST, PASSWORD, DATABASE, OUTPUT

FILE="$DATABASE.zip"
FILEPATH="${OUTPUT}/${FILE}"

# Install curl and unzip
sudo apt install -y curl unzip

# Request database backup and save to filepath
echo "Requesting backup of $DATABASE to $FILEPATH"
curl -X POST \
  -F "master_pwd=$PASSWORD" \
  -F "name=$DATABASE" \
  -F "backup_format=zip" \
  -o "$FILEPATH" \
  "$ODOO_HOST/web/database/backup"

# Check for errors
FILETYPE="$(file --mime-type -b "$FILEPATH")"
if [[ "$FILETYPE" != 'application/zip' ]]; then
  grep error "$FILEPATH"
fi

# Announce backup completed
echo "Backup completed: $FILEPATH"
