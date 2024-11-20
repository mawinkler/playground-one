# Frequently asked Questions

## How to update the Playgound One Container

Typically, a complete upgrade of the Playground One Container is not necessary, since you can easily update the *"internals"* of the container at runtime.

***Update the Internals***

Being inside the container do the following:

- Ideally destroy applied infrastructure. This is not a must but if you can you'd avoid some potential trouble later on.
    ```sh
    # Destroy your deployments
    pgo --destroy all

    # Destroy your network
    pgo --destroy nw
    ```

- Change to the `playground-one` directory.

    ```sh
    # Do the update
    cd ${ONEPATH}
    ```

- Run `git pull` to update the Playground One.
- Run `pgo --init all` to upgrade the Terraform Providers.

    ```sh
    # Do the update
    git pull
    pgo --init all
    ```

- Continue playing 🎡.

***Upgrade the Container***

Updating the container or changing to a different release of the container can be done following these steps:

- Edit the file `.PGO_VERSION` to set the version you want (e.g. `0.4.8`).
- Run `./pgoc update`
   - This will backup your current `workdir` and save your `config.yaml`.
   - The desired version of the container is pulled and a new `workdir` is created.
   - The previous `config.yaml` is restored alongside the possibly existing `.aws` config.
- Start the new container with `./pgoc start` and login via ssh. You likely get an error when connecting with ssh. If so, delete the offending line in `~/.ssh/known_hosts` and retry.
- Run `pgo --init all` to upgrade the Terraform Providers.
- Continue playing 🎠.

## How to update the Playgound One when running Natively?

The Playground is under contiuous development. Even if I try to not implement breaking changes please follow the steps below ***before*** updating it to the latest version:

```sh
# Destroy your deployments
pgo --destroy all

# Destroy your network
pgo --destroy nw

# Do the update
cd ${ONEPATH}
git pull

# Update Terraform Providers
pgo --init all
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

## Inspect the Kubernetes Manifest of Container Security

If you want to inspect the full kubernetes manifest of Container Security deployed on your environment run:

```sh
helm get values --namespace trendmicro-system container-security | helm template container-security \
  --namespace trendmicro-system \
  --values - \
  https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz > manifest.yaml
```

## AWS EC2 Instance Connect does not work from the AWS EC2 Console

EC2 Instance Connect uses specific IP address ranges for browser-based SSH connections to your instance (when users use the Amazon EC2 console to connect to an instance). These IP address ranges are documented [here](https://ip-ranges.amazonaws.com/ip-ranges.json).

To filter this large list for instance connect run:

```sh
jq '.prefixes[] | select(.service=="EC2_INSTANCE_CONNECT") | .' ip-ranges.json
```

Currently, Playground One does only allow Instance Connect from the following regions:

Region | IP address range
------ | ----------------
eu-central-1 | 3.120.181.40/29
eu-west-1 | 18.202.216.48/29
eu-west-2 | 3.8.37.24/29
eu-west-3 | 35.180.112.80/29
eu-north-1 | 13.48.4.200/30
us-east-1 | 18.206.107.24/29
us-east-2 | 3.16.146.0/29
us-west-1 | 13.52.6.112/29
us-west-2 | 18.237.140.160/29

If you need any other reagion, please let me know.

See:

- [AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-linux-inst-eic.html)
- [AWS IP Ranges](https://docs.aws.amazon.com/vpc/latest/userguide/aws-ip-ranges.html)

## Know how to check the region and Data Center location details in Trend Vision One

To find out API URLs and datacenter locations, check the Vision One Site URL you are using:

Site | Vision One Site                      
---- | -------------------------------------
US   | https://portal.xdr.trendmicro.com/   
EU   | https://portal.eu.xdr.trendmicro.com/
JP   | https://portal.jp.xdr.trendmicro.com/
SG   | https://portal.sg.xdr.trendmicro.com/
AU   | https://portal.au.xdr.trendmicro.com/
IN   | https://portal.in.xdr.trendmicro.com/

This takes you to the Region Code and API URL:

Site | Region Code    | API URL
---- | -------------- | ---------------------------------
US   | us-east-1      | https://api.xdr.trendmicro.com
EU   | eu-central-1   | https://api.eu.xdr.trendmicro.com
JP   | ap-northeast-1 | https://api.xdr.trendmicro.co.jp
SG   | ap-southeast-1 | https://api.sg.xdr.trendmicro.com
AU   | ap-southeast-2 | https://api.au.xdr.trendmicro.com 
IN   | ap-south-1     | https://api.in.xdr.trendmicro.com

The Data Centers for the locations are then listed below:

Site | Data Center Name | Data Center Location Azure | Data Center Location AWS
---- | ---------------- | -------------------------- | ------------------------
US   | United States    | East US - N. Virginia      | East US - N. Virginia
EU   | Germany          | West Europe - Netherlands  | Frankfurt, Germany
JP   | Japan            | Tokyo, Japan               | Tokyo, Japan
SG   | Singapore        | Singapore                  | Singapore
AU   | Australia        | Australia Central          | Sidney, Australia
IN   | India            | Mumbai                     | Mumbai

Link: [Trend Micro Business Success Portal](https://success.trendmicro.com/dcx/s/solution/000296614?language=en_US)

## How to use Docker inside the Playground One Container?

So, this depends, but typically is easy. Actually, it depends on the `/var/run/docker.sock` available on the host and therefore on the container engine you're using. Depending on the runtime the socket does have different ACLs set. Check them by running

```sh
ls -l /var/run/docker.sock`
```

```sh
# On Ubuntu
srw-rw---- 1 root docker 0 Oct  7 09:44 /var/run/docker.sock
```

The above is fine, since the `pgo` user inside the container is member of the `docker` group. A `docker ps` for example should succeed.

In some cases, for example when you're using Docker Desktop on the sockets ACLs are set to `root.root` and a `docker ps` inside the container will fail because the `pgo` user is neither `root` nor in the `root` group.

To use the `docker` cli in such a situation you can switch to the root context inside the container doing the following:

```sh
sudo su -
```

If the ACL of the socket is something else than `root.docker` or `root.root` you can also try the following command:

```sh
docker4pgo
```

The above checks the group of the socket, creates this group inside the container and adds the `pgo` user to this group. Now, exit the container and reconnect. Ideally, it does work now.
