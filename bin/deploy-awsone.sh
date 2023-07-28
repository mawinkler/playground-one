#!/bin/bash

set -e

# Source helpers
.  $ONEPATH/bin/playground-helpers.sh

# Get config
# AWS
AWS_ACCOUNT_ID="$(yq '.services[] | select(.name=="aws") | .account_id' $ONEPATH/config.yaml)"
AWS_REGION="$(yq '.services[] | select(.name=="aws") | .region' $ONEPATH/config.yaml)"
AWS_ENVIRONMENT="$(yq '.services[] | select(.name=="aws") | .environment' $ONEPATH/config.yaml)"

# AWS One
ACCESS_IP="$(yq '.services[] | select(.name=="awsone") | .access_ip' $ONEPATH/config.yaml)"

# Instances
INSTANCES_CREATE_LINUX="$(yq '.services[] | select(.name=="awsone") | .instances.create_linux' $ONEPATH/config.yaml)"
INSTANCES_CREATE_WINDOWS="$(yq '.services[] | select(.name=="awsone") | .instances.create_windows' $ONEPATH/config.yaml)"

# Cluster EKS
EKS_CREATE_FARGATE_PROFILE="$(yq '.services[] | select(.name=="awsone") | .cluster-eks.create_fargate_profile' $ONEPATH/config.yaml)"

CLOUD_ONE_API_KEY="$(yq '.services[] | select(.name=="cloudone") | .api_key' $ONEPATH/config.yaml)"
CLOUD_ONE_REGION="$(yq '.services[] | select(.name=="cloudone") | .region' $ONEPATH/config.yaml)"
CLOUD_ONE_INSTANCE="$(yq '.services[] | select(.name=="cloudone") | .instance' $ONEPATH/config.yaml)"
[[ "${CLOUD_ONE_REGION}" = "null" ]] && CLOUD_ONE_REGION="trend-us-1"
[[ "${CLOUD_ONE_INSTANCE}" = "null" ]] && CLOUD_ONE_INSTANCE="cloudone"

# Workload Security
WS_TENANTID="$(yq '.services[] | select(.name=="workload-security") | .ws_tenant_id' $ONEPATH/config.yaml)"
WS_TOKEN="$(yq '.services[] | select(.name=="workload-security") | .ws_token' $ONEPATH/config.yaml)"
WS_POLICY="$(yq '.services[] | select(.name=="workload-security") | .ws_policy_id' $ONEPATH/config.yaml)"
[[ "${WS_TENANTID}" = "null" ]] && WS_TENANTID=""
[[ "${WS_TOKEN}" = "null" ]] && WS_TOKEN=""
[[ "${WS_POLICY}" = "null" ]] && WS_POLICY=0

# Container Security
CLOUD_ONE_POLICY_ID="$(yq '.services[] | select(.name=="container_security") | .policy_id' $ONEPATH/config.yaml)"
[[ "${CLOUD_ONE_POLICY_ID}" = "null" ]] && CLOUD_ONE_POLICY_ID=""

#######################################
# Create Terraform variables.tfvars
# Globals:
#   AWS_ACCOUNT_ID
#   AWSONE_WINDOWS_PASSWORD
# Arguments:
#   None
# Outputs:
#   None
#######################################
function create_tf_variables() {

  printf '%s\n' "Create terraform.tfvars for network"
  AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} \
  AWS_REGION=${AWS_REGION} \
  AWS_ENVIRONMENT=${AWS_ENVIRONMENT} \
  ACCESS_IP=${ACCESS_IP} \
    envsubst <$ONEPATH/templates/terraform-2-network.tfvars >$ONEPATH/awsone/2-network/terraform.tfvars

  printf '%s\n' "Create terraform.tfvars for instances"
  AWS_REGION=${AWS_REGION} \
  ACCESS_IP=${ACCESS_IP} \
  AWS_ENVIRONMENT=${AWS_ENVIRONMENT} \
  INSTANCES_CREATE_LINUX=${INSTANCES_CREATE_LINUX} \
  INSTANCES_CREATE_WINDOWS=${INSTANCES_CREATE_WINDOWS} \
    envsubst <$ONEPATH/templates/terraform-3-instances.tfvars >$ONEPATH/awsone/3-instances/terraform.tfvars

  printf '%s\n' "Create terraform.tfvars for cluster-eks"
  AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} \
  AWS_REGION=${AWS_REGION} \
  AWS_ENVIRONMENT=${AWS_ENVIRONMENT} \
  ACCESS_IP=${ACCESS_IP} \
  EKS_CREATE_FARGATE_PROFILE=${EKS_CREATE_FARGATE_PROFILE} \
    envsubst <$ONEPATH/templates/terraform-4-cluster-eks.tfvars >$ONEPATH/awsone/4-cluster-eks/terraform.tfvars

  printf '%s\n' "Create terraform.tfvars for cluster-ecs"
  AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} \
  AWS_REGION=${AWS_REGION} \
  AWS_ENVIRONMENT=${AWS_ENVIRONMENT} \
  ACCESS_IP=${ACCESS_IP} \
  WS_TENANTID=${WS_TENANTID} \
  WS_TOKEN=${WS_TOKEN} \
  WS_POLICY=${WS_POLICY} \
    envsubst <$ONEPATH/templates/terraform-5-cluster-ecs.tfvars >$ONEPATH/awsone/5-cluster-ecs/terraform.tfvars

  printf '%s\n' "Create terraform.tfvars for cluster-eks deployments"
  AWS_ENVIRONMENT=${AWS_ENVIRONMENT} \
  CLOUD_ONE_API_KEY=${CLOUD_ONE_API_KEY} \
  CLOUD_ONE_REGION=${CLOUD_ONE_REGION} \
  CLOUD_ONE_INSTANCE=${CLOUD_ONE_INSTANCE} \
  CLOUD_ONE_POLICY_ID=${CLOUD_ONE_POLICY_ID} \
    envsubst <$ONEPATH/templates/terraform-8-cluster-eks-deployments.tfvars >$ONEPATH/awsone/8-cluster-eks-deployments/terraform.tfvars

  echo "💬 Terraform terraform.tfvars dropped to configurations"
}

#######################################
# Prepares a AWS based V1 & C1
# demo environment
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
#######################################
function create_environment() {

  cd $ONEPATH/awsone/2-network
}

#######################################
# Main:
# Deploys a AWS based V1 & C1
# demo environment
#######################################
function main() {

  create_tf_variables
  create_environment
}

function cleanup() {
  return
  false
}

function test() {
  return
  false
}

# run main of no arguments given
if [[ $# -eq 0 ]] ; then
  main
fi

printf '\n%s\n' "###TASK-COMPLETED###"
