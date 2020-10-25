# macOS Developer Set Up

## Applications

### Visual Studio Code

* Download from https://code.visualstudio.com/download

* Unzip and move to Applications

* Update Settings
    * Set Tab Size to 2
    * Auto Save: afterDelay

* Install the following extensions
  * Terraform (Anton Kulikov)

### Docker Desktop

* Download from https://docs.docker.com/docker-for-mac/install/

* Open .dmg, move Docker to Applications and launch to install 

## Command Line Tools

Set environment variables and directories for command line installation

    export FULL_NAME="<your full name>"
    export EMAIL_ADDRESS=<your email address>
    mkdir -p ~/dev/tools

### Prerequisities / General Tools

    brew install wget
    brew install jq

### zsh / oh-my-zsh
    
    brew install zsh

 Run zsh and configure

    brew install zsh-completions

    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    git clone \
      https://github.com/zsh-users/zsh-autosuggestions \
      $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions


Update to the following plugins in .zshrc

    plugins=(
      git
      kubectl
      minikube
      zsh-autosuggestions
      helm
    )

### git /

    brew install git
    git config --global user.name $FULL_NAME
    git config --global user.email $EMAIL_ADDRESS
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
    brew install hub

### Google Cloud Platform

    cd ~/dev/tools
    wget -c https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-315.0.0-darwin-x86_64.tar.gz -O - | tar -xz
    ./google-cloud-sdk/install.sh
    . ~/.zshrc
    gcloud init
        
Authenticate with greenlight.coop account

### Kubernetes Tools

    brew install kubectl
    brew install helm
    brew install terraform
    brew tap knative/client
    brew install kn
    brew install argocd

### NodeJS

    brew install nvm
    mkdir ~/.nvm
  
Follow instructions in output to update .zshrc
  
    . ~/.zshrc
    nvm install --lts