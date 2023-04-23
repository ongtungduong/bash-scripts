#!/bin/bash

# Run this script with sudo

# Set variables
POSTGRES_VERSION=15 # Change me
EXPORTER_VERSION=0.12.0
EXPORTER_PORT=17018 # Change me
USER=postgres_exporter
GROUP=postgres_exporter
PASSWORD=QmaQ4K6Tv9 # Change me
POSTGRES_EXPORTER_FOLDER=/etc/postgres-exporter

mkdir -p $POSTGRES_EXPORTER_FOLDER

# Download postgres_exporter
echo "Downloading postgres_exporter v$EXPORTER_VERSION"
curl -LJO "https://github.com/prometheus-community/postgres_exporter/releases/download/v$EXPORTER_VERSION/postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz"
tar xvfz postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz
mv postgres_exporter-$EXPORTER_VERSION.linux-amd64/postgres_exporter /usr/local/bin
rm -rf postgres_exporter-$EXPORTER_VERSION.linux-amd64 postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz

# Create postgres_exporter systemd service
echo "Creating postgres_exporter systemd service"
cat > /etc/systemd/system/postgres_exporter.service << EOF
[Unit]
Description=postgres_exporter
Wants=network.target
After=network.target

[Service]
Type=simple
User=$USER
Group=$GROUP

EnvironmentFile=$POSTGRES_EXPORTER_FOLDER/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter --web.listen-address=:$EXPORTER_PORT

[Install]
WantedBy=multi-user.target
EOF

# Create postgres_exporter environment file
echo "Creating postgres_exporter environment file"
cat > $POSTGRES_EXPORTER_FOLDER/postgres_exporter.env << EOF
DATA_SOURCE_NAME="postgresql://$USER:$PASSWORD@localhost:5432/postgres?sslmode=disable"
PG_EXPORTER_AUTO_DISCOVER_DATABASES=true
PG_EXPORTER_EXTEND_QUERY_PATH=$POSTGRES_EXPORTER_FOLDER/queries.yaml
EOF


# Create postgres_exporter yaml queries file
echo "Creating postgres exporter queries file"
curl -LJO "https://raw.githubusercontent.com/prometheus-community/postgres_exporter/master/queries.yaml"
mv queries.yaml $POSTGRES_EXPORTER_FOLDER

# Create user, group and set password for postgres_exporter
echo "Creating user, group and set password for postgres_exporter"
useradd --no-create-home --shell /bin/false $USER
groupadd $GROUP
echo "$USER:$PASSWORD" | chpasswd

# Configure PostgreSQL for postgres_exporter
echo "Configuring PostgreSQL for postgres_exporter"
echo "shared_preload_libraries = 'pg_stat_statements'" >> /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf
echo "pg_stat_statements.track = all" >> /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf

echo "Restarting PostgreSQL"
systemctl restart postgresql

echo "Creating pg_stat_statements extension"
sudo -i -u postgres psql -c "CREATE EXTENSION pg_stat_statements;"
sudo -i -u postgres psql -c "CREATE USER $USER WITH PASSWORD '$PASSWORD';"
sudo -i -u postgres psql -c "GRANT pg_read_all_stats TO $USER;"

# Reload systemd daemon and start postgres_exporter
echo "Reloading systemd daemon and starting postgres_exporter"
systemctl daemon-reload
systemctl start postgres_exporter
systemctl enable postgres_exporter
systemctl status postgres_exporter --no-pager
