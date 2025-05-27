# Scenario: Playground One Testlab for Customer Success<!-- omit in toc -->

ToDos:

- Rename Apex Servers
- Add t3.xlarge to testlab (Exchange)
- PGO to remove amis from config

## Setup from Scratch

### Locally

```sh
git clone git@github.com-mawinkler:mawinkler/playground-one.git
mv playground-one playground-one-cs

cd playground-one-cs
source bin/activate
```

Eventually copy some upload files from `playground-one/awsone/0-files` to the `playground-one-cs/awsone/0-files` directory.

Then, run

```sh
pgo --config
```

Settings:

```yaml
services:
  environment_name: pgo-cs
  initialize: false
  aws:
    account-id: <AWS ACCOUNT ID>
    region: eu-central-1
    service-gateway: true
    managed-active-directory: false
    active-directory: true
    pgo_user_enabled: true
    virtual-network-sensor:
      enabled: false
    private-access-gateway: false
    deep-discovery-inspector:
      enabled: true
    pgo_user_access_key: <ACCESS KEY GENERATEY BY pgo -a user>
    pgo_user_secret_key: <SECRET ACCESS KEY GENERATEY BY pgo -a user>
    vpn-gateway: true
    configuration:
      network:
        ami-active-directory-dc: ami-036eb8f316bfead70
        ami-active-directory-ca: ami-0b7a3ea4c0aa0cf56
      testlab-cs:
        ami-apex-one-server: ami-02e2b667941d221d4
        ami-apex-one-central: ami-0db3d88ff90e312b3
        ami-windows-client: ["ami-0ac8520632672372e", "ami-02d7d816af0ab6646"]
        ami-bastion: ami-0c6bf4e74f840b978
        ami-dsm: ami-071d66264a53ff5f9
        ami-postgresql: ami-0d2a3ca2006496dad
  azure:
    enabled: false
  playground-one:
    access-ip: ["87.170.13.77/32"]
    ec2:
      create-database: true
    px: false
    azvm:
      create-linux: false
  integrations:
    prometheus:
      enabled: false
    trivy:
      enabled: false
    calico:
      enabled: false
    metallb:
      enabled: false
    istio:
      enabled: false
    pgoweb:
      enabled: false
    argocd:
      enabled: false
  deep-security:
    enabled: true
    license: <DS ACTIVATION KEY>
    username: masteradmin
    password: playground
  vision-one:
    container-security:
      enabled: false
    api-key: <V1 API-KEY>
    region: us-east-1
    endpoint-security:
      enabled: true
      type: TMServerAgent
  workload-security:
    enabled: false
```

```sh
pgo --init user
pgo --init satellite

pgo --apply user
pgo --apply satellite
```

### AWS Console - Satellite Instance

Go to AWS Console EC2 in region `eu-central-1` and direct connect to the satellite instance.

Wait for initialization of Playground One has finished.

For this run some of this commands: `kubectl`, `yq`, and `pgo`.

```sh
pgo --config
```

All seetings should already be correct since the `config.yaml` has been copied into the `satellite`. Just update the Access IP to match with the `satellite` IP.

```sh
pgo --init network
pgo --init testlab-cs
pgo --init testlab-bare

# pgo --apply network
```

> Note: The above created the VPC including other typically enabled services like Active Directory, Service Gateway, VPN, and the Deep Discovery Inspector.

Optionally, get the VPN Peers and RDP configurations:

```
cd playground-one

s3cp --put vpn-peers
s3cp --put vpn-rdps
```

These files are now located in the satellites S3 bucket. Get the bucket name with:

```sh
pgo --output network
# s3_bucket = "pgo-cs-..."
```

> ***Fix:***
>
> `wg-quick` errors with `resolvconf: command not found`
>
> Solution:
>
> `sudo ln -s /usr/bin/resolvectl /usr/local/bin/resolvconf`

To start the Testlabs run

```sh
# Naked
pgo --apply testlab-bare

# Full
pgo --apply testlab-cs
```

If AMIs are configured, they will be used. Atherwise *empty* instances are used.

## Playground One Web UI

https://docs.olivetin.app/index.html
https://icon-sets.iconify.design/?query=snapshot

On the Satellite install the UI by running:

```sh
pgo-ui install
```

Config File: `/etc/OliveTin/config.yaml`

To access the UI from outside AWS you need three things:

- The Satellite SSH Key (ask me 😇)
- The Satellite public IP (ask me, again 😛)
- Establish an SSH Tunnel: `ssh -i <SSH KEY FILE>> -L 1337:localhost:1337 ubuntu@<SATELLITE PUBLIC IP>`
 
Example: `ssh -i pgo-satellite-pgo-cs-key-pair-y73bwukz.pem -L 1337:localhost:1337 ubuntu@3.68.166.174`

Then use your browser to connect to `http://localhost:1337`.

## Things to Know

### Private IP Assignments

Configuration | Instance     | Private IP
------------- | ------------ | ----------
Network       | Wireguard    | 10.0.4.10 
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

### Snapshots

***Retrieve***

Example using tag: `20250324-01`

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


### (Optional): Create Your own Local Administrator

Before snapshotting it is advised to create a new local administrator. Being authenticated as the domain administrator run the following in powershell:

```ps
$Username = "LocalAdmin"
$Password = ConvertTo-SecureString "SECURE PASSWORD" -AsPlainText -Force

# Create the local user account
New-LocalUser -Name $Username -Password $Password -FullName "Local Administrator" -Description "Local Admin Account"

# Add the user to the Administrators group
Add-LocalGroupMember -Group "Administrators" -Member $Username

Write-Output "Local administrator account '$Username' has been created successfully."
```

## Knowledge Base

### Disaster Recovery

See [Setup from Scratch](#setup-from-scratch) but retrieve the latest snapshots before applying the network and testlabs.


### Transfer a custom Amazon Machine Image (AMI)

To transfer a custom Amazon Machine Image (AMI) from one AWS account to another, you can share the AMI with the target account and then have the target account copy it. Here's how to do it:​

🔄 Step 1: Share the AMI with the Target Account
In the source AWS account (the one that owns the AMI):​

- Share the AMI:
  - Using the AWS Console:
    - Navigate to the EC2 Dashboard.
    - In the left-hand menu, select AMIs.
    - Locate and select your custom AMI.
    - Click on Actions > Modify Image Permissions.
    - Choose Private.
    - Under Shared accounts, click Add account ID.
    - Enter the 12-digit AWS account ID of the target account.
    - Click Share AMI, then Save changes.
  - Using the AWS CLI:
      ```sh
      aws ec2 modify-image-attribute \
      --image-id ami-xxxxxxxxxxxxxxxxx \
      --launch-permission "Add=[{UserId=123456789012}]"
      ```
      Replace ami-xxxxxxxxxxxxxxxxx with your AMI ID and 123456789012 with the target AWS account ID.

> Note: If your AMI uses encrypted Amazon EBS snapshots, ensure that the target account has the necessary permissions to use the associated AWS Key Management Service (KMS) keys. ​

📥 Step 2: Copy the Shared AMI in the Target Account
In the target AWS account:​

- Copy the Shared AMI:
  - Using the AWS Console:
    - Navigate to the EC2 Dashboard.
    - In the left-hand menu, select AMIs.
    - Change the filter to Shared with me to view AMIs shared by other accounts.
    - Select the shared AMI you wish to copy.
    - Click on Actions > Copy AMI.
    - In the Copy AMI dialog:
    - Provide a name and description for the new AMI.
    - Select the destination region (if different from the current one).
    - Choose whether to encrypt the new AMI.
    - Click Copy AMI to initiate the copy process.
  - Using the AWS CLI:
      ```sh
      aws ec2 copy-image \
      --source-image-id ami-xxxxxxxxxxxxxxxxx \
      --source-region us-west-2 \
      --name "MyCopiedAMI" \
      --region us-east-1
      ```
      Replace ami-xxxxxxxxxxxxxxxxx with the shared AMI ID, us-west-2 with the source region, and us-east-1 with the destination region.

> Note: After copying, the AMI in the target account is independent of the source account. The target account can now launch instances from this AMI, modify it, or share it further. ​

⚠️ Important Considerations

- Encrypted AMIs: If the AMI uses encrypted snapshots, ensure that the target account has permissions to use the associated KMS keys. ​
- Region-Specific: AMIs are region-specific. If you need the AMI in a different region, you must copy it to that region. ​
- Permissions: Sharing an AMI does not grant permissions to the underlying snapshots. Ensure that the necessary permissions are in place for the target account to use the snapshots.​
- Billing: The account that owns the AMI is billed for the storage of the AMI and its snapshots. The account that copies or launches instances from the AMI is billed for the usage in their account. ​

By following these steps, you can successfully transfer a custom AMI from one AWS account to another.

### From ISO to AMI

Get QEMU

```sh
brew install qemu
```

#### Service Role

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

#### Import Snapshot

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

#### Register Image

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

#### Run through

Set environment:

```sh
export IMAGE_NAME="DDAN-7.6.0-1069-x86_64"
export BUCKET="pgo-iso"
```

***Use qemu-img to Convert ISO to RAW Format***

```sh
qemu-img convert -f raw -O raw ${IMAGE_NAME}.iso ${IMAGE_NAME}.raw
```

- -f raw → Input format (ISO)
- -O raw → Output format (RAW)
- ${IMAGE_NAME}.raw → Output file (needed for AWS)

***Upload the Image to AWS S3***

Before importing the image, upload it to an S3 bucket:

```sh
aws s3 cp ${IMAGE_NAME}.raw s3://${BUCKET}/
```

***Import the RAW Image as an EBS Snapshot***
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

***Create an AMI from the Snapshot***

Now, use the snapshot ID to create an AMI:

```sh
aws ec2 register-image --name "MyCustomAMI" \
  --root-device-name /dev/sda1 \
  --block-device-mappings DeviceName=/dev/sda1,Ebs={SnapshotId=snap-xxxxxxxx}
```

***Launch an EC2 Instance from the AMI***

Once the AMI is ready, you can launch an EC2 instance:

```sh
aws ec2 run-instances --image-id ami-xxxxxxxx --instance-type m5a.2xlarge
```
