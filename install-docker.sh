#!/bin/bash

# Install docker
apt update -y && apt upgrade -y
curl -o- https://get.docker.com | sh

# Run docker as non-root user
user="" # Change me
sudo groupadd docker
sudo usermod -aG docker $user
newgrp docker

# Enable docker.service and containerd.service
sudo systemctl enable docker.service
sudo systemctl enable containerd.service