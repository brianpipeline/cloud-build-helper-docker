#!/bin/bash
source send-message.sh

# Only do on main.
buildAndPushDocker() {
    replyTopic=$1
    projectId=$2
    gitRef=$3
    repositoryName=$(yq eval '.repositoryName' "pipeline.yaml")
    artifactName=$(yq eval '.artifactName' "pipeline.yaml")
    tag=$(yq eval '.tag' "pipeline.yaml")

    doNotPush=false
    if [[ $gitRef == "refs/heads/main" ]]; then
        if [[ $tag == "null" ]]; then
            tag="latest"
        fi
    elif [[ $gitRef == *"release"* ]]; then
        tag=$(echo "$gitRef" | cut -d'/' -f4)
    else
        doNotPush=true
        tag="wontpush"
    fi

    if ! docker build -f Dockerfile -t us-central1-docker.pkg.dev/"${projectId}"/"$repositoryName"/"$artifactName":"$tag" .; then
        echo "Failed to build Docker image."
        sendMessage "$replyTopic" "Pipeline failed."
        exit 1
    fi

    if [[ $doNotPush == true ]]; then
        echo "Docker image us-central1-docker.pkg.dev/${projectId}/$repositoryName/$artifactName:$tag built successfully - did not push because we are not on main or release."
    else
        if ! docker push us-central1-docker.pkg.dev/"${projectId}"/"$repositoryName"/"$artifactName":"$tag"; then
            echo "Failed to push Docker image."
            sendMessage "$replyTopic" "Pipeline failed."
            exit 1
        fi

        echo "Docker image us-central1-docker.pkg.dev/${projectId}/$repositoryName/$artifactName:$tag built and pushed successfully."
    fi
}
