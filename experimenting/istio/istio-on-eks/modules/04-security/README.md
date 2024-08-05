# Module 4 - Security

This module will cover the security related capabilities of Istio service-mesh on Amazon EKS.

## Prerequisites:

To be able to work on this module you should meet the following prerequisites. Ensure that you have the following tools installed locally:
  * [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  * [terraform](https://developer.hashicorp.com/terraform/install)
  * [kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
  * [helm](https://helm.sh/docs/intro/install/)
  * [jq](https://jqlang.github.io/jq/download/)
  * [siege](https://github.com/JoeDog/siege)
    - For Homebrew based installation refer to [siege](https://formulae.brew.sh/formula/siege).
  * [istioctl](https://istio.io/latest/docs/ops/diagnostic-tools/istioctl/#install-hahahugoshortcode860s2hbhb)

## Setup
This module will create its own EKS cluster with secure Istio workload configurations.

**Note: Configuring this module in an existing cluster is not supported.**

Provision an EKS cluster with Istio and the security module resources by executing the below commands.

```bash
# This assumes that you are currently in "istio-on-eks" base directory
cd modules/04-security/terraform
terraform init
terraform apply -auto-approve
```
**Note**: The terraform stack can take between 25 to 30 minutes to provision all the resources required for this module. Take a short break and grab a cup of your favorite hot beverage. :coffee:

The terraform stack creates the following resources.
  * VPC resources to host the EKS cluster
  * EKS cluster named `istio-on-eks-04-security`
  * Private CA configured to issue short lived certificates for mutual TLS
  * `cert-manager` and `aws-privateca-issuer` addon to issue short-lived certificates from AWS Private CA
  * `cert-manager-istio-csr` to forward certificate requests from Istio control plane and workload proxies to `cert-manager`
  * Keycloak to manage application users and issue JSON Web Tokens (JWTs)
  * Istio with built-in CA disabled and configured with `cert-manager-istio-csr`
  * Gatekeeper for mutating workload deployments to enforce Open Policy Agent (OPA) based external authorization
  * Workload microservices with an HTTPS route

### Keycloak resources
The above setup installs Keycloak and creates the following Keycloak resources for request authentication and external authorization modules.

| Resource Type | Name | Purpose |
|---------------|------|---------|
| Realm | `workshop` | A container for users, roles and OIDC application client settings. |
| Client | `productapp` | OIDC application client. |
| Roles | `-` | See below section for Application Roles |
| Users | `-` | See below section for Application Users|

#### Application Roles
The following application roles are created in the `workshop` realm.

| Role | Purpose |
|------|---------------|
| `guest` | Views products list. |
| `admin` | Views and modifies products list. |
| `other` | `-` |

#### Application Users
The following application users and the corresponding role assignments are created in the `workshop` realm.

| User | Role |
|------|------|
| `alice` | `guest` |
| `bob` | `admin` |
| `charlie` | `other` |

### Scripts to interact with Keycloak
The following scripts have been provided to interact with Keycloak and configure Istio request authentication and authorization resources from the terminal.

| Name | Purpose | Arguments |
|------|---------|-----------|
| [`scripts/helpers.sh`](/modules/04-security/scripts/helpers.sh) | Contains helper functions to generate and inspect access tokens, apply authentication and authorization policies on ingress gateway, and print Keycloak admin console access information. | See below section|

### Script Arguments: `helpers.sh`

The following table lists the arguments of `helpers.sh` script:

| Short Form | Long Form | Value Type | Required | Default | Description |
|------------|-----------|------------|----------|---------|-------------|
| `-a` | `--admin` | `-` | No | `-` | Print Keycloak admin password. This is a mutually exclusive option. See [below](#mutually-exclusive-options) for more details. |
| `-c` | `--console` | `-` | No | `-` | Print Keycloak console URL. This is a mutually exclusive option. See [below](#mutually-exclusive-options) for more details. |
| `-g` | `--generate` | `-` | No | `-` | Generate access token for application user (requires `-u`\|`--user`). This is a mutually exclusive option. See [below](#mutually-exclusive-options) for more details. |
| `-u` | `--user` | `string` | Required when `-g\|--generate` is set | `-` | Application username. |
| `-i` | `--inspect` | `-` | No | `-` | Inspect access token (requires `-t`\|`--token`). This is a mutually exclusive option. See [below](#mutually-exclusive-options) for more details. |
| `-t` | `--token` | `string` | Required when `-i`\|`--inspect` is set | `-` | Access token. |
| `-w` | `--wait-lb` | `-` | No | `-` | Wait for load balancer endpoint to become healthy (requires `-l`\|`--lb-arn-pattern`). This is a mutually exclusive option. See [below](#mutually-exclusive-options) for more details. |
| `-l` | `--lb-arn-pattern` | `string` | Required when `-w`\|`--wait-lb` is set | `-` | Load balancer ARN pattern. |
| `-` | `--authn` | `-` | `-` | `-` | Apply `RequestAuthentication` manifest. This is a mutually exclusive option. See [below](#mutually-exclusive-options) for more details. |
| `-` | `--authz` | `-` | `-` | `-` | Apply `AuthorizationPolicy` manifest. This is a mutually exclusive option. See [below](#mutually-exclusive-options) for more details. |
| `-n` | `--keycloak-namespace` | `string` | No | `keycloak` | Namespace for keycloak. |
| `-r` | `--keycloak-realm` | `string` | No | `workshop` | Keycloak realm for workshop. |
| `-h` | `--help` | `-` | No | `-` | Show help message. |
| `-v` | `--verbose` | `-` | No | `-` | Enable verbose output. |

#### Mutually Exclusive Options
The below options cannot appear together for an invocation of this script.
  * `-a`, `--admin`
  * `-c`, `--console`
  * `-g`, `--generate`
  * `-i`, `--inspect`
  * `-w`, `--wait-lb`
  * `--authn`
  * `--authz`

Below are some examples of using the helper script to perform various actions related to configuring Istio request authentication and authorization.

### Examples:
---

| Action description | Script invocation |
|--------------------|-------------------|
| Generate access token for application user `alice` | `scripts/helpers.sh -g -u alice` |
| Inspect generated access token | `scripts/helpers.sh -i -t {TOKEN}` |
| Apply `RequestAuthentication` manifest | `scripts/helpers.sh --authn` |
| Apply `AuthorizationPolicy` manifest | `scripts/helpers.sh --authz` |
| Print Keycloak admin console URL | `scripts/helpers.sh -c` |
| Print Keycloak admin user password | `scripts/helpers.sh -a` |

**Note:** Remember to set the correct AWS region in the terminal window before invoking the script.
For example, in the bash terminal window execute the following. Make sure the region is the one where the terraform stack has created the keycloak resources.

```bash
export AWS_REGION=us-west-2
```

### Install Observability Tools
Use the following code snippet to add the Istio Observability add-ons to the EKS cluster with deployed Istio.
```
for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done
```

#### Configure Port Forwarding for Kiali
Run the following command in the terminal session to port-forward kiali traffic on to a designated port on your localhost.
```
kubectl port-forward svc/kiali 8080:20001 -n istio-system
```

## 🧱 Sub Modules of Security

### [1. Peer Authentication](/modules/04-security/peer-authentication/README.md)
### [2. Request Authentication](/modules/04-security/request-authentication/README.md)
### [3. Ingress Security](/modules/04-security/ingress-security/README.md)
### [4. OPA based External Authorization](/modules/04-security/opa-external-authorization/README.md)

## Clean up
Clean up all the resources using `terraform destroy` command.

```bash
terraform destroy -auto-approve
```
