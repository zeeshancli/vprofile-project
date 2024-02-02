#!/bin/bash

# Nexus version
NEXUS_VERSION="3.64.0-04"

# Step 1: Install OpenJDK 1.8 on Ubuntu 20.04 LTS
sudo apt update
sudo apt install -y openjdk-8-jre-headless

# Step 2: Download Nexus Repository Manager setup on Ubuntu 20.04 LTS
sudo mkdir -p /opt
cd /opt

# Download the specified Nexus Repository Manager Setup version
sudo wget https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

# Step 3: Install Nexus Repository on Ubuntu 20.04 LTS
sudo tar -zxvf nexus-${NEXUS_VERSION}-unix.tar.gz
sudo mv /opt/nexus-${NEXUS_VERSION} /opt/nexus

# Create a new user named 'nexus' with the password 'zeeshan100'
sudo useradd -m -p $(openssl passwd -1 zeeshan100) nexus

# Give permission to nexus files and nexus directory to nexus user
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

# To run Nexus as a service at boot time, create and configure nexus.rc file
sudo tee /opt/nexus/bin/nexus.rc > /dev/null <<EOL
run_as_user="nexus"
EOL

# Step 4: Run Nexus as a service using Systemd
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOL
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Start Nexus service using systemctl
sudo systemctl start nexus

# Enable Nexus service at system startup
sudo systemctl enable nexus

# Check Nexus service status
sudo systemctl status nexus

echo "Nexus Repository Manager is installed and configured. Access it at: http://localhost:8081"
echo "Default Nexus username: admin"
echo "Default Nexus password: admin123"

# To stop Nexus service
# sudo systemctl stop nexus

# If Nexus service is not started, check the Nexus logs
# tail -f /opt/sonatype-work/nexus3/log/nexus.log
