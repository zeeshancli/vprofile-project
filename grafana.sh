#!/bin/bash

# Set your domain variable
YOUR_DOMAIN="172.210.49.242"

# Install Nginx if not already installed
if ! command -v nginx &> /dev/null
then
    sudo apt update
    sudo apt install -y nginx
fi

# Step 1: Installing Grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt update
sudo apt install -y grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Step 2: Setting Up the Reverse Proxy with Nginx
sudo touch /etc/nginx/sites-available/your_domain

# Add the following configuration:
cat <<EOL | sudo tee -a /etc/nginx/sites-available/your_domain
map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

server {
    listen 80;
    listen [::]:80;

    root /var/www/$YOUR_DOMAIN/html;
    index index.html index.htm index.nginx-debian.html;

    server_name $YOUR_DOMAIN www.$YOUR_DOMAIN;

    location / {
       proxy_set_header Host $http_host;
       proxy_pass http://localhost:3000;
    }

    location /api/live {
       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection $connection_upgrade;
       proxy_set_header Host $http_host;
       proxy_pass http://localhost:3000;
    }
}
EOL

# Test and reload Nginx
sudo nginx -t
sudo systemctl reload nginx

# Step 3: Updating Grafana Credentials
# Change the default password to "zeeshan100"
curl -X POST -H "Content-Type: application/json" -d '{"password":"zeeshan100"}' http://admin:admin@$YOUR_DOMAIN:3000/api/user/password

echo "Grafana is installed and configured. Access it at: https://$YOUR_DOMAIN"
