FROM gcr.io/cloud-builders/gcloud

# Set environment variables
ENV YQ_VERSION=4.43.1
ENV DOCKER_VERSION=5:24.0.9-1~ubuntu.20.04~focal

# Install yq
RUN curl -sL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq && chmod +x /usr/bin/yq

# Install git
RUN apt-get update && apt-get install -y git

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
        https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" >/etc/apt/sources.list.d/docker.list &&
    apt-get -y update &&
    apt-get -y dist-upgrade &&
    apt-get autoremove &&
    apt-get clean
RUN apt-get -y install \
    docker-ce=${DOCKER_VERSION} \
    docker-ce-cli=${DOCKER_VERSION} \
    docker-compose docker-compose-plugin &&
    apt-get clean

COPY ./scripts /scripts
RUN chmod +x /scripts -R

ENV PATH="/scripts:${PATH}"
USER 0:0

# Set the entrypoint to /bin/bash
ENTRYPOINT ["/bin/bash"]
