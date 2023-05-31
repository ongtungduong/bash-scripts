#!/bin/bash

PGTUNE_PATH="" # Change me
POSTGRES_VERSION=15 # Change me
PGCONF_PATH="/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf"

function config_postgres() {
    param="$1"
    value="$2"
    sed -i "s/^#*\s*\($param\s*=\s*\).*/\1$value/" $PGCONF_PATH
    echo "Changed $param to $value"
}

while read line; do 
    param=$(echo "$line" | cut -d= -f1 | tr -d ' ')
    value=$(echo "$line" | cut -d= -f2 | tr -d ' ')
    config_postgres "$param" "$value"
done < $PGTUNE_PATH

systemctl restart postgresql
