# Getting Started

There are multiple ways to prepare Playground One:

- The Playground One Container, or
- the native use on your system.

The Playground One Container runs on `arm64`  or `amd64` machines providing a container engine like Docker, Docker Desktop or Colima to run the container. It is the most simple way to use. The container contains everything what is needed by the Playground One to operate and does not change your local system in any way.

Running Playground One natively allows you to have all components available system wide. This makes it possible to not only manage an environment implemented by Playground One.

## Playground One Container (Easy and portable)

Follow this chapter if...

- you intent to use Playground One Container on any `arm64`  or `amd64` based container engine. This includes AWS Cloud9 environments with Amazon Linux or Ubuntu.

First, start a terminal and ensure to have a running container engine, eventually run `docker ps` to verify this.

Then simply run

```sh
curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/get_pgoc.sh | bash
```

The above will pull the latest version of the container. If you're already authenticated to AWS and/or have an already existing `config.yaml` from a previous Playground One installation in the current directory, they will automatically be made available to the Playground One container.

> ***Note:*** When running the above `curl`-command on an ***AWS Cloud9*** instance you will be asked to run `./get_pgoc.sh` manually. It will asked for your AWS credentials which will never be stored on disk and get removed from memory after creating and assigning an instance role to the Cloud9 instance.
> If you didn't do before, you will be asked to turn off AWS managed temporary credentials: 
> - Click the gear icon (in top right corner), or click to open a new tab and choose `[Open Preferences]`
> - Select AWS SETTINGS
> - Turn OFF `[AWS managed temporary credentials]`

You will notice, that a new directory called `workdir` has been created. This directory represents the `home`-directory from your Playground One Container. To access it run

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

If you exited the container, reconnect with

```sh
ssh -p 2222 pgo@localhost
# password: pgo
```

Eventually authenticate to AWS and/or Azure by either running

```ssh
aws configure
```

and/or

```ssh
az login --use-device-code
```

Stopping the container is possible with `./pgoc stop`, to restart it just rerun `./pgoc start`.

> ***Note***: For the curious ones, here's the [Dockerfile](https://github.com/mawinkler/playground-one/blob/main/container/Dockerfile).

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

Follow this chapter if...

- you're using the Playground on a AWS Cloud9 environment.

Follow the steps below to create a Cloud9 suitable for the Playground.

- Point your browser to AWS
- Choose your default AWS region in the top right
- Go to the Cloud9 service
- Select `[Create Cloud9 environment]`
- Name it as you like
- Choose `[t3.medium]` for instance type and
- `Ubuntu 22.04 LTS` as the platform
- For the rest take all default values and click `[Create environment]`

Update IAM Settings for the Workspace

- Click the gear icon (in top right corner), or click to open a new tab and choose `[Open Preferences]`
- Select AWS SETTINGS
- Turn OFF `[AWS managed temporary credentials]`
- Close the Preferences tab

Now, run the Playground

```sh
curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgo | bash && exit
```

If you run the above command on a newly created or rebooted Cloud9 instance and are receiving the following error, just wait a minute or two and rerun the curl command. The reason for this error is, that directly after starting the machine some update processes are running in the background causing the lock to the package manager process.

```sh
E: Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)
E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
```

You will be asked for your AWS credentials. They will never be stored on disk and get removed from memory after creating and assigning an instance role to the Cloud9 instance.

If you forgot to disable AWS managed temporary credentials you will asked to do it again.

The bootstrapping process will exit your current terminal or shell after it has done it's work. Depending on your environment just create a new terminal session and continue with [Configuration](configuration.md).

If you want to work on Azure you now need to authenticate the `az` cli with

```ssh
az login --use-device-code
```

Then, continue with [Configuration](configuration.md).
