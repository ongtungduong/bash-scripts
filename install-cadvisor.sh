#!/bin/bash

# Add key and repository
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install cadvisor
sudo apt-get update
sudo apt-get install -y cadvisor

# Reload systemd daemon and start cadvisor
sudo systemctl daemon-reload
sudo systemctl start cadvisor
sudo systemctl enable cadvisor
sudo systemctl status cadvisor --no-pager
