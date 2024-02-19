# Frequently asked Questions

## How to update the Playgound One?

The Playground is under contiuous development. Even if I try to not implement breaking changes please follow the steps below ***before*** updating it to the latest version:

```sh
# Destroy your deployments
pgo --destroy all

# Destroy your network
pgo --destroy nw

# Do the update
cd ${ONEPATH}
git pull

# Run config
pgo --config
```

If everything went well you should be able to recreate your environment. If you run into trouble please open an [issue](https://github.com/mawinkler/playground-one/issues/new).

## I'm running the Playground on a Cloud9 and want to restrict access to my home IP

If you work on a Cloud9 you need to take care on two public IP addresses instead of one when having the playground locally. These are the public IP of your own network (where your own computer is located) and the public IP of your Cloud9.

Your own IP is required since you likely want to access the applications provided by the Playground One running on EKS, ECS and connect to the EC2 instances.

The public IP of the Cloud9 is required to allow your Cloud9 access the EC2 instances while provisioning.

For this to work you need to define two `Access IPs/CIDRs` in the configuration workflow with `pgo --configure`.

**Example:**

Public IP address of your

- Cloud 9 instance: `3.123.18.11` (get it from the EC2 console), and
- Client at home: `87.170.6.193`

```sh
 __                 __   __   __             __      __        ___ 
|__) |     /\  \ / / _` |__) /  \ |  | |\ | |  \    /  \ |\ | |__  
|    |___ /~~\  |  \__> |  \ \__/ \__/ | \| |__/    \__/ | \| |___ 
                                                                   
...
Please set/update your Playground One configuration
Access IPs/CIDRs []: 3.123.18.11, 87.170.6.193
...
```

The above will automatically be converted into the correct CIDRs `3.123.18.11/32, 87.170.6.193/32`

To simplify this process you can easily let the config tool determine the Cloud9 public IP address by entering the keyword `pub`.

```sh
...
Please set/update your Playground One configuration
Access IPs/CIDRs []: pub, 87.170.6.193
...
```

Then run

```sh
pgo --init nw
pgo --apply nw
```

## My IP address has changed and I cannot access my environment anymore

If you need to change the access IP later on, maybe your provider assigned you a new one, follow these steps:

1. Run `pgo --updateip` and set the new IP address as described in [Getting Started Configuration](getting-started/configuration.md#section-playground-one)
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

This should be completed within a minute.

If the above didn't work for you and you still need to update the IP(s) you need to run

```sh
pgo --destroy all
pgo --init all
pgo --apply nw
```

Then reapply your eks, ecs, ec2 or scenarios by `pgo --apply <configuration>`.

## I restarted my Cloud9 instance and I cannot access my environment anymore

See above.

## I cannot destroy the ECS cluster(s)

If you have enabled `Runtime Scanning` and/or `Runtime Security` in your Vision One console for your ECS clusters disable them and press `[Save]`. Wait for the container security services/tasks disappear on the EC2 console. The clusters should then be successfully destroyed.

***Background:*** Vision One injects addisional tasks to the ECS clusters which are not known by the playground. Even if you delete the task in the AWS console they are injected again by Vision One. This causes a remaining dependency on the AWS side which prevents the destruction of ECS.

***Special case for ECS EC2***

There's a known bug in Terraform. The problem is that this new capacity_provider property on the aws_ecs_cluster introduces a new dependency:
aws_ecs_cluster depends on aws_ecs_capacity_provider depends on aws_autoscaling_group.

This causes terraform to destroy the ECS cluster before the autoscaling group, which is the wrong way around: the autoscaling group must be destroyed first because the cluster must contain zero instances before it can be destroyed.

This leads to Terraform error out with the cluster partly alive and the capacity providers fully alive.

The `pgo` CLI solves this problem by running `aws` CLI commands to delete the capacity providers before doing `terraform destroy`. Not nice but works.

## I don't find the `todolist`-app of Java-Goof

To access the `todolist` application append `/todolist` to the loadbalancer DNS name in your browser.

For authentication use:

- Username: `foo@bar.org`
- Password: `foobar`

## Upgrade Vision One Container Security to the latest Release

```sh
helm get values --namespace trendmicro-system container-security | helm upgrade container-security \
    --namespace trendmicro-system \
    --values - \
    https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz
```
