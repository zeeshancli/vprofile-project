#!/bin/bash

# Add the Trivy GPG key
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

# Add Trivy repository
echo deb [arch=amd64] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list

# Update apt cache
sudo apt-get update

# Install Trivy
sudo apt-get install trivy
