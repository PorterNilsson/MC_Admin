#!/bin/sh

sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo 
echo "-----------------------------------------------------"
echo "Installing Docker"
echo "----------------------------------------------------"
echo
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker run hello-world

sudo groupadd docker
sudo usermod -aG docker mcadmindev

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Install Golang
echo 
echo "-----------------------------------------------------"
echo "Installing Golang"
echo "----------------------------------------------------"
echo
wget https://go.dev/dl/go1.24.3.linux-arm64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.3.linux-arm64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
. /etc/profile
go version
rm -f go1.24.3.linux-amd64.tar.gz

# Delete the script itself
rm -- "$0"