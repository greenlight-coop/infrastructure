# macOS Developer Set Up

## Applications

### Visual Studio Code

* Download from https://code.visualstudio.com/download

* Download, unzip and move to Applications

* Set Tab Size to 2 in Settings

## Command Line Tools

Set environment variables for command line installation

    export FULL_NAME="<your full name>"
    export EMAIL_ADDRESS=<your email address>

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

### git

    brew install git
    git config --global user.name $FULL_NAME
    git config --global user.email $EMAIL_ADDRESS
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
