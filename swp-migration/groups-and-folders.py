#!/usr/bin/env python3
import argparse
import json
import logging
import os
import sys
import textwrap
from pprint import pprint as pp
from typing import Any, Dict, List

import requests
import urllib3
from typeguard import typechecked

# Comment out if DS is using a trusted certificate
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

DOCUMENTATION = """
---
module: groups-and-folders.py

short_description: Implements for following functionality:
    - List Computer Groups in DS and SWP
    - List Smart Folders in DS and SWP
    - Merge Computer Group structure from DS with SWP and vice versa
    - Merge Smart Folders structure from DS with SWP and vice versa

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
  -h, --help           show this help message and exit
  --listgroups TYPE    list computer groups (TYPE=ds|swp)
  --mergegroups TYPE   merge computer groups from given source (TYPE=ds|swp)
  --listfolders TYPE   list smart folders (TYPE=ds|swp)
  --mergefolders TYPE  list smart folders from given source (TYPE=ds|swp)

author:
    - Markus Winkler (markus_winkler@trendmicro.com)
"""

EXAMPLES = """
# Merge Computer Groups from DS to SWP
$ ./groups-and-folders.py --mergegroups ds

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

        elif endpoint == ENDPOINT_DS:
            self._url = f"{API_BASE_URL_DS}"
            self._headers = {
                "Content-type": "application/json",
                "Accept": "application/json",
                "api-secret-key": API_KEY_DS,
                "api-version": "v1",
            }
            self._verify = False

        else:
            raise ValueError(f"Invalid endpoint: {endpoint}")

    def get(self, endpoint) -> Any:
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

    def patch(self, endpoint, data) -> Any:
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

    def post(self, endpoint, data) -> Any:
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

    @typechecked
    def get_paged(self, endpoint, key) -> Dict:
        """Retrieve all from endpoint"""

        paged = {}
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
                    paged[item.get("ID")] = item

            id_value = response[key][-1]["ID"]

            if num_found == 0:
                break

            total_num = total_num + num_found

        return paged

    @typechecked
    def get_by_name(self, endpoint, key, name, parent_id) -> int:
        """Retrieve all"""

        # We limit to more than one to detect duplicates by name
        max_items = 2

        if parent_id is None:
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
        else:
            if key == "computerGroups":
                parent_field = "parentGroupID"
            elif key == "smartFolders":
                parent_field = "parentSmartFolderID"
            else:
                raise ValueError(f"Invalid key: {key}")

            payload = {
                "maxItems": max_items,
                "searchCriteria": [
                    {
                        "fieldName": "name",
                        "stringTest": "equal",
                        "stringValue": name,
                    },
                    {
                        "fieldName": parent_field,
                        "numericTest": "equal",
                        "numericValue": parent_id,
                    },
                ],
                "sortByObjectID": "true",
            }

        response = self.post(endpoint + "/search", data=payload)

        cnt = len(response[key])
        if cnt == 1:
            item = response[key][0]
            if item.get("ID") is not None:
                return item.get("ID")
        elif cnt > 1:
            _LOGGER.warning(f"More than one group or folder where returned. Count {len(response[key])}")
            # endpoint_groups = self.get_paged(endpoint, key)

        else:
            raise ValueError(f"Group or folder named {name} not found.")

    @staticmethod
    def _check_error(response: requests.Response) -> None:
        """Check response for Errors.

        Args:
            response (Response): Response to check.
        """

        if not response.ok:
            match response.status_code:
                case 400:
                    tre = TrendRequestError("400 Bad request")
                    tre.message = json.loads(response.content.decode("utf-8")).get("message")
                    _LOGGER.error(f"{tre.message}")
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
                    raise TrendRequestValidationError("500 Unprocessed Entity. Validation error")
                case 500:
                    raise TrendRequestError("500 The parsing of the template file failed")
                case 503:
                    raise TrendRequestError("503 Service unavailable")
                case _:
                    raise TrendRequestError(response.text)


# #############################################################################
# List
# #############################################################################
@typechecked
def list_groups(product) -> Dict:
    """List Computer Groups."""

    endpoint = "computergroups"
    if product == ENDPOINT_SWP:
        response = connector_swp.get_paged(endpoint=endpoint, key="computerGroups")

    elif product == ENDPOINT_DS:
        response = connector_ds.get_paged(endpoint=endpoint, key="computerGroups")

    else:
        raise ValueError(f"Invalid endpoint: {product}")

    return response


@typechecked
def list_folders(product) -> Dict:
    """List Smart Folders."""

    endpoint = "smartfolders"
    if product == ENDPOINT_SWP:
        response = connector_swp.get_paged(endpoint=endpoint, key="smartFolders")

    elif product == ENDPOINT_DS:
        response = connector_ds.get_paged(endpoint=endpoint, key="smartFolders")

    else:
        raise ValueError(f"Invalid endpoint: {product}")

    return response


# #############################################################################
# Add
# #############################################################################
@typechecked
def add_group(product, data) -> int:
    """Add Computer Group."""

    endpoint = "computergroups"
    if product == ENDPOINT_SWP:
        data.pop("ID")
        try:
            response = connector_swp.post(endpoint=endpoint, data=data)
        except TrendRequestError as tre:
            if "already exists" in tre.message:
                id = connector_swp.get_by_name(
                    endpoint=endpoint, key="computerGroups", name=data.get("name"), parent_id=data.get("parentGroupID")
                )
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
                id = connector_ds.get_by_name(
                    endpoint=endpoint, key="computerGroups", name=data.get("name"), parent_id=data.get("parentGroupID")
                )
                _LOGGER.debug(f"Group with name: {data.get("name")} already exists with id: {id}")
                return id
            else:
                raise tre
    else:
        raise ValueError(f"Invalid endpoint: {product}")

    return response.get("ID")


@typechecked
def add_folder(product, data) -> int:
    """Add Smart Folder."""

    endpoint = "smartfolders"
    if product == ENDPOINT_SWP:
        data.pop("ID")
        try:
            response = connector_swp.post(endpoint=endpoint, data=data)
        except TrendRequestError as tre:
            if "already exists" in tre.message:
                id = connector_swp.get_by_name(
                    endpoint=endpoint,
                    key="smartFolders",
                    name=data.get("name"),
                    parent_id=data.get("parentSmartFolderID"),
                )
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
                id = connector_ds.get_by_name(
                    endpoint=endpoint,
                    key="smartFolders",
                    name=data.get("name"),
                    parent_id=data.get("parentSmartFolderID"),
                )
                _LOGGER.debug(f"Smart Folder name: {data.get("name")} already exists with id: {id}")
                return id
            else:
                raise tre
    else:
        raise ValueError(f"Invalid endpoint: {product}")

    return response.get("ID")


# #############################################################################
# Merge
# #############################################################################
# def get_group_path(groups, path, id) -> List:

#     group = groups.get(id)
#     parent_id = group.get("parentGroupID")

#     path.append(group.get("ID"))
#     if parent_id is not None:
#         path = get_group_path(groups, path, parent_id)

#     return path


def merge_groups(product, data) -> None:
    """Unidirectional merge Computer Groups"""

    tree = {}
    remaining = []
    if product == ENDPOINT_SWP:
        target = ENDPOINT_DS

    elif product == ENDPOINT_DS:
        target = ENDPOINT_SWP

    else:
        raise ValueError(f"Invalid endpoint: {product}")

    for item in data.values():
        if item.get("parentGroupID") is None:
            local_id = item.get("ID")
            _LOGGER.info(f"Adding root group {local_id}")
            item["name"] = f"{item["name"]}"
            tree[local_id] = add_group(target, item)

        elif item.get("parentGroupID") in tree:
            local_id = item.get("ID")
            parent_id = tree.get(item.get("parentGroupID"))
            _LOGGER.info(f"Adding child group {local_id} to {parent_id}")
            item["parentGroupID"] = parent_id
            item["name"] = f"{item["name"]}"
            tree[local_id] = add_group(target, item)

        else:
            remaining.append(item)

    _LOGGER.debug(f"Group mapping: {tree}")
    if len(remaining) > 0:
        _LOGGER.warning(f"{len(remaining)} groups to create")


def merge_folders(product, data) -> None:
    """Unidirectional merge Computer Groups"""

    tree = {}
    remaining = []
    if product == ENDPOINT_SWP:
        target = ENDPOINT_DS

    elif product == ENDPOINT_DS:
        target = ENDPOINT_SWP

    else:
        raise ValueError(f"Invalid endpoint: {product}")

    for item in data.values():
        if item.get("parentSmartFolderID") is None:
            local_id = item.get("ID")
            _LOGGER.info(f"Adding root folder {local_id}")
            item["name"] = f"{item["name"]}"
            tree[local_id] = add_folder(target, item)

        elif item.get("parentSmartFolderID") in tree:
            local_id = item.get("ID")
            parent_id = tree.get(item.get("parentSmartFolderID"))
            _LOGGER.info(f"Adding child folder {local_id} to {parent_id}")
            item["parentSmartFolderID"] = parent_id
            item["name"] = f"{item["name"]}"
            tree[local_id] = add_folder(target, item)

        else:
            remaining.append(item)

    _LOGGER.debug(f"Folder mapping: {tree}")
    if len(remaining) > 0:
        _LOGGER.warning(f"{len(remaining)} folders to create")


# #############################################################################
# Main
# #############################################################################
# Connectors
connector_ds = Connector(ENDPOINT_DS)
connector_swp = Connector(ENDPOINT_SWP)


def main() -> None:
    """Entry point."""

    parser = argparse.ArgumentParser(
        prog="python3 groups-and-folders.py",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="List and merge Computer Groups and Smart Folders in between DS and SWP",
        epilog=textwrap.dedent(
            """\
            Examples:
            --------------------------------
            # Merge Computer Groups from DS with SWP
            $ ./groups-and-folders.py --mergegroups ds

            # List Smart Folders in SWP
            $ ./groups-and-folders.py --listfolders swp
            """
        ),
    )
    parser.add_argument("--listgroups", type=str, nargs=1, metavar="TYPE", help="list computer groups (TYPE=ds|swp)")
    parser.add_argument(
        "--mergegroups", type=str, nargs=1, metavar="TYPE", help="merge computer groups from given source (TYPE=ds|swp)"
    )
    parser.add_argument("--listfolders", type=str, nargs=1, metavar="TYPE", help="list smart folders (TYPE=ds|swp)")
    parser.add_argument(
        "--mergefolders", type=str, nargs=1, metavar="TYPE", help="list smart folders from given source (TYPE=ds|swp)"
    )

    args = parser.parse_args()

    if args.listgroups:
        groups = list_groups(args.listgroups[0].lower())
        for group in groups.values():
            print(group)

    if args.mergegroups:
        groups = list_groups(args.mergegroups[0].lower())
        merge_groups(args.mergegroups[0].lower(), groups)

    if args.listfolders:
        folders = list_folders(args.listfolders[0].lower())
        for folder in folders.values():
            print(folder)

    if args.mergefolders:
        folders = list_folders(args.mergefolders[0].lower())
        merge_folders(args.mergefolders[0].lower(), folders)


if __name__ == "__main__":
    main()
