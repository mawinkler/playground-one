#!/usr/bin/env python3
import argparse
import json
import os
import os.path
import sys
import logging
import requests
import textwrap
import uuid
from datetime import datetime, timedelta, UTC
#from pprint import pprint as pp

DOCUMENTATION = """
---
module: scanner_c1_uuid.py

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
    - Set environment variable C1CSPM_SCANNER_KEY with the API key of the
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
$ ./scanner_c1_uuid.py --scan 2-network

# Run approval workflows in engine, here implementing the approved workflow
$ ./scanner_c1_uuid.py --exclude 2-network

# Now add the exclusion tags to the corresponding resources
# in the Terraform template

# Run template scan again to verify that the scan result is clean
$ ./scanner_c1_uuid.py --scan 2-network

# Apply configuration
$ ./scanner_c1_uuid.py --apply 2-network

# Trigger bot run
$ ./scanner_c1_uuid.py --bot

# Suppress findings
$ ./scanner_c1_uuid.py --suppress

# Suppressions are active for 1 week
$ ./scanner_c1_uuid.py --expire

# Wait for suppressions to expire
$ ./scanner_c1_uuid.py --expire

# Cleanup
$ ./scanner_c1_uuid.py --destroy 2-network
$ ./scanner_c1_uuid.py --reset
$ ./scanner_c1_uuid.py --expire
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
REGION = "trend-us-1"
SCAN_PROFILE_ID = "Tc0NcdFKU"
ACCOUNT_ID = "ed68602b-0eb1-4cbb-ad0b-64676877fadf"
SCAN_PROFILE_NAME = "Scan Profile Benelux"
REPORT_TITLE = "Workflow Tests"
RISK_LEVEL_FAIL = "MEDIUM"
# /HERE

# Do not change
RISK_LEVEL = ["LOW", "MEDIUM", "HIGH", "CRITICAL"]
EXCEPTIONS_FILE = "exceptions.json"
SUPPRESSIONS_FILE = "suppressions.json"
PLAN_FILE = "plan.json"
SCAN_RESULT_FILE = "scan_result.json"
API_KEY = os.environ["C1CSPM_SCANNER_KEY"]
API_BASE_URL = f"https://conformity.{REGION}.cloudone.trendmicro.com/api"
REQUESTS_TIMEOUTS = (2, 30)
# /Do not change


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
            "Authorization": f"ApiKey {API_KEY}",
            "Content-Type": "application/vnd.api+json",
        }

    def get(self, url):
        """Send an HTTP GET request to Conformity and check response for errors.

        Args:
            url (str): API Endpoint
        """

        response = None
        try:
            response = requests.get(
                url, headers=self._headers, verify=True, timeout=REQUESTS_TIMEOUTS
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

        return response.json()

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

        return response.json()

    @staticmethod
    def _check_error(response: requests.Response):
        """Check response from Conformity for Errors.

        Args:
            response (Response): Response from Conformity to check.
        """

        if not response.ok:
            match response.status_code:
                case 400:
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
# Terraform functions
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
# Scan template
# #############################################################################
def scan_template(contents) -> str:
    """Initiate Conformity Template Scan."""

    _LOGGER.info("Starting Template Scan...")

    url = f"{API_BASE_URL}/template-scanner/scan"

    data = {
        "data": {
            "attributes": {
                "profileId": SCAN_PROFILE_ID,
                "type": "terraform-template",
                "contents": contents,
            }
        }
    }

    response = connector.post(url=url, data=data)

    with open(SCAN_RESULT_FILE, "w", encoding="utf-8") as scan_result:
        json.dump(response, scan_result, indent=2)

    _LOGGER.info("Template Scan done.")

    return response


# #############################################################################
# Scan account
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

    bot_status = response.get("data", {}).get("attributes", {}).get("bot-status")

    _LOGGER.info("Account Bot status: %s", bot_status)


# #############################################################################
# Report functions
# #############################################################################
def download_report() -> None:
    """Download latest Conformity Report for Account"""

    url = f"{API_BASE_URL}/reports?accountId={ACCOUNT_ID}"

    response = connector.get(url=url)

    download_endpoint = None
    created_date = 0
    for report in response.get("data", []):
        if (
            report["attributes"]["title"] == REPORT_TITLE
            and report["attributes"]["created-date"] > created_date
        ):
            created_date = report["attributes"]["created-date"]
            included = report.get("attributes", {}).get("included", {})
            for include in included:
                if include["type"] == "PDF":
                    download_endpoint = include["report-download-endpoint"]

    if download_endpoint is None:
        _LOGGER.info("No report found.")
        return None

    response = connector.get(url=download_endpoint)

    try:
        response = requests.get(response.get("url"), verify=True, timeout=30)
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
    finally:
        # Error handling
        if not response.ok:
            match response.status_code:
                case 500:
                    raise ConformityError("500 Internal server error")
                case 503:
                    raise ConformityError("503 Service unavailable")
                case _:
                    raise ConformityError(response.text)

    with open("report.pdf", "wb") as report:
        report.write(response.content)
    _LOGGER.info("Report saved to report.pdf.")


# #############################################################################
# Handle scan failures in scan profile
# #############################################################################
def scan_failures(contents, exclude=False) -> None:
    """Parse scan result for failures and set exceptions in exclude == True."""

    for finding in contents.get("data", []):
        if finding["attributes"]["status"] == "FAILURE":
            risk_level = finding.get("attributes", {}).get("risk-level", None)

            if RISK_LEVEL.index(risk_level) < RISK_LEVEL.index(RISK_LEVEL_FAIL):
                continue

            rule_title = finding.get("attributes", {}).get("rule-title", None)
            tags = list(finding.get("attributes", {}).get("tags", {}))
            resource = finding.get("attributes", {}).get("resource", None)
            rule_id = (
                finding.get("relationships", {})
                .get("rule", {})
                .get("data", {})
                .get("id", None)
            )

            if exclude:
                _LOGGER.info(
                    "Setting Exception for rule %s with Risk Level %s, Rule Title: %s for Resource: %s",
                    rule_id,
                    risk_level,
                    rule_title,
                    resource,
                )
                set_exception(rule_id, risk_level, tags, resource)
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

    for rule in response.get("included", []):
        if rule["id"] == rule_id:
            return (
                rule.get("attributes", {}).get("exceptions", {}).get("filterTags", [])
            )
    return []


def set_exception(rule_id, risk_level, tags, resource):
    """Set Rule Exception in Profile."""

    # Retrieve exceptions set by this script
    exceptions_profile = {}
    if os.path.isfile(EXCEPTIONS_FILE):
        with open(EXCEPTIONS_FILE) as json_file:
            exceptions_profile = json.load(json_file)

    # Retrieve already existing tags from rule
    merged_tags = rule_tags_existing(rule_id)
    # Test if a tag for the resource already exists
    tag = [tag for tag in merged_tags if f"::{resource}_{rule_id}" in tag]
    if len(tag) == 0:
        _LOGGER.info(
            "Creating new Exception tag for %s in Profile %s",
            resource,
            SCAN_PROFILE_ID,
        )
        tag = f"{uuid.uuid4()}::{resource}_{rule_id}"
        merged_tags.append(tag)

    url = f"{API_BASE_URL}/profiles/{SCAN_PROFILE_ID}"

    # Patch profile with updated exception
    data = {
        "included": [
            {
                "type": "rules",
                "id": rule_id,
                "attributes": {
                    "enabled": True,
                    "exceptions": {
                        "tags": [],
                        "filterTags": merged_tags,
                        "resources": [],
                    },
                    "extraSettings": [],
                    "riskLevel": risk_level,
                    "provider": "aws",
                },
            }
        ],
        "data": {
            "type": "profiles",
            "id": SCAN_PROFILE_ID,
            "attributes": {"name": SCAN_PROFILE_NAME, "description": "Scan exclusions"},
            "relationships": {
                "ruleSettings": {"data": [{"type": "rules", "id": rule_id}]}
            },
        },
    }

    connector.patch(url=url, data=data)

    # Writing new exceptions file
    exceptions_profile[rule_id] = {
        "scan_profile_id": SCAN_PROFILE_ID,
        "tags": merged_tags,
    }

    with open(EXCEPTIONS_FILE, "w", encoding="utf-8") as json_file:
        json.dump(exceptions_profile, json_file, indent=2)

    # _LOGGER.info(
    #     "Exception for %s and %s in Profile %s set",
    #     resource,
    #     rule_id,
    #     SCAN_PROFILE_ID,
    # )


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
        "included": [],
        "data": {
            "type": "profiles",
            "id": SCAN_PROFILE_ID,
            "attributes": {"name": SCAN_PROFILE_NAME, "description": "Scan exclusions"},
            "relationships": {},
        },
    }

    # Building updated profile
    for rule in current_profile.get("included", []):
        rule_id = rule.get("id", None)
        exception = exceptions.get(rule_id, None)
        if exception is not None:
            rule_exception_filtertags = (
                rule.get("attributes", {}).get("exceptions", {}).get("filterTags", [])
            )
            exception_exception_filtertags = exception.get("tags", [])

            resulting_exception_filtertags = list(
                set(rule_exception_filtertags) - set(exception_exception_filtertags)
            )

            _LOGGER.info(
                "Removing Exception Tags for %s in Profile %s", rule_id, SCAN_PROFILE_ID
            )
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
            updated_profile["data"]["relationships"]["ruleSettings"] = {"data": data}
        else:
            _LOGGER.info(
                "Not changing Exception Tags for %s in Profile %s",
                rule_id,
                SCAN_PROFILE_ID,
            )
            updated_profile["included"].append(rule)
            data = (
                updated_profile.get("data", {})
                .get("relationships", {})
                .get("ruleSettings", {})
                .get("data", [])
            )
            data.append({"id": rule_id, "type": "rules"})
            updated_profile["data"]["relationships"]["ruleSettings"] = {"data": data}

    url = f"{API_BASE_URL}/profiles/"

    connector.post(url=url, data=updated_profile)

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
        "included": [],
        "data": {
            "type": "profiles",
            "id": SCAN_PROFILE_ID,
            "attributes": {"name": SCAN_PROFILE_NAME, "description": "Scan exclusions"},
            "relationships": {},
        },
    }

    updated_exceptions = {}
    updated_suppressions = {}

    # Building updated profile
    # Iterating over customized rules in scan profile
    for rule in current_profile.get("included", []):
        rule_id = rule.get("id")
        exception = exceptions.get(rule_id)
        suppressions_rule_id = []

        # Check if rule has any suppressions and create list of suppressions
        for suppression in suppressions:
            if suppressions.get(suppression, {}).get("rule_id") == rule_id:
                suppressions_rule_id.append(suppression)

        # Test if an exception is set for this rule which has suppressions assigned
        if exception is not None and len(suppressions_rule_id) > 0:
            for suppression in suppressions_rule_id:
                now = datetime.timestamp(datetime.now(UTC).replace(tzinfo=None)) * 1000

                # if suppressions.get(suppression, {}).get("rule_id") == "EC2-001":
                #     _LOGGER.warning("Fast forward 1 week to fake expiration")
                #     now = datetime.now(UTC).replace(tzinfo=None)
                #     now = int((now + timedelta(days=7)).timestamp() * 1000)

                # Test for Suppression expired
                if now > suppressions.get(suppression, {}).get("suppress_until"):
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
            updated_profile["included"].append(rule)
            data = (
                updated_profile.get("data", {})
                .get("relationships", {})
                .get("ruleSettings", {})
                .get("data", [])
            )
            data.append({"id": rule_id, "type": "rules"})
            updated_profile["data"]["relationships"]["ruleSettings"] = {"data": data}
            if exception is not None:
                updated_exceptions[rule_id] = exception

    url = f"{API_BASE_URL}/profiles/"

    connector.post(url=url, data=updated_profile)

    # pp(updated_exceptions)
    # pp(updated_suppressions)
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

    url = f"{API_BASE_URL}/profiles/"

    data = {
        "included": [],
        "data": {
            "type": "profiles",
            "id": SCAN_PROFILE_ID,
            "attributes": {"name": "AWS Scanner", "description": "Scan exclusions"},
            "relationships": {},
        },
    }

    connector.post(url=url, data=data)

    updated_exceptions = {}
    with open(EXCEPTIONS_FILE, "w", encoding="utf-8") as json_file:
        json.dump(updated_exceptions, json_file, indent=2)

    _LOGGER.info("Removed all Rule configurations in Profile %s", SCAN_PROFILE_ID)


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

        response = connector.get(url=url)

        additional_findings = response.get("data", [])
        findings += additional_findings

        total = response.get("meta", {}).get("total", 0)
        if (page_number * page_size) >= total:
            break
        page_number += 1

        _LOGGER.debug("Retrieved %s of %s findings", len(findings), total)

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
            if (
                bot_finding.get("relationships", {})
                .get("rule", {})
                .get("data", {})
                .get("id")
                == exception_id
            ):
                # Check if tags match with exception tags
                bot_finding_tags = bot_finding.get("attributes", {}).get("tags")

                # Filter bot finding tags on rule id
                bot_finding_tags = [
                    tag for tag in bot_finding_tags if f"_{exception_id}" in tag
                ]

                if bot_finding_tags is None or len(bot_finding_tags) == 0:
                    # Skip bot findings without tags
                    continue

                if len(exception_tags) > 0 and set(bot_finding_tags).issubset(
                    set(exception_tags)
                ):
                    _LOGGER.info(
                        "Bot finding match %s for Scan Tags %s",
                        exception_id,
                        bot_finding_tags,
                    )
                    suppress_check(bot_finding.get("id", None), exception_tags)
                else:
                    _LOGGER.info(
                        "Bot finding match, Scan Tags not included: %s",
                        format(exception_tags),
                    )


def suppress_check(check_id, exception_tags) -> None:
    """Suppress Check."""

    # Retrieve suppressions set by this script
    suppressions = {}
    if os.path.isfile(SUPPRESSIONS_FILE):
        with open(SUPPRESSIONS_FILE) as json_file:
            suppressions = json.load(json_file)

    now = datetime.now(UTC).replace(tzinfo=None)
    suppress_until = int((now + timedelta(days=7)).timestamp() * 1000)

    _LOGGER.info("Setting Suppression for Check %s", format(check_id))

    url = f"{API_BASE_URL}/checks/{check_id}"
    data = {
        "data": {
            "type": "checks",
            "attributes": {"suppressed": True, "suppressed-until": suppress_until},
        },
        "meta": {"note": "suppressed for 1 week, failure not-applicable"},
    }

    response = connector.patch(url=url, data=data)

    # Writing new suppressions file
    suppressions[response.get("data", {}).get("id", {})] = {
        "rule_id": response.get("data", {})
        .get("relationships", {})
        .get("rule", {})
        .get("data", {})
        .get("id", {}),
        "scan_profile_id": SCAN_PROFILE_ID,
        "tags": exception_tags,
        "suppress_until": suppress_until,
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
        prog="python3 scanner_c1.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Run template scans and handle scan exceptions and suppressions.",
        epilog=textwrap.dedent(
            """\
            Examples:
            --------------------------------
            # Run template scan
            $ ./scanner_c1_uuid.py --scan 7-scenarios-cspm

            # trigger bot run
            $ ./scanner_c1_uuid.py --bot
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
    parser.add_argument(
        "--report",
        action="store_const",
        const=True,
        default=False,
        help="download latest report",
    )
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
        msg = "Sure to clear exceptions in scan profile?\n  Only 'Yes' will be accepted to approve.\n\nEnter a value: "
        confirm = str(input(msg))
        if confirm == "Yes":
            clear_exceptions()

    if args.expire:
        remove_expired_exceptions()

    if args.reset:
        msg = "Sure to reset scan profile?\n  Only 'Yes' will be accepted to approve.\n\nEnter a value: "
        confirm = str(input(msg))
        if confirm == "Yes":
            reset_profile()

    if args.report:
        download_report()


if __name__ == "__main__":
    main()
