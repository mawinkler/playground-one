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

# from pprint import pprint as pp

DOCUMENTATION = """
---
module: category_compliance_c1.py

short_description: Implements for following functionality:
    - Run Conformity Bot and request status
    - Report Compliance status for Categories

description:
    - The reporting of compliance status may be limited by the number of days back in
      and a minimum level of criticality.

requirements:
    - Set environment variable C1CSPM_SCANNER_KEY with the API key owning 
      Full Access to Conformity.
    - Adapt the constants in between
      # HERE
      and
      # /HERE
      to your requirements

options:
  -h, --help        show this help message and exit
  --bot         scan account
  --botstatus   account bot status
  --compliance  retrieve compliance with category

author:
    - Markus Winkler (markus_winkler@trendmicro.com)
"""

EXAMPLES = """
# Get the Compliance by Categories
$ ./category_compliance_c1.py --compliance

# Start the Conformity Bot
$ ./category_compliance_c1.py --bot
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
ACCOUNT_ID = "ed68602b-0eb1-4cbb-ad0b-64676877fadf"
RISK_LEVEL_FAIL = "LOW"
CREATED_LESS_THAN_DAYS = 90
# /HERE

# Do not change
RISK_LEVEL = ["LOW", "MEDIUM", "HIGH", "VERY_HIGH", "EXTREME"]
API_KEY = os.environ["C1CSPM_SCANNER_KEY"]
API_BASE_URL = f"https://conformity.{REGION}.cloudone.trendmicro.com/api"
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
            response = requests.get(url, headers=self._headers, verify=True, timeout=REQUESTS_TIMEOUTS)
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

    bot_status = response.get("data", {}).get("attributes", {}).get("bot-status")

    _LOGGER.info("Account Bot status: %s", bot_status)


# #############################################################################
# Suppress findings in AWS Account
# #############################################################################
def retrieve_bot_results():
    """Retrieve Bot results from AWS Account"""

    page_size = 200
    page_number = 0
    service_names = ""
    risk_levels = ";".join(RISK_LEVEL[RISK_LEVEL.index(RISK_LEVEL_FAIL) :])
    compliances = ""  # "AWAF"

    findings = []
    while True:
        url = f"{API_BASE_URL}/checks"
        url += f"?accountIds={ACCOUNT_ID}"
        url += f"&page[size]={page_size}"
        url += f"&page[number]={page_number}"
        url += f"&filter[services]={service_names}"
        url += f"&filter[createdLessThanDays]={CREATED_LESS_THAN_DAYS}"
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

# Conformity Connector
connector = Connector()
categories_summary = Categories()

# #############################################################################
# Main
# #############################################################################
def main():
    """Entry point."""
    parser = argparse.ArgumentParser(
        prog="python3 category_compliance_c1.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Run the Conformity Bot and calculate Compliance by Categories.",
        epilog=textwrap.dedent(
            """\
            Examples:
            --------------------------------
            # Get the Compliance by Categories
            $ ./category_compliance_c1.py --compliance

            # Start the Conformity Bot
            $ ./category_compliance_c1.py --bot
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
