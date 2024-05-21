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
from datetime import datetime, timedelta, UTC
from pprint import pprint as pp
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
scan_profile_id = "Tc0NcdFKU"
account_id = "ed68602b-0eb1-4cbb-ad0b-64676877fadf"
risk_level_fail = "MEDIUM"


def terraform_plan(working_dir) -> str:
    """Create Terraform Plan of Configuration."""

    print("Plan Terraform Configuration...")

    os.system(f"terraform -chdir={working_dir} init")
    os.system(f"terraform -chdir={working_dir} plan -out=plan.out")
    os.system(f"terraform -chdir={working_dir} show -json plan.out > plan.json")
    os.system(f"rm {working_dir}/plan.out")

    with open("plan.json", "r", encoding="utf-8") as json_file:
        plan = json_file.read()

    print()

    return plan


def terraform_apply(working_dir) -> None:
    """Apply Terraform Plan of Configuration."""

    print("Apply Terraform Configuration...")

    os.system(f"terraform -chdir={working_dir} apply -auto-approve")

    print()

    return None


def terraform_destroy(working_dir) -> None:
    """Destroy Terraform Plan of Configuration."""

    print("Destroy Terraform Configuration...")

    os.system(f"terraform -chdir={working_dir} destroy -auto-approve")

    print()

    return None


def scan_template(contents) -> str:
    """Initiate Conformity Template Scan."""

    print("Starting Template Scan...")

    url = f"{api_base_url}/template-scanner/scan"
    data = {
        "data": {
            "attributes": {
                "profileId": scan_profile_id,
                "type": "terraform-template",
                "contents": contents
            }
        }
    }
    headers = {
        "Authorization": f"ApiKey {api_key}",
        "Content-Type": "application/vnd.api+json"
    }
    
    response = requests.post(
        url, data=json.dumps(data), headers=headers, verify=True, timeout=30
    ).json()

    # Error handling
    if "message" in response:
        if response["message"] == "User is not authorized to access this resource with an explicit deny":
            raise ValueError("Invalid API Key")

    with open("scan_result.json", "w", encoding="utf-8") as scan_result:
        json.dump(response, scan_result, indent=2)

    print("Template Scan done.")
    
    return response


def scan_failures(contents, exclude=False) -> None:
    """Parse scan result for failures and set exceptions."""

    for finding in contents.get("data", []):
        if finding["attributes"]["status"] == "FAILURE":
            risk_level = finding.get("attributes", {}).get("risk-level", None)
            if RISK_LEVEL.index(risk_level) < RISK_LEVEL.index(risk_level_fail):
                continue
            rule_title = finding.get("attributes", {}).get("rule-title", None)
            tags = finding.get("attributes", {}).get("tags", {})
            rule_id = finding.get("relationships", {}).get("rule", {}).get("data", {}).get("id", None)

            if exclude:
                print(f"Setting Exception for rule {rule_id} with Risk Level {risk_level}, Rule Title: {rule_title}")
                set_exception(rule_id, risk_level, tags)
            else:
                print(f"Skipping Exception for rule {rule_id} with Risk Level {risk_level}, Rule Title: {rule_title}")


def rule_tags_set(rule_id) -> str:
    """Retrive tags in exception"""
    
    url = f"{api_base_url}/profiles/{scan_profile_id}?includes=ruleSettings"
    headers = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"ApiKey {api_key}"
    }

    response = requests.get(
        url, headers=headers, verify=True, timeout=30
    ).json()

    for rule in response.get("included", []):
        if rule["id"] == rule_id:
            return (rule.get("attributes", {}).get("exceptions", {}).get("filterTags", []))
    return []


def set_exception(rule_id, risk_level, tags):
    """Set Rule Exception in Profile."""

    existing_tags = rule_tags_set(rule_id)
    tags = existing_tags + list(set(tags) - set(existing_tags))

    url = f"{api_base_url}/profiles/{scan_profile_id}"
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
            "id": scan_profile_id,
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

    headers = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"ApiKey {api_key}"
    }

    response = requests.patch(
        url, data=json.dumps(data), headers=headers, verify=True, timeout=30
    ).json()

    # Error handling
    if "message" in response:
        if response["message"] == "User is not authorized to access this resource with an explicit deny":
            raise ValueError("Invalid API Key")

    print(f"Exception for {rule_id} in Profile {scan_profile_id} set for Tags {tags}")


def retrieve_bot_results():
    """Retrieve Bot results from AWS Account"""

    page_size = 5
    page_number = 0
    service_names = ""
    created_less_than_days = 5
    risk_levels = ';'.join(RISK_LEVEL[RISK_LEVEL.index(risk_level_fail):])
    compliances = ""  #"AWAF"

    findings = []
    while True:
        url = f"{api_base_url}/checks"
        url += f"?accountIds={account_id}"
        url += f"&page[size]={page_size}"
        url += f"&page[number]={page_number}"
        url += f"&filter[services]={service_names}"
        url += f"&filter[createdLessThanDays]={created_less_than_days}"
        url += f"&filter[riskLevels]={risk_levels}"
        url += f"&filter[compliances]={compliances}"
        url += "&filter[statuses]=FAILURE"
        url += "&consistentPagination=true"

        headers = {
            "Content-Type": "application/vnd.api+json",
            "Authorization": f"ApiKey {api_key}"
        }

        response = requests.get(
            url, headers=headers, verify=True, timeout=30
        ).json()

        additional_findings = response.get("data", [])
        findings += additional_findings
        
        total = response.get("meta", {}).get("total", 0)
        if (page_number * page_size) >= total:
            break
        page_number += 1
        print(f"Retrieved {len(findings)} of {total} findings")

    # pp(findings)
    
    return findings


def match_scan_result_with_findings(bot_findings):
    """Match Scan Results with Findings."""

    with open("scan_result.json", "r", encoding="utf-8") as json_file:
        scan_results = json.load(json_file)

    for scan_result in scan_results.get("data", []):
        if scan_result.get("attributes", {}).get("status") == "FAILURE":
            scan_rule_id = scan_result.get("relationships", {}).get("rule", {}).get("data", {}).get("id", None)
            scan_tags = scan_result.get("attributes", {}).get("tags", {})
            for bot_finding in bot_findings:
                if bot_finding.get("relationships", {}).get("rule", {}).get("data", {}).get("id", None) == scan_rule_id:
                    if set(bot_finding.get("attributes", {}).get("tags", {})) == set(scan_tags):
                        suppress_check(bot_finding.get("id", None))
                        continue


def suppress_check(check_id) -> None:
    """Suppress Check."""

    now = datetime.now(UTC).replace(tzinfo=None)
    suppress_until = int((now + timedelta(days=7)).timestamp() * 1000)

    print(f"Setting Suppression for Check {check_id}")

    url = f"{api_base_url}/checks/{check_id}"
    data = {
        "data": {
            "type": "checks",
            "attributes": {
                "suppressed": True,
                "suppressed-until": suppress_until
            }
        },
        "meta": {
            "note": "suppressed for 1 week, failure not-applicable"
        }
    }

    headers = {
        "Content-Type": "application/vnd.api+json",
        "Authorization": f"ApiKey {api_key}"
    }

    # response = requests.patch(
    #     url, data=json.dumps(data), headers=headers, verify=True, timeout=30
    # ).json()

    # # Error handling
    # if "message" in response:
    #     if response["message"] == "User is not authorized to access this resource with an explicit deny":
    #         raise ValueError("Invalid API Key")

    print(f"Check {check_id} suppressed")


def main():
    """Entry point."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--configuration", type=str, help="scan configuration")
    parser.add_argument("--apply", action='store_const', const=True, default=False, help="apply configuration")
    parser.add_argument("--destroy", action='store_const', const=True, default=False, help="destroy configuration")
    parser.add_argument("--suppress", action='store_const', const=True, default=False, help="suppress findings")
    parser.add_argument("--exclude", action='store_const', const=True, default=False, help="exclude findings")
    args = parser.parse_args()

    if args.suppress:
        print("Suppression enabled")
        bot_findings = retrieve_bot_results()
        match_scan_result_with_findings(bot_findings)
    else:
        if args.destroy:
            print("Destroy enabled")
            terraform_destroy(args.configuration)
        else:
            if args.configuration:
                print("Configuration provided")
                plan = terraform_plan(args.configuration)
                scan_result = scan_template(plan)
                scan_failures(scan_result, args.exclude)

            if args.apply:
                print("Apply enabled")
                terraform_apply(args.configuration)


if __name__ == "__main__":
    main()
