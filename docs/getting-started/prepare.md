# Getting Started

There are multiple ways to prepare Playground One:

- The Playground One Container, or
- the native use on your system.

The Playground One Container runs on `arm64`  or `amd64` machines providing a container engine like Docker, Docker Desktop or Colima to run the container. It is the most simple way to use. The container contains everything what is needed by the Playground One to operate and does not change your local system in any way.

Running Playground One natively allows you to have all components available system wide. This makes it possible to not only manage an environment implemented by Playground One.

## Playground One Container (Easy and portable)

Follow this chapter if...

- you intent to use Playground One Container on any `arm64`  or `amd64` based container engine. This includes AWS Cloud9 environments with Amazon Linux or Ubuntu.

> ***Note***: For the curious ones, here's the [Dockerfile](https://github.com/mawinkler/playground-one/blob/main/container/Dockerfile).

First, start a terminal and ensure to have a running container engine, eventually run `docker ps` to verify this.

> ***Note:*** If you want to specify a Playground One Container version instead of using `latest` create a file with the version (tag) to use by running:
>
> `echo "<VERSION>" >.PGO_VERSION`
> 
> Example:
>
> `echo "0.2" >.PGO_VERSION`
>
> See [Change Log](#change-log).

Then simply run

```sh
curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/get_pgoc.sh | bash
```

The above will pull the latest version (or the version you specified in the `.PGO_VERSION`-file) of the container. If you're already authenticated to AWS, Azure, and/or have an already existing `config.yaml` from a previous Playground One installation in the current directory, they will automatically be made available to the Playground One container.

> ***Note:*** When running the above `curl`-command on an ***AWS Cloud9*** instance, the instance should be at least a `t3.medium` and you will be asked to run `./get_pgoc.sh` manually. The script will ask for your AWS credentials which will never be stored on disk and get removed from memory after creating and assigning an instance role to the Cloud9 instance.
> 
> If you didn't do before, you will be asked to turn off AWS managed temporary credentials:<br> 
> 
> - Click the gear icon (in top right corner), or click to open a new tab and choose `[Open Preferences]`<br>
> - Select AWS SETTINGS<br>
> - Turn OFF `[AWS managed temporary credentials]`

You will notice, that a new directory called `workdir` has been created. This directory represents the `home`-directory from your Playground One Container.

To access the container run

```sh
./pgoc start
# password: pgo
```

```sh
Starting Playground One Container
cd741d37446ee0565f6da3f224eb60e4d3bab9824d3255ae08afef8b4263b2c9

Connect:  ssh -p 2222 pgo@localhost
Password: pgo
pgo@localhost's password: 
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 6.1.72-96.166.amzn2023.x86_64 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
 ____  _                                             _    ___             
|  _ \| | __ _ _   _  __ _ _ __ ___  _   _ _ __   __| |  / _ \ _ __   ___ 
| |_) | |/ _` | | | |/ _` | '__/ _ \| | | | '_ \ / _` | | | | | '_ \ / _ \
|  __/| | (_| | |_| | (_| | | | (_) | |_| | | | | (_| | | |_| | | | |  __/
|_|   |_|\__,_|\__, |\__, |_|  \___/ \__,_|_| |_|\__,_|  \___/|_| |_|\___|
               |___/ |___/                                                
pgo@cd741d37446e:~$ 
```

If you exited the container, reconnect anytime with

```sh
ssh -p 2222 pgo@localhost
# password: pgo
```

Eventually authenticate to AWS and/or Azure by either running

```sh
# Not required when using Cloud9
aws configure
```

and/or

```ssh
az login --use-device-code
```

Stopping the container is possible with `./pgoc stop`, to start it again just run `./pgoc start`.

> ***Note***: Updating the container or changing to a different release of the container can be done following these steps:
>
> 1. Edit the file `.PGO_VERSION` to set the version you want (e.g. `0.2`).
> 2. Run `./pgoc update`
>    1. This will backup your current `workdir` and save your `config.yaml`.
>    2. The desired version of the container is pulled and a new `workdir` is created.
>    3. The previous `config.yaml` is restored alongside the eventually existing `.aws` config.
> 3. Start the new container with `./pgoc start` and login via ssh.
> 
> You likely get an error when connecting with ssh. If so, delete the offending line in `~/.ssh/known_hosts` and retry.

Then, continue with [Configuration](configuration.md).

## Advanced but native

### Ubuntu

Follow this chapter if...

- you're using the Playground on a Ubuntu machine (not Cloud9).

Test if `sudo` requires a password by running `sudo ls /etc`. If you don't get a password prompt you're fine, otherwise run.

```sh
sudo visudo -f /etc/sudoers.d/custom-users
```

Add the following line:

```sh
<YOUR USER NAME> ALL=(ALL) NOPASSWD:ALL 
```

Now, run the Playground

```sh
curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgo | bash && exit
```

The bootstrapping process will exit your current terminal or shell after it has done it's work. Depending on your environment just create a new terminal session.

You now need to manually authenticate to AWS and/or Azure by either running

```ssh
aws configure
```

and/or

```ssh
az login --use-device-code
```

Then, continue with [Configuration](configuration.md).

### ***EXPERIMENTAL*** - MacOS Apple silicon and Intel

Follow this chapter if...

- you're using the Playground on a MacOS machine with an M1+ (ARM) or Intel chip.

> ***Note:*** The initial bootstrapping process might require administrative privileges. Depending on your OS configuration you might need to enable administrator mode. Updating an already installed Playground does *not* require admin privileges.

Now, run the Playground

```sh
curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgo | bash && exit
```

The bootstrapping process will exit your current terminal or shell after it has done it's work. Depending on your environment just create a new terminal session.

You now need to manually authenticate to AWS and/or Azure by either running

```ssh
aws configure
```

and/or

```ssh
az login --use-device-code
```

Then, continue with [Configuration](configuration.md).

### Cloud9

> ***Note:*** Native installation on Cloud9 is no longer supported. Use [Playground One Container (Easy and portable)](#playground-one-container-easy-and-portable) instead.

## Change Log

### 0.2.1 Fix release (02/27/2024)

#### Fixes

- The implementation of a proper Vision One Container Security life-cycle broke the deployment since the DELETE api_call was fired too early.

#### Changes

- Simple S3 Bucket scanner now part of Playground One. This includes a dedicated [scenario](https://mawinkler.github.io/playground-one-pages/scenarios/as/tmfs-s3-bucket-scanning/).
- Improved handling of public IPs in configflow when running on Cloud9.
- Eventually existing Azure credentials are now made available within the container.

### 0.2 Maintenance release (02/20/2024)

#### Fixes

- Vision One Container Security gets unregistered from Vision One on cluster destroy.
- Cluster deployments are now correctly destroyed in the correct order.
- Allow docker client to work with docker.sock on Cloud9

#### Changes

- Playground One Container now supports versioning.
- ECS Fargate task definition patcher bumped to version 2.3.30
- New scenario added: [Container Image Vulnerability and Malware Scanning as GitHub Action](https://mawinkler.github.io/playground-one-pages/scenarios/as/tmas-github-action/).
- Removed openssl3 demo app.

### 0.1 Initial release (02/06/2024)
