#!/bin/bash

# Add PGAdmin GPG key and repository
curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add -
echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list

# Install PGAdmin
sudo apt-get update
sudo apt-get install -y pgadmin4
sudo /usr/pgadmin4/bin/setup-web.sh
