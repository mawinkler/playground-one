# Scenario: Container Image Scanning for Vulnerabilities, Malware, and Secrets

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

The `tmas` tools supports three scan variants:

- malware, -M          Perform a malware scan on an image artifact
- secrets, -S          Perform a secrets scan on an artifact
- vulnerabilities, -V  Perform a vulnerability scan on an artifact

You can either choose an individual scan type or combine multiple via flags.

To easily scan an image for vulnerabililies run

```sh
# Service region us-east-1
tmas scan vulnerabilities docker:nginx:latest
# short
tmas scan -V docker:nginx:latest

# Service region eu-central-1
tmas scan vulnerabilities docker:nginx:latest --region eu-central-1
```

Scanning an image for vulnerabilities and malware simultaneously is as easy as above

```sh
tmas scan -VM docker:mawinkler/evil2:latest
```

At the time of writing, the second scan should find 137 vulnerabilities and one malware:

```json
{
  "vulnerabilities": {
    "totalVulnCount": 137,
    "criticalCount": 0,
    "highCount": 4,
    "mediumCount": 65,
    "lowCount": 61,
    "negligibleCount": 7,
    "unknownCount": 0,
    "overriddenCount": 0,
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
            "fileName": "__Zoq9GPNzgoaVyXYSKgniGj__",
            "malwareName": "OSX_EICAR.PFH"
          }
        ]
      }
    ],
    "scanID": "53e856d2-6385-46f7-b661-21d01b3604a2",
    "scannerVersion": "1.0.0-66"
  }
}
```

Another malware example might be this:

```sh
tmas scan malware registry:quay.io/petr_ruzicka/malware-cryptominer-container:2.1.1
```

Scanning for secrets is very similar:

```sh
tmas scan secrets registry:trufflesecurity/secrets
```

🎉 Success 🎉
