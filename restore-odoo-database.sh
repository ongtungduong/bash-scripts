#!/bin/bash

# Set the script to stop on any errors
set -e

# Environment variables: ODOO_HOST, PASSWORD, DATABASE, FILE_PATH

REPLACE='true'

# Install curl and unzip
sudo apt install -y curl unzip

# Replace existing database if REPLACE='true'
if $REPLACE; then
  echo "Drop database $DATABASE"
  curl \
    --silent \
    -F "master_pwd=${PASSWORD}" \
    -F "name=${DATABASE}" \
    ${ODOO_HOST%/}/web/database/drop | grep -q -E 'Internal Server Error|Redirecting...'
fi

# Request database restore
echo "Restore database $DATABASE"
CURL=$(curl \
  -F "master_pwd=$PASSWORD" \
  -F "name=$DATABASE" \
  -F backup_file=@$FILE_PATH \
  -F 'copy=true' \
  "${ODOO_HOST%/}/web/database/restore")

# Check for errors
(echo $CURL | grep -q 'Redirecting...') || (echo "Restore database failed:"; echo $CURL | grep error; exit 1)

# Announce restore completed
echo "Restore database $DATABASE completed"