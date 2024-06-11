# Scenario: File Malware Scanning

## Prerequisites

- Vision One Cloud Security File Scanner API-Key with the following permissions:
    - Cloud Security Operations
        - File Security
            - Run file scan via SDK

Ensure to have the latest `tmfs` deployed:

```sh
tmcli-update
```

## Scan Images

First, set the Artifact Scanner API-Key as an environment variable:

```sh
export TMFS_API_KEY=<YOUR API-Key>
```

> ***Note:*** tmfs defaults to the Vision One service region `us-east-1`. If your Vision One is serviced from any other region you need to add the `--region` flag to the scan request.
> 
> Valid regions: `[ap-southeast-2 eu-central-1 ap-south-1 ap-northeast-1 ap-southeast-1 us-east-1]`

To easily scan an image for vulnerabililies run

```sh
# Service region us-east-1, scan directory
tmfs scan dir:path/to/yourproject

# Service region us-east-1, scan single file
tmfs scan file:path/to/yourproject/file

# Service region eu-central-1, scan single file
tmfs scan file:path/to/yourproject/file --region eu-central-1
```

Example output for `tmfs scan file:./eicar.zip | jq .`:

```json
{
  "scannerVersion": "1.0.0-631",
  "schemaVersion": "1.0.0",
  "scanResult": 1,
  "scanId": "72c04b72-0e5b-45b4-a460-6c4346beec5e",
  "scanTimestamp": "2023-12-20T11:44:30.526Z",
  "fileName": "./eicar.zip",
  "foundMalwares": [
    {
      "fileName": "./eicar.zip",
      "malwareName": "OSX_EICAR.PFH"
    }
  ],
  "fileSHA1": "d27265074c9eac2e2122ed69294dbc4d7cce9141",
  "fileSHA256": "2546dcffc5ad854d4ddc64fbf056871cd5a00f2471cb7a5bfd4ac23b6e9eedad"
}
```

🎉 Success 🎉
