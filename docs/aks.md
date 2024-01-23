# Playground One builds AKS

- [Playground One builds AKS](#playground-one-builds-aks)
  - [Preparations](#preparations)
  - [Start Building](#start-building)

## Preparations

Login to Azure

```sh
az login --use-device-code
```

Get your subscription ID

```sh
az account list |  grep -oP '(?<="id": ")[^"]*'
```

Make a note now of your subscription id.

Create a Service Principal

```sh
az ad sp create-for-rbac \
  --role="Contributor" \
  --scopes="/subscriptions/76ef4d98-5497-4f05-ae13-73aef5fe4c42"
```

```json
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2021-02-13-20-01-37",
  "name": "http://azure-cli-2021-02-13-20-01-37",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

Make a note of the appId, password, and tenant. You need those to set up Terraform.

## Start Building


```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```

