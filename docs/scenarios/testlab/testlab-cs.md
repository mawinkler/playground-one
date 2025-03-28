# Scenario: File Crunching with PGOWeb


## Prerequisites

- Playground One Active Directory

Verify, that you have `AWS AD - create PGO Active Directory` enabled in your configuration.

```sh
pgo --config
```

```sh
...
AWS AD - create PGO Active Directory [true]: 
...
```

```sh
# With PGO AD enabled
pgo --apply network
```

## Development Status

### Working, ready for Testing as of 03/07/2025

- VPC including all required networking configurations.
  - Public, private, dababase, intranet subnets
  - Security groups
  - Internet & NAT gateway
  - etc.
- Within the VPC an (optional) Active Directory based on Windows Server 2022 is available.
  - SSL is supported.
  - It can easily be prepulated with users and groups, etc.
- Management Server within AWS aka Playground Satellite.
  - The Satellite is accessible via Instance Connect (from within the AWS Console) for users with the required permissions :-)
- AWS User creation with Playground's required permissions only.
- Trend Solutions
  - Deep Security Manager. Selected servers can automatically activate against the DSM.
  - Deep Discovery Inspector
  - Service Gateway
- Creation of Windows, Linux servers according to specification (to be defined)

All of the above are terraformed and controlled using the Playground CLI tool pgo.

Latest additions:

- Converting manually installed solutions/products into reusable AMIs
  - To the best of my knowledge, most of the Trend products which are currently discussed do not support a programmatic way for the implementation and configuration. This means, that someone has to implement the products including a required base configuration. The instances are created by the Playground (according to the requirements) and can then be snapshotted including the creation of the AMIs.
  - These AMIs can be reused later on if the evironment was somehow broken.
  - If a new product version is required, setup and configuration is again performed manually, followed by the creation of an AMI.
  - *Attention: I didn't do any testing with Apex etc. yet. I only tested with freshly built Windows Servers.*

### ToDo or to Decide

- Secure Access via VPN
  - I started the implementation based on Wireguard since we're not allowed to implement AWS Client VPN.
  - It's a little unclear to me how much we're violating the guidelines, but I don't see any other viable approach.
  - The 'custom' VPN should do the job when finished, the user management may be a little manual, but it should do the trick.
- Active Directory will probably complicate things, and I don't know how important it is for the test lab. This is where the requirements need to be specified.
- I am still having some problems with creating GPOs using Powershell. Anyone out there?
- Creating snapshots of the testlab is automated and seems to be fuctional, same as cleaning up everything. Using the AMIs to rebuild everything is not automated yet but will come. Manual testing was successful.
- Will it be necessary to have several test labs at the same time? This is technically possible, but will create some management issues later. I suggest a PoC with only one environment.
- Staffing:
  - Who can contribute to the PoC for the implementation of the Trend products? In the beginning, I think it will probably be Apex One and Apex Server.
  - Who can potentially help with some Windows Domain stuff?

## Current Limitations

- Adaptions in the configuration for multiple Windows clients with different AMIs needed.
 
## Review the Active Directory

After applying the network the Active Directory will build itself automatically. It consists out of two machines both based on Windows Server 2022:

- Windows Domain Controller 
- Windows Certification Authority

After instantiation of the virtual machines the domain is created and the servers are rebooted as required in Windows 😜.

This process takes a couple of minutes.

The output of `pgo --output network` lists some relevant info for this scenario:

```sh
...
ad_ca_ip = "3.71.6.173"
ad_dc_ip = "18.196.75.194"
ad_dc_pip = "10.0.4.107"
ad_domain_admin = "Administrator"
ad_domain_name = "pgo-id.local"
...
ad_admin_password = TrendMicro.1
```

- `ad_ca_ip`: Public IP address of your Certification Authority
- `ad_dc_ip` and `ad_dc_pip`: Public and private IP address of your Domain Controller
- `ad_domain_name`: Name of your Domain
- `ad_domain_admin` and `ad_admin_password`: Name and password for the Domain Admin

## Life-Cycle

### Create Satellite

```sh
pgo --apply satellite
```

When instance is running connect via AWS EC2 Instance Connect.

### Check PGO Configuration

```sh
cd playground-one
mv ../config.yaml .

pgo --config
```

```sh
 __                 __   __   __             __      __        ___ 
|__) |     /\  \ / / _` |__) /  \ |  | |\ | |  \    /  \ |\ | |__  
|    |___ /~~\  |  \__> |  \ \__/ \__/ | \| |__/    \__/ | \| |___ 
                                                                   
Using PDO User Access Key ID: ...4DMF
!!! Access IP mismatch !!!

Section: Playground One
Please set/update your Playground One configuration
Initialize Terraform Configurations? [false]: true
PGO Environment Name [pgo-cs]: 
Access IPs/CIDRs [87.170.20.71/32]: 87.170.20.71/32
Public IP of EC2 instance running PGO [87.170.20.71/32]: pub
Public IP(s)/CIDR(s): ["87.170.20.71/32","18.194.28.201/32"]
Running in Product Experience? [false]: 

Section: AWS
Please set/update your AWS configuration
Account ID [634503960501]: 
Region Name [eu-central-1]: 
Use PGO User? [true]: 
PGO User Access Key [AKIAZHO3CC62R6C64DMF]: 
PGO User Secret Key [DM5kpOKsBl...]: 
VPN - create PGO VPN Gateway? [true]: 
AD - create PGO Active Directory? [true]: 
MAD - create Managed Active Directory? [false]: 
SG - create Service Gateway? [false]: 
PAC - create Private Access Gateway? [false]: 
VNS - create Virtual Network Sensor? [false]: 
DDI - create Deep Discovery Inspector? [false]: 
...

Section: Vision One
Please set/update your Vision One configuration
API Key [eyJ0eXAiOi...]: 
Region Name [us-east-1]: 
ASRM - Create Predictive Attack Path(s)? [false]: 
Enable Endpoint Security Automatic Deployment? [true]: 
Endpoint Security Agent Type (TMServerAgent|TMSensorAgent) [TMServerAgent]: 
...

Section: Deep Security (on-prem)
Please set/update your Deep Security configuration
Enable Deep Security? [true]: 
License [AP-3VP6-KV...]:
Username [masteradmin]: 
Password [playground]: 
```

### Retrieve Snapshot

Currently, we use tag: `20250324-01`

```sh
pgo --snapshot-retrieve nw
 __                 __   __   __             __      __        ___ 
|__) |     /\  \ / / _` |__) /  \ |  | |\ | |  \    /  \ |\ | |__  
|    |___ /~~\  |  \__> |  \ \__/ \__/ | \| |__/    \__/ | \| |___ 
                                                                   
Using PDO User Access Key ID: ...4DMF
Configuration name: nw
Snapshot Name []: 20250324-01
Retrieveing AMIs with Snapshot Name=20250324-01
pgo-cs-pgo-ca=ami-05a12f55ae7405bcd
pgo-cs-pgo-dc=ami-0e61a9f4e07e7a6bf
pgo-cs-wireguard=ami-05b9d82424f512bfe
/home/ubuntu/playground-one/awsone/2-network/terraform.tfvars patched.
```

```sh
pgo --snapshot-retrieve testlab-cs
 __                 __   __   __             __      __        ___ 
|__) |     /\  \ / / _` |__) /  \ |  | |\ | |  \    /  \ |\ | |__  
|    |___ /~~\  |  \__> |  \ \__/ \__/ | \| |__/    \__/ | \| |___ 
                                                                   
Using PDO User Access Key ID: ...4DMF
Configuration name: testlab-cs
Snapshot Name []: 20250324-01
Retrieveing AMIs with Snapshot Name=20250324-01
pgo-cs-apex-one-central=ami-0ec4d20a387209e4c
pgo-cs-apex-one-server=ami-0262e4fa611cede56
pgo-cs-bastion=ami-0cee542f7127666ee
pgo-cs-dsm=ami-05924c7d9d2b13b5b
pgo-cs-postgresql=ami-072674ffa536a172b
pgo-cs-windows-client-0=ami-0d52d610877fedd3b
pgo-cs-windows-client-1=ami-020fc9b9b0428cecb
/home/ubuntu/playground-one/awsone/3-testlab-cs/terraform.tfvars patched.
```

### Create Network and Testlab-CS

```sh
pgo --apply network

pgo --apply testlab-cs
```

### (Optional): Create Your own Local Administrator

Before snapshotting it is advised to create a new local administrator. Being authenticated as the domain administrator run the following in powershell:

```ps
$Username = "LocalAdmin"
$Password = ConvertTo-SecureString "TrendMicro.1" -AsPlainText -Force

# Create the local user account
New-LocalUser -Name $Username -Password $Password -FullName "Local Administrator" -Description "Local Admin Account"

# Add the user to the Administrators group
Add-LocalGroupMember -Group "Administrators" -Member $Username

Write-Output "Local administrator account '$Username' has been created successfully."
```

### Snapshot Testlab Instances

```sh
pgo --freeze testlab-cs
```

Name the Snapshot, e.g. `v1`.

After the snapshot has been created ***and the AMIs are not in pending state anymore*** you can destroy the Testlab with `--destroy testlab-cs`.

The same can be done for the Active Directory which is part of the `network` configuration.

```sh
pgo --freeze nw
```

### Retrieve Testlab Snapshot

```sh
pgo --freeze testlab-cs-retrieve
```

Enter the Snapshots Name, e.g. `v1`.

The `3-testlab-cs/terraform.tfvars` will be configured automatically. The `windows_count` variable is now ignored.

Then

```sh
pgo --apply testlab-cs
```

When the instances are up either use the domain admin of local admin from above to connect.

Same for the Active Directory.

```sh
pgo --freeze nw-retrieve
```

### Delete Snapshots:

```sh
pgo --freeze testlab-cs-delete
```

Enter the Snapshots Name, e.g. `v1`.

Same for the Active Directory.

```sh
pgo --freeze nw-delete
```

🎉 Success 🎉

## Private IP Assignments

Configuration | Instance     | Private IP
------------- | ------------ | ----------
Network       | Wireguard*   | 10.0.4.10 
TestLab-CS    | Bastion*     | 10.0.4.11 
Network       | pgo-dc       | 10.0.0.10 
Network       | pgo-ca       | 10.0.0.11 
Network       | sg           | 10.0.0.12
TestLab-CS    | DSM          | 10.0.0.20 
TestLab-CS    | Apex One     | 10.0.0.22 
TestLab-CS    | Apex Central | 10.0.0.23 
TestLab-CS    | PostgreSQL   | 10.0.0.24 
Network       | ddi          | 10.0.1.2
TestLab-CS    | Client 0     | 10.0.1.10 
TestLab-CS    | Client 1     | 10.0.1.11 
TestLab-CS    | Client x     | 10.0.1.xx 

## From ISO to AMI

Get QEMU

```sh
brew install qemu
```

### Service Role

trust-policy.json

```json
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:Externalid": "vmimport"
            }
         }
      }
   ]
}
```

```sh
aws iam create-role --role-name vmimport --assume-role-policy-document "file://trust-policy.json"
```

role-policy.json

```json
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket" 
         ],
         "Resource": [
            "arn:aws:s3:::pgo-iso",
            "arn:aws:s3:::pgo-iso/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetBucketAcl"
         ],
         "Resource": [
            "arn:aws:s3:::pgo-iso",
            "arn:aws:s3:::pgo-iso/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource": "*"
      }
   ]
}
```

```sh
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://role-policy.json"
```

container.json

```json
{
    "Description": "DDAN-7.6.0-1069-x86_64",
    "Format": "RAW",
    "UserBucket": {
        "S3Bucket": "pgo-iso",
        "S3Key": "DDAN-7.6.0-1069-x86_64.raw"
    }
}
```

```sh
aws ec2 import-snapshot --description "DDAN-7.6.0-1069-x86_64" --disk-container "file://container.json"

aws ec2 describe-import-snapshot-tasks
```

```json
{
    "ImportSnapshotTasks": [
        {
            "Description": "DDAN-7.6.0-1069-x86_64",
            "ImportTaskId": "import-snap-2b608c5f4fbcc276t",
            "SnapshotTaskDetail": {
                "DiskImageSize": 4702863360.0,
                "Format": "RAW",
                "Progress": "19",
                "SnapshotId": "",
                "Status": "active",
                "StatusMessage": "downloading/converting",
                "UserBucket": {
                    "S3Bucket": "pgo-iso",
                    "S3Key": "DDAN-7.6.0-1069-x86_64.raw"
                }
            },
            "Tags": []
        }
    ]
}
```

```json
{
    "ImportSnapshotTasks": [
        {
            "Description": "DDAN-7.6.0-1069-x86_64",
            "ImportTaskId": "import-snap-2b608c5f4fbcc276t",
            "SnapshotTaskDetail": {
                "DiskImageSize": 4702863360.0,
                "Format": "RAW",
                "SnapshotId": "snap-08cb42c1c642c77e3",
                "Status": "completed",
                "UserBucket": {
                    "S3Bucket": "pgo-iso",
                    "S3Key": "DDAN-7.6.0-1069-x86_64.raw"
                }
            },
            "Tags": []
        }
    ]
}
```

```sh
aws ec2 register-image --name "DDAN-7.6.0-1069-x86_64" \
  --root-device-name /dev/sda1 \
  --block-device-mappings DeviceName=/dev/sda1,Ebs={SnapshotId=snap-08cb42c1c642c77e3}
```

```json
{
    "ImageId": "ami-08791c849d6057341"
}
```







Run through



```sh
qemu-img convert -f raw -O raw DDAN-7.6.0-1069-x86_64.iso DDAN-7.6.0-1069-x86_64.raw

aws s3 cp DDAN-7.6.0-1069-x86_64.raw s3://pgo-iso/

aws ec2 import-snapshot --description "DDAN-7.6.0-1069-x86_64" --disk-container "file://container.json"

aws ec2 import-snapshot --description "DDAN-7.6.0-1069-x86_64" \
  --disk-container Format=RAW,UserBucket={'S3Bucket="pgo-iso",S3Key="DDAN-7.6.0-1069-x86_64.raw"'}

aws ec2 describe-import-snapshot-tasks

aws ec2 register-image --name "DDAN-7.6.0-1069-x86_64" \
  --root-device-name /dev/sda1 \
  --block-device-mappings DeviceName=/dev/sda1,Ebs={SnapshotId=snap-xxxxxxxx}

aws ec2 run-instances --image-id ami-xxxxxxxx --instance-type m5a.2xlarge
```

Set environment:

```sh
export IMAGE_NAME="DDAN-7.6.0-1069-x86_64"
export BUCKET="pgo-iso"
```

### Use qemu-img to Convert ISO to RAW Format

```sh
qemu-img convert -f raw -O raw ${IMAGE_NAME}.iso ${IMAGE_NAME}.raw
```

- -f raw → Input format (ISO)
- -O raw → Output format (RAW)
- ${IMAGE_NAME}.raw → Output file (needed for AWS)

### Upload the Image to AWS S3

Before importing the image, upload it to an S3 bucket:

```sh
aws s3 cp ${IMAGE_NAME}.raw s3://${BUCKET}/
```

### Import the RAW Image as an EBS Snapshot
Use AWS EC2 VM Import to import the disk image:

```sh
aws ec2 import-snapshot --description "My ISO-based AMI" \
  --disk-container Format=RAW,UserBucket={S3Bucket="${BUCKET}",S3Key="${IMAGE_NAME}.raw"}
```

This process may take some time. You can check the progress:

```sh
aws ec2 describe-import-snapshot-tasks
```

Once completed, it will generate a snapshot ID.

### Create an AMI from the Snapshot

Now, use the snapshot ID to create an AMI:

```sh
aws ec2 register-image --name "MyCustomAMI" \
  --root-device-name /dev/sda1 \
  --block-device-mappings DeviceName=/dev/sda1,Ebs={SnapshotId=snap-xxxxxxxx}
```

### Launch an EC2 Instance from the AMI

Once the AMI is ready, you can launch an EC2 instance:

```sh
aws ec2 run-instances --image-id ami-xxxxxxxx --instance-type m5a.2xlarge
```
