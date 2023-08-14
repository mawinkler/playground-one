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

## My IP address has changed and I cannot access my apps anymore

If you need to change the access IP later on, maybe your provider assigned you a new one, follow these steps:

1. Run `pgo --udateip` and set the new IP address.
2. Terraform tells you which actions will be performed when approving them. Validate that there will be only one in-place update on the resource `module.ec2.aws_security_group.sg["public"]`.

    ```ascii
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
      ~ update in-place

    Terraform will perform the following actions:

      # module.ec2.aws_security_group.sg["public"] will be updated in-place
      ~ resource "aws_security_group" "sg" {
            id                     = "sg-01e76a72ffd468baa"
          ~ ingress                = [
    ...
    ```

3. Approve the actions by entering `yes`, otherwise press `^c`.

If you have applied any of the configurations below you need to reapply them to update the IP address in the ingresses as well:

Configuration | Run
------------- | ---
`ecs` | `pgo --init ecs`<br>`pgo --apply ecs`
`scenarios` | `pgo --init scenarios`<br>`pgo --apply scenarios`

This should be completed within seconds.

If the above didn't work for you and you still need to update the IP(s) you need to run

```sh
pgo --destroy all
pgo --init all
pgo --apply nw
```

Then reaply your eks, ecs, ec2 or scenarios by `pgo --apply <configuration>`.

## I cannot destroy the ECS EC2 cluster

The problem is that this new capacity_provider property on the aws_ecs_cluster introduces a new dependency:
aws_ecs_cluster depends on aws_ecs_capacity_provider depends on aws_autoscaling_group.

This causes terraform to destroy the ECS cluster before the autoscaling group, which is the wrong way around: the autoscaling group must be destroyed first because the cluster must contain zero instances before it can be destroyed.

This leads to Terraform error out with the cluster partly alive and the capacity providers fully alive.

I don't have a proper fix for that, yet. For now, initiate the `destroy` process via `pgo -d ecs` and head over to the AWS EC2 console --> Auto Scaling groups. Select the two groups with the prefix of your environment name and choose the Action `Delete`.

## I don't find the `todolist`-app of Java-Goof

To access the `todolist` application append `/todolist` to the loadbalancer DNS name in your browser.

For authentication use:

- Username: `foo@bar.org`
- Password: `foobar`
