#!/bin/bash

DEFAULT_VERSION=0.12.0
DEFAULT_PORT=17018

read -p "Select postgres_exporter version [$DEFAULT_VERSION]: " EXPORTER_VERSION
EXPORTER_VERSION=${EXPORTER_VERSION:-$DEFAULT_VERSION}
read -p "Set postgres_exporter port [$DEFAULT_PORT]: " EXPORTER_PORT
EXPORTER_PORT=${EXPORTER_PORT:-$DEFAULT_PORT}
read -s -p "Set postgres_exporter password: " PASSWORD
echo

# Download postgres_exporter
curl -LJO "https://github.com/prometheus-community/postgres_exporter/releases/download/v$EXPORTER_VERSION/postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz"
tar xzf postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz
mv postgres_exporter-$EXPORTER_VERSION.linux-amd64/postgres_exporter /usr/local/bin
rm -rf postgres_exporter-$EXPORTER_VERSION.linux-amd64 postgres_exporter-$EXPORTER_VERSION.linux-amd64.tar.gz

USER=postgres_exporter
GROUP=postgres_exporter

# Create postgres_exporter directory
POSTGRES_EXPORTER_FOLDER=/etc/postgres-exporter
mkdir -p $POSTGRES_EXPORTER_FOLDER

# Create postgres_exporter.env
cat > $POSTGRES_EXPORTER_FOLDER/postgres_exporter.env << EOF
DATA_SOURCE_NAME="postgresql://$USER:$PASSWORD@localhost:5432/postgres?sslmode=disable"
PG_EXPORTER_AUTO_DISCOVER_DATABASES=true
PG_EXPORTER_EXTEND_QUERY_PATH=$POSTGRES_EXPORTER_FOLDER/queries.yaml
EOF

# Create queries.yaml
curl -LJO "https://raw.githubusercontent.com/prometheus-community/postgres_exporter/master/queries.yaml"
mv queries.yaml $POSTGRES_EXPORTER_FOLDER

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

# Create user, group and set password for postgres_exporter
useradd --no-create-home --shell /bin/false $USER
groupadd $GROUP

# Configure and restart PostgreSQL
POSTGRES_VERSION=$(psql --version | cut -d ' ' -f3 | awk -F '.' '{print $1}')
POSTGRES_CONF=/etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf
if grep -q -E pg_stat_statements.track $POSTGRES_CONF ; then       
    sed -i "s/^#*\s*\(pg_stat_statements.track\s*=\s*\).*/\1all/" $POSTGRES_CONF
else echo pg_stat_statements.track = all | tee -a $POSTGRES_CONF
fi
sed -i "s/^#*\s*\(shared_preload_libraries\s*=\s*\).*/\1'pg_stat_statements'/" $POSTGRES_CONF
sudo -i -u postgres psql -c "CREATE USER $USER WITH PASSWORD '$PASSWORD';"
sudo -i -u postgres psql -c "GRANT pg_monitor to $USER;"

systemctl restart postgresql
systemctl daemon-reload
systemctl enable postgres_exporter --now
systemctl status postgres_exporter --no-pager
