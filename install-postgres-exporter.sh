#!/bin/bash

# Run this script with sudo

# CHANGE THESE ENVIRONMENT VARIABLES
POSTGRES_VERSION=15 # Change me
EXPORTER_VERSION=0.12.0 # Change me
EXPORTER_PORT=17018 # Change me
PASSWORD=QmaQ4K6Tv9 # Change me

# Download postgres_exporter
curl -LJO "https://github.com/prometheus-community/postgres_exporter/releases/download/v$EXPORTER_VERSION/postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz"
tar xvfz postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz
mv postgres_exporter-$EXPORTER_VERSION.linux-amd64/postgres_exporter /usr/local/bin
rm -rf postgres_exporter-$EXPORTER_VERSION.linux-amd64 postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz
echo "Postgres Exporter Version $EXPORTER_VERSION downloaded"

USER=postgres_exporter
GROUP=postgres_exporter

# Create postgres_exporter directory
POSTGRES_EXPORTER_FOLDER=/etc/postgres-exporter
mkdir -p $POSTGRES_EXPORTER_FOLDER
echo "Postgres Exporter Directory: $POSTGRES_EXPORTER_FOLDER"

# Create postgres_exporter.env
cat > $POSTGRES_EXPORTER_FOLDER/postgres_exporter.env << EOF
DATA_SOURCE_NAME="postgresql://$USER:$PASSWORD@localhost:5432/postgres?sslmode=disable"
PG_EXPORTER_AUTO_DISCOVER_DATABASES=true
PG_EXPORTER_EXTEND_QUERY_PATH=$POSTGRES_EXPORTER_FOLDER/queries.yaml
EOF
echo "postgres_exporter.env created"

# Create queries.yaml
curl -LJO "https://raw.githubusercontent.com/prometheus-community/postgres_exporter/master/queries.yaml"
mv queries.yaml $POSTGRES_EXPORTER_FOLDER
echo "queries.yaml created"

# Create postgres_exporter.sql
curl -LJO "https://gist.githubusercontent.com/ongtungduong/a290705ecde7ede35c30b26dcc14cd8e/raw/postgres_exporter.sql"
mv postgres_exporter.sql $POSTGRES_EXPORTER_FOLDER
echo "postgres_exporter.sql created"

# Create postgres_exporter systemd service
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
echo "postgres_exporter.service created"

# Create user, group and set password for postgres_exporter
useradd --no-create-home --shell /bin/false $USER
groupadd $GROUP
echo "$USER:$PASSWORD" | chpasswd

# Configure and restart PostgreSQL
sed -i "s/^#*\s*\(shared_preload_libraries\s*=\s*\).*/\1'pg_stat_statements'/" /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf
sed -i "s/^#*\s*\(pg_stat_statements.track\s*=\s*\).*/\1all/" /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf
systemctl restart postgresql
echo "PostgreSQL configured and restarted"

sudo -i -u postgres psql -c "CREATE USER $USER WITH PASSWORD '$PASSWORD';"
sudo -i -u postgres psql $POSTGRES_EXPORTER_FOLDER/postgres_exporter.sql
echo "postgres_exporter configured"

# Reload systemd daemon and start postgres_exporter
systemctl daemon-reload
systemctl start postgres_exporter
systemctl enable postgres_exporter
systemctl status postgres_exporter --no-pager
