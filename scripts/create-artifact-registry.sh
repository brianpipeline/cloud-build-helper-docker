#!/bin/bash
source send-message.sh

# Only do on main.
createArtifactRegistry() {
    replyTopic=$1
    repositoryName=$(yq eval '.repositoryName' "pipeline.yaml")

    if ! gcloud artifacts repositories describe "$repositoryName" --location=us-central1; then
        echo "Creating Artifact Registry $repositoryName"
        if ! gcloud artifacts repositories create "$repositoryName" --repository-format=docker --location=us-central1; then
            echo "Failed to create Artifact Registry $repositoryName"
            sendMessage "$replyTopic" "Pipeline failed."
            exit 1
        fi
    else
        echo "Artifact Registry $repositoryName already exists."
    fi
}
