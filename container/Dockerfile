FROM ubuntu:22.04 AS base

# root context
ARG VERSION=version
ARG user=pgo
ARG group=pgo
ARG uid
ARG gid

LABEL Description="This is the Multi Cloud Shell"

# ##############################################################
# Configure run User
# ##############################################################
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
RUN addgroup -gid ${gid} ${group} || true
# Add group id of Cloud9 Amazon Linux docker groups
RUN addgroup -gid 990 c9damzn || true
RUN addgroup -gid 999 c9dubuntu || true
# Add user pgo and add user to group id of Cloud9 Amazon Linux docker groups
RUN useradd -m -s /usr/bin/bash -d /home/${user} -u ${uid} -g ${gid} ${user} && \
    usermod -a -G 990 ${user} && \
    usermod -a -G 999 ${user}

RUN \
    # set password
    echo 'pgo:pgo' | chpasswd

# ##############################################################
# Bootstrap Playground One Container
# ##############################################################
RUN \
    apt update && \
    \
    # Install packages
    apt install -y \
        curl \
        figlet \
        git \
        nano \
        openssh-server \
        sudo \
        vim && \
    \
    chown root:root /usr/bin/sudo && \
    chmod u+s /usr/bin/sudo && \
    \
    # No sudo prompts for us
    echo "${user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/custom-users && \
    \
    # Configure ssh server
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    ssh-keygen -A && \
    mkdir -p /run/sshd && \
    figlet "Playground One" > /etc/motd

# ##############################################################
# Bootstrap Playground One
# ##############################################################
FROM base AS tools

# User context
ARG user=${user}
USER ${user}
WORKDIR /home/${user}

RUN \
    export TERM=xterm-256color && \
    \
    curl -fsSL https://raw.githubusercontent.com/mawinkler/playground-one/main/bin/pgo | bash

# ##############################################################
# Final Stage
# ##############################################################
FROM tools

# User context
USER ${user}
WORKDIR /home/${user}

RUN \
    # Archive home directory
    tar cpzf /tmp/home.tgz /home/${user} && \
    \
    # Banner
    echo "cat /etc/motd" >> .bashrc

# Root context
USER root

EXPOSE 22

# Start ssh daemon
ENTRYPOINT [ "/bin/bash", "-c", "--", "service ssh restart && while true; do sleep 30; done;" ]
