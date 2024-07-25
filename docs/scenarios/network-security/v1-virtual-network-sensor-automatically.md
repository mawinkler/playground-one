# Scenario: Deploying Virtual Network Sensor on AWS Automatically

***Draft***

!!! warning "NOT FINISHED YET"

    Solve dependency with instances. Create Traffic Mirror Session in instances when VNS is enabled. 

## Prerequisites

- Playground One Network
- Activated Marketplace AMI for Trend Virtual Network Sensor BYOL

You need to have activated the Trend Virtual Network Sensor BYOL
 AMI in Marketplace once. To do this, on the AWS Console choose the service EC2 and navigate to `Images --> AMI Catalog`. Select the tab `AWS Marketplace AMIs` and seach for `Trend Micro Virtual Network Sensor`.

![alt text](images/v1-aws-sgm-03.png "Vision One")

There should only be one AMI shown for your current region. Click on `[Select]` and `[Subscribe on instance launch]`. 

![alt text](images/v1-aws-sgm-04.png "Vision One")

Now, check your Playground One configuration.

Verify, that you have `AWS SG - create Virtual Network Sensor` enabled in your configuration.

```sh
pgo --config
```

```sh
...
VNS - create Virtual Network Sensor? [true]: 
VNS - Virtual Network Sensor Token [eyJhbGciOi]: 
...
```

Ensure to have the Playground One Network and Linux Instances up and running:

```sh
# Network configuration
pgo --apply network

# Instances configuration
pgo --apply instances
```

## Test It

Connect to the `linux_web` instance

```sh
pgo -o instances
 __                 __   __   __             __      __        ___ 
|__) |     /\  \ / / _` |__) /  \ |  | |\ | |  \    /  \ |\ | |__  
|    |___ /~~\  |  \__> |  \ \__/ \__/ | \| |__/    \__/ | \| |___ 
                                                                   
Using PDO User Access Key ID: ...S7CH
Configuration instances in directory /home/markus/projects/opensource/playground/playground-one/awsone/3-instances
instance_ip_linux_db = "18.194.28.64"
instance_ip_linux_web = "18.185.107.182"
instance_username_linux_server = "ubuntu"
s3_bucket = "pgo-id-bucket-vkdhir40"
ssh_instance_linux_db = "ssh -i /home/markus/projects/opensource/playground/playground-one/pgo-id-key-pair-51f2emm2.pem -o StrictHostKeyChecking=no ubuntu@18.194.28.64"
ssh_instance_linux_web = "ssh -i /home/markus/projects/opensource/playground/playground-one/pgo-id-key-pair-51f2emm2.pem -o StrictHostKeyChecking=no ubuntu@18.185.107.182"
``´

```sh
ssh -i /home/markus/projects/opensource/playground/playground-one/pgo-id-key-pair-51f2emm2.pem -o StrictHostKeyChecking=no ubuntu@18.185.107.182
```

Now install `nmap` to trigger a simple detection with our Virtual Network Sensor.

```sh
sudo apt update
sudo apt install -y nmap
```

Scan the subnet

```sh
nmap 10.0.4.0/24
```

```sh
Starting Nmap 7.80 ( https://nmap.org ) at 2024-07-25 11:15 UTC
Nmap scan report for ip-10-0-4-13.eu-central-1.compute.internal (10.0.4.13)
Host is up (0.000074s latency).
Not shown: 998 closed ports
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http

Nmap scan report for ip-10-0-4-57.eu-central-1.compute.internal (10.0.4.57)
Host is up (0.00040s latency).
Not shown: 986 filtered ports
PORT     STATE  SERVICE
20/tcp   closed ftp-data
21/tcp   closed ftp
22/tcp   open   ssh
25/tcp   closed smtp
53/tcp   closed domain
80/tcp   closed http
110/tcp  closed pop3
113/tcp  closed ident
143/tcp  closed imap
443/tcp  closed https
993/tcp  closed imaps
1521/tcp closed oracle
3306/tcp closed mysql
5560/tcp closed isqlplus

Nmap done: 256 IP addresses (2 hosts up) scanned in 7.67 seconds
```

Head over to XDR Threat Investigation -> Observed Attack Techniques.

Set the Risk Level to include `Medium` and Datasource to `Network -> Network Sensor`. The following detection should pop up:

![alt text](images/vns-detection-01.png "Detection")
