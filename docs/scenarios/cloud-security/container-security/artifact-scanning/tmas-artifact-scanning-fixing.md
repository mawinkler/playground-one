# Scenario: Fixing Vulnerabilities and Secrets with Artifact Scanning

!!! warning "Challenge ahead!"

    This scenario gets a bit challenging after scanning images, but you should be able to get through it.

## Prerequisites

- Vision One Container Security Artifact Scanner API-Key with the following permissions:
    - Cloud Security Operations
        - Container Protection
            - Run artifact scan

Ensure to have the latest `tmas` deployed:

```sh
tmcli-update
```

## Scan Images for Vulnerabilities, Malware, and Secrets

First, set the Artifact Scanner API-Key as an environment variable:

```sh
export TMAS_API_KEY=<YOUR API-Key>
```

> ***Note:*** tmas defaults to the Vision One service region `us-east-1`. If your Vision One is serviced from any other region you need to add the `--region` flag to the scan request.
> 
> Valid regions: `[ap-southeast-2 eu-central-1 ap-south-1 ap-northeast-1 ap-southeast-1 us-east-1]`

If you followed the other scenarios on Artifact Scanning and Shift Left Security you know how to use `tmas` already.

In this scenario we're going to fix findings.

## Vulnerabilities - How to Fix Findings (Python Example)

So, let's go through fixing Vulnerabilities in a container image. For this we play with one of my apps, [UpTonight](https://github.com/mawinkler/uptonight). For the curious ones out there, it calculates the best astrophotography targets for the night at a given location and date. These are deep sky objects, solar system bodies and coments.

We start with version 2.2 from beginning October and scan it for vulnerabilities:

```sh
tmas scan -V registry:mawinkler/uptonight:2.2
```

Heading over to the `Cloud Security -> Shift Left Security` we click on the `66` below `Vulnerabilities` for the Artifact `mawinkler/uptonight` with the Tag `2.2`.

![alt text](images/tmas-01.png "Results")

We can now filter on `Fix Available` and get six findings that we can address.

![alt text](images/tmas-03.png "Results")

Alternatively, we could do this in our shell by running:

```sh
tmas scan -V registry:mawinkler/uptonight:2.2 | \
  jq -r '.vulnerabilities.findings.Medium[] | select(.fix!="not-fixed") | [.id, .name, .version, .fix] | @tsv'
```

```sh
GHSA-8495-4g3g-x7pr     aiohttp 3.10.5  3.10.11
CVE-2024-9287   libpython3.10-minimal   3.10.12-1~22.04.6       3.10.12-1~22.04.7
CVE-2024-9287   libpython3.10-stdlib    3.10.12-1~22.04.6       3.10.12-1~22.04.7
CVE-2024-9287   python3.10      3.10.12-1~22.04.6       3.10.12-1~22.04.7
CVE-2024-9287   python3.10-minimal      3.10.12-1~22.04.6       3.10.12-1~22.04.7
GHSA-9wx4-h78v-vm56     requests        2.31.0  2.32.0
```

What this tells us is that there seem to be three areas where we need to take a closer look:

- Four findings are introduced by a vulnerable python version 3.10.12 we could update.
- Similar for the `requests` library which is used to create HTTP(s) requests.
- And `aoihttp` which we should update as well.

It is of course important that we test any version upgrades.

### Setting Up a Python Virtual Environment

We need to make sure we're using the same version of Python as in the image. To do this safely without breaking the system, we'll use `pyenv` to do this in an isolated environment. If you don't have it, install it by running:

***Linux***

```sh
# Linux
curl https://pyenv.run | bash
```

Append the following to your `.bashrc`:

```sh
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

Ensure some dependencies:

```sh
sudo apt update
sudo apt-get install build-essential zlib1g-dev libffi-dev libssl-dev libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev libncurses-dev tk-dev 
```

And restart the terminal.

***MacOS***

```sh
# MacOS
brew install pyenv
```

Append the following to your `.zshrc`:

```sh
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
```

And restart the terminal.


Now, let's downlod the sources into a temporary directory:

```sh
mkdir uptonight && cd uptonight
wget https://github.com/mawinkler/uptonight/archive/refs/tags/2.2.tar.gz
tar xfvz 2.2.tar.gz
cd uptonight-2.2
```

Since the image in this release uses Python 3.10.12, we install and activate it.

```sh
pyenv install 3.10.12
pyenv local 3.10.12
```

```sh
Downloading Python-3.10.12.tar.xz...
-> https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tar.xz
Installing Python-3.10.12...
Installed Python-3.10.12 to /home/markus/.pyenv/versions/3.10.12
```

Now, we create the virtual environment:

```sh
python3 -m venv venv && source venv/bin/activate
python --version
```

```sh
Python 3.10.12
```

Note that your prompt has changed `(venv) ...`. This indicates that you're now in a python virtual environment.

### Run UpTonight

Before running UpTonight we need to install it's dependencies, which are defined in the `requirements.txt`.

```sh
pip install -r requirements.txt
```

Now run UpTonight for a quick test:

```sh
# Center of Munich
export LONGITUDE="11d34m51.50s"
export LATITUDE="48d08m10.77s"
export ELEVATION=519
export TIMEZONE="Europe/Berlin"

python3 main.py
```

This should produce some output in your shell and create some files within the `out` directory. If interested, check them out ;-).

### Fix the `requests` Package

This is pretty easy. We only need to change one line within the `requirements.txt`, update the dependencies in our environment and check if it still works.

```sh
vi requirements.txt
```

Change `requests==2.31.0` to `requests==2.32.0` and rerun:

```sh
pip install -r requirements.txt
```

and retest:

```sh
python3 main.py
```

### Fix the `aiohttp` Package

So this is a little more tricky since this is a nested dependency (not listed in `requirements.txt`)

To get an idea where it sits in the dependency tree we can utilize `pipdeptree`.

```sh
pip install pipdeptree
pipdeptree
```

We can see that `aiohttp` is introduced by `s3fs`, the AWS S3 python library.

```sh
...
s3fs==2024.10.0
├── aiobotocore [required: >=2.5.4,<3.0.0, installed: 2.15.2]
│   ├── aiohttp [required: >=3.9.2,<4.0.0, installed: 3.11.7]
│   │   ├── aiohappyeyeballs [required: >=2.3.0, installed: 2.4.3]
│   │   ├── aiosignal [required: >=1.1.2, installed: 1.3.1]
│   │   │   └── frozenlist [required: >=1.1.0, installed: 1.5.0]
│   │   ├── async-timeout [required: >=4.0,<6.0, installed: 5.0.1]
│   │   ├── attrs [required: >=17.3.0, installed: 24.2.0]
│   │   ├── frozenlist [required: >=1.1.1, installed: 1.5.0]
│   │   ├── multidict [required: >=4.5,<7.0, installed: 6.1.0]
│   │   │   └── typing_extensions [required: >=4.1.0, installed: 4.12.2]
│   │   ├── propcache [required: >=0.2.0, installed: 0.2.0]
│   │   └── yarl [required: >=1.17.0,<2.0, installed: 1.18.0]
│   │       ├── idna [required: >=2.0, installed: 3.10]
│   │       ├── multidict [required: >=4.0, installed: 6.1.0]
│   │       │   └── typing_extensions [required: >=4.1.0, installed: 4.12.2]
│   │       └── propcache [required: >=0.2.0, installed: 0.2.0]
│   ├── aioitertools [required: >=0.5.1,<1.0.0, installed: 0.12.0]
│   ├── botocore [required: >=1.35.16,<1.35.37, installed: 1.35.36]
│   │   ├── jmespath [required: >=0.7.1,<2.0.0, installed: 1.0.1]
│   │   ├── python-dateutil [required: >=2.1,<3.0.0, installed: 2.9.0.post0]
│   │   │   └── six [required: >=1.5, installed: 1.16.0]
│   │   └── urllib3 [required: >=1.25.4,<3,!=2.2.0, installed: 2.2.3]
│   └── wrapt [required: >=1.10.10,<2.0.0, installed: 1.17.0]
├── aiohttp [required: !=4.0.0a1,!=4.0.0a0, installed: 3.11.7]
│   ├── aiohappyeyeballs [required: >=2.3.0, installed: 2.4.3]
│   ├── aiosignal [required: >=1.1.2, installed: 1.3.1]
│   │   └── frozenlist [required: >=1.1.0, installed: 1.5.0]
│   ├── async-timeout [required: >=4.0,<6.0, installed: 5.0.1]
│   ├── attrs [required: >=17.3.0, installed: 24.2.0]
│   ├── frozenlist [required: >=1.1.1, installed: 1.5.0]
│   ├── multidict [required: >=4.5,<7.0, installed: 6.1.0]
│   │   └── typing_extensions [required: >=4.1.0, installed: 4.12.2]
│   ├── propcache [required: >=0.2.0, installed: 0.2.0]
│   └── yarl [required: >=1.17.0,<2.0, installed: 1.18.0]
│       ├── idna [required: >=2.0, installed: 3.10]
│       ├── multidict [required: >=4.0, installed: 6.1.0]
│       │   └── typing_extensions [required: >=4.1.0, installed: 4.12.2]
│       └── propcache [required: >=0.2.0, installed: 0.2.0]
└── fsspec [required: ==2024.10.0.*, installed: 2024.10.0]
...
```

`s3fs` is introduced by `astropy[all]` which we can verify here `https://github.com/astropy/astropy/blob/main/pyproject.toml`. UpTonight does not use AWS so we can try the `astropy[recommended]` variant.

```sh
vi requirements.txt
```

Change `astropy[all]==6.0.1` to `astropy[recommended]==6.0.1` and run:

```sh
# Clean up installed packages
pip install pip-tools
pip-sync requirements.txt

# Ensure requirements are still met
pip install -r requirements.txt
```

and retest:

```sh
python3 main.py
```

Good, still seems to to work.

### Verify Our Changes

Let's build the container, scan it and check if we successfully fixed the two vulnerabilities:

```sh
docker build -t uptonight-patched --load .
tmas scan -V docker:uptonight-patched | \
  jq -r '.vulnerabilities.findings.Medium[] | select(.fix!="not-fixed") | [.id, .name, .version, .fix] | @tsv'
```

```sh
CVE-2024-9287   libpython3.10-minimal   3.10.12-1~22.04.6       3.10.12-1~22.04.7
CVE-2024-9287   libpython3.10-stdlib    3.10.12-1~22.04.6       3.10.12-1~22.04.7
CVE-2024-9287   python3.10      3.10.12-1~22.04.6       3.10.12-1~22.04.7
CVE-2024-9287   python3.10-minimal      3.10.12-1~22.04.6       3.10.12-1~22.04.7
```

Wahoo, we did it :-) Two are gone.

### Fix the `python3.10` Package

Python3 is installed within the Dockerfile:

```Dockerfile
# Compile image
FROM ubuntu:jammy AS compile-image

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update \
    && apt-get install -y python3-pip python3-dev pkg-config libhdf5-dev \
    && cd /usr/local/bin \
    && ln -s /usr/bin/python3 python \
    && pip3 install --upgrade pip

COPY requirements.txt requirements.txt

RUN pip3 install --upgrade pip setuptools && \
    pip install --no-cache-dir -r requirements.txt --user && \
    pip list

# Run image
FROM ubuntu:jammy AS runtime-image

RUN apt-get update \
    && apt-get install -y python3 \
    && cd /usr/local/bin \
    && ln -s /usr/bin/python3 python

COPY --from=compile-image /root/.local /root/.local
COPY --from=compile-image /etc/ssl /etc/ssl

WORKDIR /app

COPY uptonight uptonight
COPY targets targets
COPY main.py .

ENV PATH=/root/local/bin:$PATH

ENTRYPOINT ["python3", "/app/main.py"]
```

This Dockerfile tells us, that it is based on `ubuntu:jammy` and therefore depends on the the packages made available by Ubuntu. It is actually a multi-stage build, the `compile-image` uses `python3-dev` whereby the `runtime-image` uses only `python3`.

Apparently Ubuntu doesn't ship the required Python minor version we want to use. We can now install python from the official sources (which is a bit more difficult) or we can use the newer version of `Jammy`, which is `Noble`. This will also upgrade Python3 to 3.12, which is much more restrictive in terms of pip installation systemwide.

So we need to change the `Dockerfile` a little (`FROM`s and add `--break-system-packages`):

```Dockerfile
FROM ubuntu:noble AS compile-image

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update \
    && apt-get install -y python3-pip python3-dev pkg-config libhdf5-dev  \
    && cd /usr/local/bin \
    && ln -s /usr/bin/python3 python 

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir -r requirements.txt --user --break-system-packages && \
    pip list

# Run image
FROM ubuntu:noble AS runtime-image
...
```

Now rebuild/retest the image.

```sh
docker build -t uptonight-patched --load .
tmas scan -V docker:uptonight-patched | \
  jq -r '.vulnerabilities.findings.Medium[] | select(.fix!="not-fixed") | [.id, .name, .version, .fix] | @tsv'
```

Nothing to fix in Medium anymore and if we check for all vulnerabilities we now have only 18 left, which are not fixable currently. Good job!

But is UpTonight still working?

```sh
docker run -e LONGITUDE="11d34m51.50s" -e LATITUDE="48d08m10.77s" -e ELEVATION=519 -e TIMEZONE="Europe/Berlin" -v ./out:/app/out uptonight-patched
```

Wahoo! We made it.

Lastly, deactivate the python virtual environment:

```sh
deactivate
```

## Secrets - How to Deal with False Positives (Python Example)

Here, we're going to tackle false positives in the scan results.

Depending on the programming language used in a containerized app and how it got containerized `tmas` will likely discover lots of generic secrets. These false positives are usually found within unit tests or examples included in the language runtime distribution.

Let's play again with [UpTonight](https://github.com/mawinkler/uptonight).

First, let's run a scan on the `2.2` image:

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

Not that bad! Feel free to inspect the remaining secrets discovered.

## Finally, a Properly Stripped Down Image

As promised, let's see the difference with a properly stripped down image of the same application, now in version 2.3:

```sh
tmas scan -VS registry:mawinkler/uptonight:2.3
```

```json
{
  "vulnerabilities": {
    "totalVulnCount": 15,
    "criticalCount": 0,
    "highCount": 0,
    "mediumCount": 9,
    "lowCount": 4,
    "negligibleCount": 2,
    "unknownCount": 0,
    "overriddenCount": 0,
...
  },
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
