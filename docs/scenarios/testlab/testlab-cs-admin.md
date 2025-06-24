# Scenario: Playground One Testlab for Customer Success - Admin Guide<!-- omit in toc -->

## What's Inside

The TestLab provides a complete and secure test environment hosted on AWS. Currently it offers the following services:

- Dedicated VPC with secure VPN Access
- Graphical Management UI
- Base Services:
    - Microsoft Active Directory
    - Microsoft Certification Authority
    - Microsoft Exchange
- Trend Micro Services
    - Service Gateway
    - Deep Discovery Inspector
    - Deep Security w/ PostgrSQL
    - Apex One
    - Apex Central
    - Windows Clients/Member Servers

The TestLab supports two flavours - one fully integrated with ready to use configuration of Trend Micro solutions. Second, a bare playground just with member servers and a Deep Security base installation.

## Playground One Web UI

### Using SSH Port Forwarding

To access the UI from outside AWS you need three things:

- The Satellite SSH Key (ask me 😇)
- The Satellite public IP (ask me, again 😛)
- Establish an SSH Tunnel: `ssh -i <SSH KEY FILE>> -L 1337:localhost:1337 ubuntu@<SATELLITE PUBLIC IP>`
 
Example: `ssh -i pgo-satellite-pgo-cs-key-pair-y73bwukz.pem -L 1337:localhost:1337 ubuntu@3.68.166.174`


ssh -i pgo-satellite-pgo-cs-key-pair-y73bwukz.pem -L 1337:localhost:1337 ubuntu@3.68.166.174

Then use your browser to connect to `http://localhost:1337`.

### Using Security Group Patcher

Be authenticated with your access and secret key and run `pgo-ui-ip-update`. This adds your public IP to the security group of the Satellite.


## Life-Cycle using the UI

### Playground Status

Lists the applied configurations and currently available EC2 instances including their state.

### Create a Fresh Environment

- `Snapshots --> --clear` for `network` and `testlab-cs`.
- `Base Environment --> --init`
- `Base Environment --> --apply`

Test if the UI is connected to the network:

- `Ping the Base Environment`
- `Testlab CS --> --init`
- `Testlab CS --> --apply`

### Stop/Start the Environment

- `Base Environment --> --stop/--start`
- `Testlab CS --> --stop/--start`

### Destroy the Environment

- `Base Environment --> --destroy`
- `Testlab CS --> --destroy`

### Connect/Ping/Disconnect the Base Environment

Press the corresponding buttons. This connects the Satellite/UI to or disconnects it from the Base Environment. Ping checks the connection.

### Peers for Admin and Users

Press `Playground Peers` and/or `Playground Admin Peer`.

Copy the information to either your Wireguard UI client or a `.conf` file for `wg-quick`.

### Snapshots

This chapter covers the `network` and `testlab-cs` configurations.

***Create Snapshots***

It's best to first snapshot the testlab, then the the network.

*Snapshots:*

- Action: `--snapshot-freeze`
- Configuration: `testlab-cs`

*Snapshots:*

- Action: `--snapshot-freeze`
- Configuration: `network`

You need to restart the `Base Environment` and `Testlab CS` using `Base Environment --> --start` and `Testlab CS --> --start` again.

***Retrieve Snapshots***

First, you need the snapshot IDs:

*Snapshots:*

- Action: `--snapshot-list-tags`
- Configuration: `testlab-cs`

Remember the id.

*Snapshots:*

- Action: `--snapshot-retrieve`
- Configuration: `testlab-cs`
- Snapshot ID: `<the ID from above>`

You need to re-apply the configurations using `Testlab CS --> --init` and `Testlab CS --> --apply`.

Same for `Base Environment` (`network`).

***Delete Snapshots***

First, you need the snapshot IDs:

*Snapshots:*

- Action: `--snapshot-list-tags`
- Configuration: `testlab-cs`

Remember the id.

*Snapshots:*

- Action: `--snapshot-delete`
- Configuration: `testlab-cs`
- Snapshot ID: `<the ID from above>`

Same for `Base Environment` (`network`).

***Clear Snapshot Settings from Configuration***

*Snapshots:*

- Action: `--snapshot-clear`
- Configuration: `testlab-cs`

This removes the AMIs from the configuration and allow you to create fresh instances. You need to re-apply the configurations using `Testlab CS --> --init` and `Testlab CS --> --apply`.

Same for `Base Environment` (`network`).

## Things to Know

### Private IP Assignments

Configuration | Instance           | Private IP
------------- | ------------------ | ----------
Network       | Wireguard          | 10.0.4.10
Network       | PGO-DC             | 10.0.0.10
Network       | PGO-CA             | 10.0.0.11
Network       | SG                 | 10.0.0.12
Network       | DDI                | 10.0.1.2
TestLab-CS    | DSM                | 10.0.0.20
TestLab-CS    | Apex One           | 10.0.0.22
TestLab-CS    | Apex Central       | 10.0.0.23
TestLab-CS    | PostgreSQL         | 10.0.0.24
TestLab-CS    | Exchange           | 10.0.0.25
TestLab-CS    | Exchange Transport | 10.0.0.26
TestLab-CS    | Client 0           | 10.0.1.10
TestLab-CS    | Client 1           | 10.0.1.11
TestLab-CS    | Client x           | 10.0.1.xx
TestLab-Bare  | DSM                | 10.0.2.20
TestLab-Bare  | PostgreSQL         | 10.0.2.24
TestLab-Bare  | Client 0           | 10.0.2.120
TestLab-Bare  | Client 1           | 10.0.2.121
TestLab-Bare  | Client x           | 10.0.2.xx
