# Scenario: Shift Left Security - Scan a Helm Chart

## Prerequisites

- Vision One Container Security Artifact Scanner API-Key with the following permissions:
    - Cloud Security Operations
        - Container Protection
            - Run artifact scan

Ensure to have the latest `tmas` deployed:

```sh
tmcli-update
```

## Why Scanning a Helm Chart?

So you want to use someone else Helm chart in your cluster but want to know if it is compliant to your cluster policy before deploying it?

## Preparations

First, set the Artifact Scanner API-Key as an environment variable:

```sh
export TMAS_API_KEY=<YOUR API-Key>
```

> ***Note:*** tmas defaults to the Vision One service region `us-east-1`. If your Vision One is serviced from any other region you need to add the `--region` flag to the scan request.
> 
> Valid regions: `[ap-southeast-2 eu-central-1 ap-south-1 ap-northeast-1 ap-southeast-1 us-east-1]`

## Scan a Heml Chart

A simple approach is to *template* the chart locally, extract all the uniq images that will be used in the deployment, and iterate with `tmas` over these images.

For this simple exercise we're using the Vision One Container Security chart. Make sure to include your `overrides.yaml`.

Example `overrides.yaml`:

```yaml
cloudOne: 
    apiKey: <THE GENERATED API KEY>
    endpoint: https://container.us-1.cloudone.trendmicro.com
    exclusion: 
        namespaces: [kube-system]
    runtimeSecurity:
        enabled: true
    inventoryCollection:
        enabled: true
```

Scanning all the images used by this chart requires just two lines of shell code:

```sh
# Template the chart
helm template trendmicro \
  --namespace trendmicro-system \
  --create-namespace \
  --values overrides.yaml \
  https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz > manifest.yaml

# Scan the images
for image in $(cat manifest.yaml | \
  grep "image:" | sed 's/^[^"]*"\([^"]*\)".*/\1/' | sort |  uniq); \
  do tmas scan -V registry:$image ; done
```

You may adapt the scanning parameters to your needs, e.g. to enable secrets scan. The scan results will be visible within Shift-left-Security on the Vision One Console.

🎉 Success 🎉
