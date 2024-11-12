#!/usr/bin/env python3
import argparse
import json
import logging
import os
import os.path
import sys
import textwrap
from datetime import UTC, datetime, timedelta
from pprint import pprint as pp

import requests

DOCUMENTATION = """
---
module: scanner_v1_name.py

short_description: Implements for following functionality:
    - Create Terrafrom Plan of Configuration and run Conformity Template Scan
    - Set Exceptions in Scan Profile based on Name-Tags assigned to the resource
    - Create Terraform Apply of Configuration
    - Create Terraform Destroy of Configuration
    - Remove Exceptions in Scan Profile or reset the Scan Profile
    - Suppress Findings in Account Profile
    - Expire Findings in Account Profile
    - Run Conformity Bot and request status
    - Download latest Report

description:
    - Implements required functionality for Terraform Template Scan, Exception
      approval workflows and temporary suppression of findings in Conformity
      Account Profile.

requirements:
    - Set environment variable V1CSPM_SCANNER_KEY with the API key of the
      Conformity Scanner owning Full Access to Conformity.
    - Adapt the constants in between
      # HERE
      and
      # /HERE
      to your requirements

options:
  -h, --help        show this help message and exit
  --scan CONFIG     scan configuration
  --exclude CONFIG  scan configuration and exclude findings
  --apply CONFIG    apply configuration
  --destroy CONFIG  destroy configuration
  --bot             scan account
  --botstatus       account bot status
  --suppress        suppress findings
  --clear           clear exceptions
  --expire          expire exceptions
  --reset           reset profile
  --report          download latest report

author:
    - Markus Winkler (markus_winkler@trendmicro.com)
"""

EXAMPLES = """
# Run template scan
$ ./scanner_v1_name.py --scan 2-network

# Run approval workflows in engine, here implementing the approved workflow
$ ./scanner_v1_name.py --exclude 2-network

# Run template scan again to verify that the scan result is clean
$ ./scanner_v1_name.py --scan 2-network

# Apply configuration
$ ./scanner_v1_name.py --apply 2-network

# Trigger bot run
$ ./scanner_v1_name.py --bot

# Suppress findings
$ ./scanner_v1_name.py --suppress

# Suppressions are active for 1 week
$ ./scanner_v1_name.py --expire

# Wait for suppressions to expire
$ ./scanner_v1_name.py --expire

# Cleanup
$ ./scanner_v1_name.py --destroy 2-network
$ ./scanner_v1_name.py --reset
$ ./scanner_v1_name.py --expire
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

# HERE
REGION = ""  # Examples: eu. sg.
SCAN_PROFILE_ID = "TQNDl13ix"
ACCOUNT_ID = "e37fe1b7-2b14-4b2c-96a4-db1bb2be8c8b"
SCAN_PROFILE_NAME = "Playground One Template Scanner"
REPORT_TITLE = "Workflow Tests"
RISK_LEVEL_FAIL = "MEDIUM"
# /HERE

# For demoing purposes to quickly expire suppressions.
TIMESHIFT_DAYS = 8

# Do not change
RISK_LEVEL = ["LOW", "MEDIUM", "HIGH", "VERY_HIGH", "EXTREME"]
EXCEPTIONS_FILE = "exceptions.json"
SUPPRESSIONS_FILE = "suppressions.json"
PLAN_FILE = "plan.json"
SCAN_RESULT_FILE = "scan_result.json"
API_KEY = os.environ["V1CSPM_SCANNER_KEY"]
API_BASE_URL = f"https://api.{REGION}xdr.trendmicro.com/beta/cloudPosture"
REQUESTS_TIMEOUTS = (2, 30)
# /Do not change

# Get account and template id
# curl -s --location "https://api.xdr.trendmicro.com/beta/cloudPosture/accounts" \
#      --header 'Content-Type: application/json;charset=utf-8' \
#      --header "Authorization: Bearer ${V1CSPM_SCANNER_KEY}" | \
#      jq -r '.items[] | .id + ": " + .name'


# curl -s --location "https://api.xdr.trendmicro.com/beta/cloudPosture/profiles" \
#      --header 'Content-Type: application/json;charset=utf-8' \
#      --header "Authorization: Bearer ${V1CSPM_SCANNER_KEY}" | \
#      jq -r '.items[] | .id + ": " + .name'


# #############################################################################
# Errors
# #############################################################################
class ConformityError(Exception):
    """Define a base error."""

    pass


class ConformityAuthorizationError(ConformityError):
    """Define an error related to invalid API Permissions."""

    pass


class ConformityValidationError(ConformityError):
    """Define an error related to a validation error from a request."""

    pass


class ConformityNotFoundError(ConformityError):
    """Define an error related to requested information not found."""

    pass


# #############################################################################
# Connector to Conformity
# #############################################################################
class Connector:
    def __init__(self) -> None:
        self._headers = {
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json;charset=utf-8",
        }

    def get(self, url, params=None, filter=None):
        """Send an HTTP GET request to Conformity and check response for errors.

        Args:
            url (str): API Endpoint
        """
        
        headers = self._headers
        if filter is not None:
            headers["TMV1-Filter"] = filter

        response = None
        try:
            response = requests.get(
                url, headers=self._headers, params=params, verify=True, timeout=REQUESTS_TIMEOUTS
            )
            self._check_error(response)
            response.raise_for_status()
        except requests.exceptions.HTTPError as errh:
            _LOGGER.error(errh.args[0])
            raise
        except requests.exceptions.ReadTimeout:
            _LOGGER.error("Time out")
            raise
        except requests.exceptions.ConnectionError:
            _LOGGER.error("Connection error")
            raise
        except requests.exceptions.RequestException:
            _LOGGER.error("Exception request")
            raise

        return response.json()

    def patch(self, url, data):
        """Send an HTTP PATCH request to Conformity and check response for errors.

        Args:
            url (str): API Endpoint
            data (json): PATCH request body.
        """

        response = None
        try:
            response = requests.patch(
                url,
                data=json.dumps(data),
                headers=self._headers,
                verify=True,
                timeout=REQUESTS_TIMEOUTS,
            )
            self._check_error(response)
            response.raise_for_status()
        except requests.exceptions.HTTPError as errh:
            _LOGGER.error(errh.args[0])
            raise
        except requests.exceptions.ReadTimeout:
            _LOGGER.error("Time out")
            raise
        except requests.exceptions.ConnectionError:
            _LOGGER.error("Connection error")
            raise
        except requests.exceptions.RequestException:
            _LOGGER.error("Exception request")
            raise

        if 'application/json' in response.headers.get('Content-Type', '') and len(response.content):
            return response.json()
        else:
            return {}

        # return response.json()

    def post(self, url, data):
        """Send an HTTP POST request to Conformity and check response for errors.

        Args:
            url (str): API Endpoint
            data (json): POST request body.
        """

        response = None
        try:
            response = requests.post(
                url,
                data=json.dumps(data),
                headers=self._headers,
                verify=True,
                timeout=REQUESTS_TIMEOUTS,
            )
            self._check_error(response)
            response.raise_for_status()
        except requests.exceptions.HTTPError as errh:
            _LOGGER.error(errh.args[0])
            raise
        except requests.exceptions.ReadTimeout:
            _LOGGER.error("Time out")
            raise
        except requests.exceptions.ConnectionError:
            _LOGGER.error("Connection error")
            raise
        except requests.exceptions.RequestException:
            _LOGGER.error("Exception request")
            raise
        
        # print(response.status_code)
        # for k, v in response.headers.items():
        #     print(f'{k}: {v}')
        # print('')
        if 'application/json' in response.headers.get('Content-Type', '') and len(response.content):
            return response.json()
        else:
            return {}

        # return response.json()

    @staticmethod
    def _check_error(response: requests.Response):
        """Check response from Conformity for Errors.

        Args:
            response (Response): Response from Conformity to check.
        """

        if not response.ok:
            match response.status_code:
                case 400:
                    print(response.text)
                    raise ConformityError("400 Bad request")
                case 401:
                    raise ConformityAuthorizationError(
                        "401 Unauthorized. The requesting user does not have enough privilege."
                    )
                case 403:
                    raise ConformityAuthorizationError(
                        "403 Forbidden. The requesting user does not have enough privilege."
                    )
                case 404:
                    raise ConformityNotFoundError("404 Not found")
                case 422:
                    raise ConformityValidationError(
                        "500 Unprocessed Entity. Validation error"
                    )
                case 500:
                    raise ConformityError("500 The parsing of the template file failed")
                case 503:
                    raise ConformityError("503 Service unavailable")
                case _:
                    raise ConformityError(response.text)


# #############################################################################
# Terraform functions - migrated
# #############################################################################
def terraform_plan(working_dir) -> str:
    """Create Terraform Plan of Configuration."""

    _LOGGER.info("Plan Terraform Configuration...")

    os.system(f"terraform -chdir={working_dir} init")
    os.system(f"terraform -chdir={working_dir} plan -out=plan.out")
    os.system(f"terraform -chdir={working_dir} show -json plan.out > {PLAN_FILE}")
    os.system(f"rm {working_dir}/plan.out")

    with open(PLAN_FILE, "r", encoding="utf-8") as json_file:
        plan = json_file.read()

    print()

    return plan

def terraform_apply(working_dir) -> None:
    """Apply Terraform Plan of Configuration."""

    _LOGGER.info("Apply Terraform Configuration...")

    os.system(f"terraform -chdir={working_dir} apply -auto-approve")

    print()

    return None

def terraform_destroy(working_dir) -> None:
    """Destroy Terraform Plan of Configuration."""

    _LOGGER.info("Destroy Terraform Configuration...")

    os.system(f"terraform -chdir={working_dir} destroy -auto-approve")

    print()

    return None


# #############################################################################
# Scan template - migrated
# #############################################################################
def scan_template(contents) -> str:
    """Initiate Conformity Template Scan."""

    _LOGGER.info("Starting Template Scan...")

    url = f"{API_BASE_URL}/scanTemplate"

    data = {
        "profileId": SCAN_PROFILE_ID,
        "type": "terraform-template",
        "content": contents,
    }

    response = connector.post(url=url, data=data)

    with open(SCAN_RESULT_FILE, "w", encoding="utf-8") as scan_result:
        json.dump(response, scan_result, indent=2)

    _LOGGER.info("Template Scan done.")

    return response


# #############################################################################
# Scan account - migrated
# #############################################################################
def scan_account() -> None:
    """Initiate Conformity Account Scan."""

    _LOGGER.info("Starting Account Scan...")

    url = f"{API_BASE_URL}/accounts/{ACCOUNT_ID}/scan"

    data = {}

    connector.post(url=url, data=data)

    _LOGGER.info("Account Scan initiated.")


def bot_status_account() -> None:
    """Retrieve Conformity Bot Status."""

    _LOGGER.info("Retrieving Conformity Bot Status...")

    url = f"{API_BASE_URL}/accounts/{ACCOUNT_ID}"

    response = connector.get(url=url)

    bot_status = response.get("scanStatus")

    _LOGGER.info("Account Bot status: %s", bot_status)


# #############################################################################
# Report functions - endpoint not available yet
# #############################################################################
# def download_report() -> None:
#     """Download latest Conformity Report for Account"""

#     url = f"{API_BASE_URL}/reports?accountId={ACCOUNT_ID}"

#     response = connector.get(url=url)

#     download_endpoint = None
#     created_date = 0
#     for report in response.get("data", []):
#         if (
#             report["attributes"]["title"] == REPORT_TITLE
#             and report["attributes"]["created-date"] > created_date
#         ):
#             created_date = report["attributes"]["created-date"]
#             included = report.get("attributes", {}).get("included", {})
#             for include in included:
#                 if include["type"] == "PDF":
#                     download_endpoint = include["report-download-endpoint"]

#     if download_endpoint is None:
#         _LOGGER.info("No report found.")
#         return None

#     response = connector.get(url=download_endpoint)

#     try:
#         response = requests.get(response.get("url"), verify=True, timeout=30)
#         response.raise_for_status()
#     except requests.exceptions.HTTPError as errh:
#         _LOGGER.error(errh.args[0])
#         raise
#     except requests.exceptions.ReadTimeout:
#         _LOGGER.error("Time out")
#         raise
#     except requests.exceptions.ConnectionError:
#         _LOGGER.error("Connection error")
#         raise
#     except requests.exceptions.RequestException:
#         _LOGGER.error("Exception request")
#         raise
#     finally:
#         # Error handling
#         if not response.ok:
#             match response.status_code:
#                 case 500:
#                     raise ConformityError("500 Internal server error")
#                 case 503:
#                     raise ConformityError("503 Service unavailable")
#                 case _:
#                     raise ConformityError(response.text)

#     with open("report.pdf", "wb") as report:
#         report.write(response.content)
#     _LOGGER.info("Report saved to report.pdf.")


# #############################################################################
# Handle scan failures in scan profile
# #############################################################################
def scan_failures(contents, exclude=False) -> None:
    """Parse scan result for failures and set exceptions in exclude == True."""

    for finding in contents.get("scanResults", []):
        if finding["status"] == "FAILURE":
            risk_level = finding.get("riskLevel", None)

            if RISK_LEVEL.index(risk_level) < RISK_LEVEL.index(RISK_LEVEL_FAIL):
                continue

            rule_title = finding.get("ruleTitle", None)
            tags = list(finding.get("tags", {}))
            resource = finding.get("resource", None)
            rule_id = finding.get("ruleId", None)

            if exclude:
                _LOGGER.info(
                    "Setting Exception for rule %s with Risk Level %s, Rule Title: %s for Resource: %s",
                    rule_id,
                    risk_level,
                    rule_title,
                    resource,
                )
                set_exception(rule_id, risk_level, tags)
            else:
                _LOGGER.info(
                    "Finding of rule %s with Risk Level %s, Rule Title: %s for Resource: %s",
                    rule_id,
                    risk_level,
                    rule_title,
                    resource,
                )


def rule_tags_existing(rule_id) -> str:
    """Retrive tags in exception"""

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}?includes=ruleSettings"

    response = connector.get(url=url)

    for rule in response.get("scanRules", []):
        if rule["id"] == rule_id:
            return (
                rule.get("exceptions", {}).get("filterTags", [])
            )
    return []


def set_exception(rule_id, risk_level, tags):
    """Set Rule Exception in Profile."""

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}?includes=ruleSettings"

    # Retrieve current profile
    current_profile = connector.get(url=url)

    exceptions_profile = {}
    if os.path.isfile(EXCEPTIONS_FILE):
        with open(EXCEPTIONS_FILE) as json_file:
            exceptions_profile = json.load(json_file)
            
    # Container for the updated profile
    updated_profile = {
        "name": current_profile.get("name", ""),
        "description": current_profile.get("description", ""),
        "scanRules": [],
    }

    scan_rules = current_profile.get("scanRules", [])
    updated_rules = []
    merged_tags = []
    
    # Check existing scan rules
    for rule in scan_rules:
        if rule.get("id") == rule_id:
            exceptions = rule.get("exceptions", {})
            merged_tags = exceptions.get("filterTags", [])
            for tag in tags:
                if tag not in merged_tags:
                    if tag.startswith("Name::"):
                        merged_tags.append(tag)
            if "exceptions" not in rule:
                rule["exceptions"] = {}
            rule["exceptions"]["filterTags"] = merged_tags
            rule.pop("deprecated", None)
            updated_rules.append(rule)
        else:
            rule.pop("deprecated", None)
            updated_rules.append(rule)

    result = [d for d in updated_rules if d["id"] == rule_id]
    if len(result) == 0:
        merged_tags = []
        for tag in tags:
            if tag not in merged_tags:
                if tag.startswith("Name::"):
                    merged_tags.append(tag)
        rule = { "enabled": True, "exceptions": { "filterTags": merged_tags}, "id": rule_id, "provider": "aws", "riskLevel": risk_level}
        updated_rules.append(rule)

    updated_profile["scanRules"] = updated_rules        


    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}"

    connector.patch(url=url, data=updated_profile)

    # Writing new exceptions file
    exceptions_profile[rule_id] = {
        "scan_profile_id": SCAN_PROFILE_ID,
        "tags": merged_tags,
    }

    with open(EXCEPTIONS_FILE, "w", encoding="utf-8") as json_file:
        json.dump(exceptions_profile, json_file, indent=2)

    _LOGGER.info(
        "Exception for %s in Profile %s set",
        rule_id,
        SCAN_PROFILE_ID,
    )


def clear_exceptions():
    """Remove all exceptions created by this script from profile."""

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}?includes=ruleSettings"

    # Retrieve current profile
    current_profile = connector.get(url=url)

    # Retrieve exceptions set by this script
    exceptions = {}
    if os.path.isfile(EXCEPTIONS_FILE):
        with open(EXCEPTIONS_FILE) as json_file:
            exceptions = json.load(json_file)

    # Container for the updated profile
    updated_profile = {
        "name": current_profile.get("name", ""),
        "description": current_profile.get("description", ""),
        "scanRules": [],
    }

    # Building updated profile
    for rule in current_profile.get("scanRules", []):
        rule_id = rule.get("id", None)
        exception = exceptions.get(rule_id, None)
        if exception is not None:
            rule_exception_filtertags = (
                rule.get("exceptions", {}).get("filterTags", [])
            )
            exception_exception_filtertags = exception.get("tags", [])

            resulting_exception_filtertags = list(
                set(rule_exception_filtertags) - set(exception_exception_filtertags)
            )

            _LOGGER.info(
                "Removing Exception Tags for %s in Profile %s", rule_id, SCAN_PROFILE_ID
            )
            rule["exceptions"]["filterTags"] = (
                resulting_exception_filtertags
            )
            rule.pop("deprecated", None)
            updated_profile["scanRules"].append(rule)
        else:
            _LOGGER.info(
                "Not changing Exception Tags for %s in Profile %s",
                rule_id,
                SCAN_PROFILE_ID,
            )
            updated_profile["scanRules"].append(rule)

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}"

    connector.patch(url=url, data=updated_profile)

    # Clean up exceptions file
    exceptions = {}

    with open(EXCEPTIONS_FILE, "w", encoding="utf-8") as json_file:
        json.dump(exceptions, json_file, indent=2)

    _LOGGER.info(
        "Scan Exceptions updated in Profile %s",
        SCAN_PROFILE_ID,
    )


def remove_expired_exceptions():
    """Remove expired exceptions from profile."""

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}?includes=ruleSettings"

    # Retrieve current profile
    current_profile = connector.get(url=url)

    # Retrieve exceptions set by this script
    exceptions = {}
    if os.path.isfile(EXCEPTIONS_FILE):
        with open(EXCEPTIONS_FILE) as json_file:
            exceptions = json.load(json_file)

    # Retrieve suppressions set by this script
    suppressions = {}
    if os.path.isfile(SUPPRESSIONS_FILE):
        with open(SUPPRESSIONS_FILE) as json_file:
            suppressions = json.load(json_file)

    # Container for the updated profile
    updated_profile = {
        "name": current_profile.get("name", ""),
        "description": current_profile.get("description", ""),
        "scanRules": [],
    }

    updated_exceptions = {}
    updated_suppressions = {}

    # Building updated profile
    # Iterating over customized rules in scan profile
    for rule in current_profile.get("scanRules", []):
        rule_id = rule.get("id")
        exception = exceptions.get(rule_id, None)
        if exception is not None:
            suppressions_rule_id = []

            # Check if rule has any suppressions and create list of suppressions
            for suppression in suppressions:
                if suppressions.get(suppression, {}).get("rule_id") == rule_id:
                    suppressions_rule_id.append(suppression)

            # Test if an exception is set for this rule which has suppressions assigned
            if exception is not None and len(suppressions_rule_id) > 0:
                for suppression in suppressions_rule_id:
                    now = datetime.now(UTC).replace(tzinfo=None) 

                    # Test for Suppression expired
                    if now + timedelta(days=TIMESHIFT_DAYS) > datetime.strptime(suppressions.get(suppression, {}).get("suppress_until"), "%Y-%m-%dT%H:00:00Z"):
                        # Suppression expired, remove Exception Tags
                        _LOGGER.info(
                            "Suppression expired, removing Exception Tags for %s in Profile %s",
                            rule_id,
                            SCAN_PROFILE_ID,
                        )
                    else:
                        # Suppression still valid, keep exception
                        _LOGGER.info(
                            "Suppression still valid for %s in Profile %s",
                            rule_id,
                            SCAN_PROFILE_ID,
                        )

                        rule.pop("deprecated", None)
                        updated_profile["scanRules"].append(rule)

                        if exception is not None:
                            updated_exceptions[rule_id] = exception
                        if suppression is not None:
                            updated_suppressions[suppression] = suppressions.get(
                                suppression, {}
                            )
                        continue

                    # Compare filter tags
                    rule_exception_filtertags = (
                        rule.get("attributes", {})
                        .get("exceptions", {})
                        .get("filterTags", [])
                    )
                    exception_exception_filtertags = exception.get("tags", [])
                    suppression_filtertags = suppressions.get(suppression, {}).get(
                        "tags", []
                    )

                    if set(exception_exception_filtertags).issubset(
                        set(suppression_filtertags)
                    ):
                        _LOGGER.info(
                            "Exception Filter Tags included in Suppression Filter Tags for %s in Profile %s",
                            rule_id,
                            SCAN_PROFILE_ID,
                        )

                        # Remove filter Tags from exception
                        resulting_exception_filtertags = list(
                            set(rule_exception_filtertags)
                            - set(exception_exception_filtertags)
                        )

                        _LOGGER.info(
                            "Removing Exception Tags for %s in Profile %s",
                            rule_id,
                            SCAN_PROFILE_ID,
                        )
                        if len(resulting_exception_filtertags) > 0:
                            rule["attributes"]["exceptions"]["filterTags"] = (
                                resulting_exception_filtertags
                            )
                            updated_profile["included"].append(rule)
                            data = (
                                updated_profile.get("data", {})
                                .get("relationships", {})
                                .get("ruleSettings", {})
                                .get("data", [])
                            )
                            data.append({"id": rule_id, "type": "rules"})
                            updated_profile["data"]["relationships"]["ruleSettings"] = {
                                "data": data
                            }

                        _LOGGER.info(
                            "Removing Exception from storage with Profile %s",
                            SCAN_PROFILE_ID,
                        )

            # Rule has no exception assigned and/or no suppressions assigned
            else:
                _LOGGER.info(
                    "Not changing Exception Tags for %s in Profile %s",
                    rule_id,
                    SCAN_PROFILE_ID,
                )
                rule.pop("deprecated", None)
                updated_profile["scanRules"].append(rule)

                if exception is not None:
                    updated_exceptions[rule_id] = exception

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}"

    connector.patch(url=url, data=updated_profile)

    with open(EXCEPTIONS_FILE, "w", encoding="utf-8") as json_file:
        json.dump(updated_exceptions, json_file, indent=2)

    with open(SUPPRESSIONS_FILE, "w", encoding="utf-8") as json_file:
        json.dump(updated_suppressions, json_file, indent=2)

    _LOGGER.info(
        "Scan Exceptions updated in Profile %s",
        SCAN_PROFILE_ID,
    )


def reset_profile():
    """Reset all rule configurations in scan profile."""

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}?includes=ruleSettings"

    # Retrieve current profile
    current_profile = connector.get(url=url)
    
    updated_profile = {
        "name": current_profile.get("name", ""),
        "description": current_profile.get("description", ""),
        "scanRules": [],
    }
    
    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}"
    
    connector.patch(url=url, data=updated_profile)

    updated_exceptions = {}
    with open(EXCEPTIONS_FILE, "w", encoding="utf-8") as json_file:
        json.dump(updated_exceptions, json_file, indent=2)

    _LOGGER.info("Removed all Rule configurations in Profile %s", SCAN_PROFILE_ID)


# #############################################################################
# Suppress findings in AWS Account
# #############################################################################
def retrieve_bot_results():
    """Retrieve Bot results from AWS Account"""

    page_size = 50
    page_number = 0
    service_names = ""
    created_less_than_days = 5
    compliances = ""  # "AWAF"

    now_24 = datetime.now(UTC).replace(tzinfo=None) - timedelta(hours=24) 
    
    # filter = f"accountId eq '{ACCOUNT_ID}' and riskLevel eq '{risk_levels}' and status eq 'FAILURE'"
    # filter = f"(accountId eq '{ACCOUNT_ID}') and (status eq 'FAILURE') and (riskLevel eq 'LOW')"
    # filter = f"(riskLevel eq 'HIGH' or riskLevel eq 'MEDIUM') and accountId eq '{ACCOUNT_ID}' and service eq 'EC2'"
    # filter = f"accountId eq '{ACCOUNT_ID}' and service eq 'EC2' and riskLevel eq 'MEDIUM'"

    findings = []
    for risk_level in RISK_LEVEL[RISK_LEVEL.index(RISK_LEVEL_FAIL):]:
        filter = f"accountId eq '{ACCOUNT_ID}' and riskLevel eq '{risk_level}'"
        page_number = 0

        while True:
            url = f"{API_BASE_URL}/checks"
            url += f"?skipToken={page_size * page_number}"
            
            params = {
                "top": f"{page_size}",
                "startDateTime": f"{now_24.strftime("%Y-%m-%dT%H:00:00Z")}",
                "dateTimeTarget": "createdDate"
            }

            response = connector.get(url=url, params=params, filter=filter)
            count = response.get("count", 0)
            findings += response.get("items", [])
            
            _LOGGER.debug("Retrieved %s findings.", len(findings))
            
            if count < page_size:
                break
            page_number += 1

    return findings


def match_scan_result_with_findings(bot_findings):
    """Match Scan Results with Findings."""

    exceptions_profile = {}
    with open(EXCEPTIONS_FILE, "r", encoding="utf-8") as json_file:
        exceptions_profile = json.load(json_file)

    _LOGGER.info("Analysing %s Bot findings", len(bot_findings))
    for exception_id in exceptions_profile.keys():
        exception_tags = exceptions_profile.get(exception_id, {}).get("tags", {})

        # Check if rule id matches with exception id
        for bot_finding in bot_findings:
            if bot_finding.get("status") == "SUCCESS":
                continue

            if (
                bot_finding.get("ruleId") == exception_id
            ):
                # Check if tags match with exception tags
                bot_finding_tags = bot_finding.get("tags")

                if bot_finding_tags is None or len(bot_finding_tags) == 0:
                    # Skip bot findings without tags
                    continue
                if ("Name::" in "\t".join(bot_finding_tags)) is False:
                    # Skip bot findings without Name tags
                    continue
                name_tags = [tag for tag in bot_finding_tags if "Name::" in tag]

                if len(name_tags) > 0 and set(name_tags).issubset(set(exception_tags)):
                    _LOGGER.info(
                        "Bot finding match %s for Scan Tags %s", exception_id, name_tags
                    )
                    suppress_check(bot_finding.get("id", None), exception_id, exception_tags)
                else:
                    _LOGGER.info(
                        "Bot finding match, Scan Tags not included: %s",
                        format(exception_tags),
                    )


def suppress_check(check_id, rule_id, exception_tags) -> None:
    """Suppress Check."""

    # Retrieve suppressions set by this script
    suppressions = {}
    if os.path.isfile(SUPPRESSIONS_FILE):
        with open(SUPPRESSIONS_FILE) as json_file:
            suppressions = json.load(json_file)

    now = datetime.now(UTC).replace(tzinfo=None)
    suppress_until = now + timedelta(days=7)

    _LOGGER.info("Setting Suppression for Check %s", format(check_id))

    url = f"{API_BASE_URL}/checks/{check_id}"
    data = {
        "suppressed": True,
        "suppressedUntilDateTime": suppress_until.strftime("%Y-%m-%dT%H:00:00Z"),
        "note": "suppressed for 1 week, failure not-applicable",
    }

    connector.patch(url=url, data=data)

    # Writing new suppressions file
    suppressions[rule_id] = {
        "rule_id": rule_id,
        "scan_profile_id": SCAN_PROFILE_ID,
        "tags": exception_tags,
        "suppress_until": suppress_until.strftime("%Y-%m-%dT%H:00:00Z"),
    }

    with open(SUPPRESSIONS_FILE, "w", encoding="utf-8") as json_file:
        json.dump(suppressions, json_file, indent=2)

    _LOGGER.info("Check %s suppressed", check_id)


# Conformity Connector
connector = Connector()


# #############################################################################
# Main
# #############################################################################
def main():
    """Entry point."""
    parser = argparse.ArgumentParser(
        prog="python3 scanner_v1.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Run template scans and handle scan exceptions and suppressions.",
        epilog=textwrap.dedent(
            """\
            Examples:
            --------------------------------
            # Run template scan
            $ ./scanner_v1_name.py --scan 7-scenarios-cspm

            # trigger bot run
            $ ./scanner_v1_name.py --bot
            """
        ),
    )
    parser.add_argument(
        "--scan", type=str, nargs=1, metavar="CONFIG", help="scan configuration"
    )
    parser.add_argument(
        "--exclude",
        type=str,
        nargs=1,
        metavar="CONFIG",
        help="scan configuration and exclude findings",
    )
    parser.add_argument(
        "--apply", type=str, nargs=1, metavar="CONFIG", help="apply configuration"
    )
    parser.add_argument(
        "--destroy", type=str, nargs=1, metavar="CONFIG", help="destroy configuration"
    )
    parser.add_argument(
        "--bot", action="store_const", const=True, default=False, help="scan account"
    )
    parser.add_argument(
        "--botstatus",
        action="store_const",
        const=True,
        default=False,
        help="account bot status",
    )
    parser.add_argument(
        "--suppress",
        action="store_const",
        const=True,
        default=False,
        help="suppress findings",
    )
    parser.add_argument(
        "--clear",
        action="store_const",
        const=True,
        default=False,
        help="clear exceptions",
    )
    parser.add_argument(
        "--expire",
        action="store_const",
        const=True,
        default=False,
        help="expire exceptions",
    )
    parser.add_argument(
        "--reset",
        action="store_const",
        const=True,
        default=False,
        help="reset profile",
    )
    # parser.add_argument(
    #     "--report",
    #     action="store_const",
    #     const=True,
    #     default=False,
    #     help="download latest report",
    # )
    args = parser.parse_args()

    if args.scan:
        plan = terraform_plan(args.scan[0])
        scan_result = scan_template(plan)
        scan_failures(scan_result, False)

    if args.exclude:
        plan = terraform_plan(args.exclude[0])
        scan_result = scan_template(plan)
        scan_failures(scan_result, True)

    if args.apply:
        terraform_apply(args.apply[0])

    if args.destroy:
        terraform_destroy(args.destroy[0])

    if args.bot:
        scan_account()

    if args.botstatus:
        bot_status_account()

    if args.suppress:
        bot_findings = retrieve_bot_results()
        match_scan_result_with_findings(bot_findings)

    if args.clear:
        # msg = "Sure to clear exceptions in scan profile?\n  Only 'Yes' will be accepted to approve.\n\nEnter a value: "
        # confirm = str(input(msg))
        # if confirm == "Yes":
        clear_exceptions()

    if args.expire:
        remove_expired_exceptions()

    if args.reset:
        # msg = "Sure to reset scan profile?\n  Only 'Yes' will be accepted to approve.\n\nEnter a value: "
        # confirm = str(input(msg))
        # if confirm == "Yes":
        reset_profile()

    # if args.report:
    #     download_report()


if __name__ == "__main__":
    main()
