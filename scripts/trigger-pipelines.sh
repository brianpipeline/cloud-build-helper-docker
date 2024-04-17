#!/bin/bash
source send-message.sh

triggerPipelines() {
    cloneUrl="$1"
    repositoryName="$2"
    gitRef="$3"
    headSha="$4"
    buildId="$5"
    projectId="$6"

    repoType=$(yq eval '.type' "pipeline.yaml")

    message="{\"git\": { \"clone_url\": \"$cloneUrl\", \"name\": \"$repositoryName\", \"ref\":\"$gitRef\", \"head_sha\": \"$headSha\" }, \"reply_topic\": \"projects/$projectId/topics/topic_$buildId\"}"

    case $repoType in
    "cloudbuild-deploy")
        sendMessage "projects/$projectId/topics/cloudbuild-deploy" "$message"
        ;;
    "dockerfile-deploy")
        sendMessage "projects/$projectId/topics/dockerfile-deploy" "$message"
        ;;
    "terraform-deploy")
        sendMessage "projects/$projectId/topics/terraform-deploy" "$message"
        ;;
    "java21")
        sendMessage "projects/$projectId/topics/gradle-java21-deploy" "$message"
        ;;
    "node20")
        sendMessage "projects/$projectId/topics/node20-deploy" "$message"
        ;;
    *)
        echo "Unknown repo type: $repoType"
        exit 1
        ;;
    esac

    echo "Pipeline triggered."
}
