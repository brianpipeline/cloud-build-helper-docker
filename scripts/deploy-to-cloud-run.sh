#!/bin/bash
source send-message.sh

deployToCloudRun() {
    local replyTopic=$1
    local serviceName=$2
    local projectId=$3
    local tagToDeploy=$4
    local env=$5
    local serviceAccount=$6
    local projectType
    projectType=$(yq eval '.type' "pipeline.yaml")
    local port
    local envVar=""

    if [[ $projectType == "java21" ]]; then
        port=8080
        envVar="SPRING_PROFILES_ACTIVE=${env}"
    elif [[ $projectType == "node20" ]]; then
        port=3000
        envVar="NODE_ENV=${env}"
    else
        echo "Unknown project type: $projectType"
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi

    if ! gcloud run deploy "${serviceName}"-"${env}" \
        --service-account="$serviceAccount" \
        --image=us-central1-docker.pkg.dev/"${projectId}"/"${serviceName}"/"${serviceName}":"${tagToDeploy}" \
        --ingress=all \
        --allow-unauthenticated \
        --min-instances=1 \
        --max-instances=1 \
        --project="$projectId" \
        --region=us-central1 \
        --set-env-vars="$envVar" \
        --port="$port"; then
        echo "Failed to deploy to Cloud Run."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi
    echo "Cloud Run deployment succeeded."
}
