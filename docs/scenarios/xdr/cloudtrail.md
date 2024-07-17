# Scenario: CloudTrail

## Prerequisites

- None

## Overview

Automated malicious actions are executed on running this scenario which lead to detections in Observed Attack Techniques and the generation of Workbenches.

## The story

Using a leaked user with S3 access allows the attacker to list all the buckets and look for buckets where possible sensitive information is stored.

## What is going to happen?

This demo is executing the following actions:

1. Preparation
   1. Create a S3 Bucket and upload a `password.zip`.
   2. Create an IAM User with `S3FullAccess` policy.
   3. Create an EC2 instance acting as the final target.
2. Attack (using the created user)
   1. Create a `download` directory.
   2. Iterate through each bucket (filtered on PGO environment name).
   3. List bucket objects.
   4. Download bucket object if key matches `password.zip` and `*.pem`.
   5. Access EC2 instance with downloaded key and query instance role.
3. Clean up
   1. Destroy bucket, instance, and user.

Screenshot of generated OATs:

![alt text](images/cloudtrail-01.png "OATs")

## Run the Attack

So, this is very simple :-)

```sh
# Create the user, search buckets, download credentials
pgo --apply scenarios-cloudtrail
```

```sh
Outputs:

access_key = "AKIAZHO3CC62YYHHCD6N"
attack = tomap({
  "instance_role" = "pgo-id-ec2-role-24yi5egt"
})
attacker_arn = "arn:aws:iam::634503960501:user/pgo-id-attacker-ragfl318"
instance_ip_linux = "35.158.122.99"
s3_bucket = "pgo-id-scenarios-wk3gd608"
secret_key = <sensitive>
```

`pgo-id-ec2-role-24yi5egt` is the role name of the target instance to which the attacker gained access after finding and downloading the ssh key from S3. He connected to the instance and queried it's metadata.

```sh
# Delete the user again
pgo --destroy scenarios-cloudtrail
```

Review the detections in Vision One.

![alt text](images/cloudtrail-02.png "OATs")

🎉 Success 🎉
