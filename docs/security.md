# Playground One Security



## Network

## EKS

### 5.4. Cluster Networking

***Restrict Access to the Control Plane Endpoint***

Authorized networks are a way of specifying a restricted range of IP addresses that are permitted to access your cluster's control plane. Kubernetes Engine uses both Transport Layer Security (TLS) and authentication to provide secure access to your cluster's control plane from the public internet. This provides you the flexibility to administer your cluster from anywhere; however, you might want to further restrict access to a set of IP addresses that you control. You can set this restriction by specifying an authorized network.

Restricting access to an authorized network can provide additional security benefits for your container cluster, including:

- Better protection from outsider attacks: Authorized networks provide an additional layer of security by limiting external access to a specific set of addresses you designate, such as those that originate from your premises. This helps protect access to your cluster in the case of a vulnerability in the cluster's authentication or authorization mechanism.
- Better protection from insider attacks: Authorized networks help protect your cluster from accidental leaks of master certificates from your company's premises. Leaked certificates used from outside Cloud Services and outside the authorized IP ranges (for example, from addresses outside your company) are still denied access.

By enabling private endpoint access to the Kubernetes API server, all communication between your nodes and the API server stays within your VPC. You can also limit the IP addresses that can access your API server from the internet, or completely disable internet access to the API server.

With this in mind, you can update your cluster accordingly using the AWS CLI to ensure that Private Endpoint Access is enabled.

If you choose to also enable Public Endpoint Access then you should also configure a list of allowable CIDR blocks, resulting in restricted access from the internet. If you specify no CIDR blocks, then the public API server endpoint is able to receive and process requests from all IP addresses by defaulting to ['0.0.0.0/0'].

For example, the following command would enable private access to the Kubernetes API as well as limited public access over the internet from a single IP address (noting the /32 CIDR suffix):

```sh
aws eks update-cluster-config --region ${aws_region} --name ${cluster_name} --resources-vpc-config endpointPrivateAccess=true, endpointPrivateAccess=true,publicAccessCidrs="203.0.113.5/32"
```

Audit - Playground One:

```sh
cd ${ONEPATH}/awsone/4-cluster-eks
cluster_name=$(terraform output -raw cluster_name)

echo Cluster private access enpoint enabled:
aws eks describe-cluster --name ${cluster_name} --query "cluster.resourcesVpcConfig.endpointPrivateAccess"

echo Cluster public access enpoint enabled:
aws eks describe-cluster --name ${cluster_name} --query "cluster.resourcesVpcConfig.endpointPublicAccess"

echo Cluster public access CIDRs:
aws eks describe-cluster --name ${cluster_name} --query "cluster.resourcesVpcConfig.publicAccessCidrs"
```

```sh
# Example
Cluster private access enpoint enabled:
true
Cluster public access enpoint enabled:
true
Cluster public access CIDRs:
[
    "84.190.104.66/32"
]
```


References: <https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html>

CIS Controls:

- 4.4 Implement and Manage a Firewall on Servers Implement and manage a firewall on servers, where supported. Example implementations include a virtual firewall, operating system firewall, or a third-party firewall agent.
- 9.3 Maintain and Enforce Network-Based URL Filters Enforce and update network-based URL filters to limit an enterprise asset from connecting to potentially malicious or unapproved websites. Example implementations include category-based filtering, reputation-based filtering, or through the use of block lists. Enforce filters for all enterprise assets.
- 7.4 Maintain and Enforce Network-Based URL Filters Enforce network-based URL filters that limit a system's ability to connect to websites not approved by the organization. This filtering shall be enforced for each of the organization's systems, whether they are physically at an organization's facilities or not.

***Ensure clusters are created with Private Endpoint Enabled and Public Access Disabled***

In a private cluster, the master node has two endpoints, a private and public endpoint. The private endpoint is the internal IP address of the master, behind an internal load balancer in the master's VPC network. Nodes communicate with the master using the private endpoint. The public endpoint enables the Kubernetes API to be accessed from outside the master's VPC network.

Although Kubernetes API requires an authorized token to perform sensitive actions, a vulnerability could potentially expose the Kubernetes publically with unrestricted access. Additionally, an attacker may be able to identify the current cluster and Kubernetes API version and determine whether it is vulnerable to an attack. Unless required, disabling public endpoint will help prevent such threats, and require the attacker to be on the master's VPC network to perform any attack on the Kubernetes API.
Impact:

Configure the EKS cluster endpoint to be private.

1. LeavetheclusterendpointpublicandspecifywhichCIDRblockscan communicate with the cluster endpoint. The blocks are effectively a whitelisted set of public IP addresses that are allowed to access the cluster endpoint.
2. ConfigurepublicaccesswithasetofwhitelistedCIDRblocksandsetprivate endpoint access to enabled. This will allow public access from a specific range of public IPs while forcing all network traffic between the kubelets (workers) and the Kubernetes API through the cross-account ENIs that get provisioned into the cluster VPC when the control plane is provisioned.

Audit - Playground One (see above)

References: <https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html>

CIS Controls:

- 4.4 Implement and Manage a Firewall on Servers Implement and manage a firewall on servers, where supported. Example implementations include a virtual firewall, operating system firewall, or a third-party firewall agent.
- 12 Boundary Defense

***Ensure clusters are created with Private Nodes***

Disabling public IP addresses on cluster nodes restricts access to only internal networks, forcing attackers to obtain local network access before attempting to compromise the underlying Kubernetes hosts.

To enable Private Nodes, the cluster has to also be configured with a private master IP range and IP Aliasing enabled.

Private Nodes do not have outbound access to the public internet. If you want to provide outbound Internet access for your private nodes, you can use Cloud NAT or you can manage your own NAT gateway.

Audit - Playground One (see above)

References: <https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html>

CIS Controls:

- 4.4 Implement and Manage a Firewall on Servers Implement and manage a firewall on servers, where supported. Example implementations include a virtual firewall, operating system firewall, or a third-party firewall agent.
- 12 Boundary Defense

***Ensure Network Policy is Enabled and set as appropriate***

```sh
cd ${ONEPATH}/awsone/4-cluster-eks
cluster_name=$(terraform output -raw cluster_name)

echo Cluster security group id:
aws eks describe-cluster --name ${cluster_name} --query "cluster.resourcesVpcConfig.clusterSecurityGroupId"
```

```sh
# Example
Cluster security group id:
"sg-0a8c50569b529a3b3"
```

CIS Controls:

- 12.6 Use of Secure Network Management and Communication Protocols. Use secure network management and communication protocols (e.g., 802.1X, Wi-Fi Protected Access 2 (WPA2) Enterprise or greater).
- 9.2 Ensure Only Approved Ports, Protocols and Services Are Running. Ensure that only network ports, protocols, and services listening on a system with validated business needs, are running on each system.
- 9.4 Apply Host-based Firewalls or Port Filtering Apply host-based firewalls or port filtering tools on end systems, with a default-deny rule that drops all traffic except those services and ports that are explicitly allowed.

***Encrypt traffic to HTTPS load balancers with TLS certificates***

Encrypting traffic between users and your Kubernetes workload is fundamental to protecting data sent over the web.

Audit:

Your load balancer vendor can provide details on auditing the certificates and policies required to utilize TLS.

CIS Controls:

- 3.10 Encrypt Sensitive Data in Transit. Encrypt sensitive data in transit. Example implementations can include: Transport Layer Security (TLS) and Open Secure Shell (OpenSSH).
- 14.4 Encrypt All Sensitive Information in Transit Encrypt all sensitive information in transit.

## Vision One Container Security

The API key is used for communication with the backend throughout the life of the in-cluster app.

The API key is generated when generating the cluster and copied to the `overrides.yaml`.

Determine whether to use existing secrets in the target namespace rather than specifying in overrides.yaml. Useful if you want to manage secrets on your own, e.g., in argocd.

When this is enabled, typically you will need these secrets created in your target namespace.
(names may vary depending on your settings):

- trendmicro-container-security-auth
- trendmicro-container-security-outbound-proxy-credentials

You can fill overrides.yaml and use helm install --dry-run to generate these secret's
template.

After deployment, if you update the secret after deployment, you will need to restart pods of
container security to make changes take effect.

`useExistingSecrets: false`
