#!/usr/bin/env python3
DOCUMENTATION = """
---
module: scanner_c1_exception

short_description: 

description:
    - "TODO"

options:
    --query       cves to handle

author:
    - Markus Winkler (markus_winkler@trendmicro.com)
"""

EXAMPLES = """
TODO
"""

RETURN = """
TODO
"""

# import ssl
import argparse
import json
import os
import os.path
import sys
import logging
import requests
# from python_terraform import Terraform, TerraformCommandError
# ssl._create_default_https_context = ssl._create_unverified_context
# import urllib3

# urllib3.disable_warnings()

_LOGGER = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG,
                    format='%(asctime)s %(levelname)s (%(threadName)s) [%(funcName)s] %(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S')
logging.getLogger("requests").setLevel(logging.WARNING)
logging.getLogger("urllib3").setLevel(logging.WARNING)

RISK_LEVEL = [
    "LOW",
    "MEDIUM",
    "HIGH",
    "CRITICAL"
]

region = "trend-us-1"
api_key = os.environ["C1CSPM_SCANNER_KEY"]
api_base_url = f"https://conformity.{region}.cloudone.trendmicro.com/api"
profile_id = "Tc0NcdFKU"


def terraform_plan(working_dir) -> str:
    """Create Terraform Plan of Configuration."""

    os.system(f"terraform -chdir={working_dir} init")
    os.system(f"terraform -chdir={working_dir} plan -out=plan.out")
    os.system(f"terraform -chdir={working_dir} show -json plan.out > plan.json")
    os.system(f"rm {working_dir}/plan.out")

    with open("plan.json", "r", encoding="utf-8") as json_file:
        plan = json_file.read()

    print()

    return plan


def scan_template(contents) -> str:
    """Initiate Conformity Template Scan."""

    print("Starting Template Scan...")

    url = f"{api_base_url}/template-scanner/scan"
    data = {
        "data": {
            "attributes": {
                "profileId": profile_id,
                "type": "terraform-template",
                "contents": contents
            }
        }
    }
    post_header = {
        "Authorization": f"ApiKey {api_key}",
        "Content-Type": "application/vnd.api+json"
    }
    
    response = requests.post(
        url, data=json.dumps(data), headers=post_header, verify=True, timeout=30
    ).json()

    # Error handling
    if "message" in response:
        if response["message"] == "User is not authorized to access this resource with an explicit deny":
            raise ValueError("Invalid API Key")

    return response


def scan_failures(contents) -> None:
    """Parse scan result for failures and set exceptions."""

    for finding in contents.get("data", []):
        if finding["attributes"]["status"] == "FAILURE":
            risk_level = finding.get("attributes", {}).get("risk-level", None)
            if RISK_LEVEL.index(risk_level) < 1:
                continue
            rule_title = finding.get("attributes", {}).get("rule-title", None)
            tags = finding.get("attributes", {}).get("tags", {})
            rule_id = finding.get("relationships", {}).get("rule", {}).get("data", {}).get("id", None)

            print(f"Setting Exception for rule {rule_id} with Risk Level {risk_level}, Rule Title: {rule_title}")

            set_exception(rule_id, risk_level, tags)


def rule_tags_set(rule_id) -> str:
    """Retrive tags in exception"""
    
    url = f"{api_base_url}/profiles/{profile_id}?includes=ruleSettings"
    get_header = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"ApiKey {api_key}"
    }

    response = requests.get(
        url, headers=get_header, verify=True, timeout=30
    ).json()

    for rule in response.get("included", []):
        if rule["id"] == rule_id:
            return (rule.get("attributes", {}).get("exceptions", {}).get("filterTags", []))
    return []


def set_exception(rule_id, risk_level, tags):
    """Set Rule Exception in Profile."""

    existing_tags = rule_tags_set(rule_id)
    tags = existing_tags + list(set(tags) - set(existing_tags))

    url = f"{api_base_url}/profiles/{profile_id}"
    data = {
        "included": [{
            "type": "rules",
            "id": rule_id,
            "attributes": {
                "enabled": True,
                "exceptions": {
                    "tags": [],
                    "filterTags": tags,
                    "resources": []
                },
                "extraSettings": [],
                "riskLevel": risk_level,
                "provider": "aws"
            }
        }],
        "data": {
            "type": "profiles",
            "id": profile_id,
            "attributes": {
                "name": "AWS Scanner",
                "description": "Scan exclusions"
            },
            "relationships": {
                "ruleSettings": {
                    "data": [{
                        "type": "rules",
                        "id": rule_id
                    }]
                }
            }
        }
    }

    patch_header = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"ApiKey {api_key}"
    }

    response = requests.patch(
        url, data=json.dumps(data), headers=patch_header, verify=True, timeout=30
    ).json()

    # Error handling
    if "message" in response:
        if response["message"] == "User is not authorized to access this resource with an explicit deny":
            raise ValueError("Invalid API Key")

    print(f"Exception for {rule_id} in Profile {profile_id} set for Tags {tags}")


def main():
    """Entry point."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--conf", type=str, help="configuration")
    args = parser.parse_args()

    plan = terraform_plan(args.conf)
    scan_result = scan_template(plan)
    scan_failures(scan_result)


if __name__ == "__main__":
    main()
