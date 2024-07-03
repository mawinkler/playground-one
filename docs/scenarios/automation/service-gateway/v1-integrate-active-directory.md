# Scenario: Integrate an Active Directory with Vision One via Service Gateway on AWS

## Prerequisites

- Playground One Network with PGO Active Directory (recommended) and/or Managed Active Directory enabled

Verify, that you have `AWS AD - create PGO Active Directory` and/or `AWS MAD - create Managed Active Directory` enabled in your configuration.

```sh
pgo --config
```

```sh
...
AWS MAD - create Managed Active Directory [true]:
# and/or
AWS AD - create PGO Active Directory [true]:
...
```

```sh
pgo --apply network
```

## Connect an Active Directory

In Vision One head over to `Workflow and Automation -> Service Gateway Management` again. There should now be a Service Gateway listed. Select it, click on `Manage Services` just in the center, and download the `On-premise directory connection` to the gateway.

![alt text](images/v1-aws-sgm-13.png "Vision One")

![alt text](images/v1-aws-sgm-14.png "Vision One")

Since the Playground One is able to create two different Active Directories depending on what you have enabled in your configuration continue if the following chapters.

### Connect the PGO Active Directory

From within your console/shell run the following command (or find the output from the previous step):

```sh
pgo --output network
```

```sh
...
ad_ca_ip = "54.93.162.135"
ad_dc_ip = "3.71.102.69"
ad_dc_pip = "10.0.4.57"
...
ad_admin_password = TrendMicro.1
```

The interesting values are now `ad_dc_pip` and the `ad_admin_password`.

Lastly, in the Connection Settings choose the following parameters:

- Server Type: Microsoft Active Directory
- Server address: One of the private IPs out of `ad_dc_pip`
- Encryption: `SSL`
- Port: `636`
- Base Distinguished Name: `Specific`, value: `DC=<your environment name>, DS=local`
- Permission scope: `Read & write`
- User Name: `Administrator@<your environment name>.local`
- Password: `ad_admin_password`

Example with environment name `pgo-id`:

![alt text](images/v1-aws-sgm-17.png "Vision One")

This should connect the Active Directory to Vision One via the Service Gateway.

Using the PGO Active Directory allows you to utilize the Security Event Forwarding. For this functionality you need to download the current installation package on the Domain Controller and walk through the installation procedure.

Let's start from the beginning:

First, head over to `Workflow and Automation -> Service Gateway Management` and obtain your API Key (top right, this will be the same for all Service Gateways connected) the private IP of your Service Gateway, here `10.0.4.40`.

![alt text](images/v1-aws-sef-00.png "Vision One")

Next, in `Workflow and Automation -> Service Gateway Management -> Active Directory (on-premise)` open the tab `Security Event Forwarding` and click the button `[Download Installation Package]` to copy the link.

![alt text](images/v1-aws-sef-01.png "Vision One")

Connect to the Domain Controller and download the agent via the browser by pasting the link from above.

Open the downloaded executable and install. 

![alt text](images/v1-aws-sef-02.png "Vision One")

![alt text](images/v1-aws-sef-03.png "Vision One")

![alt text](images/v1-aws-sef-04.png "Vision One")

![alt text](images/v1-aws-sef-05.png "Vision One")

Follow the workflow and file in the IP and API Key of your Service Gateway.

![alt text](images/v1-aws-sef-06.png "Vision One")

Heading back to the Active Directory integration of Vision One the agent should be listed after a short period of time.

![alt text](images/v1-aws-sef-07.png "Vision One")

### Connect the Managed Active Directory

From within your console/shell run the following command (or find the output from the previous step):

```sh
pgo --output network
```

```sh
...
mad_id = "d-99677cba24"
mad_ips = toset([
  "10.0.0.37",
  "10.0.1.229",
])
...
key_name = "pgo-key-pair-oaxuizlr"
mad_admin_password = <sensitive>
...
mad_admin_password = XrJ*5VPDZGmhhL70
```

The interesting values are now `mad_ips` and the `mad_admin_password`.

Lastly, in the Connection Settings choose the following parameters:

- Server address: One of the private IPs out of `mad_ips`
- Encryption: `NONE` (the MAD built by Playground One does not have a certificate yet)
- Port: `389`
- Permission scope: `Read & write`
- User Name: `admin`
- Password: `mad_admin_password`

![alt text](images/v1-aws-sgm-15.png "Vision One")

This should connect the Active Directory to Vision One via the Service Gateway.

🎉 Success 🎉
