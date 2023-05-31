#!/bin/bash

set -e

# Environment variables: DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, FILE_PATH

echo "Backing up database $DB_NAME ..."

# Create directory for database backup
mkdir -p $FILE_PATH/$DB_NAME
cd $FILE_PATH/$DB_NAME

# Backup database using pg_dump, split into multiple files and compress using gzip
pg_dump postgres://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME | split -b 2G --filter="gzip > \"$DB_NAME-\$FILE\".gz"

# Compress the backup directory
cd ..
DATE=$(date +%Y%m%d)
BACKUP_FILE="$DATE-$DB_NAME.tar.gz"
tar -czf "$BACKUP_FILE" "$DB_NAME"

echo "Backup file is ready: $FILE_PATH/$BACKUP_FILE"
