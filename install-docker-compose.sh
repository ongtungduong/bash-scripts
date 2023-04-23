#!/bin/bash

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# Ensure docker-compose is executable
sudo chmod +x /usr/local/bin/docker-compose
# Check docker-compose version
docker-compose --version