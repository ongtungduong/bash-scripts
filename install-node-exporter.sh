# !/bin/bash

# Set variables
EXPORTER_VERSION=1.5.0
EXPORTER_PORT=17017 # Change me
USER=node_exporter
GROUP=node_exporter
PASSWORD=QmaQ4K6Tv9 # Change me

# Download node_exporter
echo "Downloading node_exporter v$EXPORTER_VERSION"
cd usr/local/bin
sudo wget https://github.com/prometheus/node_exporter/releases/download/v$EXPORTER_VERSION/node_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz
sudo tar xvfz node_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin
sudo rm -rf node_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz node_exporter-$EXPORTER_VERSION.linux-amd64

# Create node_exporter systemd service
echo "Creating node_exporter systemd service"
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

# Create node_exporter user and group
echo "Creating node_exporter user and group"
sudo useradd --no-create-home --shell /bin/false $USER
sudo groupadd $GROUP
echo "$USER:$PASSWORD" | chpasswd

# Reload systemd daemon and start node_exporter
echo "Reloading systemd daemon and starting node_exporter"
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter --no-pager