#!/bin/bash

# psql -c "ALTER SYSTEM RESET ALL;" to reset all configuration entries from postgresql.auto.conf
# systemctl restart postgresql after changing postgresql.conf

PGTUNE_CONF="./pgtune.conf" # Copy configuration from https://pgtune.leopard.in.ua/
POSTGRES_VERSION=$(head -n 1 "$PGTUNE_CONF" | cut -d : -f 2 | tr -d ' ')
POSTGRES_CONF="/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf"

# Find params in postgresql.conf and replace with new values
function config_postgres() {
    param="$1"
    value="$2"
    sed -i "s/^#*\s*\($param\s*=\s*\).*/\1$value/" $POSTGRES_CONF
    echo "Changed $param to $value"
}

while IFS= read -r line || [[ -n $line ]]; do
    [[ -z $line || $line == \#* ]] && continue
    param=$(echo "$line" | cut -d = -f 1 | tr -d ' ')
    value=$(echo "$line" | cut -d = -f 2 | tr -d ' ')
    config_postgres "$param" "$value"
done < $PGTUNE_CONF
