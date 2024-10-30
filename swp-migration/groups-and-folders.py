#!/usr/bin/env python3
import argparse
import json
import logging
import os
import sys
import textwrap
from pprint import pprint as pp

import requests
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

DOCUMENTATION = """
---
module: groups-and-folders.py

short_description: Implements for following functionality:
    - List Computer Groups in DS and SWP
    - List Smart Folders in DS and SWP
    - Create Computer Group structure from DS in SWP and vice versa (copy)
    - Create Smart Folders structure from DS in SWP and vice versa (copy)

description:
    - Using REST APIs of DS and SWP

requirements:
    - Set environment variable V1SWP_API_KEY with the API key of the
      Server & Workload Security instance to use.
    - Set environment variable DS_API_KEY with the API key of the
      Deep Security instance to use.
    - Adapt the constants in between
      # HERE
      and
      # /HERE
      to your requirements

options:
  -h, --help          show this help message and exit
  --listgroups TYPE   list computer groups (TYPE=ds|swp)
  --copygroups TYPE   copy computer groups from given source (TYPE=ds|swp)
  --listfolders TYPE  list smart folders (TYPE=ds|swp)
  --copyfolders TYPE  list smart folders from given source (TYPE=ds|swp)

author:
    - Markus Winkler (markus_winkler@trendmicro.com)
"""

EXAMPLES = """
# Copy Computer Groups from DS to SWP
$ ./groups-and-folders.py --copygroups ds

# List Smart Folders in SWP
$ ./groups-and-folders.py --listfolders swp
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
REGION_SWP = "us-1."  # Examples: eu-1. sg-1.
API_BASE_URL_DS = f"https://3.76.217.110:4119/api/"
# /HERE

# Do not change
ENDPOINT_SWP = "swp"
ENDPOINT_DS = "ds"
API_KEY_SWP = os.environ["API_KEY_SWP"]
API_BASE_URL_SWP = f"https://workload.{REGION_SWP}cloudone.trendmicro.com/api/"
API_KEY_DS = os.environ["API_KEY_DS"]
REQUESTS_TIMEOUTS = (2, 30)
# /Do not change


# #############################################################################
# Errors
# #############################################################################
class TrendRequestError(Exception):
    """Define a base error."""

    pass


class TrendRequestAuthorizationError(TrendRequestError):
    """Define an error related to invalid API Permissions."""

    pass


class TrendRequestValidationError(TrendRequestError):
    """Define an error related to a validation error from a request."""

    pass


class TrendRequestNotFoundError(TrendRequestError):
    """Define an error related to requested information not found."""

    pass


# #############################################################################
# Connector to SWP/DS
# #############################################################################
class Connector:
    def __init__(self, endpoint) -> None:
        # # V1
        # self._headers = {
        #     "Authorization": f"Bearer {API_KEY_SWP}",
        #     "Content-Type": "application/json;charset=utf-8",
        # }
        
        # SWP / DS
        if endpoint == ENDPOINT_SWP:
            self._url = f"{API_BASE_URL_SWP}"
            self._headers = {
                "Content-type": "application/json",
                "api-secret-key": API_KEY_SWP,
                "api-version": "v1",
            }
            self._verify = True

        if endpoint == ENDPOINT_DS:
            self._url = f"{API_BASE_URL_DS}"
            self._headers = {
                "Content-type": "application/json",
                'Accept': 'application/json',
                "api-secret-key": API_KEY_DS,
                "api-version": "v1",
            }
            self._verify = False
            
    def get(self, endpoint):
        """Send an HTTP GET request and check response for errors.

        Args:
            url (str): API Endpoint
        """

        response = None
        try:
            response = requests.get(
                self._url + endpoint, headers=self._headers, verify=self._verify, timeout=REQUESTS_TIMEOUTS
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

    def patch(self, endpoint, data):
        """Send an HTTP PATCH request and check response for errors.

        Args:
            url (str): API Endpoint
            data (json): PATCH request body.
        """

        response = None
        try:
            response = requests.patch(
                self._url + endpoint,
                data=json.dumps(data),
                headers=self._headers,
                verify=self._verify,
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

    def post(self, endpoint, data):
        """Send an HTTP POST request and check response for errors.

        Args:
            url (str): API Endpoint
            data (json): POST request body.
        """

        response = None
        try:
            response = requests.post(
                self._url + endpoint,
                data=json.dumps(data),
                headers=self._headers,
                verify=self._verify,
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

    def get_paged(self, endpoint, key):
        """Retrieve all"""

        paged = []
        id_value, total_num = 0, 0
        max_items = 100

        while True:
            payload = {
                "maxItems": max_items,
                "searchCriteria": [
                    {
                        "idValue": id_value,
                        "idTest": "greater-than",
                    }
                ],
                "sortByObjectID": "true",
            }

            response = self.post(endpoint + "/search", data=payload)

            num_found = len(response[key])
            if num_found == 0:
                break

            for item in response[key]:
                # Filter out groups from cloud providers
                # TODO: validate checks
                if item.get("cloudType") is None and item.get("type") != "aws-account":
                    paged.append(item)

            id_value = response[key][-1]["ID"]

            if num_found == 0:
                break

            total_num = total_num + num_found

        return paged

    def get_by_name(self, endpoint, key, name):
        """Retrieve all"""

        paged = []
        max_items = 1

        payload = {
            "maxItems": max_items,
            "searchCriteria": [
                {
                    "fieldName": "name",
                    "stringTest": "equal",
                    "stringValue": name,
                }
            ],
            "sortByObjectID": "true",
        }

        response = self.post(endpoint + "/search", data=payload)

        for item in response[key]:
            if item.get("ID") is not None:
                return item.get("ID")

        return paged
    
    @staticmethod
    def _check_error(response: requests.Response):
        """Check response for Errors.

        Args:
            response (Response): Response to check.
        """

        if not response.ok:
            match response.status_code:
                case 400:
                    tre = TrendRequestError("400 Bad request")
                    tre.message = json.loads(response.content.decode("utf-8")).get("message")
                    print(json.loads(response.content.decode("utf-8")))
                    raise tre
                case 401:
                    raise TrendRequestAuthorizationError(
                        "401 Unauthorized. The requesting user does not have enough privilege."
                    )
                case 403:
                    raise TrendRequestAuthorizationError(
                        "403 Forbidden. The requesting user does not have enough privilege."
                    )
                case 404:
                    raise TrendRequestNotFoundError("404 Not found")
                case 422:
                    raise TrendRequestValidationError(
                        "500 Unprocessed Entity. Validation error"
                    )
                case 500:
                    raise TrendRequestError("500 The parsing of the template file failed")
                case 503:
                    raise TrendRequestError("503 Service unavailable")
                case _:
                    raise TrendRequestError(response.text)


# #############################################################################
# List
# #############################################################################
def list_groups(product) -> dict:
    """List Computer Groups."""

    # _LOGGER.info("List Computer Groups...")

    endpoint = "computergroups"
    if product == ENDPOINT_SWP:
        response = connector_swp.get_paged(endpoint=endpoint, key="computerGroups")

    elif product == ENDPOINT_DS:
        response = connector_ds.get(endpoint=endpoint)

    else:
        raise ValueError(f"Invalid endpoint: {product}")

    if product == ENDPOINT_DS:
        return response.get("computerGroups")
    else:
        return response

def list_folders(product) -> dict:
    """List Smart Folders."""

    # _LOGGER.info("List Smart Folders...")

    endpoint = "smartfolders"
    if product == ENDPOINT_SWP:
        response = connector_swp.get_paged(endpoint=endpoint, key="smartFolders")

    elif product == ENDPOINT_DS:
        response = connector_ds.get(endpoint=endpoint)

    else:
        raise ValueError(f"Invalid endpoint: {product}")

    if product == ENDPOINT_DS:
        return response.get("smartFolders")
    else:
        return response

# #############################################################################
# Add
# #############################################################################
def add_group(product, data) -> dict:
    """Add Computer Group."""

    # _LOGGER.info("Add Computer Group...")

    endpoint = "computergroups"
    if product == ENDPOINT_SWP:
        data.pop("ID")
        try:
            response = connector_swp.post(endpoint=endpoint, data=data)
        except TrendRequestError as tre:
            if "already exists" in tre.message:
                id = connector_swp.get_by_name(endpoint=endpoint, key="computerGroups", name=data.get("name"))
                _LOGGER.debug(f"Group with name: {data.get("name")} already exists with id: {id}")
                return id
            else:
                raise tre

    elif product == ENDPOINT_DS:
        data.pop("ID")
        try:
            response = connector_ds.post(endpoint=endpoint, data=data)
        except TrendRequestError as tre:
            if "already exists" in tre.message:
                id = connector_ds.get_by_name(endpoint=endpoint, key="computerGroups", name=data.get("name"))
                _LOGGER.debug(f"Group with name: {data.get("name")} already exists with id: {id}")
                return id
            else:
                raise tre
    else:
        raise ValueError(f"Invalid endpoint: {product}")

    return response.get("ID")


def add_folder(product, data) -> dict:
    """Add Smart Folder."""

    # _LOGGER.info("Add Computer Group...")

    endpoint = "smartfolders"
    if product == ENDPOINT_SWP:
        data.pop("ID")
        try:
            response = connector_swp.post(endpoint=endpoint, data=data)
        except TrendRequestError as tre:
            if "already exists" in tre.message:
                id = connector_swp.get_by_name(endpoint=endpoint, key="smartFolders", name=data.get("name"))
                _LOGGER.debug(f"Smart Folder with name: {data.get("name")} already exists with id: {id}")
                return id
            else:
                raise tre

    elif product == ENDPOINT_DS:
        data.pop("ID")
        try:
            response = connector_ds.post(endpoint=endpoint, data=data)
        except TrendRequestError as tre:
            if "already exists" in tre.message:
                id = connector_ds.get_by_name(endpoint=endpoint, key="smartFolders", name=data.get("name"))
                _LOGGER.debug(f"Smart Folder name: {data.get("name")} already exists with id: {id}")
                return id
            else:
                raise tre
    else:
        raise ValueError(f"Invalid endpoint: {product}")

    return response.get("ID")

# #############################################################################
# Copy
# #############################################################################
def copy_groups(product, data):
    """Unidirectional copy Computer Groups"""

    tree = {}
    remaining = []
    if product == ENDPOINT_SWP:
        target = ENDPOINT_DS

    elif product == ENDPOINT_DS:
        target = ENDPOINT_SWP

    else:
        raise ValueError(f"Invalid endpoint: {product}")

    for item in data:
        if item.get("parentGroupID") is None:
            local_id = item.get("ID")
            _LOGGER.info(f"Adding root group {local_id}")
            item["name"] = f"{item["name"]}"
            group_id = add_group(target, item)
            tree[local_id] = group_id

        elif item.get("parentGroupID") in tree:
            local_id = item.get("ID")
            parent_id = tree.get(item.get("parentGroupID"))
            _LOGGER.info(f"Adding child group {local_id} to {parent_id}")
            item["parentGroupID"] = parent_id
            item["name"] = f"{item["name"]}"
            group_id = add_group(target, item)
            tree[local_id] = group_id

        else:
            remaining.append(item)
    
    _LOGGER.debug(f"Group mapping: {tree}")
    if len(remaining) > 0:
        _LOGGER.warning(f"{len(remaining)} groups to create")

def copy_folders(product, data):
    """Unidirectional copy Computer Groups"""

    tree = {}
    remaining = []
    if product == ENDPOINT_SWP:
        target = ENDPOINT_DS

    elif product == ENDPOINT_DS:
        target = ENDPOINT_SWP

    else:
        raise ValueError(f"Invalid endpoint: {product}")

    for item in data:
        print(tree)
        if item.get("parentSmartFolderID") is None:
            local_id = item.get("ID")
            _LOGGER.info(f"Adding root group {local_id}")
            item["name"] = f"{item["name"]}"
            print(item)
            group_id = add_folder(target, item)
            tree[local_id] = group_id

        elif item.get("parentSmartFolderID") in tree:
            local_id = item.get("ID")
            parent_id = tree.get(item.get("parentSmartFolderID"))
            _LOGGER.info(f"Adding child group {local_id} to {parent_id}")
            item["parentSmartFolderID"] = parent_id
            item["name"] = f"{item["name"]}"
            group_id = add_folder(target, item)
            tree[local_id] = group_id

        else:
            remaining.append(item)
    
    _LOGGER.debug(f"Group mapping: {tree}")
    if len(remaining) > 0:
        _LOGGER.warning(f"{len(remaining)} groups to create")


# #############################################################################
# Main
# #############################################################################
# Connectors
connector_ds = Connector(ENDPOINT_DS)
connector_swp = Connector(ENDPOINT_SWP)

def main():
    """Entry point."""

    parser = argparse.ArgumentParser(
        prog="python3 groups-and-folders.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="List and copy Computer Groups and Smart Folders in between DS and SWP",
        epilog=textwrap.dedent(
            """\
            Examples:
            --------------------------------
            # Copy Computer Groups from DS to SWP
            $ ./groups-and-folders.py --copygroups ds

            # List Smart Folders in SWP
            $ ./groups-and-folders.py --listfolders swp
            """
        ),
    )
    parser.add_argument(
        "--listgroups", type=str, nargs=1, metavar="TYPE", help="list computer groups (TYPE=ds|swp)"
    )
    parser.add_argument(
        "--copygroups", type=str, nargs=1, metavar="TYPE", help="copy computer groups from given source (TYPE=ds|swp)"
    )
    parser.add_argument(
        "--listfolders", type=str, nargs=1, metavar="TYPE", help="list smart folders (TYPE=ds|swp)"
    )
    parser.add_argument(
        "--copyfolders", type=str, nargs=1, metavar="TYPE", help="list smart folders from given source (TYPE=ds|swp)"
    )

    args = parser.parse_args()

    if args.listgroups:
        groups = list_groups(args.listgroups[0].lower())
        pp(groups)

    if args.copygroups:
        groups = list_groups(args.copygroups[0].lower())
        copy_groups(args.copygroups[0].lower(), groups)
        
    if args.listfolders:
        folders = list_folders(args.listfolders[0].lower())
        pp(folders)

    if args.copyfolders:
        folders = list_folders(args.copyfolders[0].lower())
        copy_folders(args.copyfolders[0].lower(), folders)


if __name__ == "__main__":
    main()
