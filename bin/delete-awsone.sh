#!/bin/bash

set -e

# Source helpers
.  $ONEPATH/bin/playground-helpers.sh

cd $ONEPATH/terraform-awsone
terraform init
terraform destroy -auto-approve

printf '\n%s\n' "###TASK-COMPLETED###"
