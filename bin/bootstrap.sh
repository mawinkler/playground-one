#!/bin/bash

set -e
#o errexit

if [ -z "$1" ]; then
  CURRENT_PATH=$(pwd)
else
  CURRENT_PATH=$1
fi

# Colors
# Num  Colour    #define         R G B
# 0    black     COLOR_BLACK     0,0,0
# 1    red       COLOR_RED       1,0,0
# 2    green     COLOR_GREEN     0,1,0
# 3    yellow    COLOR_YELLOW    1,1,0
# 4    blue      COLOR_BLUE      0,0,1
# 5    magenta   COLOR_MAGENTA   1,0,1
# 6    cyan      COLOR_CYAN      0,1,1
# 7    white     COLOR_WHITE     1,1,1
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
BOLD=$(tput bold)
RESET=$(tput sgr0)

OS="$(uname)"
# Allowed values:
#   apt
#   brew
PACKAGE_MANAGER="apt"

# Repo
REPO=https://raw.githubusercontent.com/mawinkler/playground-one/main

function find_playground() {
  if [ "${ONEPATH}" != "" ] && [ -f "${ONEPATH}/.pghome" ]; then
    return
  fi
  false
}

function ensure_bashrc() {
  if ! find_playground ; then
    if [ ! -f "$HOME/.bashrc" ]; then
      echo 'creating .bashrc'
      touch $HOME/.bashrc
    fi

    if [[ ":$PATH:" == *"playground"* ]]; then
      echo 'playground-one already in $PATH'
    else
      echo 'adding playground-one to $PATH'
      echo "export ONEPATH=${CURRENT_PATH}/playground-one" >> $HOME/.bashrc
      echo 'export PATH=${ONEPATH}/bin:$PATH' >> $HOME/.bashrc
    fi

    if [ ! -f "$HOME/.bash_profile" ] && [ -f "$HOME/.profile" ]; then
      if [ -n "$(grep '# include .bashrc if it exists' $HOME/.profile)" ]; then
        echo 'copying .profile to .bash_profile'
        cp $HOME/.profile $HOME/.bash_profile
      fi
    fi

    if [ ! -f "$HOME/.bash_profile" ]; then
      echo 'creating .bash_profile'
      touch $HOME/.bash_profile
    fi

    if [ -z "$(grep '# include .bashrc if it exists' $HOME/.bash_profile)" ]; then
      echo 'ensure that .bash_profile loads .bashrc'
      echo 'if [ -n "$BASH_VERSION" ]; then' >> $HOME/.bash_profile
      echo '  # include .bashrc if it exists' >> $HOME/.bash_profile
      echo '  if [ -f "$HOME/.bashrc" ]; then' >> $HOME/.bash_profile
      echo '    . "$HOME/.bashrc"' >> $HOME/.bash_profile
      echo '  fi' >> $HOME/.bash_profile
      echo 'fi' >> $HOME/.bash_profile
    fi

    if [ -z "$(grep '/bash_aliases' $HOME/.bash_profile)" ]; then
      echo 'if [ -f ${ONEPATH}/bash_aliases ]; then' >> $HOME/.bashrc
      echo '  . ${ONEPATH}/bash_aliases' >> $HOME/.bashrc
      echo 'fi' >> $HOME/.bashrc
    fi

    source $HOME/.bashrc

    # FIXME: why does the source from above not work?
    export ONEPATH=${CURRENT_PATH}/playground-one
    export PATH==${ONEPATH}/bin:$PATH
  else
    echo "playground already installed in ${ONEPATH}"
  fi
}

function ensure_playground() {

  # Getting Playground repo or update it
  if ! find_playground ; then
    git clone https://github.com/mawinkler/playground-one.git
  else
    cd ${ONEPATH}
    git pull
  fi
  # Source helpers
  .  $ONEPATH/bin/playground-helpers.sh
}

# Installing essentials
function ensure_essentials() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing essential packages on linux"
  sudo apt update
  sudo apt install -y jq apt-transport-https gnupg2 curl nginx apache2-utils pv unzip dialog software-properties-common

  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    if ! command -v brew &>/dev/null; then
      printf "${RED}${BOLD}%s${RESET}\n" "Installing brew on linux"

      # Installing homebrew
      NONINTERACTIVE=1 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

      if [ -z "$(grep '$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' .bashrc)" ]; then
        echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/${USER}/.bashrc
        echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/${USER}/.bashrc
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      fi
    else
      printf "${YELLOW}%s${RESET}\n" "Brew already installed, updating packages"
      brew update
    fi
  fi
}

function ensure_awscli() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing aws CLI on linux"
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update
  rm -Rf /tmp/aws /tmp/awscliv2.zip

  curl -fsSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  rm -Rf /tmp/eksctl
}

function ensure_azcli() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing az CLI on linux"
  sudo mkdir -p /etc/apt/keyrings
  curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
      gpg --dearmor |
      sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

  AZ_DIST=$(lsb_release -cs)
  echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" |
      sudo tee /etc/apt/sources.list.d/azure-cli.list
      
  # echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" | \
  #     sudo tee /etc/apt/sources.list.d/dotnetdev.list

  sudo apt update
  sudo apt install -y azure-cli azure-functions-core-tools-4

  curl -fsSL https://aka.ms/downloadazcopy-v10-linux | tar xz --strip-components=1 -C /tmp
  sudo mv /tmp/azcopy /usr/local/bin
  rm -rf /tmp/azcopy*
  sudo chmod 755 /usr/local/bin/azcopy
}

function query_aws_keys() {

  # In short: 3>&1 opens a new file descriptor which points to stdout,
  # 1>&2 redirects stdout to stderr,
  # 2>&3 points stderr to stdout and 
  # 3>&- deletes the files descriptor 3 after the command has been executed.
  AWS_ACCESS_KEY_ID=$(dialog --title "AWS Account" --insecure --passwordbox "Enter AWS ACCESS KEY:" 8 40 3>&1 1>&2 2>&3 3>&-)
  AWS_SECRET_ACCESS_KEY=$(dialog --title "AWS Account" --insecure --passwordbox "Enter AWS SECRET ACCESS KEY:" 8 40 3>&1 1>&2 2>&3 3>&-)
  AWS_DEFAULT_REGION=$(dialog --title "AWS Account" --inputbox "Enter AWS REGION:" 8 40 3>&1 1>&2 2>&3 3>&-)
}

function ensure_ec2_instance_role() {
  # Are we bootstrapping an EC2 intance (e.g. Cloud9), we need an instance role

  if is_ec2 ; then
    # Checking instance role
    if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "ekscluster" ]]; then
      echo Instance role set
    else
      FAIL=1
  
      # Are the keys set? If not query them
      if [ -v $AWS_ACCESS_KEY_ID ] || [ -v $AWS_SECRET_ACCESS_KEY ] || [ -v $AWS_DEFAULT_REGION ]; then
        query_aws_keys
      fi
  
      # FIXME: How to do this nicely?
      AKI=${AWS_ACCESS_KEY_ID}
      SAK=${AWS_SECRET_ACCESS_KEY}
      DR=${AWS_DEFAULT_REGION}
  
      unset AWS_ACCESS_KEY_ID
      unset AWS_SECRET_ACCESS_KEY
      unset AWS_DEFAULT_REGION
  
      while [ $FAIL -eq 1 ]; do
        # Checking credentials
        if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "ekscluster" ]]; then
          echo Instance role set
          FAIL=0
        elif [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "AWSCloud9SSMAccessRole" ]] || [ "$(aws sts get-caller-identity --query Arn 2> /dev/null)" == "" ]; then
          echo AWS managed temporary credentials are turned off 
          FAIL=0
        else
          echo Turn off AWS managed temporary credentials
          dialog --msgbox "Turn off AWS managed temporary credentials." 8 40
          FAIL=1
        fi
      done
  
      AWS_ACCESS_KEY_ID=${AKI}
      AWS_SECRET_ACCESS_KEY=${SAK}
      AWS_DEFAULT_REGION=${DR}
  
      if [ -v $AWS_ACCESS_KEY_ID ]; then
        echo Set AWS_ACCESS_KEY_ID with: 'export AWS_ACCESS_KEY_ID=<YOUR ACCESS KEY>'
        FAIL=1
      fi
      if [ -v $AWS_SECRET_ACCESS_KEY ]; then
        echo Set AWS_SECRET_ACCESS_KEY with: 'export AWS_SECRET_ACCESS_KEY=<YOUR ACCESS KEY>'
        FAIL=1
      fi
      if [ -v $AWS_DEFAULT_REGION ]; then
        echo Set AWS_DEFAULT_REGION with: 'export AWS_DEFAULT_REGION=<YOUR DESIRED REGION>'
        FAIL=1
      fi
      if [ "$FAIL" == "1" ]; then
        exit 0
      fi
  
      # Create and assign instance role
      if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "ekscluster" ]]; then
        echo
      else
        AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
          AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
          AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
          $ONEPATH/tools/cloud9-instance-role.sh
      fi
  
      # Unset AWS credentials
      unset AWS_ACCESS_KEY_ID
      unset AWS_SECRET_ACCESS_KEY
  
      for i in {1..60} ; do
        sleep 2
        if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "ekscluster" ]]; then
          break
        fi
        printf '%s' "."
      done
  
      if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "ekscluster" ]]; then
        echo "IAM role valid"
      else
        echo "IAM role NOT valid"
        exit 0
      fi
  
      # Resizing Cloud9 disk
      curl -fsSL ${REPO}/tools/cloud9-resize.sh | bash
    fi
  else
    echo Not running on Cloud9
  fi
}

function ensure_docker() {
  if ! command -v docker &>/dev/null; then
    if [ "${OS}" == 'Linux' ]; then
      # Enable Universe and Multiverse
      sudo add-apt-repository universe
      sudo add-apt-repository multiverse
      sudo apt update
      sudo apt install -y \
        apt-transport-https ca-certificates curl \
        gnupg-agent software-properties-common

      # Add Docker’s official GPG key:
      curl -fsSL \
        https://download.docker.com/linux/ubuntu/gpg | \
        sudo apt-key add -

      # Docker stable repository
      sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

      # Install Docker
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      sudo usermod -aG docker $(whoami)

      # Allow insecure registries
      # FIXME: check if already configured. If not merge not replace
      sudo mkdir -p /etc/docker
      sudo touch /etc/docker/daemon.json && \
        sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup && \
        echo '{"insecure-registries": ["172.250.255.1","172.250.255.2","172.250.255.3","172.250.255.4","172.250.255.5","172.250.255.1:5000","172.250.255.2:5000","172.250.255.3:5000","172.250.255.4:5000","172.250.255.5:5000"]}' > /tmp/daemon.json && \
        sudo mv /tmp/daemon.json /etc/docker/daemon.json && \
        sudo systemctl restart docker
    fi
  else
    if [ "${OS}" == 'Linux' ]; then
      printf "${RED}${BOLD}%s${RESET}\n" "Upgrading docker on linux"
      sudo apt upgrade -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

      # Allow insecure registries
      # FIXME: check if already configured. If not merge not replace
      sudo mkdir -p /etc/docker
      sudo touch /etc/docker/daemon.json && \
        sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup && \
        echo '{"insecure-registries": ["172.250.255.1","172.250.255.2","172.250.255.3","172.250.255.4","172.250.255.5","172.250.255.1:5000","172.250.255.2:5000","172.250.255.3:5000","172.250.255.4:5000","172.250.255.5:5000"]}' > /tmp/daemon.json && \
        sudo mv /tmp/daemon.json /etc/docker/daemon.json && \
        sudo systemctl restart docker
    fi
  fi
}

function ensure_formulae () {
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for gcc"
  brew install gcc
  # brew install awscli
  # brew install azure-cli
  # FIXME 4 Linux: brew install --cask google-cloud-sdk
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for kubectl"
  brew install kubernetes-cli
  # brew install eksctl
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for kustomize"
  brew install kustomize
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for helm"
  brew install helm
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for k9s"
  brew install k9s
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for stern"
  brew install stern
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for krew"
  brew install krew
}

function ensure_terraform() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for terraform"
  # if ! is_ec2 ; then
    if ! command -v terraform &>/dev/null; then
      printf "${RED}${BOLD}%s${RESET}\n" "Installing terraform on linux"
      # sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
      wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt update
      sudo apt-get install terraform
    else
      printf "${YELLOW}%s${RESET}\n" "Terraform already installed, ensuring latest version"
      # sudo apt-get upgrade -y terraform
    fi
  # fi
}

function ensure_kubectl() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for kubectl"
  if ! command -v kubectl &>/dev/null; then
    printf "${RED}${BOLD}%s${RESET}\n" "Installing kubectl on linux"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && \
      sudo apt-get update && \
      sudo apt-get install -y kubectl
  else
    printf "${YELLOW}%s${RESET}\n" "Kubectl already installed, ensuring latest version"
    sudo apt-get upgrade -y kubectl
  fi
}

function ensure_eksctl() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for eksctl"
  if ! command -v eksctl &>/dev/null; then
    printf "${RED}${BOLD}%s${RESET}\n" "Installing eksctl on linux"
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
  else
    printf "${YELLOW}%s${RESET}\n" "Eksctl already installed, ensuring latest version"
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
  fi
}

# function ensure_kustomize() {

#   printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for kustomize"
#   if ! command -v kustomize &>/dev/null; then
#     printf "${RED}${BOLD}%s${RESET}\n" "Installing kustomize on linux"
#     curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
#       sudo mv ./kustomize /usr/local/bin
#   else
#     printf "${YELLOW}%s${RESET}\n" "Kustomize already installed, ensuring latest version"
#     printf "${RED}${BOLD}%s${RESET}\n" "Upgrading kustomize on linux"
#     curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
#       sudo mv ./kustomize /usr/local/bin
#   fi
# }

function ensure_helm() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for helm"
  if ! command -v helm &>/dev/null; then
    printf "${RED}${BOLD}%s${RESET}\n" "Installing helm on linux"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
      chmod 700 get_helm.sh && \
      ./get_helm.sh
      rm -f ./get_helm.sh
  else
    printf "${YELLOW}%s${RESET}\n" "Helm already installed, ensuring latest version"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
      chmod 700 get_helm.sh && \
      ./get_helm.sh
      rm -f ./get_helm.sh
  fi
}

function ensure_kind() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for kind"
  if ! command -v kind &>/dev/null; then
    printf "${RED}${BOLD}%s${RESET}\n" "Installing kind on linux"
    curl -fsSLo ./kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-$(uname)-amd64"
    chmod +x ./kind
    sudo mv kind /usr/local/bin/
  else
    printf "${YELLOW}%s${RESET}\n" "Kind already installed, ensuring version 0.17.0"
    curl -fsSLo ./kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-$(uname)-amd64"
    chmod +x ./kind
    sudo mv kind /usr/local/bin/
  fi
}

function ensure_k9s() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for k9s"
  if ! command -v k9s &>/dev/null; then
    printf "${RED}${BOLD}%s${RESET}\n" "Ensuring latest version of k9s on linux"
    curl -fsSL https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_x86_64.tar.gz -o /tmp/k9s_Linux_x86_64.tar.gz
    tar xfz /tmp/k9s_Linux_x86_64.tar.gz -C /tmp k9s
    sudo mv /tmp/k9s /usr/local/bin/
    rm /tmp/k9s_Linux_x86_64.tar.gz
  else
    printf "${YELLOW}%s${RESET}\n" "K9s already installed"
  fi
}

function ensure_stern() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for stern"
  if ! command -v stern &>/dev/null; then
    printf "${RED}${BOLD}%s${RESET}\n" "Installing stern on linux"
    curl -Lo stern.tgz https://github.com/stern/stern/releases/download/v1.24.0/stern_1.24.0_linux_amd64.tar.gz && \
      tar xfvz stern.tgz && \
      rm -f LICENSE stern.tgz && \
      sudo mv stern /usr/local/bin/stern
  else
    printf "${YELLOW}%s${RESET}\n" "Stern already installed"
  fi
}

function ensure_yq() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for yq"
  if ! command -v yq &>/dev/null; then
    printf "${RED}${BOLD}%s${RESET}\n" "Installing yq on linux"
    curl -Lo yq https://github.com/mikefarah/yq/releases/download/v4.30.5/yq_linux_amd64 && \
      chmod +x yq && \
      sudo mv yq /usr/local/bin/yq
  else
    printf "${YELLOW}%s${RESET}\n" "Yq already installed"
  fi
}

# function ensure_krew() {

#   printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for krew"
#   if ! command -v ~/.krew/bin/kubectl-krew &>/dev/null; then
#     printf "${RED}${BOLD}%s${RESET}\n" "Installing krew on linux"
#     cd "$(mktemp -d)" &&
#       OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
#       ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
#       KREW="krew-${OS}_${ARCH}" &&
#       curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
#       tar zxf "${KREW}.tar.gz" &&
#       ./$KREW install krew
#     rm -f "${KREW}.tar.gz" ./krew-*
#     if [[ ":$PATH:" == *":$HOME/.krew/bin:"* ]]; then
#       echo "~/.krew/bin already in $PATH"
#     else
#       echo "export PATH=~/.krew/bin:$PATH" >> ~/.bashrc
#     fi
#     export PATH=~/.krew/bin:$PATH
#   else
#     printf "${YELLOW}%s${RESET}\n" "Krew already installed"
#   fi
# }

function ensure_syft() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for syft"
  # if ! command -v ~/.syft/bin/syft &>/dev/null; then
  printf "${RED}${BOLD}%s${RESET}\n" "Ensuring latest version of syft on linux"
  mkdir -p ~/.syft/bin
  curl -fsSL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ~/.syft/bin
  if [[ ":$PATH:" == *":$HOME/.syft/bin:"* ]]; then
    echo '~/.syft/bin already in $PATH'
  else
    echo 'export PATH=~/.syft/bin:$PATH' >> ~/.bashrc
  fi
  export PATH=~/.syft/bin:$PATH
  # else
  #   printf "${YELLOW}%s${RESET}\n" "Syft already installed"
  # fi
}

function ensure_grype() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for grype"
  # if ! command -v ~/.grype/bin/grype &>/dev/null; then
  printf "${RED}${BOLD}%s${RESET}\n" "Ensuring latest version of grype on linux"
  mkdir -p ~/.grype/bin
  curl -fsSL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ~/.grype/bin
  if [[ ":$PATH:" == *":$HOME/.grype/bin:"* ]]; then
    echo '~/.grype/bin already in $PATH'
  else
    echo 'export PATH=~/.grype/bin:$PATH' >> ~/.bashrc
  fi
  export PATH=~/.grype/bin:$PATH
  # else
  #   printf "${YELLOW}%s${RESET}\n" "Grype already installed"
  # fi
}

ensure_bashrc
ensure_playground
ensure_essentials
ensure_ec2_instance_role
ensure_terraform
# ensure_docker
if [ "${PACKAGE_MANAGER}" == "brew" ]; then
  ensure_formulae
else
  ensure_kubectl
  ensure_eksctl
  # ensure_kustomize
  ensure_helm
  ensure_k9s
  ensure_stern
fi
ensure_yq
ensure_kind
ensure_syft
ensure_grype
ensure_awscli
ensure_azcli
# if [ "${PACKAGE_MANAGER}" != "brew" ]; then
#   ensure_krew
# fi

printf '\n%s\n' "###TASK-COMPLETED###"
