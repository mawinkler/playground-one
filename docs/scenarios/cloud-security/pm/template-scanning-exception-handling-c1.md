# Scenario: Terraform IaC Scanning in Pipelines with Exception Handling (Cloud One)

!!! danger "Warning!"

    This scenario does use Cloud One Conformity! For Vision One Cloud Posture Template Scanning use the scenario above!

## Prerequisites

- Cloud One API-Key with the following permissions:
    - Conformity
        - Full-Access

The provided Python scripts implement the required functionality for Terraform Template Scanning, Exception approval workflows and temporary suppression of findings in Conformity Account Profile. It mainly focuses on the logic to support these kind of scenarios and cannot be used 1-to-1 in real life pipelines without modifications. The implementation assumes that an external workflow engine such as ServiceNow is used for approval workflows, which include an expiration set on the specific exception.

Conformity offers two different variants to “allow” non-compliance:

- Exceptions in rule configuration based on Tags or Resource ID (AWS ARN)
- Suppressions on specific findings

The required functionality as part of the workflow requirements is available via Conformity's REST API in combination with ServiceNow for workflow management.

Logical architecture:

![alt text](images/iac-scanning-01.png "Logical")

The idea is to create one or more *Scan Profiles* with are used by the template scanner. The *Scan Profile* gets Exceptions assigned so that a template scan result can pass before deployment.

![alt text](images/iac-scanning-02.png "Profiles")

In the above screenshot we have two Scan Profiles with different settings.

Scan Profile contains

- Rule Settings and
- approved Exceptions

Suppressions are set in Account to (temporarily) suppress but report Findings. When Suppression(s) expire, Exceptions in Scan Profile are to be adapted/removed.

The onboarding workflow:

![alt text](images/iac-scanning-04.png "Onboarding")

The next graph shows the complete workflow implemented in this scenario:

![alt text](images/iac-scanning-05.png "Workflow")

Things to be aware of:

- Resource IDs (e.g. ARNs) are often unknown at Terraform Plan stage
- Name-Tags might not be granular enough in regards Suppressions
- Tags on resources may be set incorrectly, possibly intentionally
  - Resolution idea (partly implemented):
    - Trigger Template Scan
    - Findings trigger Exemption Workflow
    - Approved Exceptions get a unique ID assigned which is bound to the Resource and Rule ID
    - Allowed non-compliant resources are tagged in the Terraform Template with this unique ID
    - Allows validation before deployment (does the tag match to the resource and Rule ID?)

## Playing through the Workflow

The scenarios offer two different terraform configurations that you can play with for convenience. Effectively it is not limitted to these, the Python script can scan any configuration, even the Playground One configurations of `awsone`.

There are two variants implemented which differ in their approach to identity AWS resources to build:

- `scanner_c1_name.py`: Simply uses name tags on the resources.
- `scanner_c1_uuid.py`: Automatically creates an unique `uuid`-tag for the resources which need to be assigned manually to the resource before deployment to be compliant.

The scripts are located in the `cspm`-directory and assume, that all exeption are granted and expire after seven days.

### Prepare

- Set environment variable `C1CSPM_SCANNER_KEY` with the API key of the
  Conformity Scanner owning Full Access to Conformity.
- Adapt the constants in the Python script in between `# HERE` and `# /HERE` to your requirements.
- Lines 106ff. 
  ```py
  # HERE
  REGION = "trend-us-1"
  SCAN_PROFILE_ID = "<Scan Profile ID>"
  ACCOUNT_ID = "<Conformity AWS Account ID>"
  SCAN_PROFILE_NAME = "<Scan Profile Name>"
  REPORT_TITLE = "Workflow Tests"
  RISK_LEVEL_FAIL = "MEDIUM"
  # /HERE
  ```

- Get your `ACCOUNT_ID`:

  ```sh
  curl --location 'https://conformity.trend-us-1.cloudone.trendmicro.com/api/accounts' \
      --header 'Content-Type: application/vnd.api+json' \
      --header 'Authorization: ApiKey <YOUR API KEY>'
  ```
- Get the `SCAN_PROFILE_ID` and `SCAN_PROFILE_NAME`:

  ```sh
  curl --location 'https://conformity.trend-us-1.cloudone.trendmicro.com/api/profiles' \
  --header 'Content-Type: application/vnd.api+json' \
  --header 'Authorization: ApiKey <YOUR API KEY>'
  ```

### Using Name-Tags

First, we're going the easy route using name tags.

Here's the quick run-through:

```sh
# Run template scan
$ ./scanner_c1_name.py --scan 2-network
```

This produces the following output:

```sh
2024-11-13 13:15:25 INFO (MainThread) [scan_template] Starting Template Scan...
2024-11-13 13:15:38 INFO (MainThread) [scan_template] Template Scan done.
2024-11-13 13:15:38 INFO (MainThread) [scan_failures] Finding of rule EC2-001 with Risk Level MEDIUM, Rule Title: Security Group Port Range for Resource: module.ec2.aws_security_group.sg["public"]
2024-11-13 13:15:38 INFO (MainThread) [scan_failures] Finding of rule EC2-033 with Risk Level MEDIUM, Rule Title: Unrestricted Security Group Egress for Resource: module.ec2.aws_security_group.sg["private"]
2024-11-13 13:15:38 INFO (MainThread) [scan_failures] Finding of rule EC2-033 with Risk Level MEDIUM, Rule Title: Unrestricted Security Group Egress for Resource: module.ec2.aws_security_group.sg["public"]
```

For now, let's assume the user did run through an approval workflow for the above findings and is therefore allowed to create exceptions. For this, we run:

```sh
# Run approval workflows in engine, here implementing the approved workflow
$ ./scanner_c1_name.py --exclude 2-network
```

```sh
2024-11-13 13:16:33 INFO (MainThread) [scan_template] Starting Template Scan...
2024-11-13 13:16:37 INFO (MainThread) [scan_template] Template Scan done.
2024-11-13 13:16:37 INFO (MainThread) [scan_failures] Setting Exception for rule EC2-001 with Risk Level MEDIUM, Rule Title: Security Group Port Range for Resource: module.ec2.aws_security_group.sg["public"]
2024-11-13 13:16:44 INFO (MainThread) [set_exception] Exception for EC2-001 in Profile TQNDl13ix set
2024-11-13 13:16:44 INFO (MainThread) [scan_failures] Setting Exception for rule EC2-033 with Risk Level MEDIUM, Rule Title: Unrestricted Security Group Egress for Resource: module.ec2.aws_security_group.sg["private"]
2024-11-13 13:16:49 INFO (MainThread) [set_exception] Exception for EC2-033 in Profile TQNDl13ix set
2024-11-13 13:16:49 INFO (MainThread) [scan_failures] Setting Exception for rule EC2-033 with Risk Level MEDIUM, Rule Title: Unrestricted Security Group Egress for Resource: module.ec2.aws_security_group.sg["public"]
2024-11-13 13:16:52 INFO (MainThread) [set_exception] Exception for EC2-033 in Profile TQNDl13ix set
```

The exceptions are based on the name-tags of the resource. You can find the exption tags generated within the `exceptions.json`-file.

```json
{
  "EC2-001": {
    "scan_profile_id": "TQNDl13ix",
    "tags": [
      "Name::pgo-public-sg"
    ]
  },
  "EC2-033": {
    "scan_profile_id": "TQNDl13ix",
    "tags": [
      "Name::pgo-private-sg",
      "Name::pgo-public-sg"
    ]
  }
}
```

A subsequent template scan should now pass without findings and the template is prepared for deployment.

```sh
# Run template scan again to verify that the scan result is clean
$ ./scanner_c1_name.py --scan 2-network
```

```sh
2024-11-13 13:18:39 INFO (MainThread) [scan_template] Starting Template Scan...
2024-11-13 13:18:44 INFO (MainThread) [scan_template] Template Scan done.
```

Now, lets apply the configuration and trigger a bot run:

```sh
# Apply configuration
$ ./scanner_c1_name.py --apply 2-network

# Trigger bot run
$ ./scanner_c1_name.py --bot
```

Even if the scan was clean, the bot will still identify violations since the bot uses the account and not the scanning template. To temporarily suppress the findings run:

```sh
# Suppress findings
$ ./scanner_c1_name.py --suppress
```

The above suppressed the findings for a week. Running the script with the `--expire` flag will check all the suppressions and if a suppression is expired, it will remove the exception from the scan profile, simulating an expired exception.

```sh
# Suppressions are active for 1 week
$ ./scanner_c1_name.py --expire
```

To do a cleanup and remove the suppressions and exceptions run:

```sh
# Cleanup
$ ./scanner_c1_name.py --destroy 2-network
$ ./scanner_c1_name.py --reset
$ ./scanner_c1_name.py --expire
```

### Using UUID-Tags (more secure)

```sh
# Run template scan
$ ./scanner_c1_uuid.py --scan 2-network
```

This produces the following output:

```sh
2024-11-13 12:50:01 INFO (MainThread) [scan_template] Starting Template Scan...
2024-11-13 12:50:13 INFO (MainThread) [scan_template] Template Scan done.
2024-11-13 12:50:13 INFO (MainThread) [scan_failures] Finding of rule EC2-001 with Risk Level MEDIUM, Rule Title: Security Group Port Range for Resource: module.ec2.aws_security_group.sg["public"]
2024-11-13 12:50:13 INFO (MainThread) [scan_failures] Finding of rule EC2-033 with Risk Level MEDIUM, Rule Title: Unrestricted Security Group Egress for Resource: module.ec2.aws_security_group.sg["private"]
2024-11-13 12:50:13 INFO (MainThread) [scan_failures] Finding of rule EC2-033 with Risk Level MEDIUM, Rule Title: Unrestricted Security Group Egress for Resource: module.ec2.aws_security_group.sg["public"]
```

For now, let's assume the user did run through an approval workflow for the above findings and is therefore allowed to create exceptions. For this, we run:

```sh
# Run approval workflows in engine, here implementing the approved workflow
$ ./scanner_c1_uuid.py --exclude 2-network
```

```sh
2024-11-13 12:52:38 INFO (MainThread) [scan_template] Starting Template Scan...
2024-11-13 12:52:43 INFO (MainThread) [scan_template] Template Scan done.
2024-11-13 12:52:43 INFO (MainThread) [scan_failures] Setting Exception for rule EC2-001 with Risk Level MEDIUM, Rule Title: Security Group Port Range for Resource: module.ec2.aws_security_group.sg["public"]
2024-11-13 12:52:45 INFO (MainThread) [set_exception] Creating new Exception tag for module.ec2.aws_security_group.sg["public"] in Profile TQNDl13ix
2024-11-13 12:52:49 INFO (MainThread) [set_exception] Exception for EC2-001 in Profile TQNDl13ix set
2024-11-13 12:52:49 INFO (MainThread) [scan_failures] Setting Exception for rule EC2-033 with Risk Level MEDIUM, Rule Title: Unrestricted Security Group Egress for Resource: module.ec2.aws_security_group.sg["private"]
2024-11-13 12:52:50 INFO (MainThread) [set_exception] Creating new Exception tag for module.ec2.aws_security_group.sg["private"] in Profile TQNDl13ix
2024-11-13 12:52:53 INFO (MainThread) [set_exception] Exception for EC2-033 in Profile TQNDl13ix set
2024-11-13 12:52:53 INFO (MainThread) [scan_failures] Setting Exception for rule EC2-033 with Risk Level MEDIUM, Rule Title: Unrestricted Security Group Egress for Resource: module.ec2.aws_security_group.sg["public"]
2024-11-13 12:52:54 INFO (MainThread) [set_exception] Creating new Exception tag for module.ec2.aws_security_group.sg["public"] in Profile TQNDl13ix
2024-11-13 12:52:56 INFO (MainThread) [set_exception] Exception for EC2-033 in Profile TQNDl13ix set
```

For each exception the script genarates a unique tag which needs to be assigned to the resource definition within the Terraform configuration. You can find the exption tags generated within the `exceptions.json`-file.

```json
{
  "EC2-001": {
    "scan_profile_id": "TQNDl13ix",
    "tags": [
      "39c34a53-7368-40ba-b96b-254877a7d8a5::module.ec2.aws_security_group.sg[\"public\"]_EC2-001"
    ]
  },
  "EC2-033": {
    "scan_profile_id": "TQNDl13ix",
    "tags": [
      "d2c3b1ee-8278-4b8c-9adb-e82fd5bb79c0::module.ec2.aws_security_group.sg[\"private\"]_EC2-033",
      "bf8d1c3f-a6bb-40af-b0e9-6b8820bcf397::module.ec2.aws_security_group.sg[\"public\"]_EC2-033"
    ]
  }
}
```

The generated exception-tags have the following schema: `<UUID>::<RESOURCE>_<RULE ID>`.

Copy the exception-tag for the resource in the tags section of the resource. Don't forget to replace the `::` with `" = "` as shown in the example below.

```terraform
locals {
  security_groups = {
    public = {
      name        = "${var.environment}-public-sg"
      description = "Security group for Public Access"
      tags = {
        "39c34a53-7368-40ba-b96b-254877a7d8a5" = "module.ec2.aws_security_group.sg[\"public\"]_EC2-001"
        "bf8d1c3f-a6bb-40af-b0e9-6b8820bcf397" = "module.ec2.aws_security_group.sg[\"public\"]_EC2-033"
      }
      ingress = {
...
    private = {
      name        = "${var.environment}-private-sg"
      description = "Security group for Private Access"
      tags = {
        "d2c3b1ee-8278-4b8c-9adb-e82fd5bb79c0" = "module.ec2.aws_security_group.sg[\"private\"]_EC2-033"
      }
      ingress = {
...
```

This allows to validate, that the unique tag key is assigned to the designated resource and violating rule only.

A subsequent template scan should now pass without findings and the template is prepared for deployment.

```sh
# Run template scan again to verify that the scan result is clean
$ ./scanner_c1_uuid.py --scan 2-network
```

The scan results are now clean:

```sh
2024-11-13 12:59:39 INFO (MainThread) [scan_template] Starting Template Scan...
2024-11-13 12:59:43 INFO (MainThread) [scan_template] Template Scan done.
```

Now, lets apply the configuration and trigger a bot run:

```sh
# Apply configuration
$ ./scanner_c1_uuid.py --apply 2-network

# Trigger bot run
$ ./scanner_c1_uuid.py --bot
```

Even if the scan was clean, the bot will still identify violations since the bot uses the account and not the scanning template. To temporarily suppress the findings run:

```sh
# Suppress findings
$ ./scanner_c1_uuid.py --suppress
```

The above suppressed the findings for a week. Running the script with the `--expire` flag will check all the suppressions and if a suppression is expired, it will remove the exception from the scan profile, simulating an expired exception.

```sh
# Suppressions are active for 1 week
$ ./scanner_c1_uuid.py --expire
```

To do a cleanup and remove the suppressions and exceptions run:

```sh
# Cleanup
$ ./scanner_c1_uuid.py --destroy 2-network
$ ./scanner_c1_uuid.py --reset
$ ./scanner_c1_uuid.py --expire
```

🎉 Success 🎉
