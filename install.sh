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
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release
sudo apt-get update

echo '**   Installing packages and devtools from deb repos (gcloud-sdk, httpie, docker, etc)   **'
sudo apt-get install -y \
python-is-python3 \
python3-pip \
wget \
git \
vim \
htop \
zip \
unzip \
httpie \
bash-completion \
fzf \
mtr-tiny \
google-cloud-sdk \
google-cloud-sdk-gke-gcloud-auth-plugin \
docker-ce docker-ce-cli containerd.io;

echo '**   TODO Terraform       **'

echo '**   Installing git-lfs   **'
sudo add-apt-repository ppa:git-core/ppa && \
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
sudo apt-get install git-lfs && \
git lfs install;

echo '**   Set up pip deps (awscli, virtualenv, pyenv, docker-compose)   **'
sudo pip3 install awscli virtualenv docker-compose
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
echo 'export PATH="/home/tyler/.pyenv/bin:$PATH"' >> ~/.bashrc 
echo 'eval "$(pyenv init -)"' >> ~/.bashrc 
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc 

echo '**   Set up docker user.   **'
sudo usermod -aG docker $USER

echo '**   Installing kubectl   **'
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
echo '#kubectl' >> ~/.bashrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
kubectl completion bash > kubectl_completions
sudo mv kubectl_completions /etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
echo '#TODO: removeme after k8s 1.26'
echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> ~/.bashrc

echo '**   Installing kubectx/kubens   **'
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
sudo ln -sf ~/.kubectx/completion/kubens.bash /etc/bash_completion.d/kubens
sudo ln -sf ~/.kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
echo '#kubectx and kubens' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.kubectx' >> ~/.bashrc

echo '**   Installing NVM (Node Version Manager) and NodeJS   **'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install 16

echo '**   Setting default terminal editor to vim   **'
echo '#vim master race' >> ~/.bashrc
echo 'export VISUAL=vim' >> ~/.bashrc
echo 'export EDITOR="$VISUAL"' >> ~/.bashrc

echo '**   Setting shell prompt and aliases   **'
echo '#show git branch in bash prompt' >> ~/.bashrc
echo 'parse_git_branch() {' >> ~/.bashrc
echo "     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'" >> ~/.bashrc
echo '}' >> ~/.bashrc
echo 'export PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "' >> ~/.bashrc
echo '#fzf bash history' >> ~/.bashrc
echo "export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'" >> ~/.bashrc
echo 'source /usr/share/doc/fzf/examples/key-bindings.bash' >> ~/.bashrc

echo 'Please run "source ~/.bashrc" and you\'re all set :)'
