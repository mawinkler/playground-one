# Frequently asked Questions

## I'm running the Playground on a Cloud9 and want to restrict access to my home IP

There is no issue if you want to play with EKS and/or ECS. If you apply the EC2 configuration the provisioning process of the EC2 instances require that your Cloud9 can access the instances as well. For this to work you need to define two `access_ip`s.

Example:

Public IP address of your

- Cloud 9 instance: `3.123.18.11` (get it from the EC2 console), and
- Client at home: `87.170.6.193`

Within your `config.yaml` set `awsone.access_ip` to `["87.170.6.193/32","3.123.18.11/32"]`

```yaml
services:
  ...
  - name: awsone
    ## Restrict access to AWS One
    ## 
    ## To define multipe IPs/CIDRs do something like
    ## ["87.170.6.193/32","3.123.18.11/32"]
    ##
    ## Default value: ["0.0.0.0/0"]
    access_ip: ["87.170.6.193/32","3.123.18.11/32"]
```

Then run

```sh
pgo --init nw
pgo --apply nw
```
