#!/bin/bash
source send-message.sh

createArtifactRegistry() {
    replyTopic=$1
    gitRef=$2
    repositoryName=$(yq eval '.repositoryName' "pipeline.yaml")

    if [[ $gitRef != "refs/heads/main" && $gitRef != *"release"* ]]; then
        echo "Not on main or release branch, skipping Artifact Registry creation."
        exit 0
    fi

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
