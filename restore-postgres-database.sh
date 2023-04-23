#!/bin/bash

set -e

# Environment variables: db, user, password, host, port

# Extract database backup
echo "Extracting database backup"
tar -xzf "$db.tar.gz"

# Drop database if it exists and create database
echo "Dropping database $db"
psql postgres://$user:$password@$host:$port/postgres -c "DROP DATABASE IF EXISTS \"$db\" WITH (FORCE);"
echo "Creating database $db with owner $user"
psql postgres://$user:$password@$host:$port/postgres -c "CREATE DATABASE \"$db\" WITH OWNER \"$user\";"

# Restore database
cd $db
echo "Restoring database $db"
zcat $db-* | psql postgres://$user:$password@$host:$port/$db
# cat $db-* | gunzip | psql postgres://$user:$password@$host:$port/$db
