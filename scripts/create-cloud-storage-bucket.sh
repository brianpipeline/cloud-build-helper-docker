#!/bin/bash
source send-message.sh

createCloudStorageBucket() {
    local repoName=$1
    local replyTopic=$2
    local bucketName="gs://${repoName}_tf_state/"

    if ! gsutil ls -b "$bucketName" &>/dev/null; then
        echo "Bucket $bucketName does not exist - creating bucket."
        if gsutil mb -b on "$bucketName"; then
            echo "Bucket '$bucketName' created successfully."
        else
            echo "Failed to create bucket '$bucketName'."
            sendMessage "$replyTopic" "Pipeline failed."
            exit 1
        fi
    else
        echo "Bucket $bucketName already exists."
    fi
}
