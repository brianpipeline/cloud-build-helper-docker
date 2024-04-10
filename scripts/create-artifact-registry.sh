#!/bin/bash
createArtifactRegistry() {
    repositoryName=$(yq eval '.repositoryName' "pipeline.yaml")

    if ! gcloud artifacts repositories describe repositoryName --location=us-central1; then
        echo "Creating Artifact Registry $repositoryName"
        if ! gcloud artifacts repositories create "$repositoryName" --repository-format=docker --location=us-central1; then
            echo "Failed to create Artifact Registry $repositoryName"
            exit 1
        fi
    fi
}
