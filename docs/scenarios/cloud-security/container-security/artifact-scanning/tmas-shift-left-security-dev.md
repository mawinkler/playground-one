# Scenario: Shift Left Security - Scan at Development

## Prerequisites

- Vision One Container Security Artifact Scanner API-Key with the following permissions:
    - Cloud Security Operations
        - Container Protection
            - Run artifact scan

Ensure to have the latest `tmas` deployed:

```sh
tmcli-update
```

For demoing purposes we play with one of my apps, [UpTonight](https://github.com/mawinkler/uptonight). For the curious ones out there, it calculates the best astrophotography targets for the night at a given location and date. These are deep sky objects, solar system bodies and coments.

If you want to replay with [UpTonight](https://github.com/mawinkler/uptonight) run

```sh
git clone https://github.com/mawinkler/uptonight
cd uptonight
```

Alternatively, you can use any other project that contains a valid and buildable Docker file.

## Why Scanning at Development?

If you are developing an application that you want to package in a container image, the easiest way to identify security vulnerabilities is at build time, without having to push an image to a registry, have it scanned, and retrieve the scan results.

In this scenario, we'll play with two scripts from Playground One that simplify this approach. The scipts we're going to use are:

- [`bin/scan-image`](https://github.com/mawinkler/playground-one/blob/main/bin/scan-image)
- [`bin/scan-layers`](https://github.com/mawinkler/playground-one/blob/main/bin/scan-layers)

As the scripts are not dependent on Playground One, they can be used independently. Internally the scripts use the command line tool `tmas` aka Trend Micro Artifact Scanner CLI `tmas`.

## Preparations

First, set the Artifact Scanner API-Key as an environment variable:

```sh
export TMAS_API_KEY=<YOUR API-Key>
```

> ***Note:*** tmas defaults to the Vision One service region `us-east-1`. If your Vision One is serviced from any other region you need to add the `--region` flag to the scan request.
> 
> Valid regions: `[ap-southeast-2 eu-central-1 ap-south-1 ap-northeast-1 ap-southeast-1 us-east-1]`

## Scan Development Image

Make sure to be in the development directory containing the `Dockerfile`. Then run:

```sh
scan-image
```

```sh
[+] Building 256.6s (19/19) FINISHED
...
Scan Complete

Scan Results:
{
  "vulnerabilities": {
    "totalVulnCount": 17,
    "criticalCount": 0,
    "highCount": 0,
    "mediumCount": 10,
    "lowCount": 5,
    "negligibleCount": 2,
    "unknownCount": 0,
    "overriddenCount": 0
  }
}
Scan Results File: /tmp/tmp.x8PkVMgQa7/results.json
Image SBOM: /tmp/tmp.x8PkVMgQa7/sbom.json
```

The output gives us an overview on the discovered vulnerabilities and tells us where to find the full scan results and the SBOM.

By default, `scan-image` only scans for vulnerabilities. If you want to run the scan differently, simply use the `tmas` parameter syntax.

Example: `scan-image -VMS -r us-east-1`.

## Scan Development Image Layer by Layer

Alternatively, if we are interested in which layers the vulnerabilities are introduced from, we can scan layer by layer:

```sh
scan-layers
```

The results list the layers bottom up. Individual scan results and SBOMs can be reviewed in the Scan Results directory (here: `/tmp/tmp.zxJ69aloqR/`):

```sh
[+] Building 256.6s (19/19) FINISHED
...
Scanning blobs/sha256/687d50f2f6a697da02e05f2b2b9cb05c1d551f37c404ebe55fdec44b0ae8aa5c
Scan Complete

Scanning blobs/sha256/3a0695210b0c11412d2ed865de82e45cb0f6b38d9aa2effc6766a3dfe49c7be6
Scan Complete

Scanning blobs/sha256/d7f315f48e5132c45ddd07bb555247c274117454c6f20e7e7fb6ec1f5e14f471
Scan Complete

Scanning blobs/sha256/064fb442e76b7454f96d6671ce297cad3fad6be5f600c7869b531b3a977b272c
Scan Complete

layer                                                             total  critical  high  medium  low  negligible  unkown  overridden
687d50f2f6a697da02e05f2b2b9cb05c1d551f37c404ebe55fdec44b0ae8aa5c  17     0         0     10      5    2           0       0
3a0695210b0c11412d2ed865de82e45cb0f6b38d9aa2effc6766a3dfe49c7be6  0      0         0     0       0    0           0       0
d7f315f48e5132c45ddd07bb555247c274117454c6f20e7e7fb6ec1f5e14f471  0      0         0     0       0    0           0       0
064fb442e76b7454f96d6671ce297cad3fad6be5f600c7869b531b3a977b272c  0      0         0     0       0    0           0       0
Scan Results: /tmp/tmp.zxJ69aloqR/
```

The results directory contains all the contents of each layer separately. This makes it easy to analyse layer by layer.

```sh
.
├── blobs
│   └── sha256
└── disk
    └── blobs
        └── sha256
            ├── 064fb442e76b7454f96d6671ce297cad3fad6be5f600c7869b531b3a977b272c
            │   └── app
            │       └── targets
            ├── 3a0695210b0c11412d2ed865de82e45cb0f6b38d9aa2effc6766a3dfe49c7be6
            │   └── app
            ├── 687d50f2f6a697da02e05f2b2b9cb05c1d551f37c404ebe55fdec44b0ae8aa5c
            │   ├── bin -> usr/bin
            │   ├── boot
            │   ├── dev
            │   ├── etc
            │   ├── home
            │   ├── lib -> usr/lib
            │   ├── lib64 -> usr/lib64
            │   ├── media
            │   ├── mnt
            │   ├── opt
            │   ├── proc
            │   ├── root
            │   ├── run
            │   ├── sbin -> usr/sbin
            │   ├── srv
            │   ├── sys
            │   ├── tmp
            │   ├── usr
            │   └── var
            └── d7f315f48e5132c45ddd07bb555247c274117454c6f20e7e7fb6ec1f5e14f471
                └── app
```

The layer that introduces the vulnerabilities is the layer that starts with `687d50f2...` and represents the root volume of the image. The other three layers make up the actual application, where no vulnerabilities were found.

We can map the above information easily to the Dockerfile:

```Dockerfile
# 687d50f2f6a697da02e05f2b2b9cb05c1d551f37c404ebe55fdec44b0ae8aa5c
FROM ubuntu:noble AS runtime-image

# 3a0695210b0c11412d2ed865de82e45cb0f6b38d9aa2effc6766a3dfe49c7be6
WORKDIR /app

# d7f315f48e5132c45ddd07bb555247c274117454c6f20e7e7fb6ec1f5e14f471
COPY --from=compile-image /app/dist/main /app/main

# 064fb442e76b7454f96d6671ce297cad3fad6be5f600c7869b531b3a977b272c
COPY --from=compile-image /app/targets /app/targets

# Run the UpTonight executable
ENTRYPOINT ["/app/main"]
```

🎉 Success 🎉
