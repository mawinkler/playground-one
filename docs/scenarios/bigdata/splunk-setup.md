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

## The `docker-compose.yaml`-File

Create a file named [`~/docker-compose.yaml`](files/splunk/docker-compose.yaml) with the following content:

```sh
vi ~/docker-compose.yaml
```

```yaml
version: "3.7"
services:

  splunk:
    container_name: splunk
    hostname: splunk
    image: ${SPLUNK_IMAGE:-splunk/splunk:latest}
    environment:
      - SPLUNK_START_ARGS=--accept-license --answer-yes --no-prompt --gen-and-print-passwd --seed-passwd TrendMicro.1
      - SPLUNK_USER=admin
      - SPLUNK_PASSWORD=TrendMicro.1
      - SPLUNK_ENABLE_LISTEN=9997
      - SPLUNK_ADD=tcp 1514
      - TZ=Europe/Berlin
      - PHP_TZ=Europe/Berlin
    volumes:
      - opt-splunk-etc:/opt/splunk/etc
      - opt-splunk-var:/opt/splunk/var
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    ports:
      - "8000:8000"
      - "9997:9997"
      - "8088:8088"
      - "1514:1514"
      - "10701:10701/udp"
      - "10702:10702/udp"
      - "10703:10703/udp"
      - "10704:10704/udp"
      - "10705:10705/udp"
      - "10706:10706/udp"
      - "10707:10707/udp"
    restart: always

# ##########################################################################
# Volumes
# ##########################################################################

volumes:
  opt-splunk-etc:
  opt-splunk-var:
```

This will prepare a Splunk Free, which can process up to 500MB per day.

## Start Splunk

In your shell run

```sh
docker compose up splunk
```

The first startup requires some minutes to complete.

Try to access your Splunk instance at <http://localhost:8000> and use the following credentials:

- Username: `admin`
- Password: `TrendMicro.1`

## Have a Splunk User Account

To be able to download Add-Ons for your Splunk you need to own a free Splunk user account. If you don't already have one, create it [here](https://www.splunk.com/en_us/sign-up.html?redirecturl=https://www.splunk.com/).

