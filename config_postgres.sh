#!/bin/bash

# Run script with sudo

# Define the path to the postgresql.conf file
PGTUNE_CONF="./pgtune.conf" # Change me
POSTGRES_VERSION=15 # Change me
POSTGRES_CONF="/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf"

# Find params in postgresql.conf and replace with new values
function config_postgres() {
    param="$1"
    value="$2"
    sed -i "s/^#*\s*\($param\s*=\s*\).*/\1$value/" $POSTGRES_CONF
    echo "Changed $param to $value"
}

while read line; do 
    param=$(echo "$line" | cut -d= -f1 | tr -d ' ')
    value=$(echo "$line" | cut -d= -f2 | tr -d ' ')
    config_postgres "$param" "$value"
done < $PGTUNE_CONF

# Restart PostgreSQL server after making changes to postgresql.conf
# systemctl start postgresql