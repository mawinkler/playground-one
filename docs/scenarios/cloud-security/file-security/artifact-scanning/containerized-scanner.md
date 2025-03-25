# Scenario: Containerized Scanner

## Prerequisites

- A Kubernetes Cluster of your choice
  - eks-ec2
  - kind
  - your own flavour :-)

## Deployment

Create and copy the v1-registration token. This is used for onboarding and registering your scanner with Trend Micro.

`Cloud Security --> File Security --> Containerized Scanner --> Get Registration Token`

```sh
export FSS_CS_TOKEN=<YOUR Token>
kubectl create namespace visionone-filesecurity
kubectl create secret generic token-secret --from-literal=registration-token="${FSS_CS_TOKEN}" -n visionone-filesecurity
kubectl create secret generic device-token-secret -n visionone-filesecurity
```

Download the Helm chart containing the scanner from the GitHub repository

```sh
helm repo add visionone-filesecurity https://trendmicro.github.io/visionone-file-security-helm/
helm repo update
```

Deploy

```sh
helm install file-security visionone-filesecurity/visionone-filesecurity -n visionone-filesecurity
```


## Verify that the scanner is working

```sh
export SERVICE_NAME=$(kubectl get svc --namespace visionone-filesecurity \
  -l "app.kubernetes.io/name=visionone-filesecurity,app.kubernetes.io/instance=file-security" \
  -o jsonpath="{.items[*].metadata.name}" | tr ' ' '\n' | grep 'scanner$')
echo $SERVICE_NAME
```

The above should return `file-security-visionone-filesecurity-scanner`.

## Test it using the CLI

Create a pod with an interactive shell

```sh
kubectl run -it --image=ubuntu kshell --restart=Never --labels=kshell=true --rm -- /bin/bash
```

```sh
cd

apt update && apt install -y curl jq

curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/tmcli-update | bash
```

Your first scan

```sh
curl -OL https://secure.eicar.org/eicarcom2.zip

export TMFS_API_KEY=<Your V1 FSS_API_KEY>
tmfs scan file:./eicarcom2.zip \
  --tls=false --endpoint=file-security-visionone-filesecurity-scanner.visionone-filesecurity.svc.cluster.local:50051
```

🎉 Success 🎉
