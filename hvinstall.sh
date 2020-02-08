#!/bin/bash

echo '**   Adding and updating repos **'
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo '**   Updating package list.   **'
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt-get update

echo '**   Installing desktop packages and devtools from the Ubuntu repo.   **'
sudo apt-get install -y \
python \
python-pip \
python3 \
python3-pip \
git \
vim \
zip \
unzip \
dotnet-sdk-2.2 \
docker-ce;

echo '**   Installing git-lfs   **'
sudo add-apt-repository ppa:git-core/ppa && \
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
sudo apt-get install git-lfs && \
git lfs install;

echo '**   Set up docker-compose and user.   **'
sudo pip install docker-compose
sudo usermod -aG docker $USER

echo '**   Installing NVM (Node Version Manager) and NodeJS   **'
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.35.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install 10

echo '**   Configure Go 1.12 (AMD64)   **'
wget "https://dl.google.com/go/go1.12.14.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf go1.12.14.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile

echo '**   Setting default terminal editor to vim   **'
echo 'export VISUAL=vim' >> ~/.profile
echo 'export EDITOR="$VISUAL"' >> ~/.profile

echo 'Please run "source ~/.bashrc" and youre all set :)'
