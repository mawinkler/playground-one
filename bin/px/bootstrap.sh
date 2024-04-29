#!/bin/bash

set -e
#o errexit

export DEBIAN_FRONTEND=noninteractive

# Source helpers
if [ -f $ONEPATH/bin/playground-helpers.sh ]; then
  .  $ONEPATH/bin/playground-helpers.sh
else
  curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/px/playground-helpers.sh -o /tmp/playground-helpers.sh
  . /tmp/playground-helpers.sh
fi

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
GREEN=$(tput setaf 2)
BOLD=$(tput bold)
RESET=$(tput sgr0)

OS="$(uname)"
if is_linux; then
  # Allowed values:
  #   apt
  #   brew
  PACKAGE_MANAGER="apt"
fi
if is_darwin; then
  # Allowed values:
  #   brew
  PACKAGE_MANAGER="brew"
fi

ARCH=$(uname -m)
case $ARCH in
  armv5*) ARCH="armv5";;
  armv6*) ARCH="armv6";;
  armv7*) ARCH="arm";;
  arm64) ARCH="arm64";;
  aarch64) ARCH="arm64";;
  x86) ARCH="386";;
  x86_64) ARCH="amd64";;
  i686) ARCH="386";;
  i386) ARCH="386";;
esac

printf "${BLUE}${BOLD}%s${RESET}\n" "Bootstrapping on ${ARCH}"

function brew_installed() {

  if brew list $1 &>/dev/null; then
    return
  # else
  #   brew install $1 && echo "$1 is installed"
  fi
  false
}

# Repo
REPO=https://raw.githubusercontent.com/mawinkler/playground-one/main

#######################################
# Configure Shells
#######################################
function find_playground() {
  if [ "${ONEPATH}" != "" ] && [ -f "${ONEPATH}/.pghome" ]; then
    return
  fi
  false
}

function ensure_bashrc() {
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking .bashrc"
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
    echo "Playground One already installed in ${ONEPATH}"
  fi
}

function ensure_bash() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for bash version"

  bash_version=$(bash --version | head -n 1 | cut -d' ' -f4 | cut -d'.' -f1)

  if [ "${bash_version}" == "3" ]; then
    if [ "$(uname -s)" == "Darwin" ]; then
      printf "${RED}${BOLD}%s${RESET}\n" "Upgrading bash on darwin"
      brew install bash
      brew install gnu-getopt
    fi
  else
    echo V5
  fi
}

function ensure_zshrc() {
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking .zshrc"
  if ! find_playground ; then
    if [ ! -f "$HOME/.zshrc" ]; then
      echo 'creating .zshrc'
      touch $HOME/.zshrc
    fi

    if [[ ":$PATH:" == *"playground"* ]]; then
      echo 'playground-one already in $PATH'
    else
      echo 'adding playground-one to $PATH'
      echo "export ONEPATH=${CURRENT_PATH}/playground-one" >> $HOME/.zshrc
      echo 'export PATH=${ONEPATH}/bin:$PATH' >> $HOME/.zshrc
    fi

    if [ -z "$(grep '/bash_aliases' $HOME/.zshrc)" ]; then
      echo 'if [ -f ${ONEPATH}/bash_aliases ]; then' >> $HOME/.zshrc
      echo '  . ${ONEPATH}/bash_aliases' >> $HOME/.zshrc
      echo 'fi' >> $HOME/.zshrc
    fi

    source $HOME/.zshrc

    # FIXME: why does the source from above not work?
    export ONEPATH=${CURRENT_PATH}/playground-one
    export PATH==${ONEPATH}/bin:$PATH
  else
    echo "Playground One already installed in ${ONEPATH}"
  fi
}

#######################################
# Get/update Playground One
#######################################
function ensure_playground() {

  # Getting Playground repo or update it
  printf "${BLUE}${BOLD}%s${RESET}\n" "Downloading/updating Playground One"
  if ! find_playground ; then
    git clone https://github.com/mawinkler/playground-one.git
  else
    cd ${ONEPATH}
    git pull
  fi
  # Source helpers
  .  $ONEPATH/bin/playground-helpers.sh
}

#######################################
# Install essential packages
#######################################
function ensure_essentials() {

  if is_linux; then
    printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading essential packages on linux"
    if [ "${PACKAGE_MANAGER}" == "apt" ]; then
      sudo apt-get update
      sudo apt-get install -y jq apt-transport-https gnupg2 curl nginx apache2-utils pv unzip dialog software-properties-common gettext-base
    fi
    if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      if ! command -v brew &>/dev/null; then
        # Installing homebrew
        NONINTERACTIVE=1 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

        if [ -z "$(grep '$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' .bashrc)" ]; then
          echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/${USER}/.bashrc
          echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/${USER}/.bashrc
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        
        # This is kind of mandatory
        brew install gcc
      else
        brew update
      fi
    fi
  fi
  if is_darwin; then
    printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading essential packages on darwin"
    if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      if ! command -v brew &>/dev/null; then
        # Installing homebrew
        NONINTERACTIVE=1 curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

        if [ -z "$(grep '$(/opt/homebrew/bin/brew shellenv)' .zshrc)" ]; then
          echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ${HOME}/.zshrc
          (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/markus_winkler/.zprofile
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        # This is kind of mandatory
        # brew install gcc
      else
        brew update
      fi
    fi
  fi
}

function ensure_yq_jq() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading yq and jq"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_yq_jq_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_yq_jq_brew
  fi
}

function ensure_yq_jq_curl() {

  curl -Lo yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH} && \
    chmod +x yq && \
    sudo mv yq /usr/local/bin/yq
}

function ensure_yq_jq_brew() {

  if ! command -v yq &>/dev/null; then
    brew install yq
  else
    brew upgrade yq
  fi
  if ! command -v jq &>/dev/null; then
    brew install jq
  else
    brew upgrade jq
  fi
}

#######################################
# AWS
#######################################
function ensure_awscli() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading AWS CLI"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_awscli_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_awscli_brew
  fi
}

function ensure_awscli_curl() {

  case $ARCH in
    amd64) AARCH="x86_64";;
    arm64) AARCH="aarch64";;
  esac

  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AARCH}.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update
  rm -Rf /tmp/aws /tmp/awscliv2.zip
}

function ensure_awscli_brew() {

  if ! command -v aws &>/dev/null; then
    brew install awscli
  else
    brew upgrade awscli
  fi
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

  # If we are bootstrapping an EC2 intance (e.g. Cloud9), we need an instance role
  printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for EC2 instance"
  if is_ec2 ; then
    printf "${BLUE}${BOLD}%s${RESET}\n" "Checking for EC2 instance role"
    # Checking instance role
    if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "pgo" ]]; then
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
        if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "pgo" ]]; then
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
      if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "pgo" ]]; then
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
        if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "pgo" ]]; then
          break
        fi
        printf '%s' "."
      done

      if [[ $(aws sts get-caller-identity --query Arn 2> /dev/null | grep assumed-role) =~ "pgo" ]]; then
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

function ensure_eksctl() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading eksctl"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_eksctl_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_eksctl_brew
  fi
}

function ensure_eksctl_curl() {

  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_${ARCH}.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
}

function ensure_eksctl_brew() {

  if ! command -v eksctl &>/dev/null; then
    brew install eksctl
  else
    brew upgrade eksctl
  fi
}

#######################################
# Azure
#######################################
function ensure_azcli() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading Azure CLI"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_azcli_apt
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_azcli_brew
  fi
}

function ensure_azcli_apt() {

  if ! command -v az &>/dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
        gpg --dearmor |
        sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

    AZ_DIST=$(lsb_release -cs)
    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" |
        sudo tee /etc/apt/sources.list.d/azure-cli.list
        
    # echo "deb [arch=${ARCH}] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" | \
    #     sudo tee /etc/apt/sources.list.d/dotnetdev.list

    sudo apt-get update
    sudo apt-get install -y azure-cli

    curl -fsSL https://aka.ms/downloadazcopy-v10-linux | tar xz --strip-components=1 -C /tmp
    sudo mv /tmp/azcopy /usr/local/bin
    rm -rf /tmp/azcopy*
    sudo chmod 755 /usr/local/bin/azcopy
  else
    sudo apt-get upgrade -y azure-cli

    curl -fsSL https://aka.ms/downloadazcopy-v10-linux | tar xz --strip-components=1 -C /tmp
    sudo mv /tmp/azcopy /usr/local/bin
    rm -rf /tmp/azcopy*
    sudo chmod 755 /usr/local/bin/azcopy
  fi
}

function ensure_azcli_brew() {

  if ! command -v az &>/dev/null; then
    echo brew install azure-cli
  else
    echo brew upgrade azure-cli
  fi
}

#######################################
# Install Container Engine
#######################################
function ensure_container_engine() {

  if is_linux; then
    if [ "${PACKAGE_MANAGER}" == "apt" ] || [ "${PACKAGE_MANAGER}" == "brew" ] ; then
      ensure_container_engine_apt
    fi
  fi

  if is_darwin; then
    if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      ensure_container_engine_brew
    fi
  fi
}

function ensure_container_engine_apt() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading Docker on linux"
  if ! command -v docker &>/dev/null; then
    # Enable Universe and Multiverse
    sudo add-apt-repository -y universe
    sudo add-apt-repository -y multiverse
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker $(whoami)
  else
    sudo apt-get upgrade -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  fi
}

function ensure_container_engine_brew() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading Colima on darwin"
  if ! command -v docker &>/dev/null; then
    brew install colima

    if [ ! $HOME/Library/LaunchAgents/homebrew.mxcl.colima.plist ]; then
      brew services start colima
    fi

    /opt/homebrew/opt/colima/bin/colima start
    brew install docker
  else
    if brew_installed colima; then
      brew upgrade colima
      brew upgrade docker
    fi
  fi
}

#######################################
# Install Terraform
#######################################
function ensure_terraform() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading terraform"
  if is_linux; then
    if [ "${PACKAGE_MANAGER}" == "apt" ] || [ "${PACKAGE_MANAGER}" == "brew" ]; then
      ensure_terraform_apt
    fi
  fi

  if is_darwin; then
    if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      ensure_terraform_brew
    fi
  fi
}

function ensure_terraform_apt() {

  if ! command -v terraform &>/dev/null; then
    # sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor | \
      sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
      sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update
    sudo apt-get install terraform
  else
    sudo apt-get upgrade -y terraform
  fi
}

function ensure_terraform_brew() {

  if ! command -v terraform &>/dev/null; then
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
  else
    brew upgrade hashicorp/tap/terraform
  fi
}

#######################################
# Install Kubernetes Tools
#######################################
function ensure_kubectl() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading kubectl"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_kubectl_apt
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_kubectl_brew
  fi
}

function ensure_kubectl_apt() {

  if ! command -v kubectl &>/dev/null; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    # curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    #   echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && \
    sudo apt-get update &&
    sudo apt-get install -y kubectl
  else
    sudo apt-get upgrade -y kubectl
  fi
}

function ensure_kubectl_brew() {

  if ! command -v kubectl &>/dev/null; then
    brew install kubernetes-cli
  else
    brew upgrade kubernetes-cli
  fi
}

function ensure_helm() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading helm"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_helm_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_helm_brew
  fi
}

function ensure_helm_curl() {

  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh
    rm -f ./get_helm.sh
}

function ensure_helm_brew() {

  if ! command -v helm &>/dev/null; then
    brew install helm
  else
    brew upgrade helm
  fi
}

function ensure_kind() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading kind"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_kind_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_kind_brew
  fi
}

function ensure_kind_curl() {

  curl -fsSLo ./kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-$(uname)-${ARCH}"
  chmod +x ./kind
  sudo mv kind /usr/local/bin/
}

function ensure_kind_brew() {

  if ! command -v kind &>/dev/null; then
    brew install kind
  else
    brew upgrade kind
  fi
}

function ensure_k9s() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading k9s"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_k9s_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_k9s_brew
  fi
}

function ensure_k9s_curl() {

  curl -fsSL https://github.com/derailed/k9s/releases/download/v0.31.7/k9s_Linux_${ARCH}.tar.gz -o /tmp/k9s_Linux.tar.gz
  tar xfz /tmp/k9s_Linux.tar.gz -C /tmp k9s
  sudo mv /tmp/k9s /usr/local/bin/
  rm /tmp/k9s_Linux.tar.gz
}

function ensure_k9s_brew() {

  if ! command -v k9s &>/dev/null; then
    brew install k9s
  else
    brew upgrade k9s
  fi
}

function ensure_kubie() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading kubie"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_kubie_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_kubie_brew
  fi
}

function ensure_kubie_curl() {

  curl -fsSL https://github.com/sbstp/kubie/releases/download/v0.23.0/kubie-linux-${ARCH} -o /tmp/kubie
  chmod +x /tmp/kubie
  sudo mv /tmp/kubie /usr/local/bin/
}

function ensure_kubie_brew() {

  if ! command -v kubie &>/dev/null; then
    brew install kubie
  else
    brew upgrade kubie
  fi
}

function ensure_stern() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading stern"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_stern_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_stern_brew
  fi
}

function ensure_stern_curl() {

  curl -Lo stern.tgz https://github.com/stern/stern/releases/download/v1.24.0/stern_1.24.0_linux_${ARCH}.tar.gz && \
    tar xfvz stern.tgz && \
    rm -f LICENSE stern.tgz && \
    sudo mv stern /usr/local/bin/stern
}

function ensure_stern_brew() {

  if ! command -v stern &>/dev/null; then
    brew install stern
  else
    brew upgrade stern
  fi
}

#######################################
# Install Anchore Tools
#######################################
function ensure_syft() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading syft"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_syft_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_syft_brew
  fi
}

function ensure_syft_curl() {

  mkdir -p ~/.syft/bin
  curl -fsSL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ~/.syft/bin
  if [[ ":$PATH:" == *":$HOME/.syft/bin:"* ]]; then
    echo '~/.syft/bin already in $PATH'
  else
    echo 'export PATH=~/.syft/bin:$PATH' >> ~/.bashrc
  fi
  export PATH=~/.syft/bin:$PATH
}

function ensure_syft_brew() {

  if ! command -v ~/.syft/bin/syft &>/dev/null; then
    brew install syft
  else
    brew upgrade syft
  fi
}

function ensure_grype() {

  printf "${BLUE}${BOLD}%s${RESET}\n" "Installing/upgrading grype"
  if [ "${PACKAGE_MANAGER}" == "apt" ]; then
    ensure_grype_curl
  fi
  if [ "${PACKAGE_MANAGER}" == "brew" ]; then
    ensure_grype_brew
  fi
}

function ensure_grype_curl() {

  mkdir -p ~/.grype/bin
  curl -fsSL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ~/.grype/bin
  if [[ ":$PATH:" == *":$HOME/.grype/bin:"* ]]; then
    echo '~/.grype/bin already in $PATH'
  else
    echo 'export PATH=~/.grype/bin:$PATH' >> ~/.bashrc
  fi
  export PATH=~/.grype/bin:$PATH
}

function ensure_grype_brew() {

  if ! command -v ~/.grype/bin/grype &>/dev/null; then
    brew install grype
  else
    brew upgrade grype
  fi
}

#######################################
# Main
#######################################
exec_start=`date +%s`

touch /tmp/bootstrap_start

if [[ "${SHELL}" == *"bash"* ]]; then
  ensure_bashrc
fi
if [[ "${SHELL}" == *"zsh"* ]]; then
  ensure_zshrc
fi

ensure_playground
ensure_essentials
ensure_bash
ensure_awscli
ensure_ec2_instance_role
ensure_terraform
ensure_container_engine
ensure_yq_jq
ensure_azcli
ensure_kubectl
ensure_helm
ensure_k9s
ensure_kubie
ensure_stern
ensure_eksctl
ensure_kind
ensure_syft
ensure_grype

exec_end=`date +%s`

exec_runtime=$((exec_end-exec_start))
printf "${GREEN}${BOLD}%s${RESET}\n" "Execution time ${exec_runtime} seconds"

exit 0
