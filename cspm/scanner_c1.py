#!/usr/bin/env python3
import argparse
import json
import os
import os.path
import sys
import logging
import requests
import textwrap
from datetime import datetime, timedelta, UTC
from pprint import pprint as pp

DOCUMENTATION = """
---
module: scanner_c1.py

short_description: Implements for following functionality:
    - Create Terrafrom Plan of Configuration and run Conformity Template Scan
    - Create Terraform Apply of Configuration
    - Create Terraform Destroy of Configuration
    - Create exceptions in Scan Profile based on Tags assigned to the resource
    - Remove Exceptions in Scan Profile
    - Suppress Findings in Account Profile

description:
    - Implements the required functionality for Template Scan, Exception
      approval workflows and temporary suppression of findings in Conformity
      Account Profile.

requirements:
    - Set environment variable C1CSPM_SCANNER_KEY with the API key of the
      Conformity Scanner owning Full Access to the Conformity Account.
    - Adapt the following constants to your requirements below:
        REGION = "trend-us-1"
        SCAN_PROFILE_ID = "Tc0NcdFKU"
        ACCOUNT_ID = "ed68602b-0eb1-4cbb-ad0b-64676877fadf"
        RISK_LEVEL_FAIL = "MEDIUM"

options:
    --configuration     Terraform Configuration location
    --apply             Apply Terraform Configuration specified with
                        --configuration.
    --destroy           Destroy Terraform Configuration specified with
                        --configuration.
    --exclude           Create Exceptions in Scan Profile when scanning the
                        Terraform Configuration specified with --configuration.
    --suppress          Suppress Findings in Account Profile for the scan 
                        findings for the duration of 1 week.
    --clear             Removes Exceptions from Scan Profile.

author:
    - Markus Winkler (markus_winkler@trendmicro.com)
"""

EXAMPLES = """
# Run template scan
$ ./scanner_c1.py --scan ../awsone/7-scenarios-cspm

# run approval workflows in engine, here implementing the approved workflow
$ ./scanner_c1.py --exclude ../awsone/7-scenarios-cspm

# apply configuration
$ ./scanner_c1.py --apply ../awsone/7-scenarios-cspm

# trigger bot run
$ ./scanner_c1.py --bot

# suppress findings
$ ./scanner_c1.py --suppress

# trigger bot run
$ ./scanner_c1.py --bot
"""

RETURN = """
None
"""


_LOGGER = logging.getLogger(__name__)
logging.basicConfig(
    stream=sys.stdout,
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)s (%(threadName)s) [%(funcName)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logging.getLogger("requests").setLevel(logging.WARNING)
logging.getLogger("urllib3").setLevel(logging.WARNING)

RISK_LEVEL = ["LOW", "MEDIUM", "HIGH", "CRITICAL"]

REGION = "trend-us-1"  # Adapt when needed
API_KEY = os.environ["C1CSPM_SCANNER_KEY"]
API_BASE_URL = f"https://conformity.{REGION}.cloudone.trendmicro.com/api"
SCAN_PROFILE_ID = "Tc0NcdFKU"  # Adapt when needed
ACCOUNT_ID = "ed68602b-0eb1-4cbb-ad0b-64676877fadf"  # Adapt when needed
RISK_LEVEL_FAIL = "MEDIUM"  # Adapt when needed


# #############################################################################
# Terraform functions
# #############################################################################
def terraform_plan(working_dir) -> str:
    """Create Terraform Plan of Configuration."""

    _LOGGER.info("Plan Terraform Configuration...")

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

    _LOGGER.info("Apply Terraform Configuration...")

    os.system(f"terraform -chdir={working_dir} apply -auto-approve")
    os.system("cp scan_result.json scan_result_applied.json")

    print()

    return None


def terraform_destroy(working_dir) -> None:
    """Destroy Terraform Plan of Configuration."""

    _LOGGER.info("Destroy Terraform Configuration...")

    os.system(f"terraform -chdir={working_dir} destroy -auto-approve")

    print()

    return None


# #############################################################################
# Scan template
# #############################################################################
def scan_template(contents) -> str:
    """Initiate Conformity Template Scan."""

    _LOGGER.info("Starting Template Scan...")

    url = f"{API_BASE_URL}/template-scanner/scan"

    headers = {"Authorization": f"ApiKey {API_KEY}", "Content-Type": "application/vnd.api+json"}

    data = {"data": {"attributes": {"profileId": SCAN_PROFILE_ID, "type": "terraform-template", "contents": contents}}}

    response = requests.post(url, data=json.dumps(data), headers=headers, verify=True, timeout=30).json()

    # Error handling
    if "message" in response:
        if response["message"] == "User is not authorized to access this resource with an explicit deny":
            raise ValueError("Invalid API Key")

    with open("scan_result.json", "w", encoding="utf-8") as scan_result:
        json.dump(response, scan_result, indent=2)

    _LOGGER.info("Template Scan done.")

    return response


# #############################################################################
# Scan account
# #############################################################################
def scan_account() -> str:
    """Initiate Conformity Account Scan."""

    _LOGGER.info("Starting Account Scan...")

    url = f"{API_BASE_URL}/accounts/{ACCOUNT_ID}/scan"

    headers = {"Authorization": f"ApiKey {API_KEY}", "Content-Type": "application/vnd.api+json"}

    data = {}

    response = requests.post(url, data=json.dumps(data), headers=headers, verify=True, timeout=30).json()

    # Error handling
    if "message" in response:
        if response["message"] == "User is not authorized to access this resource with an explicit deny":
            raise ValueError("Invalid API Key")

    _LOGGER.info("Account Scan initiated.")

    return response


# #############################################################################
# Handle scan failures in scan profile
# #############################################################################
def scan_failures(contents, exclude=False) -> None:
    """Parse scan result for failures and set exceptions."""

    for finding in contents.get("data", []):

        if finding["attributes"]["status"] == "FAILURE":
            risk_level = finding.get("attributes", {}).get("risk-level", None)

            if RISK_LEVEL.index(risk_level) < RISK_LEVEL.index(RISK_LEVEL_FAIL):
                continue

            rule_title = finding.get("attributes", {}).get("rule-title", None)
            tags = finding.get("attributes", {}).get("tags", {})
            rule_id = finding.get("relationships", {}).get("rule", {}).get("data", {}).get("id", None)

            if exclude:
                _LOGGER.info(
                    "Setting Exception for rule %s with Risk Level %s, Rule Title: %s", rule_id, risk_level, rule_title
                )
                set_exception(rule_id, risk_level, tags)
            else:
                _LOGGER.info(
                    "Skipping Exception for rule %s with Risk Level %s, Rule Title: %s", rule_id, risk_level, rule_title
                )


def rule_tags_set(rule_id) -> str:
    """Retrive tags in exception"""

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}?includes=ruleSettings"

    headers = {"Content-Type": "application/vnd.api+json", "Authorization": f"ApiKey {API_KEY}"}

    response = requests.get(url, headers=headers, verify=True, timeout=30).json()

    for rule in response.get("included", []):
        if rule["id"] == rule_id:
            return rule.get("attributes", {}).get("exceptions", {}).get("filterTags", [])
    return []


def set_exception(rule_id, risk_level, tags):
    """Set Rule Exception in Profile."""

    existing_tags = rule_tags_set(rule_id)
    tags = existing_tags + list(set(tags) - set(existing_tags))

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}"

    headers = {"Content-Type": "application/vnd.api+json", "Authorization": f"ApiKey {API_KEY}"}

    data = {
        "included": [
            {
                "type": "rules",
                "id": rule_id,
                "attributes": {
                    "enabled": True,
                    "exceptions": {"tags": [], "filterTags": tags, "resources": []},
                    "extraSettings": [],
                    "riskLevel": risk_level,
                    "provider": "aws",
                },
            }
        ],
        "data": {
            "type": "profiles",
            "id": SCAN_PROFILE_ID,
            "attributes": {"name": "AWS Scanner", "description": "Scan exclusions"},
            "relationships": {"ruleSettings": {"data": [{"type": "rules", "id": rule_id}]}},
        },
    }

    response = requests.patch(url, data=json.dumps(data), headers=headers, verify=True, timeout=30).json()

    # Error handling
    if "message" in response:
        if response["message"] == "User is not authorized to access this resource with an explicit deny":
            raise ValueError("Invalid API Key")

    _LOGGER.info("Exception for %s in Profile %s set for Tags %s", rule_id, SCAN_PROFILE_ID, tags)


def clear_exceptions():
    """Remove all exceptions from profile."""

    # TODO: How to completely remove a rule setting?

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}?includes=ruleSettings"

    headers = {"Content-Type": "application/vnd.api+json", "Authorization": f"ApiKey {API_KEY}"}

    response = requests.get(url, headers=headers, verify=True, timeout=30).json()

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}"

    for rule in response.get("included", []):

        rule_id = rule.get("id", None)
        risk_level = rule.get("attributes", []).get("riskLevel", None)

        _LOGGER.info("Removing Exception for %s in Profile %s", rule_id, SCAN_PROFILE_ID)

        data = {
            "included": [
                {
                    "type": "rules",
                    "id": rule_id,
                    "attributes": {
                        "enabled": True,
                        "exceptions": {"tags": [], "filterTags": [], "resources": []},
                        "extraSettings": [],
                        "riskLevel": risk_level,
                        "provider": "aws",
                    },
                }
            ],
            "data": {
                "type": "profiles",
                "id": SCAN_PROFILE_ID,
                "attributes": {"name": "AWS Scanner", "description": "Scan exclusions"},
                "relationships": {"ruleSettings": {"data": [{"type": "rules", "id": rule_id}]}},
            },
        }

        response = requests.patch(url, data=json.dumps(data), headers=headers, verify=True, timeout=30).json()
        # pp(response)

        # Error handling
        if "message" in response:
            if response["message"] == "User is not authorized to access this resource with an explicit deny":
                raise ValueError("Invalid API Key")

        _LOGGER.info("Scan Exceptions in Profile %s for rule %s removed", SCAN_PROFILE_ID, rule_id)


# #############################################################################
# Suppress findings in AWS Account
# #############################################################################
def retrieve_bot_results():
    """Retrieve Bot results from AWS Account"""

    page_size = 10
    page_number = 0
    service_names = ""
    created_less_than_days = 5
    risk_levels = ";".join(RISK_LEVEL[RISK_LEVEL.index(RISK_LEVEL_FAIL):])
    compliances = ""  # "AWAF"

    findings = []
    while True:
        url = f"{API_BASE_URL}/checks"
        url += f"?accountIds={ACCOUNT_ID}"
        url += f"&page[size]={page_size}"
        url += f"&page[number]={page_number}"
        url += f"&filter[services]={service_names}"
        url += f"&filter[createdLessThanDays]={created_less_than_days}"
        url += f"&filter[riskLevels]={risk_levels}"
        url += f"&filter[compliances]={compliances}"
        url += "&filter[statuses]=FAILURE"
        url += "&consistentPagination=true"

        headers = {"Content-Type": "application/vnd.api+json", "Authorization": f"ApiKey {API_KEY}"}

        response = requests.get(url, headers=headers, verify=True, timeout=30).json()

        additional_findings = response.get("data", [])
        findings += additional_findings

        total = response.get("meta", {}).get("total", 0)
        if (page_number * page_size) >= total:
            break
        page_number += 1

        _LOGGER.debug("Retrieved %s of %s findings", len(findings), total)

    # pp(findings)

    return findings


def match_scan_result_with_findings(bot_findings):
    """Match Scan Results with Findings."""

    with open("scan_result_applied.json", "r", encoding="utf-8") as json_file:
        scan_results = json.load(json_file)

    _LOGGER.info("Analysing %s Bot findings", len(bot_findings))
    for scan_result in scan_results.get("data", []):

        if scan_result.get("attributes", {}).get("status") == "FAILURE":
            scan_rule_id = scan_result.get("relationships", {}).get("rule", {}).get("data", {}).get("id", None)
            scan_tags = scan_result.get("attributes", {}).get("tags", {})

            for bot_finding in bot_findings:

                if bot_finding.get("relationships", {}).get("rule", {}).get("data", {}).get("id", None) == scan_rule_id:
                    _LOGGER.info("Bot finding match %s", scan_rule_id)

                    if set(scan_tags).issubset(set(bot_finding.get("attributes", {}).get("tags", {}))):
                        suppress_check(bot_finding.get("id", None))
                        continue
                    else:
                        _LOGGER.info("Scan tags %s", format(scan_tags))


def suppress_check(check_id) -> None:
    """Suppress Check."""

    now = datetime.now(UTC).replace(tzinfo=None)
    suppress_until = int((now + timedelta(days=7)).timestamp() * 1000)

    _LOGGER.info("Setting Suppression for Check %s", format(check_id))

    url = f"{API_BASE_URL}/checks/{check_id}"
    data = {
        "data": {"type": "checks", "attributes": {"suppressed": True, "suppressed-until": suppress_until}},
        "meta": {"note": "suppressed for 1 week, failure not-applicable"},
    }

    headers = {"Content-Type": "application/vnd.api+json", "Authorization": f"ApiKey {API_KEY}"}

    response = requests.patch(url, data=json.dumps(data), headers=headers, verify=True, timeout=30).json()

    # Error handling
    if "message" in response:
        if response["message"] == "User is not authorized to access this resource with an explicit deny":
            raise ValueError("Invalid API Key")

    _LOGGER.info("Check %s suppressed", check_id)


# #############################################################################
# Main
# #############################################################################
def main():
    """Entry point."""
    parser = argparse.ArgumentParser(
        prog="python3 scanner_c1.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Run template scans and handle scan exceptions and suppressions.",
        epilog=textwrap.dedent(
            """\
            Workflow Example:
            --------------------------------
            # Run template scan
            $ ./scanner_c1.py --scan ../awsone/7-scenarios-cspm

            # run approval workflows in engine, here implementing the approved workflow
            $ ./scanner_c1.py --exclude ../awsone/7-scenarios-cspm

            # apply configuration
            $ ./scanner_c1.py --apply ../awsone/7-scenarios-cspm

            # trigger bot run
            $ ./scanner_c1.py --bot

            # suppress findings
            $ ./scanner_c1.py --suppress

            # trigger bot run
            $ ./scanner_c1.py --bot
            """
        ),
    )
    parser.add_argument("--scan", type=str, nargs=1, metavar="CONFIG", help="scan configuration")
    parser.add_argument("--exclude", type=str, nargs=1, metavar="CONFIG", help="scan configuration and exclude findings")
    parser.add_argument("--apply", type=str, nargs=1, metavar="CONFIG", help="apply configuration")
    parser.add_argument("--destroy", type=str, nargs=1, metavar="CONFIG", help="destroy configuration")
    parser.add_argument("--bot", action="store_const", const=True, default=False, help="scan account")
    parser.add_argument("--suppress", action="store_const", const=True, default=False, help="suppress findings")
    parser.add_argument("--clear", action="store_const", const=True, default=False, help="clear exceptions")
    args = parser.parse_args()

    if args.scan:
        _LOGGER.info("Scan configuration %s", args.scan[0])
        plan = terraform_plan(args.scan[0])
        scan_result = scan_template(plan)
        scan_failures(scan_result, False)

    if args.exclude:
        _LOGGER.info("Scan configuration %s and exclude findings", args.exclude[0])
        plan = terraform_plan(args.exclude[0])
        scan_result = scan_template(plan)
        scan_failures(scan_result, True)

    if args.apply:
        _LOGGER.info("Apply configuration %s", args.apply[0])
        terraform_apply(args.apply[0])

    if args.destroy:
        _LOGGER.info("Destroy configuration %s", args.destroy[0])
        terraform_destroy(args.destroy[0])

    if args.bot:
        _LOGGER.debug("Scan account")
        scan_account()

    if args.suppress:
        _LOGGER.debug("Suppression enabled")
        bot_findings = retrieve_bot_results()
        match_scan_result_with_findings(bot_findings)

    if args.clear:
        _LOGGER.debug("Clear enabled")
        clear_exceptions()


if __name__ == "__main__":
    main()
