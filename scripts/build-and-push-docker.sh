#!/bin/bash
source send-message.sh

# Only do on main.
buildAndPushDocker() {
    replyTopic=$1
    projectId=$2
    repositoryName=$(yq eval '.repositoryName' "pipeline.yaml")
    artifactName=$(yq eval '.artifactName' "pipeline.yaml")

    if ! docker build -f Dockerfile -t us-central1-docker.pkg.dev/"${projectId}"/"$repositoryName"/"$artifactName":0.1 .; then
        echo "Failed to build Docker image."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi

    if ! docker push us-central1-docker.pkg.dev/"${projectId}"/"$repositoryName"/"$artifactName":0.1; then
        echo "Failed to push Docker image."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi

    echo "Docker image built and pushed successfully."
}
