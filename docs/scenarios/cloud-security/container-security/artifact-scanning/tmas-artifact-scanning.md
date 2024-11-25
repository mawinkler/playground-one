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

## Secrets - False Positives

Here, we're going to tackle false positives in the scan results.

Depending on the programming language used in a containerized app and how it got containerized `tmas` will likely discover lots of generic secrets. These false positives are usually found within unit tests or examples included in the language runtime distribution.

Let's play with one of my apps, [UpTonight](https://github.com/mawinkler/uptonight).

First, let's run a scan on my `2.2` image:

```sh
tmas scan -VMS registry:mawinkler/uptonight:2.2
```

![alt text](images/tmas-01.png "Results")

So, there are apparently 306 secrets...

If we want to inspect a specific finding we need to dissect the container image into it's layers. Make sure to use the correct image digest reported by Vision One.

```sh
docker pull docker.io/mawinkler/uptonight@sha256:2dbb4a927b796b9384cc9deb6a51690407d1e661caeae163f4db4ecd53167701

docker save -o uptonight.tar docker.io/mawinkler/uptonight@sha256:2dbb4a927b796b9384cc9deb6a51690407d1e661caeae163f4db4ecd53167701
```

The above command saves the image including all of its layers into a tar archive. Extracting this archive we get the following structure:

```sh
tar xf uptonight.tar
```

```sh
.
├── blobs
│   └── sha256
│       ├── 0289e2ec8bd41c714a9c9cb966178936fbee43d105fe01228248dfb8f7e2e65f
│       ├── 14400b4a9b67b699da1139d477d547ec7641c0ed426154e44dc8801049b194d0
│       ├── 1e2970d0bac38bc6f58c786a4afd5edd618f2234ac4544d252c076d1d5ba8bcb
│       ├── 2573e0d8158209ed54ab25c87bcdcb00bd3d2539246960a3d592a1c599d70465
│       ├── 3af7b477f81821ea399f9e0ec15c01da98760385de5215b48305818ffe387eb0
│       ├── 4d4d9b9d193f30fc49e7a4436c528b23ac727344f5d1a2750be3fb306b49fc2b
│       ├── 699776f4e4fc26d1405c79779ac8884dace05694168924be559f87f938b1a2e4
│       ├── 6b6e322dc8865457a6eb8d5855f40c6a83c5719d30dfe557d0e2fa841fe4178e
│       ├── 7c51e6dae7e6949b891fee75e2035795f5cddf244b86bc05bc96b1917b542c9a
│       ├── 8498a0b71ea370be3ea0f1939319046bc8b71df07d5f7c35396d410e4b93ed90
│       ├── 895e113eb7ccd19522d9b7ca0279bc79579363c1d690d60d4d572dddbea3ef00
│       ├── 906f0ecb429801119a0bba0298aa2eaa26ba7f852ec44c7cd43d9779d4ba0cd4
│       ├── abef58d990b11bc9a7da4190cdcb05f03b6edaa3f63802d2949e4a3dd2501bba
│       ├── ac12c35f8650c0ec8b7f3bae9050a2e4ea9a30cf573a46dddb76958dababb7ff
│       ├── c72dfe6bf14c642d21076c0d9d1c1917894f8dbcc60b95d4b01ff3b71d196bf7
│       ├── ccc40309c2e9d4552ee8d86e9bb0e88be2d82bf2527755f95608076b6ac0a730
│       ├── dbe0eae7d2c32f7c87d0f6020a390f7d97b699d26c6021e81871a06a862ddab9
│       └── e72b88a7237022c675a9909b1125f50a4ad49120af2cbf52f27b9017f6b520ff
├── index.json
├── manifest.json
├── oci-layout
└── uptonight.tar

2 directories, 22 files
```

Just to be clear, the files in the `blobs/sha256` directory contain the file system of each layer that makes up the image.

Now, let us inspect some files with potential secret findings.

*JSON Web Token*

![alt text](images/tmas-02.png "Results")

```txt
Secret Type: jwt
Description: Uncovered a JSON Web Token, which may lead to unauthorized access to web applications and sensitive user data.
Artifact ID: docker.io/mawinkler/uptonight@sha256:2dbb4a927b796b9384cc9deb6a51690407d1e661caeae163f4db4ecd53167701
Path: /root/.local/lib/python3.10/site-packages/astroquery/eso/tests/data/oidc_token.json
Layer ID: sha256:c72dfe6bf14c642d21076c0d9d1c1917894f8dbcc60b95d4b01ff3b71d196bf7
Start Line: 3
End Line: 3
Start Column: 17
End Column: 122
Secret: eyJhbGciOiJIU******EPqgpup30c6Mg
Scan ID: 3148a308-6a5b-43c8-bca5-3e361e182912
```

Extract the file:

```sh
tar xf blobs/sha256/c72dfe6bf14c642d21076c0d9d1c1917894f8dbcc60b95d4b01ff3b71d196bf7 root/.local/lib/python3.10/site-packages/astroquery/eso/tests/data/oidc_token.json
```

When we open the file and search for the discovered secret, we can see that it does look like a JWT token, but since it's in a tests directory from an external library, we can be pretty sure that this is a false positive.

```
{
  "access_token": "some-access-token",
  "id_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Nzg2Mjg5NTl9.qqKrC1MesQQmLtqsFOm2kxe4f_Nqo4EPqgpup30c6Mg",
  "token_type": "bearer",
  "expires_in": 28800,
  "scope": ""
}
```

Very similar, there are AWS Access Tokens and a lot of generic secrets detected in the `botocore` which we will exclude.

It is a fairly common result to have lots of findings about generic API keys, JWT tokens, etc. when the container image uses a programming language like Python and is not stripped down to what is really needed to run the application. We will later retest the same application with the container image properly stripped down.

For now, we can create an overrides file for a tmas rescan:

`tmas_overrides.yaml`

```yaml
secrets:
  paths:
    - patterns:
        - ".*/tests/.*"
      reason: Unit tests
    - patterns:
        - "./botocore/data/.*/examples-1.json"
      reason: Botocore examples
    - patterns:
        - ".*/site-packages/cryptography/hazmat/.*"
        - ".*/site-packages/cryptography/x509/.*"
        - ".*/site-packages/numpy/core/include/numpy/old_defines.h"
      reason: "False positive in external library"
```

When now rescan the same image by running

```sh
tmas scan -S registry:mawinkler/uptonight:2.2 -o tmas_overrides.yaml
```

We have only 11 findings left, 295 are overridden.

```json
{
  "secrets": {
    "totalFilesScanned": 16531,
    "unmitigatedFindingsCount": 11,
    "overriddenFindingsCount": 295,
    "findings": {
```

As promised, let's see the difference with a properly stripped down image of the same application, now in version 2.3:

```sh
tmas scan -S registry:mawinkler/uptonight:2.3
```

```json
{
  "secrets": {
    "totalFilesScanned": 1686,
    "unmitigatedFindingsCount": 0,
    "overriddenFindingsCount": 0,
    "findings": {}
  }
}
```

The number of vulnerabilities decreased from 66 to 15, with a maximum severity rating of medium. The image size decreased from 291MB to 137MB.

🎉 Success 🎉
