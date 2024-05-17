#!/bin/bash

# Path to template file
file_path="plan.json"

# Region in which Vision One Conformity serves your organisation
# For us-east-1 leave it as "", EU would be ".eu"
region=""

# IaC code in
iac=7-scenarios-cspm
# profile_id=qTyEiufy6

# Conformity API Key
api_key=${V1CSPM_SCANNER_KEY}
api_base_url="https://api${region}.xdr.trendmicro.com"

# Finding threshold to fail
# THRESHOLD=any
# THRESHOLD=critical
THRESHOLD=high
# THRESHOLD=medium
# THRESHOLD=low

rm -f ${file_path}

# Create template
cd ${iac}
terraform init
# terraform plan -var="account_id=${AWS_ACCOUNT_ID}" -var="aws_region=${AWS_REGION}" -out=plan.out
terraform plan -out=plan.out
terraform show -json plan.out > ../${file_path}
rm -f plan.out
cd ..

# Create scan payload
contents=$(cat ${file_path} | jq '.' -MRs)
payload='{
           "type": "terraform-template",
           "content": '${contents}'
         }'
printf '%s' ${payload} > data.txt

# # Scan template
curl -s -X POST \
     -H "Authorization: Bearer ${api_key}" \
     -H "Content-Type: application/json" \
     ${api_base_url}/beta/cloudPosture/scanTemplate \
     --data-binary "@data.txt" > result.json

cp result.json result_v1.json

# Extract findings risk-level
risk_levels=$(cat result.json | jq -r '.scanResults[] | select(.status == "FAILURE") | .riskLevel')

fail=0
[ "${THRESHOLD}" = "any" ] && \
  [ ! -z "${risk_levels}" ] && fail=1

[ "${THRESHOLD}" = "critical" ] && \
  [[ ${risk_levels} == *CRITICAL* ]] && fail=2

[ "${THRESHOLD}" = "high" ] && \
  ([[ ${risk_levels} == *CRITICAL* ]] || [[ ${risk_levels} == *HIGH* ]]) && fail=3

[ "${THRESHOLD}" = "medium" ] && \
  ([[ ${risk_levels} == *CRITICAL* ]] || [[ ${risk_levels} == *HIGH* ]] || [[ ${risk_levels} == *MEDIUM* ]]) && fail=4

[ "${THRESHOLD}" = "low" ] && \
  ([[ ${risk_levels} == *CRITICAL* ]] || [[ ${risk_levels} == *HIGH* ]] || [[ ${risk_levels} == *MEDIUM* ]] || [[ ${risk_levels} == *LOW* ]]) && fail=5

[ $fail -ne 0 ] && echo !!! Threshold exceeded !!! > exceeded || true

echo ${fail}

rm -f data.txt
