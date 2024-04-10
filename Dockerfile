FROM gcr.io/cloud-builders/gcloud

# Set environment variables
ENV YQ_VERSION=4.43.1

# Install yq
RUN curl -sL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 -o /usr/bin/yq && chmod +x /usr/bin/yq

# Install git
RUN apt-get update && apt-get install -y git

COPY ./scripts /scripts
RUN chmod +x /scripts -R

ENV PATH="/scripts:${PATH}"
USER 0:0

# Set the entrypoint to /bin/bash
ENTRYPOINT ["/bin/bash"]
