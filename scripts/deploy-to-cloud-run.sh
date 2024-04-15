#!/bin/bash
source send-message.sh

deployToCloudRun() {
    local replyTopic=$1
    local repoName=$2
    local projectId=$3
    local tagToDeploy=$4
    local env=$5
    local serviceAccount=$6
    local projectType
    projectType=$(yq eval '.type' "pipeline.yaml")
    local port

    if [[ $projectType == "java21" ]]; then
        port=8080
    elif [[ $projectType == "node20" ]]; then
        port=3000
    else
        echo "Unknown project type: $projectType"
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi

    if ! gcloud run deploy "${repoName}"-"${env}" \
        --service-account="$serviceAccount" \
        --image=us-central1-docker.pkg.dev/"${projectId}"/"${repoName}"/"${repoName}":"${tagToDeploy}" \
        --ingress=all \
        --allow-unauthenticated \
        --min-instances=1 \
        --max-instances=1 \
        --project="$projectId" \
        --region=us-central1 \
        --port="$port"; then
        echo "Failed to deploy to Cloud Run."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi
    echo "Cloud Run deployment succeeded."
}
