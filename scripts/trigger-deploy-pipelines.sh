#!/bin/bash
source create-replyTo-topic.sh
source await-reply.sh
source send-message.sh

getGradleProjectName() {
    local name
    name=$(grep -Po "rootProject.name\s*=\s*['\"]\K[^'\"]+" settings.gradle)
    if [[ -z "$name" ]]; then
        echo "Failed to find project name from settings.gradle."
        exit 1
    fi
    echo "$name"
}

getGradleProjectVersion() {
    local version
    version=$(grep -Po "version\s*=\s*['\"]\K[^'\"]+" build.gradle)
    if [[ -z "$version" ]]; then
        echo "Failed to find project version from build.gradle."
        exit 1
    fi
    echo "$version"
}

getNodeProjectName() {
    local name
    name=$(jq -r '.name' package.json)
    if [[ -z "$name" ]]; then
        echo "Failed to find project name from package.json."
        exit 1
    fi
    echo "$name"
}

getNodeVersionName() {
    local version
    version=$(jq -r '.version' package.json)
    if [[ -z "$version" ]]; then
        echo "Failed to find project version from package.json."
        exit 1
    fi
    echo "$version"
}

triggerDeployPipelines() {
    gitRef="$1"
    projectId="$2"
    shortBuildId="$3"
    timeout="$4"
    replyTopic="$5"
    serviceAccount="cloud-run@cloud-build-pipeline-396819.iam.gserviceaccount.com"

    envsToDeployTo=$(yq eval '.envsToDeployTo | join(" ")' "pipeline.yaml")
    projectType=$(yq eval '.type' "pipeline.yaml")

    if [[ $gitRef != "refs/heads/main" && $gitRef != *"release"* ]]; then
        echo "Not on main or release branch, skipping deployment."
        exit 0
    fi
    if [[ $projectType != "java21" && $projectType != "node20" ]]; then
        echo "Not a valid project type, not deploying."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi

    serviceName=""
    tagToDeploy=""

    if [[ $projectType == "java21" ]]; then
        if [[ $gitRef == "refs/heads/main" ]]; then
            serviceName=$(getGradleProjectName)
            tagToDeploy="$(getGradleProjectVersion)-$shortBuildId"
        elif [[ $gitRef == *"release"* ]]; then
            serviceName=$(getGradleProjectName)
            tagToDeploy="$(getGradleProjectVersion)"
        fi
    elif [[ $projectType == "node20" ]]; then
        if [[ $gitRef == "refs/heads/main" ]]; then
            serviceName=$(getNodeProjectName)
            tagToDeploy="$(getNodeVersionName)-SNAPSHOT-$shortBuildId"
        elif [[ $gitRef == *"release"* ]]; then
            serviceName=$(getNodeProjectName)
            tagToDeploy="$(getNodeVersionName)"
        fi
    fi
    serviceName=$(getGradleProjectName)
    tagToDeploy="$(getGradleProjectVersion)-$shortBuildId"

    for env in $envsToDeployTo; do
        local replyToHash
        replyToHash=$(echo $RANDOM | md5sum | head -c 8)
        envReplyTopic=$(createReplyToTopic "$projectId" "topic_$replyToHash")
        local message="{ \"cloudrun\": { \"name\": \"$serviceName\", \"tag\": \"$tagToDeploy\", \"env\": \"$env\", \"service_account\": \"$serviceAccount\", \"projectType\": \"$projectType\" }, \"reply_topic\": \"$envReplyTopic\" }"
        sendMessage "projects/$projectId/topics/deploy-to-env-pipeline" "$message"
        echo "Pipeline triggered."
        if ! awaitReply "$envReplyTopic" "subscription_$replyToHash" "$timeout"; then
            echo "Deployment to $env failed."
            sendMessage "$replyTopic" "Pipeline failed."
            exit 1
        fi
        echo "Deployment to $env completed."
    done

    echo "All deployments completed."
}
