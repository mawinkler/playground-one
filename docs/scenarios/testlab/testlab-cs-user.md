# Scenario: Playground One Testlab for Customer Success<!-- omit in toc -->

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
    - Deep Security w/ PostgreSQL
    - Apex One
    - Apex Central
    - Windows Clients/Member Servers

The TestLab supports two flavours - one fully integrated with ready to use configuration of Trend Micro solutions. Second, a bare playground just with member servers and a Deep Security base installation.

## Requirements

- Wireguard Client
- Wireguard Peer Configuration file
- RDP Client
- RDP Configurations

## Access to the Testlab VPC

Wireguard

## Access the Machines

RDP

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
