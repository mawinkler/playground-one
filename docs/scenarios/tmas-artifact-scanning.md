# Scenario: Vulnerability and Malware Scanning

***DRAFT***

## Prerequisites

- Vision One Container Security Artifact Scanner API-Key

Ensure to have the latest `tmas` deployed:

```sh
tmas-update
```

## Scan Images

First, set the Artifact Scanner API-Key as an environment variable:

```sh
export TMAS_API_KEY=<YOUR API-Key>
```

To easily scan an image for vulnerabililies run

```sh
tmas scan docker:nginx:latest
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
