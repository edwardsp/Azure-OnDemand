#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GRAFANA_USER=${1-azhpc}
GRAFANA_PWD=$2

if [ -z "$GRAFANA_PWD" ]; then
    echo "Grafana password parameter is required"
    exit 1
fi

echo "#### Configuration repo for Grafana:"
cat <<EOF | tee /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

echo "#### Grafana Installation:"
yum -y install grafana

wget https://github.com/prometheus/prometheus/releases/download/v2.20.0/prometheus-2.20.0.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false prometheus
mkdir /etc/prometheus
mkdir /mnt/resource/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /mnt/resource/prometheus
tar -xvzf prometheus-2.8.1.linux-amd64.tar.gz
mv prometheus-2.8.1.linux-amd64 prometheuspackage
cp prometheuspackage/prometheus /usr/local/bin/
cp prometheuspackage/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
cp -r prometheuspackage/consoles /etc/prometheus
cp -r prometheuspackage/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
cat <<EOF | tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'prometheus_master'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
EOF

chown prometheus:prometheus /etc/prometheus/prometheus.yml
cat <<EOF | tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /mnt/resource/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start prometheus

echo "Add the administrator"
# https://grafana.com/docs/grafana/latest/administration/cli/
grafana-cli admin reset-admin-password "$GRAFANA_PWD"

grafana_etc_root=/etc/grafana/provisioning
dashboard_dir=/var/lib/grafana/dashboards
cat <<EOF > $grafana_etc_root/datasources/azhpcprometheus.yml
apiVersion: 1

datasources:
  - name: prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
EOF
chown root:grafana $grafana_etc_root/datasources/azhpcprometheus.yml

cat <<EOF > $grafana_etc_root/dashboards/azhpcprometheus.yml
apiVersion: 1

providers:
- name: 'azhpcprometheus'
  orgId: 2
  folder: ''
  folderUid: ''
  type: file
  disableDeletion: false
  editable: true
  allowUiUpdates: true
  options:
    path: $dashboard_dir
EOF

chown root:grafana $grafana_etc_root/dashboards/azhpcprometheus.yml

mkdir $dashboard_dir
chown grafana:grafana $dashboard_dir

cp $DIR/ondemand-clusters_rev1.json $dashboard_dir

## Enabling anonymous auth for ood dashboards:

sed -i 's/\[auth.anonymous\]/\[auth.anonymous\]\nenabled = true\norg_name = Azure Compute\norg_role = Viewer/' /etc/grafana/grafana.ini
sed -i 's/^;allow_embedding.*/allow_embedding = true/' /etc/grafana/grafana.ini

echo "Start grafana-server"
systemctl stop grafana-server
systemctl start grafana-server

