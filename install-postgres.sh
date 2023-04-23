#!/bin/bash

# Set the script to stop on any errors
set -e

# Set the version of PostgreSQL to be installed
postgres_version=15     # Change me

# Update the Ubuntu system and installs any required updates
sudo apt -y update
sudo apt -y full-upgrade

# Install prerequisites for installing PostgreSQL
echo "Installing prerequisites for installing PostgreSQL"
prerequisites=(curl gpg gnupg2 software-properties-common apt-transport-https lsb-release ca-certificates)
for prerequisite in "${prerequisites[@]}"
do
    sudo apt install -y "$prerequisite"
done

# Add PostgreSQL repository to Ubuntu
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL and its client on Ubuntu
echo "Installing PostgreSQL and its client on Ubuntu"
sudo apt install -y "postgresql-$postgres_version" "postgresql-client-$postgres_version"

# Test the connection
sudo systemctl status postgresql@"$postgres_version"-main.service --no-pager
