# Deep Security

This configuration is to simulate an on-premise Deep Security environment meant to be used in integration and migration scenarios. For simulation purposes it creates a dedicated VPC with the most commonly used architecture, private and public subnets accross two availability zones. It includes everything what a VPC should have, this is amongst others an internet gateway, NAT gateway, security groups, etc.

The Deep Security Manager is deployed to the private subnet. It uses an AWS RDS PostgreSQL in the private subnet. Access to Deep Security is granted by the help of a bastion host in the public subnet. This host supports ssh tunneling and acts as an upstream proxy on port 4119.

To create a Deep Security instance run

```sh
pgo --apply dsm
```

To create Computers activated with the Deep Security Manager run

```sh
pgo --apply dsw
```

To destroy the instance run

```sh
pgo --destroy dsw
pgo --destroy dsm
```

An applied dsm configuration can be quickly stopped and started via the commands `dsm stop` and `dsm start` without losing any configurations within Deep Security.

To come:

- Documentation of integraion scenarios:
  - DS with V1ES
    - WS with V1ES
- Documentation of migration scenarios:
    - DS --> V1ES
    - WS --> V1ES
- Creation of protected instances and policies.
