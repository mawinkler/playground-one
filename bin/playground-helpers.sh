#!/usr/bin/env bash

# if [ "$ONEPATH" == "" ]; then
#   echo ONEPATH not set
#   exit 0
# fi

# if [[ ! "$PATH" =~ .*playground/bin.* ]]; then
#   echo $ONEPATH/bin not in PATH
#   exit 0
# fi

#######################################
# Test for GKE cluster
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if GKE
#   false: if not GKE
#######################################
function is_gke() {
  if [[ $(kubectl config current-context) =~ gke_.* ]]; then
    return
  fi
  false
}

#######################################
# Test for AKS cluster
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if AKS
#   false: if not AKS
#######################################
function is_aks() {
  if [[ $(kubectl config current-context) =~ .*-aks ]]; then
    return
  fi
  false
}

#######################################
# Test for EKS cluster
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if EKS
#   false: if not EKS
#######################################
function is_eks() {
  if [[ $(kubectl config current-context) =~ arn:aws:eks:* ]] || [[ $(kubectl config current-context) =~ .*eksctl.io ]]; then
    return
  fi
  if [[ ! -z "$(kubectl config get-contexts | grep "^*" | grep "arn:aws")" ]]; then
    return
  fi
  false
}

#######################################
# Test for EC2 instance
# Globals:
#   None
# Arguments:
#   None
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
# Test for Kind cluster
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if Kind
#   false: if not Kind
#######################################
function is_kind() {
  if [[ $(kubectl config current-context) =~ kind.* ]]; then
    return
  fi
  false
}

#######################################
# Test for host operating system Linux
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if Linux
#   false: if not Linux
#######################################
function is_linux() {
  if [ "$(uname)" == 'Linux' ]; then
    return
  fi
  false
}

#######################################
# Test for host operating system Darwin
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if Darwin
#   false: if not Darwin
#######################################
function is_darwin() {
  if [ "$(uname)" == 'Darwin' ]; then
    return
  fi
  false
}

#######################################
# Retrieves the url of the registry
# Globals:
#   GCP_HOSTNAME
#   GCP_PROJECTID
#   PLAYGROUND_NAME
#   REGISTRY_NAME
#   REG_NAMESPACE
#   REG_NAME
# Arguments:
#   None
# Outputs:
#   REGISTRY
#######################################
function get_registry() {
  # gke
  # if is_gke ; then
  #   GCP_HOSTNAME="gcr.io"
  #   GCP_PROJECTID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
  #   REGISTRY=${GCP_HOSTNAME}/${GCP_PROJECTID}
  # # aks
  # elif is_aks ; then
  #   PLAYGROUND_NAME="$(yq '.cluster_name' $ONEPATH/config.yaml | tr '[:upper:]' '[:lower:]')"
  #   if [[ $(az group list | jq -r --arg PLAYGROUND_NAME ${PLAYGROUND_NAME} '.[] | select(.name==$PLAYGROUND_NAME) | .name') == "" ]]; then
  #     printf '%s\n' "creating resource group ${PLAYGROUND_NAME}"
  #     az group create --name ${PLAYGROUND_NAME} --location westeurope
  #   else
  #     printf '%s\n' "using resource group ${PLAYGROUND_NAME}"
  #   fi
  #   REGISTRY_NAME=$(az acr list --resource-group ${PLAYGROUND_NAME} | jq -r --arg PLAYGROUND_NAME ${PLAYGROUND_NAME//-/} '.[] | select(.name | startswith($PLAYGROUND_NAME)) | .name')
  #   if [[ ${REGISTRY_NAME} == "" ]]; then
  #     REGISTRY_NAME=${PLAYGROUND_NAME//-/}$(openssl rand -hex 4)
  #     printf '%s\n' "creating container registry ${REGISTRY_NAME}"
  #     az acr create --resource-group ${PLAYGROUND_NAME} --name ${REGISTRY_NAME} --sku Basic
  #   else
  #     printf '%s\n' "using container registry ${REGISTRY_NAME}"
  #   fi
  #   REGISTRY=$(az acr show --resource-group ${PLAYGROUND_NAME} --name ${REGISTRY_NAME} -o json | jq -r '.loginServer')
  # eks
  # elif is_eks ; then
  if is_eks ; then
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
    AWS_REGION=$(aws configure get region)
    REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    printf '%s\n' "Using container registry ${REGISTRY}"
  # local
  else
    REG_NAME="$(yq '.services[] | select(.name=="playground-registry") | .name' $ONEPATH/config.yaml)"
    REG_NAMESPACE="$(yq '.services[] | select(.name=="playground-registry") | .namespace' $ONEPATH/config.yaml)"
    if is_linux ; then
      REG_HOST=$(kubectl --namespace ${REG_NAMESPACE} get svc ${REG_NAME} \
                    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      REG_PORT="$(yq '.services[] | select(.name=="playground-registry") | .port' $ONEPATH/config.yaml)"
    fi
    if is_darwin ; then
      REG_HOST=$(kubectl --namespace ${REG_NAMESPACE} get svc ${REG_NAME} \
                      -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
      REG_PORT="$(yq '.services[] | select(.name=="playground-registry") | .port' $ONEPATH/config.yaml)"
    fi
    REGISTRY="${REG_HOST}:${REG_PORT}"
  fi
}

#######################################
# Retrieves the username, password,
# and url of the registry
# Globals:
#   GCP_HOSTNAME
#   GCP_PROJECTID
#   PLAYGROUND_NAME
#   REGISTRY_NAME
#   REG_NAMESPACE
#   REG_NAME
# Arguments:
#   None
# Outputs:
#   REGISTRY
#   REGISTRY_USERNAME
#   REGISTRY_PASSWORD
#######################################
function get_registry_credentials() {

  get_registry

  # gke
  if is_gke ; then
    GCP_HOSTNAME="gcr.io"
    GCP_PROJECTID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
    printf '%s\n' "GCP Project is ${GCP_PROJECTID}"
    GCR_SERVICE_ACCOUNT=service-gcrsvc
    if test -f "${GCR_SERVICE_ACCOUNT}_keyfile.json"; then
      printf '%s\n' "Using existing key file"
    else
      printf '%s\n' "Creating Service Account"
      echo ${GCR_SERVICE_ACCOUNT}_keyfile.json
      gcloud iam service-accounts create ${GCR_SERVICE_ACCOUNT}
      gcloud projects add-iam-policy-binding ${GCP_PROJECTID} --member "serviceAccount:${GCR_SERVICE_ACCOUNT}@${GCP_PROJECTID}.iam.gserviceaccount.com" --role "roles/storage.admin"
      gcloud iam service-accounts keys create ${GCR_SERVICE_ACCOUNT}_keyfile.json --iam-account ${GCR_SERVICE_ACCOUNT}@${GCP_PROJECTID}.iam.gserviceaccount.com
    fi
    REGISTRY_USERNAME="_json_key"
    REGISTRY_PASSWORD=$(cat ${GCR_SERVICE_ACCOUNT}_keyfile.json | jq tostring)
  # aks
  elif is_aks ; then
    az acr update -n ${REGISTRY} --admin-enabled true 1>/dev/null
    ACR_CREDENTIALS=$(az acr credential show --name ${REGISTRY})
    REGISTRY_USERNAME=$(jq -r '.username' <<< $ACR_CREDENTIALS)
    REGISTRY_PASSWORD=$(jq -r '.passwords[] | select(.name=="password") | .value' <<< $ACR_CREDENTIALS)
  # eks
  elif is_eks ; then
    REGISTRY_USERNAME="AWS"
    REGISTRY_PASSWORD=$(aws ecr get-login-password --region ${AWS_REGION})
  # local
  else
    REGISTRY_USERNAME="$(yq '.services[] | select(.name=="playground-registry") | .username' $ONEPATH/config.yaml)"
    REGISTRY_PASSWORD="$(yq '.services[] | select(.name=="playground-registry") | .password' $ONEPATH/config.yaml)"
  fi
}

#######################################
# Retrieves the current kubernetes
# context if it exists.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Cluster context
#######################################
function check_k8s() {
    if $(kubectl config current-context &>/dev/null); then
        CLUSTER=$(kubectl config current-context)
    else
        CLUSTER="No Cluster"
    fi
}

#######################################
# Checks a returned JSON response if
# there is a message indicating a
# failure.
# Globals:
#   None
# Arguments:
#   $1 JSON
# Outputs:
#   0: if there is no message
#   message: if existant
#######################################
function check_response() {
  CHECK_ERR=$(jq -r '.message' <<< $1)
  if [ "${CHECK_ERR}" == "null" ]; then
    return
  fi
  echo ${CHECK_ERR}
  false
}

#######################################
# Checks the Cloud One API
# Configuration
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   CLUSTER
#######################################
function check_cloudone() {
  API_KEY="$(yq '.services[] | select(.name=="cloudone") | .api_key' $ONEPATH/config.yaml)"
  REGION="$(yq '.services[] | select(.name=="cloudone") | .region' $ONEPATH/config.yaml)"
  INSTANCE="$(yq '.services[] | select(.name=="cloudone") | .instance' $ONEPATH/config.yaml)"
  if [ ${INSTANCE} = null ]; then
    INSTANCE=cloudone
  fi
  
  mkdir -p $ONEPATH/overrides
  
  API_KEY=${API_KEY} envsubst <$ONEPATH/templates/cloudone-header.txt >$ONEPATH/overrides/cloudone-header.txt
  
  local clusters=$(curl --silent --location --request GET 'https://container.'${REGION}'.'${INSTANCE}'.trendmicro.com/api/clusters' \
      --header @$ONEPATH/overrides/cloudone-header.txt)
  if check_response "$clusters" ; then
    return
  fi
  false
}

#######################################
# Retrieves the default editor
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   EDITOR
#######################################
function get_editor() {
  if [ -f $ONEPATH/config.yaml ]; then
    EDITOR="$(yq '.editor' $ONEPATH/config.yaml)"
  fi
  if [ "${EDITOR}" == "" ] || [ "${EDITOR}" == "null" ]; then
    if command -v nano &>/dev/null; then
        EDITOR=nano
    elif command -v vim &>/dev/null; then
        EDITOR=vim
    elif command -v vi &>/dev/null; then
        EDITOR=vi
    else
        echo No editor found. Aborting.
    fi
  fi
  echo Editor: ${EDITOR}
}

function vision_one_map_api_url() {
  case "$1" in
    us-east-1)
      vision_one_api_url=https://api.xdr.trendmicro.com
      ;;
    eu-central-1)
      vision_one_api_url=https://api.eu.xdr.trendmicro.com
      ;;
    ap-south-1)
      vision_one_api_url=https://api.in.xdr.trendmicro.com
      ;;
    ap-southeast-1)
      vision_one_api_url=https://api.sg.xdr.trendmicro.com
      ;;
    ap-southeast-2)
      vision_one_api_url=https://api.au.xdr.trendmicro.com 
      ;;
    ap-northeast-1)
      vision_one_api_url=https://api.xdr.trendmicro.co.jp
      ;;
  esac
}

#######################################
# Get config.yaml
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function get_config() {
  if [ $(yq '.services[] | select(.name=="aws") | .region' ${ONEPATH}/config.yaml) ]; then
    echo Old version of config file detected
  else
    # AWS
    aws_account_id="$(yq '.services.aws.account-id' $ONEPATH/config.yaml)"
    aws_region="$(yq '.services.aws.region' $ONEPATH/config.yaml)"
    aws_pgo_user_enabled="$(yq '.services.aws.pgo_user_enabled' $ONEPATH/config.yaml)"
    aws_pgo_user_access_key="$(yq '.services.aws.pgo_user_access_key' $ONEPATH/config.yaml)"
    aws_pgo_user_secret_key="$(yq '.services.aws.pgo_user_secret_key' $ONEPATH/config.yaml)"
    [[ "${aws_region}" = "null" || "${aws_region}" = "" ]] && aws_region="eu-central-1"
    # AWS Experimental
    [[ "${aws_pgo_user_enabled}" = "null" || "${aws_pgo_user_enabled}" = "" ]] && aws_pgo_user_enabled=false
    [[ "${aws_pgo_user_access_key}" = "null" || "${aws_pgo_user_access_key}" = "" || "${aws_pgo_user_enabled}" = "false" ]] && aws_pgo_user_access_key=""
    [[ "${aws_pgo_user_secret_key}" = "null" || "${aws_pgo_user_secret_key}" = "" || "${aws_pgo_user_enabled}" = "false" ]] && aws_pgo_user_secret_key=""
    # /AWS Experimental

    # Azure
    azure_enabled="$(yq '.services.azure.enabled' $ONEPATH/config.yaml)"
    azure_subscription_id="$(yq '.services.azure.subscription-id' $ONEPATH/config.yaml)"
    azure_region="$(yq '.services.azure.region' $ONEPATH/config.yaml)"
    [[ "${azure_enabled}" = "null" || "${azure_enabled}" = "" ]] && azure_enabled=false
    [[ "${azure_region}" = "null" || "${azure_region}" = "" ]] && azure_region="westeurope"

    # Environment Name
    environment_name="$(yq '.services.environment_name' $ONEPATH/config.yaml)"
    [[ "${environment_name}" = "null" || "${environment_name}" = "" ]] && environment_name="pgo"

    # Initialize Terraform Configurations
    pgo_initialize="$(yq '.services.initialize' $ONEPATH/config.yaml)"
    [[ "${pgo_initialize}" = "null" || "${pgo_initialize}" = "" ]] && pgo_initialize=true

    # Playground One
    pgo_access_ip="$(yq '.services.playground-one.access-ip' $ONEPATH/config.yaml)"
    pgo_px="$(yq '.services.playground-one.px' $ONEPATH/config.yaml)"
    pgo_managed_active_directory="$(yq '.services.aws.managed-active-directory' $ONEPATH/config.yaml)"
    pgo_active_directory="$(yq '.services.aws.active-directory' $ONEPATH/config.yaml)"
    pgo_service_gateway="$(yq '.services.aws.service-gateway' $ONEPATH/config.yaml)"
    pgo_virtual_network_sensor_enabled="$(yq '.services.aws.virtual-network-sensor.enabled' $ONEPATH/config.yaml)"
    pgo_virtual_network_sensor_token="$(yq '.services.aws.virtual-network-sensor.token' $ONEPATH/config.yaml)"
    pgo_ec2_create_linux="$(yq '.services.playground-one.ec2.create-linux' $ONEPATH/config.yaml)"
    pgo_ec2_create_windows="$(yq '.services.playground-one.ec2.create-windows' $ONEPATH/config.yaml)"
    pgo_ec2_create_database="$(yq '.services.playground-one.ec2.create-database' $ONEPATH/config.yaml)"
    pgo_azvm_create_linux="$(yq '.services.playground-one.azvm.create-linux' $ONEPATH/config.yaml)"
    [[ "${pgo_access_ip}" = "null" || "${pgo_access_ip}" = "" ]] && pgo_access_ip=[\"0.0.0.0/0\"]
    [[ "${pgo_px}" = "null" || "${pgo_px}" = "" ]] && pgo_px=false
    [[ "${pgo_managed_active_directory}" = "null" || "${pgo_managed_active_directory}" = "" ]] && pgo_managed_active_directory=false
    [[ "${pgo_active_directory}" = "null" || "${pgo_active_directory}" = "" ]] && pgo_active_directory=false
    [[ "${pgo_service_gateway}" = "null" || "${pgo_service_gateway}" = "" ]] && pgo_service_gateway=false
    [[ "${pgo_virtual_network_sensor_enabled}" = "null" || "${pgo_virtual_network_sensor_enabled}" = "" ]] && pgo_virtual_network_sensor_enabled=false
    [[ "${pgo_virtual_network_sensor_token}" = "null" || "${pgo_virtual_network_sensor_token}" = "" ]] && pgo_virtual_network_sensor_token="token"
    [[ "${pgo_ec2_create_linux}" = "null" || "${pgo_ec2_create_linux}" = "" ]] && pgo_ec2_create_linux=true
    [[ "${pgo_ec2_create_windows}" = "null" || "${pgo_ec2_create_windows}" = "" ]] && pgo_ec2_create_windows=true
    [[ "${pgo_ec2_create_database}" = "null" || "${pgo_ec2_create_database}" = "" ]] && pgo_ec2_create_database=false
    [[ "${pgo_azvm_create_linux}" = "null" || "${pgo_azvm_create_linux}" = "" ]] && pgo_azvm_create_linux=true

    # Vision One
    vision_one_cs_enabled="$(yq '.services.vision-one.container-security.enabled' $ONEPATH/config.yaml)"
    vision_one_api_key="$(yq '.services.vision-one.api-key' $ONEPATH/config.yaml)"
    vision_one_region="$(yq '.services.vision-one.region' $ONEPATH/config.yaml)"
    vision_one_cs_policy="$(yq '.services.vision-one.container-security.policy' $ONEPATH/config.yaml)"
    vision_one_cs_group_id="$(yq '.services.vision-one.container-security.group-id' $ONEPATH/config.yaml)"
    vision_one_asrm_create_attackpath="$(yq '.services.vision-one.asrm.create-attackpath' $ONEPATH/config.yaml)"
    [[ "${vision_one_api_key}" = "null" || "${vision_one_api_key}" = "" ]] && vision_one_api_key="apikey"
    [[ "${vision_one_region}" = "null" || "${vision_one_region}" = "" ]] && vision_one_region="us-east-1"
    [[ "${vision_one_cs_enabled}" = "null" || "${vision_one_cs_enabled}" = "" ]] && vision_one_cs_enabled=false
    [[ "${vision_one_cs_policy}" = "null" || "${vision_one_cs_policy}" = "" ]] && vision_one_cs_policy="LogOnlyPolicy"
    [[ "${vision_one_cs_group_id}" = "null" || "${vision_one_cs_group_id}" = "" ]] && vision_one_cs_group_id="00000000-0000-0000-0000-000000000001"
    [[ "${vision_one_asrm_create_attackpath}" = "null" || "${vision_one_asrm_create_attackpath}" = "" ]] && vision_one_asrm_create_attackpath=false
    vision_one_map_api_url ${vision_one_region}

    # Deep Security
    deep_security_license="$(yq '.services.deep-security.license' $ONEPATH/config.yaml)"
    deep_security_username="$(yq '.services.deep-security.username' $ONEPATH/config.yaml)"
    deep_security_password="$(yq '.services.deep-security.password' $ONEPATH/config.yaml)"
    deep_security_enabled="$(yq '.services.deep-security.enabled' $ONEPATH/config.yaml)"
    [[ "${deep_security_license}" = "null" || "${deep_security_license}" = "" ]] && deep_security_license=""
    [[ "${deep_security_username}" = "null" || "${deep_security_username}" = "" ]] && deep_security_username="masteradmin"
    [[ "${deep_security_password}" = "null" || "${deep_security_password}" = "" ]] && deep_security_password="trendmicro"
    [[ "${deep_security_enabled}" = "null" || "${deep_security_enabled}" = "" ]] && deep_security_enabled=false

    # # Vision One
    # vision_one_server_tenant_id="$(yq '.services.vision-one.server-workload-protection.tenant-id' $ONEPATH/config.yaml)"
    # vision_one_server_token="$(yq '.services.vision-one.server-workload-protection.token' $ONEPATH/config.yaml)"
    # vision_one_server_policy_id="$(yq '.services.vision-one.server-workload-protection.policy-id' $ONEPATH/config.yaml)"
    # [[ "${vision_one_server_tenant_id}" = "null" ]] && vision_one_server_tenant_id=""
    # [[ "${vision_one_server_token}" = "null" ]] && vision_one_server_token=""
    # [[ "${vision_one_server_policy_id}" = "null" ]] && vision_one_server_policy_id=0

    # Integrations
    integrations_calico_enabled="$(yq '.services.integrations.calico.enabled' $ONEPATH/config.yaml)"
    integrations_prometheus_enabled="$(yq '.services.integrations.prometheus.enabled' $ONEPATH/config.yaml)"
    integrations_prometheus_grafana_password="$(yq '.services.integrations.prometheus.grafana-password' $ONEPATH/config.yaml)"
    integrations_trivy_enabled="$(yq '.services.integrations.trivy.enabled' $ONEPATH/config.yaml)"
    integrations_istio_enabled="$(yq '.services.integrations.istio.enabled' $ONEPATH/config.yaml)"
    integrations_metallb_enabled="$(yq '.services.integrations.metallb.enabled' $ONEPATH/config.yaml)"
    [[ "${integrations_calico_enabled}" = "null" || "${integrations_calico_enabled}" = "" ]] && integrations_calico_enabled=false
    [[ "${integrations_prometheus_enabled}" = "null" || "${integrations_prometheus_enabled}" = "" ]] && integrations_prometheus_enabled=false
    [[ "${integrations_prometheus_grafana_password}" = "null" || "${integrations_prometheus_grafana_password}" = "" ]] && integrations_prometheus_grafana_password="playground"
    [[ "${integrations_trivy_enabled}" = "null" || "${integrations_trivy_enabled}" = "" ]] && integrations_trivy_enabled=false
    [[ "${integrations_istio_enabled}" = "null" || "${integrations_istio_enabled}" = "" ]] && integrations_istio_enabled=false
    [[ "${integrations_metallb_enabled}" = "null" || "${integrations_metallb_enabled}" = "" ]] && integrations_metallb_enabled=false
  fi

  return 0
}

function telemetry() {

  api_url=https://telemetry.collectingphotons.space/v1

  telemetry_action=$1
  telemetry_configuration=$2

  if is_darwin; then
    unix_timestamp=$(date -u +%s)
    account_id_hash=$(echo -n ${aws_account_id} | shasum -a 256 | cut -d " " -f1)
  else
    unix_timestamp=$(date --utc +%s)
    account_id_hash=$(echo -n ${aws_account_id} | sha256sum | cut -d " " -f1)
  fi
  curl -X POST "${api_url}/telemetry" \
    -H 'Content-Type: application/json' \
    -d '
  {
      "exec_time": "'${unix_timestamp}'",
      "account_id": "'${account_id_hash}'",
      "environment": "'${environment_name}'",
      "region": "'${aws_region}'",
      "action": "'${telemetry_action}'",
      "configuration": "'${telemetry_configuration}'",
      "config_ec2_linux": "'${pgo_ec2_create_linux}'",
      "config_ec2_windows": "'${pgo_ec2_create_windows}'",
      "config_ecs_ec2": "'${pgo_ecs_create_ec2}'",
      "config_ecs_fargate": "'${pgo_ecs_create_fargate}'",
      "integrations_eks_calico": "'${integrations_calico_enabled}'",
      "integrations_eks_prometheus": "'${integrations_prometheus_enabled}'",
      "integrations_eks_trivy": "'${integrations_trivy_enabled}'"
  }
      '
}
