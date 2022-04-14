ARG BASE_REGISTRY=docker.io
ARG BASE_IMAGE=ubuntu
ARG BASE_TAG=focal-20220404

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV DEBIAN_FRONTEND noninteractive

# Copy scripts
COPY . /usr/local

RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    # Remove older versions of Docker
    apt-get install --yes --no-install-recommends \
    ca-certificates \
    fonts-liberation \
    locales \
    sudo \
    gnupg \
    lsb-release \
    # git-over-ssh
    openssh-client \
    curl \
    wget \
    build-essential \
    software-properties-common \
    # Common useful utilities
    git \
    nano-tiny \
    tzdata \
    unzip \
    vim-tiny \
    make \
    jq && \
    # Setup docker repository and install
    apt-get -m remove docker docker.io containerd runc && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update --yes && \
    apt-get install --yes --no-install-recommends docker-ce docker-ce-cli containerd.io && \
    # Install Compose V2
    /usr/local/install-compose-v2.sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    # Install Compose Switch (https://docs.docker.com/compose/cli-command/#compose-switch)
    curl -fL https://github.com/docker/compose-switch/releases/download/v1.0.4/docker-compose-linux-amd64 -o /usr/local/bin/compose-switch && \
    chmod +x /usr/local/bin/compose-switch && \
    update-alternatives --install /usr/local/bin/docker-compose docker-compose /usr/local/bin/compose-switch 99 && \
    # Install VS Code Server
    chmod a+rx /usr/local/download-vs-code-server.sh && \
    /usr/local/download-vs-code-server.sh && \
    update-alternatives --install /usr/bin/nano nano /bin/nano-tiny 10 && \
    rm -rf "/usr/local/download-vs-code-server.sh" "/usr/local/install-compose-v2.sh" && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
