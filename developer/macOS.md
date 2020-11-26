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
  * Kubernetes
  * Docker

### Docker

* Download from https://docs.docker.com/docker-for-mac/install/

* Open .dmg, move Docker to Applications and launch to install

* Login to Docker Hub from the command line to enable pushing images, etc.

        docker login -u <username>

## Command Line Tools

Set environment variables and directories for command line installation

    export FULL_NAME="<your full name>"
    export EMAIL_ADDRESS=<your email address>

### Prerequisities / General Tools

    brew install wget
    brew install jq
    brew install python
    brew install go

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
      github
      kubectl
      zsh-autosuggestions
      helm
      terraform
    )

### git / GitHub

    brew install git
    git config --global user.name $FULL_NAME
    git config --global user.email $EMAIL_ADDRESS
    git config --global pull.rebase false
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
    brew install hub

### Google Cloud Platform

    brew install google-cloud-sdk

Update .zshrc per directions at start of install

    gcloud init
        
* Authenticate with greenlight.coop account
* Choose the Green Light development project (e.g. `greenlight-development-xxxx`) as the default project and `us-east4-a` as the default zone

### Kubernetes Tools

    brew install kubectl
    brew install helm
    brew install terraform
    brew tap knative/client
    brew install kn
    brew install argocd
    brew install kustomize
    brew install tektoncd-cli
    brew install k9s
    brew install kind
    go get -u github.com/tektoncd/triggers/cmd/binding-eval

### Istio

    cd ~/dev/tools
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.7.4 sh -

Add $HOME/dev/tools/istio-1.7.4/bin to PATH in ~/.zshrc and source it (`. ~/.zshrc`)

### NodeJS

    brew install nvm
    mkdir ~/.nvm
  
Follow instructions in output to update .zshrc
  
    . ~/.zshrc
    nvm install --lts

## Notes

After following these instructions, `brew ls` output should be as below. This is provided for verification and to
help distinguish which casks were installed as dependencies and which may have been added outside of these
instructions.

    argocd
    gdbm
    gettext
    git
    helm
    hub
    jq
    kn
    kubernetes-cli
    libidn2
    libunistring
    ncurses
    nvm
    oniguruma
    openssl
    openssl@1.1
    pcre
    pcre2
    pkg-config
    python@3.8
    readline
    sqlite
    terraform
    wget
    xz
    zsh
    zsh-completions
