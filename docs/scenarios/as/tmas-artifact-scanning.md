# Scenario: Container Vulnerability and Malware Scanning

## Prerequisites

- Vision One Container Security Artifact Scanner API-Key with the following permissions:
  - Cloud Security Operations
    - Container Protection
      - Run artifact scan

Ensure to have the latest `tmas` deployed:

```sh
tmcli-update
```

## Scan Images

First, set the Artifact Scanner API-Key as an environment variable:

```sh
export TMAS_API_KEY=<YOUR API-Key>
```

> ***Note:*** tmas defaults to the Vision One service region `us-east-1`. If your Vision One is serviced from any other region you need to add the `--region` flag to the scan request.
> 
> Valid regions: `[ap-southeast-2 eu-central-1 ap-south-1 ap-northeast-1 ap-southeast-1 us-east-1]`

To easily scan an image for vulnerabililies run

```sh
# Service region us-east-1
tmas scan docker:nginx:latest

# Service region eu-central-1
tmas scan docker:nginx:latest --region eu-central-1
```

Scanning an image for vulnerabilities and malware simultaneously is as easy as above

```sh
tmas scan docker:mawinkler/evil2:latest --malwareScan
```

At the time of writing, the second scan should find 24 vulnerabilities and one malware:

```json
{
  "vulnerability": {
    "totalVulnCount": 24,
    "criticalCount": 0,
    "highCount": 0,
    "mediumCount": 6,
    "lowCount": 15,
    "negligibleCount": 3,
    "unknownCount": 0,
    "findings": {
...
  "malware": {
    "scanResult": 1,
    "findings": [
      {
        "layerDigest": "sha256:d5fafe98396dfece28a75fc06ef876bf2e9014d62d908f8296a925bab92ab4b9",
        "layerDiffID": "sha256:d5fafe98396dfece28a75fc06ef876bf2e9014d62d908f8296a925bab92ab4b9",
        "fileName": "eicarcom2.zip",
        "fileSize": 308,
        "fileSHA256": "sha256:e1105070ba828007508566e28a2b8d4c65d192e9eaf3b7868382b7cae747b397",
        "foundMalwares": [
          {
            "fileName": "eicarcom2.zip",
            "malwareName": "OSX_EICAR.PFH"
          }
        ]
      }
    ],
    "scanID": "300d7aed-2f1f-4818-af62-24f9378fe91d",
    "scannerVersion": "1.0.0-471"
  }
}
```

🎉 Success 🎉
