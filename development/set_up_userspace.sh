#!/bin/sh
set -e

# Install Docker
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker run hello-world

systemctl enable docker.service
systemctl enable containerd.service

# Install Golang
wget https://go.dev/dl/go1.24.3.linux-arm64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.3.linux-arm64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile
. /etc/profile
go version
rm -f go1.24.3.linux-arm64.tar.gz

# Install git
sudo apt-get install -y git

# Generate SSH key for use with Github and cat it.
ssh-keygen -t ed25519 -C "MC_Admin_Dev_VM" -f ~/.ssh/id_ed25519 -N "" -q
echo "#################################################################"
echo
echo "Please copy and add this key to your SSH keys in GitHub:"
echo
cat ~/.ssh/id_ed25519.pub
echo
echo "Type anything when finished and hit enter."
echo
echo "#################################################################"
read

git clone git@github.com:PorterNilsson/MC_Admin.git

# Script deletes itself at the end
rm -- "$0"
