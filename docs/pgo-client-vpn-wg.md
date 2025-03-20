# Access Playground One via PGO VPN

All resources in AWS work inside private VPC. Sometimes you may need to access these resources from local computer (e.g. to interact with database). Some resources, like RDS, have the option to enable public access to them — but this is unsecure. Of course you can configure Security Group to allow access to public resource only from allowed IPs to make this setup a bit better, but still in this case all your colleagues must to have static IPs, which is not always true.

We need to provide a quick and easy solution to give access to internal AWS VPC resources for our team. In general, there are two ways to do this:

- Bastion / Jump Host — EC2 instance with SSH access for each member
- Private VPN — EC2 instance with VPN config for each member

In both cases we need to to setup a custom EC2 instance, so second variant seems more convenient to me.

## Preparation

In addition to the traditional Terraform client, we will need WireGuard CLI tools to generate a key pair. You can install WireGuard tools on macOS via brew:

```sh
# Linux
sudo apt install wireguard-tools

# MacOS
brew install wireguard-tools
```

## Generate key pairs

First we need to create key pairs which can be generated with this command:

```sh
bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv\n$pub\n"'
```

In output first line is privkey, second is pubkey.

I will generate it twice, one for server, second for first client (peer). Then for each new peer you will need to generate new key pairs. I will same generated keys to secrets.yaml file, but you can use different ways to store secrets.

Generate secrets for server and first peer (do not use this keys in your setup):

```sh
bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv\n$pub\n"'
6EQp9lETQ29NgiDw58GlTpjCwVNgxW8GuzDtZMM/a1g=
qqU5gZfDmx7qz2jNYrjirWmC6ApHStApuceuEiB52zU=
 
bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv\n$pub\n"'
MGqZLCkcoMVxyNYngZDh5+pSiZXDNgTxD7vgYH13p1M=
tC7QSeK4V74N/H4BG5OX/bgAxpczdl7UoKgxjEhbtRA=
```

Then save generated keys to secrets.yaml

```yaml
wg_server:
  privkey: 6EQp9lETQ29NgiDw58GlTpjCwVNgxW8GuzDtZMM/a1g=
  pubkey: qqU5gZfDmx7qz2jNYrjirWmC6ApHStApuceuEiB52zU=
 
wg_peers:
  - name: user1
    addr: 172.16.16.1
    privkey: MGqZLCkcoMVxyNYngZDh5+pSiZXDNgTxD7vgYH13p1M=
    pubkey: tC7QSeK4V74N/H4BG5OX/bgAxpczdl7UoKgxjEhbtRA=
```

## Execute

Finally we can run terraform init & terraform apply. In less then a minute VPN server will be created and user client will be exported to generated/user1.conf. Then we can share this file with our teammates.

Establish the tunnel

```sh
wg-quick up generated/user1.conf
```

Disconnect with

```sh
wg-quick down generated/user1.conf
```

To check VPN connection working fine you can export .conf into WireGuard client. Then for example I check my RDS instance before VPN enabled and after.

```sh
dig +short my-rds.4oexsiqydp8q.us-east-1.rds.amazonaws.com
ec2-34-226-xx-xx.compute-1.amazonaws.com.
34.226.xx.xx
 
dig +short my-rds.4oexsiqydp8q.us-east-1.rds.amazonaws.com
ec2-34-226-xx-xx.compute-1.amazonaws.com.
10.10.20.80
```

## Adding clients

Adding new client configuration is quite simple. We need to generate new key pair:

```sh
bash -c 'priv=$(wg genkey); pub=$(echo $priv | wg pubkey); printf "$priv\n$pub\n"'
ALqgaUiWd0rtcLza2K143x5RwS0Y5zwh3YwHx/L7nV0=
u1yQmh/G7n+S8aCp0PRuRuAuacmqYNzHLCPOcl9aS28=
```

Then update secrets.yaml file:

```sh
wg_peers:
  # ...
  - name: user2
    addr: 172.16.16.2
    privkey: ALqgaUiWd0rtcLza2K143x5RwS0Y5zwh3YwHx/L7nV0=
    pubkey: u1yQmh/G7n+S8aCp0PRuRuAuacmqYNzHLCPOcl9aS28=
```

And run terraform apply again. Server will be re-created (!) with new configuration. Note that existing clients will be disconnected during deploy.

## Generate Secrets in Playground

```sg
generate-secrets.sh
```

## Download WireGuard Clients

Windows: <https://download.wireguard.com/windows-client/wireguard-installer.exe>

MacOS: <https://itunes.apple.com/us/app/wireguard/id1451685025?ls=1&mt=12>

Linux: `sudo apt install wireguard-tools` client is `wg-quick`

## Test

```sh
wg-quick up generated/admin.conf

ssh -i /home/markus/projects/opensource/playground/playground-one/pgo-cs-key-pair-d7jj6sjb.pem -o StrictHostKeyChecking=no ec2-user@10.0.0.130

[ec2-user@ip-10-0-0-130 ~]$ 
logout

wg-quick down generated/admin.conf
```

## Private IP Assignments

Configuration | Instance     | Public Subnet | Private Subnet # | IP
------------- | ------------ | ------------- | ---------------- | --
Network       | wireguard    | 10.0.4.10     |                  |
TestLab-CS    | Bastion      | 10.0.4.11     |                  |
Network       | pgo-dc       |               | 10.0.0.10        |
Network       | pgo-ca       |               | 10.0.0.11        |
TestLab-CS    | DSM          |               | 10.0.0.20        |
TestLab-CS    | Apex One     |               | 10.0.0.22        |
TestLab-CS    | Apex Central |               | 10.0.0.23        |
TestLab-CS    | PostgreSQL   |               | 10.0.0.24        |
TestLab-CS    | Client 0     |               | 10.0.1.10        |
TestLab-CS    | Client 1     |               | 10.0.1.11        |
TestLab-CS    | Client x     |               | 10.0.1.xx        |
