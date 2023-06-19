# !/bin/bash

DEFAULT_VERSION=1.5.0
DEFAULT_PORT=17017

read -p "Select node_exporter version [$DEFAULT_VERSION]: " EXPORTER_VERSION
EXPORTER_VERSION=${EXPORTER_VERSION:-$DEFAULT_VERSION}
read -p "Set node_exporter port [$DEFAULT_PORT]: " EXPORTER_PORT
EXPORTER_PORT=${EXPORTER_PORT:-$DEFAULT_PORT}

# Download node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v$EXPORTER_VERSION/node_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz
tar xzf node_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin
rm -rf node_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz node_exporter-$EXPORTER_VERSION.linux-amd64

USER=node_exporter
GROUP=node_exporter

# Create node_exporter systemd service
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=node_exporter
After=network.target

[Service]
User=$USER
Group=$GROUP
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:$EXPORTER_PORT

[Install]
WantedBy=multi-user.target
EOF
echo "node_exporter.service created"

# Create node_exporter user and group
sudo useradd --no-create-home --shell /bin/false $USER
sudo groupadd $GROUP

# Reload systemd daemon and start node_exporter
sudo systemctl daemon-reload
sudo systemctl enable node_exporter --now
sudo systemctl status node_exporter --no-pager
