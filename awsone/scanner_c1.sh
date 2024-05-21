#!/bin/bash

# Path to template file
file_path="plan.json"

# Region in which Cloud Conformity serves your organisation
region="trend-us-1"

# IaC code in
iac=7-scenarios-cspm
profile_id=Tc0NcdFKU

# Conformity API Key
api_key=${C1CSPM_SCANNER_KEY}
api_base_url="https://conformity.${region}.cloudone.trendmicro.com/api"

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
           "data": {
             "attributes": {
               "profileId": '${profile_id}',
               "type": "terraform-template",
               "contents": '${contents}'
              }
            }
          }'
printf '%s' ${payload} > data.txt

# Scan template
curl -s -X POST \
     -H "Authorization: ApiKey ${api_key}" \
     -H "Content-Type: application/vnd.api+json" \
     ${api_base_url}/template-scanner/scan \
     --data-binary "@data.txt" > result.json

cp result.json result_c1.json

# Extract findings risk-level
risk_levels=$(cat result.json | jq -r '.data[] | select(.attributes.status == "FAILURE") | .attributes."risk-level"')

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

# risk_levels_high=$(cat result.json | jq -r '
#   .data[] |
#     select((.attributes.status == "FAILURE") and (.attributes."risk-level" == "HIGH")) |
#       (.attributes * .relationships.rule.data | 
#         {"risk-level", "rule-title", "tags", "id"})
# ')

# echo $risk_levels_high

rm -f data.txt
