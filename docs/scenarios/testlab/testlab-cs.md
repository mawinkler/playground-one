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

### Configure Instances

In `terraform.tfvars`. Example:

```tf
create_apex_one_server = true
create_apex_one_central = true
windows_client_count = 2
```

### Create Testlab-CS

```sh
# With SG and PGO AD enabled
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

### Delete Snapshots:

```sh
pgo --freeze testlab-cs-delete
```

Enter the Snapshots Name, e.g. `v1`.

🎉 Success 🎉
