#!/usr/bin/env bash

PGO_VERSION=latest
PORT=2222

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

#######################################
# Query AWS Keys
#######################################
function query_aws_keys() {

  # # In short: 3>&1 opens a new file descriptor which points to stdout,
  # # 1>&2 redirects stdout to stderr,
  # # 2>&3 points stderr to stdout and 
  # # 3>&- deletes the files descriptor 3 after the command has been executed.
  # AWS_ACCESS_KEY_ID=$(dialog --title "AWS Account" --insecure --passwordbox "Enter AWS ACCESS KEY:" 8 40 3>&1 1>&2 2>&3 3>&-)
  # AWS_SECRET_ACCESS_KEY=$(dialog --title "AWS Account" --insecure --passwordbox "Enter AWS SECRET ACCESS KEY:" 8 40 3>&1 1>&2 2>&3 3>&-)
  # AWS_DEFAULT_REGION=$(dialog --title "AWS Account" --inputbox "Enter AWS REGION:" 8 40 3>&1 1>&2 2>&3 3>&-)


  key_desc="AWS Access Key"
  read -p "${key_desc} [${AWS_ACCESS_KEY_ID}]: " TEMP
  if [[ ! -z "${TEMP}" ]]; then
    AWS_ACCESS_KEY_ID=${TEMP}
  fi
  if [[ ! "${AWS_ACCESS_KEY_ID}" =~ ^[0-9A-Z]+$ ]]; then
    echo "Error: Invalid ${key_desc} input."
    exit 0
  fi

  key_desc="AWS Secret Key"
  read -p "${key_desc} [${AWS_SECRET_ACCESS_KEY}]: " TEMP
  if [[ ! -z "${TEMP}" ]]; then
    AWS_SECRET_ACCESS_KEY=${TEMP}
  fi

  AWS_DEFAULT_REGION=$(curl -sS -m 1 http://169.254.169.254/latest/meta-data/placement/region --header "X-aws-ec2-metadata-token: $METADATA_TOKEN")
}

#######################################
# Test for EC2 instance
# Returns:
#   0: if EC2
#   false: if not EC2
#######################################
function is_ec2() {
  # if [[ $(curl -sS -m 1 http://169.254.169.254/latest/meta-data/instance-id 2> /dev/null) =~ i-* ]]; then
  if curl -sS -m 1 http://169.254.169.254/latest/meta-data/instance-id &> /dev/null; then
    return
  fi
  false
}

#######################################
# Create and assign EC2 instance role
#######################################
function prepare_cloud9() {

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
        printf "${RED}${BOLD}%s${RESET}\n" "Turn off AWS managed temporary credentials."
        FAIL=1
      fi
    done

    export AWS_ACCESS_KEY_ID=${AKI}
    export AWS_SECRET_ACCESS_KEY=${SAK}
    export AWS_DEFAULT_REGION=${DR}

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
      cloud9_instance_role
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
    cloud9_resize
  fi
}

#######################################
# Create and assign instance role
#######################################
function cloud9_instance_role() {

  AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)

  # Check if AWS_REGION is set to desired region. The above curl to 169.254.269.254 points to
  # an AWS internal url allowing an EC2 instance to query some information about itself without
  # requiring a role for this. Feel free to play with it
  test -n "$AWS_DEFAULT_REGION" && echo AWS_REGION is "$AWS_DEFAULT_REGION" || echo AWS_DEFAULT_REGION is not set

  # Let’s save these into bash_profile
  echo "export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}" >> ~/.bash_profile
  echo "export AWS_REGION=${AWS_DEFAULT_REGION}" >> ~/.bash_profile
  aws configure set default.region ${AWS_DEFAULT_REGION}

  # Next, we define some names:
  ROLE_NAME=pgo-admin-$(openssl rand -hex 4)
  INSTANCE_PROFILE_NAME=${ROLE_NAME}

  # Create the policy for EC2 access
  EC2_TRUST="{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Principal\": {
          \"Service\": \"ec2.amazonaws.com\"
        },
        \"Action\": \"sts:AssumeRole\"
      }
    ]
  }"

  # Create role, attach policy, create instance-profile and add role
  aws iam create-role --role-name ${ROLE_NAME} --assume-role-policy-document "${EC2_TRUST}" --output text --query 'Role.Arn'
  aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"
  aws iam create-instance-profile --instance-profile-name ${INSTANCE_PROFILE_NAME}
  aws iam add-role-to-instance-profile --role-name ${ROLE_NAME} --instance-profile-name ${INSTANCE_PROFILE_NAME}

  # Which the following commands, we grant our Cloud9 instance the priviliges to manage AWS.
  # Query the instance ID of our Cloud9 environment
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id --header "X-aws-ec2-metadata-token: $METADATA_TOKEN")

  # Attach the IAM role to an existing EC2 instance
  echo Waiting 10 seconds
  sleep 10

  ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations | \
    ./jq -r --arg iid "$INSTANCE_ID" '.IamInstanceProfileAssociations[] | select(.InstanceId | contains($iid)) | .AssociationId' )
  if [ "$ASSOCIATION_ID" != "" ]; then
    echo Replacing current accsociation
    aws ec2 replace-iam-instance-profile-association --association-id ${ASSOCIATION_ID} --iam-instance-profile Name=${INSTANCE_PROFILE_NAME}
  else
    echo Assigning association
    aws ec2 associate-iam-instance-profile --instance-id ${INSTANCE_ID} --iam-instance-profile Name=${INSTANCE_PROFILE_NAME}
  fi

  # To ensure temporary credentials aren’t already in place we will also remove any existing credentials file:
  rm -vf ${HOME}/.aws/credentials

}

#######################################
# Resize Cloud9 volume
#######################################
function cloud9_resize() {
  SIZE=${1:-30}
  INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id --header "X-aws-ec2-metadata-token: $METADATA_TOKEN")
  VOLUMEID=$(aws ec2 describe-instances \
    --instance-id $INSTANCEID \
    --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" \
    --output text)

  aws ec2 modify-volume --volume-id $VOLUMEID --size $SIZE

  while [ \
    "$(aws ec2 describe-volumes-modifications \
      --volume-id $VOLUMEID \
      --filters Name=modification-state,Values="optimizing","completed" \
      --query "length(VolumesModifications)"\
      --output text)" != "1" ]; do
  echo -n .
  sleep 1
  done

  sudo growpart /dev/nvme0n1 1

  if [ "$(df -T | grep -i '/$' | awk '{print $2}')" == "xfs" ]; then
    sudo xfs_growfs -d /
  else
    sudo resize2fs /dev/nvme0n1p1
  fi
}

#######################################
# Create working directory for pgoc
#######################################
function create_workdir() {
  if [ ! -d workdir ]; then
    printf '%s\n' "Pulling Playground One Container"
    docker pull mawinkler/pgoc:${PGO_VERSION}

    IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "mawinkler/pgoc:${PGO_VERSION}")
    printf '%s\n' "Starting Playground One Container from image ${IMAGE}"
    docker run -d --rm --name=pgoc-${PGO_VERSION} ${IMAGE} -c "/bin/sleep 60"

    printf '%s\n' "Fetch Home Directory from Container"
    CONTAINER=$(docker ps --format "{{.ID}}" --filter "name=pgoc-${PGO_VERSION}")
    docker cp ${CONTAINER}:/tmp/home.tgz .

    printf '%s\n' "Stopping Playground One Container"
    docker stop ${CONTAINER}

    printf '%s\n' "Populating workdir"
    mkdir -p workdir
    tar xpzf home.tgz --strip-components=2 -C ./workdir

    rm -f home.tgz

    if [ ! -d workdir/.aws ]; then
      if [ -d ~/.aws ]; then
        printf '%s\n' "Copy AWS credentials to workdir"
        cp -r ~/.aws workdir/
      fi
    fi

    if [ ! -f workdir/playground-one/config.yaml ]; then
      if [ -f config.yaml ]; then
        printf '%s\n' "Copy config.yaml to workdir"
        cp config.yaml workdir/playground-one/
      fi
    fi
  else
    printf '%s\n' "Workdir already present"
  fi
}


####################################### 
# Main
#######################################

if is_ec2 ; then
  export METADATA_TOKEN=$(curl -sS --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")

  if ! command -v ./jq &>/dev/null; then
    curl -fsSL https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux64 -o jq
    chmod +x jq
  fi

  # If we were piped to bash we can't read user input
  if [ -p /dev/stdin ]; then
    curl -fsSLO https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/get_pgoc.sh
    chmod +x ./get_pgoc.sh

    printf '%s\n' "Please run ./get_pgoc.sh"
    exit 0
  else
    # Create instance role and increase volume size
    prepare_cloud9
  fi
fi

# Download current version of pgoc
curl -fsSLO https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgoc
chmod +x pgoc

create_workdir

printf '\n%s\n' "Run: ./pgoc"