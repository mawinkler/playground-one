# Get Splunk Up and Running Locally

***DRAFT***

## Prerequisites

- Docker Engine with Compose enabled

## Install Compose (if required)

Use the following command to download:

```sh
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
```

Next, set the correct permissions so that the docker compose command is executable:

```sh
chmod +x ~/.docker/cli-plugins/docker-compose
```

To verify that the installation was successful, you can run:

```sh
docker compose version
```

You’ll see output similar to this:

```sh
Output
Docker Compose version v2.3.3
```

Docker Compose is now successfully installed on your system. In the next section, you’ll see how to set up a `docker-compose.yaml` file and get a containerized environment up and running with this tool.

## Start Splunk

First, change to the working directory.

```sh
# Change to working directory
cd ${ONEPATH}/stacks/splunk
```

Feel free to review the files, especially the `docker-compose.yaml` which creates the stack.

Now run

```sh
docker compose up
```

This will prepare a Splunk Free, which can process up to **500MB** per day.

The first startup requires some minutes to complete.

Try to access your Splunk instance at <http://localhost:8000> and use the following credentials:

- Username: `admin`
- Password: `TrendMicro.1`

!!! info "Detached Mode"

    If you want to run the stack continuously restart the stack but append `-d` to activate detached mode.

    `docker compose up -d`

## Have a Splunk User Account

To be able to download Add-Ons for your Splunk you need to own a free Splunk user account. If you don't already have one, create it [here](https://www.splunk.com/en_us/sign-up.html?redirecturl=https://www.splunk.com/).

## Tear Down Splunk

If you at some point want to delete your Splunk instance run the following command:

```sh
docker compose -v
```

This will remove all containers, volumes, and the network.
