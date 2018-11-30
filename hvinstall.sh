#!/bin/bash

sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y \
	build-essential \
	aptitude \
	apt-transport-https \
	ca-certificates \
	software-properties-common \
	samba \
	curl \
	vim \
	wget \
	tree \
	git \
	postgresql-client \
	python-pip \
	python3-pip;

echo '**   Installing node and nvm   **'
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install 8.12  # default node version to 8.12

echo '**   Install git lfs   **'
sudo add-apt-repository ppa:git-core/ppa && \
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
sudo apt-get install -y git-lfs && \
git lfs install;

echo '**   Configure VSCode   **'
wget https://az764295.vo.msecnd.net/stable/431ef9da3cf88a7e164f9d33bf62695e07c6c2a9/code_1.28.0-1538751525_amd64.deb
sudo apt install ./code_1.28.0-1538751525_amd64.deb
sudo apt-get install -y libxss1 libasound2 libgl1 ttf-ubuntu-font-family
sudo fc-cache -f -v

echo '**   Adding Microsoft Repos for dotnet core   **'
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update && sudo apt-get install -y 'dotnet-sdk-2.1'

echo '**   Configure Go 1.10.1 (AMD64)   **'
wget "https://storage.googleapis.com/golang/go1.10.1.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf go1.10.1.linux-amd64.tar.gz

echo '**   Configure Docker CLI   **'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER
sudo pip3 install docker-compose

echo '**   Setting default terminal editor to vim   **'
echo 'export VISUAL=vim' >> ~/.bashrc
echo 'export EDITOR="$VISUAL"' >> ~/.bashrc

echo 'Please run "source ~/.bashrc" and youre all set :)'

