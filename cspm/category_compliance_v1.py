#!/usr/bin/env python3
import argparse
import json
import logging
import os
import os.path
import sys
import textwrap
from datetime import UTC, datetime, timedelta
from typing import Dict

import requests

DOCUMENTATION = """
---
module: category_compliance_v1.py

short_description: Implements for following functionality:
    - Run Posture Management Bot and request status
    - Report Compliance status for Categories

description:
    - The reporting of compliance status may be limited by the number of days back in
      and a minimum level of criticality.

requirements:
    - Set environment variable V1CSPM_SCANNER_KEY with the API key owning
      Full Access to Posture Management.
    - Adapt the constants in between
      # HERE
      and
      # /HERE
      to your requirements

options:
  -h, --help    show this help message and exit
  --bot         scan account
  --botstatus   account bot status
  --compliance  retrieve compliance with category

author:
    - Markus Winkler (markus_winkler@trendmicro.com)
"""

EXAMPLES = """
# Get the Compliance by Categories
$ ./category_compliance_v1.py --compliance

# Start the Posture Management Bot
$ ./category_compliance_v1.py --bot
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
REGION = ""  # Examples: eu-central-1 or "" for us-east-1
ACCOUNT_ID = "e37fe1b7-2b14-4b2c-96a4-db1bb2be8c8b"
RISK_LEVEL_FAIL = "LOW"
CREATED_LESS_THAN_DAYS = 90
# /HERE

# Do not change
RISK_LEVEL = ["LOW", "MEDIUM", "HIGH", "VERY_HIGH", "EXTREME"]
API_KEY = os.environ["V1CSPM_SCANNER_KEY"]
if REGION == "us-east-1" or REGION == "":
    API_BASE_URL = "https://api.xdr.trendmicro.com/beta/cloudPosture"
else:
    API_BASE_URL = f"https://api.{REGION}.xdr.trendmicro.com/beta/cloudPosture"
REQUESTS_TIMEOUTS = (2, 30)
CATEGORIES = [
    "security",
    "cost-optimisation",
    "reliability",
    "performance-efficiency",
    "operational-excellence",
    "sustainability",
]
# /Do not change

# Get account and template id
# curl -s --location "https://api.xdr.trendmicro.com/beta/cloudPosture/accounts" \
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
            response = requests.get(url, headers=self._headers, params=params, verify=True, timeout=REQUESTS_TIMEOUTS)
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
                    raise ConformityValidationError("500 Unprocessed Entity. Validation error")
                case 500:
                    raise ConformityError("500 The parsing of the template file failed")
                case 503:
                    raise ConformityError("503 Service unavailable")
                case _:
                    raise ConformityError(response.text)


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

    bot_status = response.get("scanStatus")

    _LOGGER.info("Account Bot status: %s", bot_status)


# #############################################################################
# Suppress findings in AWS Account
# #############################################################################
def retrieve_bot_results():
    """Retrieve Bot results from AWS Account"""

    page_size = 200
    page_number = 0
    start_datetime = datetime.now(UTC).replace(tzinfo=None) - timedelta(days=CREATED_LESS_THAN_DAYS)

    # filter = f"accountId eq '{ACCOUNT_ID}' and riskLevel eq '{risk_levels}' and status eq 'FAILURE'"
    # filter = f"(accountId eq '{ACCOUNT_ID}') and (status eq 'FAILURE') and (riskLevel eq 'LOW')"
    # filter = f"(riskLevel eq 'HIGH' or riskLevel eq 'MEDIUM') and accountId eq '{ACCOUNT_ID}' and service eq 'EC2'"
    # filter = f"accountId eq '{ACCOUNT_ID}' and service eq 'EC2' and riskLevel eq 'MEDIUM'"

    findings = []
    for risk_level in RISK_LEVEL[RISK_LEVEL.index(RISK_LEVEL_FAIL) :]:
        filter = f"accountId eq '{ACCOUNT_ID}' and riskLevel eq '{risk_level}'"
        page_number = 0

        while True:
            url = f"{API_BASE_URL}/checks"
            url += f"?skipToken={page_size * page_number}"

            params = {
                "top": f"{page_size}",
                "startDateTime": f"{start_datetime.strftime('%Y-%m-%dT%H:00:00Z')}",
                "dateTimeTarget": "createdDate",
            }

            response = connector.get(url=url, params=params, filter=filter)
            count = response.get("count", 0)
            findings += response.get("items", [])

            _LOGGER.debug("Retrieved %s findings.", len(findings))

            if count < page_size:
                break
            page_number += 1

    return findings


class Categories:

    def __init__(self):
        self._categories = {}
        for category in CATEGORIES:
            self._categories[category] = {"success": 0, "failure": 0}

    def category(self, category) -> Dict:
        success = self._categories.get(category).get("success")
        failure = self._categories.get(category).get("failure")
        if success + failure == 0:
            self._categories[category]["compliance"] = 0
        else:
            self._categories[category]["compliance"] = int(round(success / (success + failure) * 100, 0))

        return self._categories.get(category)

    def increment_success(self, category):
        self._categories[category]["success"] = self._categories.get(category).get("success") + 1

    def increment_failure(self, category):
        self._categories[category]["failure"] = self._categories.get(category).get("failure") + 1


# Posture Management Connector
connector = Connector()
categories_summary = Categories()


# #############################################################################
# Main
# #############################################################################
def main():
    """Entry point."""
    parser = argparse.ArgumentParser(
        prog="python3 category_compliance_v1.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Run the PM Bot and calculate Compliance by Categories.",
        epilog=textwrap.dedent(
            """\
            Examples:
            --------------------------------
            # Get the Compliance by Categories
            $ ./category_compliance_v1.py --compliance

            # Start the Posture Management Bot
            $ ./category_compliance_v1.py --bot
            """
        ),
    )
    parser.add_argument("--bot", action="store_const", const=True, default=False, help="scan account")
    parser.add_argument(
        "--botstatus",
        action="store_const",
        const=True,
        default=False,
        help="account bot status",
    )
    parser.add_argument(
        "--compliance",
        action="store_const",
        const=True,
        default=False,
        help="retrieve compliance with category",
    )
    args = parser.parse_args()

    if args.bot:
        scan_account()

    if args.botstatus:
        bot_status_account()

    if args.compliance:
        bot_findings = retrieve_bot_results()

        for finding in bot_findings:
            status = finding.get("status")
            categories = finding.get("categories")
            for category in categories:
                if status == "SUCCESS":
                    categories_summary.increment_success(category)
                if status == "FAILURE":
                    categories_summary.increment_failure(category)

        for category in CATEGORIES:
            _LOGGER.info(f"Category: {category.capitalize()} - {categories_summary.category(category)}")


if __name__ == "__main__":
    main()
