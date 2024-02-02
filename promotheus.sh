#!/bin/bash

# Step 1: Update the system
sudo apt update

# Step 2: Download and install Prometheus
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

wget https://github.com/prometheus/prometheus/releases/download/v2.31.0/prometheus-2.31.0.linux-amd64.tar.gz
tar -xvf prometheus-2.31.0.linux-amd64.tar.gz
cd prometheus-2.31.0.linux-amd64

sudo mv prometheus promtool /usr/local/bin/
sudo mv consoles/ console_libraries/ /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml

# Check Prometheus version
prometheus --version
promtool --version

# Step 3: Configure System group and user
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

sudo chown -R prometheus:prometheus /etc/prometheus/ /var/lib/prometheus/
sudo chmod -R 775 /etc/prometheus/ /var/lib/prometheus/

# Step 4: Create a systemd file for Prometheus
sudo tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Restart=always
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Prometheus service
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Check the status of the Prometheus service
sudo systemctl status prometheus

# Step 5: Access Prometheus
# If UFW is running, open port 9090
sudo ufw allow 9090/tcp
sudo ufw reload

echo "Prometheus is installed and running. Access it at: http://server-ip:9090"
