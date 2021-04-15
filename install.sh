#!/bin/bash

echo '**   Adding and updating repos **'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

echo '**   Updating package list.   **'
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt-get update

echo '**   Installing packages and devtools from deb repos (gcloud-sdk, httpie, docker, etc)   **'
sudo apt-get install -y \
python3 \
python3-pip \
git \
vim \
htop \
zip \
unzip \
httpie \
gnupg \
bash-completion \
fzf \
mtr-tiny \
google-cloud-sdk \
docker-ce docker-ce-cli containerd.io;

echo '**   Installing git-lfs   **'
sudo add-apt-repository ppa:git-core/ppa && \
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
sudo apt-get install git-lfs && \
git lfs install;

echo '**   Set up virtualenv, pyenv, docker-compose, and docker user.   **'
sudo pip3 install virtualenv docker-compose
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
echo 'export PATH="/home/tyler/.pyenv/bin:$PATH"' >> ~/.bashrc 
echo 'eval "$(pyenv init -)"' >> ~/.bashrc 
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc 
sudo usermod -aG docker $USER

echo '**   Installing kubectl   **'
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
echo '#kubectl' >> ~/.bashrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
kubectl completion bash > kubectl_completions
sudo mv kubectl_completions /etc/bash_completion.d/kubectl

echo '**   Installing kubectx/kubens   **'
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
sudo ln -sf ~/.kubectx/completion/kubens.bash /etc/bash_completion.d/kubens
sudo ln -sf ~/.kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
echo '#kubectx and kubens' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.kubectx' >> ~/.bashrc
echo 'export FZF_DEFAULT_OPTS=\'--height 40% --layout=reverse --border\''

echo '**   Installing NVM (Node Version Manager) and NodeJS   **'
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.35.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install 14

echo '**   Setting default terminal editor to vim   **'
echo '#vim master race' >> ~/.bashrc
echo 'export VISUAL=vim' >> ~/.bashrc
echo 'export EDITOR="$VISUAL"' >> ~/.bashrc

echo '**   Setting shell prompt and aliases   **'
echo '#show git branch in bash prompt' >> ~/.bashrc
echo 'export PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "' >> ~/.bashrc
echo '#"hist" alias' >> ~/.bashrc
echo 'alias hist=\'history | grep $@\' >> ~/.bashrc 

echo 'Please run "source ~/.bashrc" and youre all set :)'
